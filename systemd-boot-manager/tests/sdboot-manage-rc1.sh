#!/usr/bin/env bash
#
# RC1 regression tests for sdboot-manage UKI/regular boot-path safety.
#
# The tests run the real sdboot-manage inside a private user+mount namespace.
# Fake /etc, /usr/lib/modules and /usr/share/libalpm/scripts trees are bind
# mounted there, and bootctl/mkinitcpio/depmod are mocked.  Nothing outside
# the temporary fixture directory is read or written, and no real firmware,
# ESP, Secure Boot, initramfs or kernel operation is performed.
#
# Usage: tests/sdboot-manage-rc1.sh [path-to-sdboot-manage]
#
# Exit: 0 all tests passed, 1 failures, 77 environment cannot isolate.

set -euo pipefail

SCRIPT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sdboot-manage}"
if [[ ! -f "${SCRIPT}" ]]; then
    echo "sdboot-manage not found: ${SCRIPT}" >&2
    exit 2
fi

if ! command -v unshare >/dev/null 2>&1 ||
   ! unshare -rm --propagation private true >/dev/null 2>&1; then
    echo "SKIP: user+mount namespaces are unavailable" >&2
    exit 77
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/sdboot-uki.XXXXXX")"
trap 'rm -rf "${WORK}"' EXIT

PASS=0
FAIL=0
RC=0
OUT=""

