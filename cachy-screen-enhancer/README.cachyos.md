# cachy-screen-enhancer

ICC color profiles that correct the sRGB transfer function to pure gamma 2.2 for CachyOS/Linux.

## Usage

```bash
/usr/share/cachy-screen-enhancer/safe-install.sh
```

The script auto-detects your GPU, display, and brightness level, generates a custom profile, applies gamma correction to the GPU, and registers the profile with KDE.

## Removal

```bash
sudo pacman -R cachy-screen-enhancer
```

The pre-remove hook cleans up gamma correction and profile files automatically.
