# cachy-screen-enhancer

ICC color profiles that correct the sRGB transfer function to pure gamma 2.2 for CachyOS/Linux.

## Usage

```bash
bash /usr/share/cachy-screen-enhancer/safe-install.sh
```

The script auto-detects your GPU, display, and brightness level, generates a custom profile, applies gamma correction to the GPU, and registers the profile with KDE.

## Direct scanout

Fullscreen video and games can scan out directly from the GPU with no extra
compositing pass when you're on Linux kernel 6.19+ with a driver that exposes
plane color pipelines (AMD RDNA2+, recent NVIDIA). Otherwise KWin composites
fullscreen content while the profile is active. Colors stay correct, but
fullscreen video and games get a little extra latency. The installer warns if
your system is affected.

## Removal

```bash
sudo pacman -R cachy-screen-enhancer
```

The pre-remove hook cleans up gamma correction and profile files automatically.