pass() { PASS=$((PASS + 1)); printf 'ok   %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$1"; }

assert_eq() { # expected actual description
    if [[ "$1" == "$2" ]]; then pass "$3"; else fail "$3 (expected '$1', got '$2')"; fi
}

assert_nonzero() { # actual description
    if [[ "$1" -ne 0 ]]; then pass "$2"; else fail "$2 (expected non-zero exit, got 0)"; fi
}

assert_exists() {
    if [[ -e "$1" ]]; then pass "$2"; else fail "$2 (missing $1)"; fi
}

assert_absent() {
    if [[ ! -e "$1" ]]; then pass "$2"; else fail "$2 (still present: $1)"; fi
}

assert_nonempty() {
    if [[ -s "$1" ]]; then pass "$2"; else fail "$2 (missing or empty: $1)"; fi
}

assert_output_contains() { # needle description
    if grep -qF -- "$1" <<<"${OUT}"; then
        pass "$2"
    else
        fail "$2 (missing: $1)"
    fi
}

assert_boot_path() { # root label
    local d="$1" label="$2"
    if [[ -e "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" ]] ||
        { [[ -s "${d}/esp/vmlinuz-linux-test" ]] &&
            grep -qx 'linux /vmlinuz-linux-test' "${d}/esp/loader/entries/linux-test.conf" 2>/dev/null; }; then
        pass "${label} recovery path exists"
    else
        fail "${label} recovery path exists"
    fi
}

# ---------------------------------------------------------------------------
# Fixture construction
# ---------------------------------------------------------------------------

write_mocks() {
    local root="$1"

    mkdir -p "${root}/bin" "${root}/alpm"

    cat >"${root}/mock-lib.sh" <<'MOCK'
control_match() {
    local control="$1" key="$2" file="${FX_ROOT}/control/${1}"
    [[ -f "${file}" ]] || return 1
    grep -qxF -- "${key}" "${file}" 2>/dev/null || grep -qxF -- '*' "${file}" 2>/dev/null
}

load_preset() {
    local name="$1" preset
    if [[ "${name}" == */* ]]; then
        preset="${name}"
    else
        preset="/etc/mkinitcpio.d/${name}.preset"
    fi
    [[ -f "${preset}" ]] || { echo "mock: preset not found: ${preset}" >&2; return 1; }
    ALL_kver=""
    default_image=""
    default_uki=""
    PRESETS=()
    # shellcheck disable=SC1090
    . "${preset}"
}

mock_generate() {
    local name="$1" kernel_hint
    load_preset "${name}" || return 1

    kernel_hint=""
    if [[ "${ALL_kver:-}" == /usr/lib/modules/*/vmlinuz ]]; then
        kernel_hint="${ALL_kver#/usr/lib/modules/}"
        kernel_hint="${kernel_hint%/vmlinuz}"
        kernel_hint="$(cat "/usr/lib/modules/${kernel_hint}/pkgbase" 2>/dev/null || true)"
    fi
    [[ -n "${kernel_hint}" ]] || kernel_hint="${name}"

    if control_match mkinitcpio_fail "${kernel_hint}"; then
        echo "mock: mkinitcpio failed for ${kernel_hint}" >&2
        return 1
    fi
    if control_match mkinitcpio_noop "${kernel_hint}"; then
        echo "mock: mkinitcpio no-op for ${kernel_hint}" >&2
        return 0
    fi
    if control_match mkinitcpio_touch "${kernel_hint}" ||
        control_match mkinitcpio_same_size "${kernel_hint}"; then
        [[ -n "${default_uki:-}" ]] || return 1
        mkdir -p "$(dirname "${default_uki}")"
        if control_match mkinitcpio_touch "${kernel_hint}"; then
            : >"${default_uki}"
        else
            printf 'MZpreexisting-uki\n' >"${default_uki}"
        fi
        return 0
    fi
    if control_match mkinitcpio_kill_before_write "${kernel_hint}"; then
        kill -KILL "${PPID}"
        exit 1
    fi
    if control_match mkinitcpio_kill_after_partial "${kernel_hint}"; then
        [[ -n "${default_uki:-}" ]] || exit 1
        mkdir -p "$(dirname "${default_uki}")"
        printf 'MZpartial\n' >"${default_uki}"
        kill -KILL "${PPID}"
        exit 1
    fi

    if [[ -n "${default_uki:-}" ]]; then
        mkdir -p "$(dirname "${default_uki}")"
        if control_match empty_uki "${kernel_hint}"; then
            : >"${default_uki}"
        else
            printf 'MZmock-uki\n' >"${default_uki}"
        fi
    elif [[ -n "${default_image:-}" ]]; then
        mkdir -p "$(dirname "${default_image}")"
        printf 'mock-initramfs\n' >"${default_image}"
    else
        echo "mock: no image target for ${name}" >&2
        return 1
    fi
}

mock_remove() {
    local name="$1"
    load_preset "${name}" || return 1
    [[ -n "${default_uki:-}" ]] && rm -f -- "${default_uki}"
    [[ -n "${default_image:-}" ]] && rm -f -- "${default_image}"
    return 0
}

mock_alpm_install() {
    local line ver pkgbase
    while read -r line; do
        [[ -n "${line}" ]] || continue
        ver="${line%/vmlinuz}"
        ver="${ver##*/}"
        pkgbase="$(cat "/usr/lib/modules/${ver}/pkgbase" 2>/dev/null)" || continue
        if control_match alpm_fail "${pkgbase}"; then
            echo "mock: alpm install failed for ${pkgbase}" >&2
            exit 1
        fi
        if control_match alpm_fail_remove_preset "${pkgbase}"; then
            rm -f "/etc/mkinitcpio.d/${pkgbase}.preset"
            echo "mock: removed preset and failed for ${pkgbase}" >&2
            exit 1
        fi
        if control_match alpm_noop "${pkgbase}"; then
            echo "mock: alpm install silently wrote nothing for ${pkgbase}" >&2
            continue
        fi
        load_preset "${pkgbase}" || exit 1
        if [[ "${ALL_kver:-}" == /* ]]; then
            mkdir -p "$(dirname "${ALL_kver}")"
            cp -f "/usr/lib/modules/${ver}/vmlinuz" "${ALL_kver}"
        fi
        if [[ -n "${default_uki:-}" ]]; then
            mkdir -p "$(dirname "${default_uki}")"
            printf 'MZmock-uki\n' >"${default_uki}"
        elif [[ -n "${default_image:-}" ]]; then
            mkdir -p "$(dirname "${default_image}")"
            printf 'mock-initramfs\n' >"${default_image}"
        fi
    done
}
MOCK

    cat >"${root}/bin/bootctl" <<'MOCK'
#!/usr/bin/env bash
case "${1:-}" in
    -p | --print-esp-path) printf '%s\n' "${FX_ROOT}/esp" ;;
    status) exit 0 ;;
    *) exit 0 ;;
esac
MOCK

    cat >"${root}/bin/mkinitcpio" <<'MOCK'
#!/usr/bin/env bash
set -u
# shellcheck source=/dev/null
. "${FX_ROOT}/mock-lib.sh"
name=""
remove=0
while (($#)); do
    case "$1" in
        -p | --preset) name="${2:-}"; shift 2 ;;
        -R | --remove) remove=1; shift ;;
        *) shift ;;
    esac
done
[[ -n "${name}" ]] || { echo "mock: mkinitcpio without -p" >&2; exit 1; }
if ((remove)); then mock_remove "${name}"; else mock_generate "${name}"; fi
MOCK

    cat >"${root}/alpm/mkinitcpio" <<'MOCK'
#!/usr/bin/env bash
set -u
# shellcheck source=/dev/null
. "${FX_ROOT}/mock-lib.sh"
case "${1:-}" in
    install) mock_alpm_install ;;
    *) exit 0 ;;
esac
MOCK

    cat >"${root}/alpm/depmod" <<'MOCK'
#!/usr/bin/env bash
set -u
# shellcheck source=/dev/null
. "${FX_ROOT}/mock-lib.sh"
line="$(cat)"
ver="${line%/}"
ver="${ver##*/}"
pkgbase="$(cat "/usr/lib/modules/${ver}/pkgbase" 2>/dev/null || true)"
if [[ -n "${pkgbase}" ]] && control_match depmod_fail "${pkgbase}"; then
    echo "mock: depmod failed for ${pkgbase}" >&2
    exit 1
fi
exit 0
MOCK

    chmod +x "${root}/bin/bootctl" "${root}/bin/mkinitcpio" \
        "${root}/alpm/mkinitcpio" "${root}/alpm/depmod"
}

new_fixture() { # directory
    local root="$1"
    mkdir -p "${root}/etc/mkinitcpio.d" "${root}/etc/kernel" \
        "${root}/modules" "${root}/alpm" "${root}/esp/loader/entries" \
        "${root}/esp/EFI/Linux" "${root}/control"
    write_mocks "${root}"

    cat >"${root}/etc/sdboot-manage.conf" <<'CONF'
USE_UKI="no"
LINUX_OPTIONS="quiet splash"
REMOVE_EXISTING="no"
OVERWRITE_EXISTING="yes"
REMOVE_OBSOLETE="yes"
CONF

    printf 'root=UUID=fixture rw\n' >"${root}/etc/kernel/cmdline"
    printf 'test-token\n' >"${root}/etc/kernel/entry-token"
    printf 'fixture-machine-id\n' >"${root}/etc/machine-id"
    printf 'timeout 3\n' >"${root}/esp/loader/loader.conf"
}

set_use_uki() { # root yes|no
    sed -i "s/^USE_UKI=.*/USE_UKI=\"$2\"/" "$1/etc/sdboot-manage.conf"
}

add_kernel() { # root pkgbase pkgver
    local root="$1" pkgbase="$2" pkgver="$3"
    mkdir -p "${root}/modules/${pkgver}"
    printf '%s\n' "${pkgbase}" >"${root}/modules/${pkgver}/pkgbase"
    printf 'mock kernel %s\n' "${pkgver}" >"${root}/modules/${pkgver}/vmlinuz"
    cat >"${root}/etc/mkinitcpio.d/${pkgbase}.preset" <<PRESET
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-${pkgbase}"
PRESETS=('default')
default_image="/boot/initramfs-${pkgbase}.img"
PRESET
}

add_traditional_path() { # root pkgbase
    local root="$1" pkgbase="$2"
    printf 'mock kernel\n' >"${root}/esp/vmlinuz-${pkgbase}"
    printf 'mock initramfs\n' >"${root}/esp/initramfs-${pkgbase}.img"
    cat >"${root}/esp/loader/entries/${pkgbase}.conf" <<ENTRY
title ${pkgbase}
linux /vmlinuz-${pkgbase}
initrd /initramfs-${pkgbase}.img
ENTRY
}

add_uki() { # root pkgver [empty]
    local root="$1" pkgver="$2" empty="${3:-no}"
    local uki="${root}/esp/EFI/Linux/test-token-${pkgver}.efi"
    if [[ "${empty}" == "yes" ]]; then
        : >"${uki}"
    else
        printf 'MZpreexisting-uki\n' >"${uki}"
    fi
}

set_control() { # root control-name key
    printf '%s\n' "$3" >"$1/control/$2"
}

run_manage() { # root [args...]
    local root="$1"
    shift
    local out
    set +e
    out="$(unshare -rm --propagation private bash -s -- "${root}" "${SCRIPT}" "$@" <<'INNER' 2>&1
set -e
root=$1
script=$2
shift 2
mount --bind "${root}/modules" /usr/lib/modules
mount --bind "${root}/alpm" /usr/share/libalpm/scripts
mount --bind "${root}/esp" /boot
mount --bind "${root}/etc" /etc
export PATH="${root}/bin:/usr/bin:/bin"
export FX_ROOT="${root}"
if [[ -f "${root}/control/readonly_entries" ]]; then
    mount --bind "${root}/esp/loader/entries" "${root}/esp/loader/entries"
    mount -o remount,ro,bind "${root}/esp/loader/entries"
fi
cd "${root}"
exec bash "${script}" "$@"
INNER
)"
    RC=$?
    set -e
    OUT="${out}"
}

show_context() {
    printf '     script exit: %s\n' "${RC}"
    if [[ -n "${OUT}" ]]; then
        printf '%s\n' "${OUT}" | tail -n 4 | sed 's/^/     | /'
    fi
}

# ---------------------------------------------------------------------------
# RC1 scenarios
# ---------------------------------------------------------------------------

prepare_regular_images() { # root
    printf 'mock kernel\n' >"$1/esp/vmlinuz-linux-test"
    printf 'mock initramfs\n' >"$1/esp/initramfs-linux-test.img"
}

test_regular_to_uki_success() {
    echo "R1 regular -> UKI success"
    local d="${WORK}/r1"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R1 exit code"
    assert_nonempty "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R1 UKI created"
    assert_absent "${d}/esp/vmlinuz-linux-test" "R1 regular kernel removed"
    assert_absent "${d}/esp/initramfs-linux-test.img" "R1 regular initramfs removed"
    assert_absent "${d}/esp/loader/entries/linux-test.conf" "R1 regular entry removed"
    show_context
}

test_regular_to_uki_failure_preexisting() {
    echo "R2 regular -> UKI failure with preexisting UKI"
    local d="${WORK}/r2"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R2 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R2 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R2 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R2 regular entry preserved"
    show_context
}

test_regular_to_uki_failure_empty() {
    echo "R3 regular -> UKI failure with empty preexisting UKI"
    local d="${WORK}/r3"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test yes
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R3 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R3 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R3 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R3 regular entry preserved"
    show_context
}

test_regular_to_uki_failure_no_uki() {
    echo "R4 regular -> UKI failure without UKI"
    local d="${WORK}/r4"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R4 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R4 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R4 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R4 regular entry preserved"
    show_context
}

test_regular_to_uki_autogen_stale() {
    echo "R5 autogen with an unverified preexisting UKI"
    local d="${WORK}/r5"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_fail linux-test
    run_manage "${d}" autogen
    assert_nonzero "${RC}" "R5 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R5 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R5 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R5 regular entry preserved"
    show_context
}

test_regular_to_uki_multi_kernel() {
    echo "R6 regular -> UKI multi-kernel, one failure"
    local d="${WORK}/r6"
    new_fixture "${d}"
    add_kernel "${d}" linux-a 6.0.0-a
    add_kernel "${d}" linux-b 6.0.0-b
    add_traditional_path "${d}" linux-a
    add_traditional_path "${d}" linux-b
    add_uki "${d}" 6.0.0-b
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_fail linux-b
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R6 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-b" "R6 failed kernel regular path preserved"
    assert_exists "${d}/esp/initramfs-linux-b.img" "R6 failed kernel initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-b.conf" "R6 failed kernel entry preserved"
    assert_nonempty "${d}/esp/EFI/Linux/test-token-6.0.0-a.efi" "R6 successful kernel UKI exists"
    show_context
}

test_uki_to_regular_success_keeps_fallback() {
    echo "R7 UKI -> regular success keeps the UKI fallback"
    local d="${WORK}/r7"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R7 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R7 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R7 regular kernel created"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R7 regular initramfs created"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R7 regular entry created"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R7 UKI fallback kept"
    show_context
}

test_uki_to_regular_install_failure() {
    echo "R8 UKI -> regular install failure keeps the UKI"
    local d="${WORK}/r8"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R8 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    set_control "${d}" alpm_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R8 exit code"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R8 UKI preserved"
    assert_boot_path "${d}" "R8"
    show_context
}

test_uki_to_regular_depmod_failure() {
    echo "R9 UKI -> regular depmod failure keeps the UKI"
    local d="${WORK}/r9"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R9 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    set_control "${d}" depmod_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R9 exit code"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R9 UKI preserved"
    if grep -qxF '## ATTENTION! START OF SYSTEMD-BOOT-MANAGER GENERATED OVERRIDE, DO NOT EDIT' "${d}/etc/mkinitcpio.d/linux-test.preset"; then
        pass "R9 preset override intact"
    else
        fail "R9 preset override intact"
    fi
    show_context
}

test_uki_to_regular_remove_existing_failure() {
    echo "R10 UKI -> regular REMOVE_EXISTING failure keeps the UKI"
    local d="${WORK}/r10"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R10 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    sed -i 's/^REMOVE_EXISTING=.*/REMOVE_EXISTING="yes"/' "${d}/etc/sdboot-manage.conf"
    set_control "${d}" alpm_fail linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R10 exit code"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R10 UKI preserved"
    show_context
}

test_uki_to_regular_custom_entry() {
    echo "R11 UKI -> regular custom entry preserved, UKI kept"
    local d="${WORK}/r11"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R11 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    sed -i 's/^OVERWRITE_EXISTING=.*/OVERWRITE_EXISTING="no"/' "${d}/etc/sdboot-manage.conf"
    cat >"${d}/esp/loader/entries/linux-test.conf" <<'ENTRY'
title Custom
linux /vmlinuz-linux-test
initrd /initramfs-linux-test.img
options custom-option
ENTRY
    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R11 exit code"
    if grep -qx 'title Custom' "${d}/esp/loader/entries/linux-test.conf"; then
        pass "R11 custom entry preserved"
    else
        fail "R11 custom entry preserved"
    fi
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R11 UKI fallback kept"
    show_context
}

test_uki_to_regular_multi_kernel_failure() {
    echo "R12 UKI -> regular multi-kernel, one failure"
    local d="${WORK}/r12"
    new_fixture "${d}"
    add_kernel "${d}" linux-a 6.0.0-a
    add_kernel "${d}" linux-b 6.0.0-b
    add_traditional_path "${d}" linux-a
    add_traditional_path "${d}" linux-b
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R12 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    set_control "${d}" alpm_fail linux-b
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R12 exit code"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-a.efi" "R12 first kernel UKI kept"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-b.efi" "R12 failing kernel UKI kept"
    show_context
}

test_regular_baseline() {
    echo "R13 regular baseline"
    local d="${WORK}/r13"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R13 exit code"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R13 regular entry present"
    if grep -qx 'options root=UUID=fixture rw quiet splash' "${d}/esp/loader/entries/linux-test.conf"; then
        pass "R13 cmdline preserved"
    else
        fail "R13 cmdline preserved"
    fi
    show_context
}

test_established_uki_rescue() {
    echo "R14 established UKI keeps a regular rescue path"
    local d="${WORK}/r14"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R14 setup UKI generation"; show_context; return; }
    prepare_regular_images "${d}"
    cat >"${d}/esp/loader/entries/linux-test.conf" <<'ENTRY'
title Rescue
linux /vmlinuz-linux-test
initrd /initramfs-linux-test.img
ENTRY
    run_manage "${d}" autogen
    assert_eq 0 "${RC}" "R14 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R14 rescue kernel preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R14 rescue entry preserved"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R14 UKI preserved"
    show_context
}

test_uki_to_regular_noop_generator() {
    echo "R15 UKI -> regular silent no-op generator keeps the UKI"
    local d="${WORK}/r15"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R15 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    set_control "${d}" alpm_noop linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R15 exit code"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R15 UKI preserved"
    show_context
}

test_uki_to_regular_existing_images() {
    echo "R16 UKI -> regular with preexisting regular images"
    local d="${WORK}/r16"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R16 setup UKI generation"; show_context; return; }
    prepare_regular_images "${d}"
    set_use_uki "${d}" no
    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R16 exit code"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R16 regular entry created"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R16 UKI fallback kept"
    show_context
}

test_regular_to_uki_noop_generator() {
    echo "R17 regular -> UKI no-op generator does not authorize deletion"
    local d="${WORK}/r17"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_noop linux-test
    run_manage "${d}" gen
    assert_nonzero "${RC}" "R17 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R17 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R17 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R17 regular entry preserved"
    show_context
}

test_remove_existing_failure_without_uki() {
    echo "R18 REMOVE_EXISTING failure without UKI keeps the rescue entry"
    local d="${WORK}/r18"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R18 setup UKI generation"; show_context; return; }
    rm -f "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi"
    mkdir -p "${d}/esp/EFI/rescue"
    printf 'rescue kernel\n' >"${d}/esp/EFI/rescue/vmlinuz"
    printf 'rescue initramfs\n' >"${d}/esp/EFI/rescue/initramfs.img"
    cat >"${d}/esp/loader/entries/rescue.conf" <<'ENTRY'
title Rescue
linux /EFI/rescue/vmlinuz
initrd /EFI/rescue/initramfs.img
ENTRY
    set_use_uki "${d}" no
    sed -i 's/^REMOVE_EXISTING=.*/REMOVE_EXISTING="yes"/' "${d}/etc/sdboot-manage.conf"
    set_control "${d}" alpm_fail linux-test

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R18 exit code"
    assert_exists "${d}/esp/loader/entries/rescue.conf" "R18 rescue entry preserved"
    assert_exists "${d}/esp/EFI/rescue/vmlinuz" "R18 rescue kernel preserved"
    assert_exists "${d}/esp/EFI/rescue/initramfs.img" "R18 rescue initramfs preserved"
    show_context
}

test_preset_restore_failure_reported() {
    echo "R19 preset restore failure is reported"
    local d="${WORK}/r19"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    set_use_uki "${d}" yes
    run_manage "${d}" gen
    [[ "${RC}" -eq 0 ]] || { fail "R19 setup UKI generation"; show_context; return; }
    set_use_uki "${d}" no
    set_control "${d}" alpm_fail_remove_preset linux-test

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R19 exit code"
    assert_output_contains "failed to restore UKI preset override" "R19 restore failure reported"
    assert_exists "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R19 UKI fallback kept"
    show_context
}

test_valid_regeneration_same_size() {
    echo "R20 valid regeneration with a preexisting same-size UKI"
    local d="${WORK}/r20"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_same_size linux-test

    run_manage "${d}" gen
    assert_eq 0 "${RC}" "R20 exit code"
    assert_nonempty "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R20 UKI regenerated"
    assert_absent "${d}/esp/vmlinuz-linux-test" "R20 regular kernel removed"
    assert_absent "${d}/esp/loader/entries/linux-test.conf" "R20 regular entry removed"
    if compgen -G "${d}/esp/EFI/Linux/.sdboot-manage-new.*" >/dev/null ||
        compgen -G "${d}/esp/EFI/Linux/.sdboot-manage-preset.*" >/dev/null; then
        fail "R20 no stale staging file left"
    else
        pass "R20 no stale staging file left"
    fi
    show_context
}

test_touch_only_generator_rejected() {
    echo "R21 touch-only generator is rejected"
    local d="${WORK}/r21"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    set_control "${d}" mkinitcpio_touch linux-test

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R21 exit code"
    assert_exists "${d}/esp/vmlinuz-linux-test" "R21 regular kernel preserved"
    assert_exists "${d}/esp/initramfs-linux-test.img" "R21 regular initramfs preserved"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R21 regular entry preserved"
    assert_nonempty "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" "R21 UKI preserved at original path"
    show_context
}

test_kill_before_replacement_write() {
    echo "K1 SIGKILL before writing the replacement keeps the original UKI path"
    local d="${WORK}/k1"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    printf 'default test-token-6.0.0-test.efi\n' >"${d}/esp/loader/loader.conf"
    set_control "${d}" mkinitcpio_kill_before_write linux-test

    run_manage "${d}" gen
    assert_nonzero "${RC}" "K1 process killed"
    if grep -qx 'MZpreexisting-uki' "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" 2>/dev/null; then
        pass "K1 original UKI still at its original path"
    else
        fail "K1 original UKI still at its original path"
    fi
    if compgen -G "${d}/esp/EFI/Linux/*.efi" | grep -qx ".*/test-token-6.0.0-test.efi"; then
        pass "K1 original UKI is auto-discovered"
    else
        fail "K1 original UKI is auto-discovered"
    fi
    if grep -qx 'default test-token-6.0.0-test.efi' "${d}/esp/loader/loader.conf" &&
        [[ -s "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" ]]; then
        pass "K1 default entry target resolves"
    else
        fail "K1 default entry target resolves"
    fi
    if compgen -G "${d}/esp/EFI/Linux/*.efi" | grep -q 'sdboot-manage-new'; then
        fail "K1 staging is not auto-discovered"
    else
        pass "K1 staging is not auto-discovered"
    fi
    show_context
}

test_kill_after_partial_replacement() {
    echo "K2 SIGKILL after a partial replacement keeps the original UKI path"
    local d="${WORK}/k2"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    add_uki "${d}" 6.0.0-test
    set_use_uki "${d}" yes
    printf 'default test-token-6.0.0-test.efi\n' >"${d}/esp/loader/loader.conf"
    set_control "${d}" mkinitcpio_kill_after_partial linux-test

    run_manage "${d}" gen
    assert_nonzero "${RC}" "K2 process killed"
    if grep -qx 'MZpreexisting-uki' "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" 2>/dev/null; then
        pass "K2 original UKI survives the partial write"
    else
        fail "K2 original UKI survives the partial write"
    fi
    if compgen -G "${d}/esp/EFI/Linux/*.efi" | grep -qx ".*/test-token-6.0.0-test.efi"; then
        pass "K2 original UKI is auto-discovered"
    else
        fail "K2 original UKI is auto-discovered"
    fi
    if grep -qx 'default test-token-6.0.0-test.efi' "${d}/esp/loader/loader.conf" &&
        [[ -s "${d}/esp/EFI/Linux/test-token-6.0.0-test.efi" ]]; then
        pass "K2 default entry target resolves"
    else
        fail "K2 default entry target resolves"
    fi
    if compgen -G "${d}/esp/EFI/Linux/*.efi" | grep -q 'sdboot-manage-new'; then
        fail "K2 staging is not auto-discovered"
    else
        pass "K2 staging is not auto-discovered"
    fi
    show_context
}

test_entry_install_failure_preserves_rescue() {
    echo "R22 entry install failure preserves the rescue entry"
    local d="${WORK}/r22"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    add_traditional_path "${d}" linux-test
    : >"${d}/control/readonly_entries"
    mkdir -p "${d}/esp/EFI/rescue"
    printf 'rescue kernel\n' >"${d}/esp/EFI/rescue/vmlinuz"
    printf 'rescue initramfs\n' >"${d}/esp/EFI/rescue/initramfs.img"
    cat >"${d}/esp/loader/entries/rescue.conf" <<'ENTRY'
title Rescue
linux /EFI/rescue/vmlinuz
initrd /EFI/rescue/initramfs.img
ENTRY
    sed -i 's/^REMOVE_EXISTING=.*/REMOVE_EXISTING="yes"/' "${d}/etc/sdboot-manage.conf"
    set_use_uki "${d}" no

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R22 exit code"
    assert_exists "${d}/esp/loader/entries/rescue.conf" "R22 rescue entry preserved"
    assert_exists "${d}/esp/EFI/rescue/vmlinuz" "R22 rescue kernel preserved"
    assert_exists "${d}/esp/EFI/rescue/initramfs.img" "R22 rescue initramfs preserved"
    if grep -qx 'linux /EFI/rescue/vmlinuz' "${d}/esp/loader/entries/rescue.conf" 2>/dev/null &&
        grep -qx 'initrd /EFI/rescue/initramfs.img' "${d}/esp/loader/entries/rescue.conf" 2>/dev/null; then
        pass "R22 rescue entry references are intact"
    else
        fail "R22 rescue entry references are intact"
    fi
    show_context
}

test_no_usable_entries_preserves_rescue() {
    echo "R23 no usable regular entry preserves the rescue entry"
    local d="${WORK}/r23"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    printf 'kernel without initramfs\n' >"${d}/esp/vmlinuz-linux-test"
    mkdir -p "${d}/esp/EFI/rescue"
    printf 'rescue kernel\n' >"${d}/esp/EFI/rescue/vmlinuz"
    printf 'rescue initramfs\n' >"${d}/esp/EFI/rescue/initramfs.img"
    cat >"${d}/esp/loader/entries/rescue.conf" <<'ENTRY'
title Rescue
linux /EFI/rescue/vmlinuz
initrd /EFI/rescue/initramfs.img
ENTRY
    sed -i 's/^REMOVE_EXISTING=.*/REMOVE_EXISTING="yes"/' "${d}/etc/sdboot-manage.conf"
    set_use_uki "${d}" no

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R23 exit code"
    assert_exists "${d}/esp/loader/entries/rescue.conf" "R23 rescue entry preserved"
    assert_exists "${d}/esp/EFI/rescue/vmlinuz" "R23 rescue kernel preserved"
    assert_exists "${d}/esp/EFI/rescue/initramfs.img" "R23 rescue initramfs preserved"
    if grep -qx 'linux /EFI/rescue/vmlinuz' "${d}/esp/loader/entries/rescue.conf" 2>/dev/null &&
        grep -qx 'initrd /EFI/rescue/initramfs.img' "${d}/esp/loader/entries/rescue.conf" 2>/dev/null; then
        pass "R23 rescue entry references are intact"
    else
        fail "R23 rescue entry references are intact"
    fi
    show_context
}

test_invalid_existing_entry_not_counted() {
    echo "R24 invalid existing entry is not counted as available"
    local d="${WORK}/r24"
    new_fixture "${d}"
    add_kernel "${d}" linux-test 6.0.0-test
    printf 'kernel without initramfs\n' >"${d}/esp/vmlinuz-linux-test"
    cat >"${d}/esp/loader/entries/linux-test.conf" <<'ENTRY'
title Broken custom
linux /vmlinuz-linux-test
initrd /initramfs-linux-test.img
ENTRY
    mkdir -p "${d}/esp/EFI/rescue"
    printf 'rescue kernel\n' >"${d}/esp/EFI/rescue/vmlinuz"
    printf 'rescue initramfs\n' >"${d}/esp/EFI/rescue/initramfs.img"
    cat >"${d}/esp/loader/entries/rescue.conf" <<'ENTRY'
title Rescue
linux /EFI/rescue/vmlinuz
initrd /EFI/rescue/initramfs.img
ENTRY
    sed -i 's/^REMOVE_EXISTING=.*/REMOVE_EXISTING="yes"/' "${d}/etc/sdboot-manage.conf"
    sed -i 's/^OVERWRITE_EXISTING=.*/OVERWRITE_EXISTING="no"/' "${d}/etc/sdboot-manage.conf"
    set_use_uki "${d}" no

    run_manage "${d}" gen
    assert_nonzero "${RC}" "R24 exit code"
    assert_exists "${d}/esp/loader/entries/linux-test.conf" "R24 custom entry preserved"
    assert_exists "${d}/esp/loader/entries/rescue.conf" "R24 rescue entry preserved"
    assert_exists "${d}/esp/EFI/rescue/vmlinuz" "R24 rescue kernel preserved"
    assert_exists "${d}/esp/EFI/rescue/initramfs.img" "R24 rescue initramfs preserved"
    if grep -qx 'linux /vmlinuz-linux-test' "${d}/esp/loader/entries/linux-test.conf" &&
        grep -qx 'initrd /initramfs-linux-test.img' "${d}/esp/loader/entries/linux-test.conf"; then
        pass "R24 custom entry references preserved"
    else
        fail "R24 custom entry references preserved"
    fi
    if grep -qx 'linux /EFI/rescue/vmlinuz' "${d}/esp/loader/entries/rescue.conf" &&
        grep -qx 'initrd /EFI/rescue/initramfs.img' "${d}/esp/loader/entries/rescue.conf"; then
        pass "R24 rescue entry references preserved"
    else
        fail "R24 rescue entry references preserved"
    fi
    show_context
}

# ---------------------------------------------------------------------------

test_regular_to_uki_success
test_regular_to_uki_failure_preexisting
test_regular_to_uki_failure_empty
test_regular_to_uki_failure_no_uki
test_regular_to_uki_autogen_stale
test_regular_to_uki_multi_kernel
test_regular_to_uki_noop_generator
test_remove_existing_failure_without_uki
test_preset_restore_failure_reported
test_valid_regeneration_same_size
test_touch_only_generator_rejected
test_kill_before_replacement_write
test_kill_after_partial_replacement
test_entry_install_failure_preserves_rescue
test_no_usable_entries_preserves_rescue
test_invalid_existing_entry_not_counted
test_uki_to_regular_success_keeps_fallback
test_uki_to_regular_install_failure
test_uki_to_regular_depmod_failure
test_uki_to_regular_remove_existing_failure
test_uki_to_regular_custom_entry
test_uki_to_regular_multi_kernel_failure
test_regular_baseline
test_established_uki_rescue
test_uki_to_regular_noop_generator
test_uki_to_regular_existing_images

printf '\n%d passed, %d failed\n' "${PASS}" "${FAIL}"
((FAIL == 0))
