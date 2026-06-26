use std::fs;
use std::io::{self, BufRead, BufReader, Write};
use std::os::unix::fs::PermissionsExt;
use std::path::Path;

fn trim(s: &str) -> &str {
    s.trim_matches(|c: char| c.is_ascii_whitespace())
}

fn or_none(s: &str) -> &str {
    if s.is_empty() {
        "(none)"
    } else {
        s
    }
}

fn startswith_comma(s: &str, prefix: &str) -> bool {
    s == prefix || (s.starts_with(prefix) && s[prefix.len()..].starts_with(','))
}

fn xkb_option(line: &str, name: &str) -> Option<String> {
    // Option <keyword> "<name>" <gap> "<value>"
    let mut parts = line.split('"');
    let keyword = parts.next()?;
    let key = parts.next()?;
    let gap = parts.next()?;
    let value = parts.next()?;

    if !trim(keyword).eq_ignore_ascii_case("Option")
        || !key.eq_ignore_ascii_case(name)
        || !trim(gap).is_empty()
    {
        return None;
    }

    let value = trim(value);
    if value.is_empty() {
        None
    } else {
        Some(value.to_string())
    }
}

fn parse_conf(path: &str) -> Option<(String, String, String, String)> {
    let f = fs::File::open(path).ok()?;
    let mut layout = String::new();
    let mut model = String::new();
    let mut variant = String::new();
    let mut options = String::new();

    for line in BufReader::new(f).lines().map_while(Result::ok) {
        for (name, slot) in [
            ("XkbLayout", &mut layout),
            ("XkbModel", &mut model),
            ("XkbVariant", &mut variant),
            ("XkbOptions", &mut options),
        ] {
            if slot.is_empty() {
                if let Some(v) = xkb_option(&line, name) {
                    *slot = v;
                }
            }
        }
    }

    if layout.is_empty() {
        None
    } else {
        Some((layout, model, variant, options))
    }
}

fn find_converted_keymap(layout: &str, variant: Option<&str>, dirs: &[&str]) -> Option<String> {
    let name = match variant {
        Some(v) if !v.is_empty() => format!("{layout}-{v}"),
        _ => layout.to_string(),
    };

    for dir in dirs {
        for ext in [".map", ".map.gz"] {
            if Path::new(&format!("{dir}xkb/{name}{ext}")).exists() {
                return Some(name);
            }
        }
    }
    None
}

fn layout_score(layout: &str, candidate: &str) -> u32 {
    if layout == candidate {
        return 10;
    }
    let reversed = candidate.rsplit(',').collect::<Vec<_>>().join(",");
    if layout == reversed {
        return 9;
    }
    if startswith_comma(layout, candidate) {
        return 5;
    }
    if startswith_comma(layout, candidate.split(',').next().unwrap_or("")) {
        return 1;
    }
    0
}

fn variant_matches(variant: &str, candidate: &str) -> bool {
    variant == candidate
        || ((variant.is_empty() || variant.chars().all(|c| c == ',')) && candidate == "-")
}

// port systemd-localed algo
fn find_legacy_keymap(
    layout: &str,
    model: &str,
    variant: &str,
    options: &str,
    kbd_map: &str,
    dirs: &[&str],
) -> Option<String> {
    let f = fs::File::open(kbd_map).ok()?;
    let mut best = 0u32;
    let mut result = None;

    for line in BufReader::new(f).lines().map_while(Result::ok) {
        let t = trim(&line);
        if t.is_empty() || t.starts_with('#') {
            continue;
        }
        let fields: Vec<&str> = t.split_whitespace().collect();
        let [console, f_layout, f_model, f_variant, f_options, ..] = fields.as_slice() else {
            continue;
        };

        let mut m = layout_score(layout, f_layout);
        if m > 0 && (model.is_empty() || model == *f_model) {
            m += 1;
            if variant_matches(variant, f_variant) {
                m += 1;
                if options == *f_options {
                    m += 1;
                }
            }
        }

        if m > best {
            best = m;
            result = Some(console.to_string());
        }
    }

    if best < 9 && !layout.is_empty() {
        let l = layout.split(',').next().unwrap_or("");
        let v = if variant.is_empty() {
            None
        } else {
            variant.split(',').next()
        };
        if let Some(c) = find_converted_keymap(l, v, dirs) {
            result = Some(c);
        }
    }

    result
}

fn convert_to_vconsole(
    layout: &str,
    model: &str,
    variant: &str,
    options: &str,
    kbd_map: &str,
    dirs: &[&str],
) -> Option<String> {
    if layout.is_empty() {
        return None;
    }
    let v_opt = if variant.is_empty() {
        None
    } else {
        Some(variant)
    };

    if let Some(k) = find_converted_keymap(layout, v_opt, dirs) {
        return Some(k);
    }
    if let Some(k) = find_legacy_keymap(layout, model, variant, options, kbd_map, dirs) {
        return Some(k);
    }
    if v_opt.is_some() {
        return find_converted_keymap(layout, None, dirs);
    }
    None
}

fn write_atomic(path: &str, data: &str) -> io::Result<()> {
    let tmp = format!("{path}.tmp");
    let mode = fs::metadata(path)
        .map(|m| m.permissions().mode() & 0o777)
        .unwrap_or(0o644);

    let mut f = fs::File::create(&tmp)?;
    f.write_all(data.as_bytes())?;
    f.sync_all()?;
    fs::set_permissions(&tmp, fs::Permissions::from_mode(mode))?;

    if let Err(e) = fs::rename(&tmp, path) {
        let _ = fs::remove_file(&tmp);
        return Err(e);
    }
    Ok(())
}

fn write_vconsole(vconsole: &str, keymap: &str) -> io::Result<()> {
    let existing = fs::read(vconsole)
        .map(|b| String::from_utf8_lossy(&b).into_owned())
        .unwrap_or_default();

    let mut out = String::new();
    let mut found = false;
    for line in existing.lines() {
        if trim(line).starts_with("KEYMAP=") {
            out.push_str(&format!("KEYMAP={keymap}\n"));
            found = true;
        } else {
            out.push_str(line);
            out.push('\n');
        }
    }
    if !found {
        out.push_str(&format!("KEYMAP={keymap}\n"));
    }

    write_atomic(vconsole, &out)
}

fn main() {
    let x11_conf = option_env!("X11_CONF").unwrap_or("/etc/X11/xorg.conf.d/00-keyboard.conf");
    let vconsole = option_env!("VCONSOLE").unwrap_or("/etc/vconsole.conf");
    let kbd_map = option_env!("KBD_MAP").unwrap_or("/usr/share/systemd/kbd-model-map");
    let dirs: Vec<&str> = match option_env!("KBD_DIRS") {
        Some(s) => s.split(':').collect(),
        None => vec![
            "/usr/share/keymaps/",
            "/usr/share/kbd/keymaps/",
            "/usr/lib/kbd/keymaps/",
        ],
    };

    let Some((layout, model, variant, options)) = parse_conf(x11_conf) else {
        return;
    };

    let keymap = match convert_to_vconsole(&layout, &model, &variant, &options, kbd_map, &dirs) {
        Some(k) => k,
        None => {
            eprintln!(
                "no console keymap for layout={layout} (model={} variant={})",
                or_none(&model),
                or_none(&variant),
            );
            return;
        }
    };

    eprintln!(
        "{layout} (model={} variant={} options={}) -> KEYMAP={keymap}",
        or_none(&model),
        or_none(&variant),
        or_none(&options),
    );

    if write_vconsole(vconsole, &keymap).is_err() {
        eprintln!("failed to write {vconsole}");
    }
}
