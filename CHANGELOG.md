# Changelog

## 2026.06.20

### What Changed
- **`kiro-plasma-servicemenus`** — declared the helper-app `depends` (was empty):
  `imagemagick kdialog meld kdesu mintstick gittyup code alacritty`. De-branded the
  `pkgdesc` ("Servicemenu files for edu" → "KDE Plasma Dolphin service-menu actions
  for Kiro").
- **Added `kiro-plasma-dolphin`** — new package build dir for the default Dolphin
  configuration. Builds from `kirodubes/kiro-plasma-dolphin` into `nemesis_repo` and
  ships a minimal `dolphinrc` to `/etc/xdg` (XDG cascade; menubar off + file-dialog
  places sizing). Same recipe shape as `kiro-plasma-system-settings`.
- **Added `kiro-plasma-konsole`** — new package build dir for the default Konsole
  configuration. Builds from `kirodubes/kiro-plasma-konsole` into `nemesis_repo` and
  ships the Kiro profile, ArcDark colour scheme, and `konsolerc` to `/etc/skel`.
  PKGBUILD models the `kiro-plasma-system-settings` recipe (`_destname="/etc"`, git+
  source, GPL3, license under `/usr/share/kiro/licenses/`, `build.sh` md5 `ff42d7d4`).
- **Added `kiro-plasma-system-settings`** — new package build dir for the default
  KDE Plasma System Settings configuration. Builds from
  `kirodubes/kiro-plasma-system-settings` into `nemesis_repo` and ships behavioural
  defaults (lock screen, logout/session, hot corner, power timeouts) to `/etc/xdg/`.

### Technical Details
- PKGBUILD modelled on `kiro-plasma-keybindings` but ships `/etc` only (no `/usr`):
  `_destname="/etc"`, git+ source, `GPL3`, license copied under
  `/usr/share/kiro/licenses/`. `build.sh` is the generic per-package builder
  (copied from `kiro-plasma-keybindings`, md5 `ff42d7d4`).
- Delivery is `/etc/xdg/` (XDG cascade defaults) rather than `/etc/skel/` —
  verified on a Plasma 6 box that all four files are honored by the cascade.
- `pkgrel` starts at `01`; version files are created on first build.

### Files Modified
- `kiro-plasma-system-settings/PKGBUILD`, `kiro-plasma-system-settings/build.sh`,
  `kiro-plasma-system-settings/readme.install`

## 2026.06.19

### What Changed
- **Added `kiro-grub-theme`** — a new package build dir for the Kiro-branded
  GRUB2 boot theme. Builds from `kirodubes/kiro-grub-theme` into `nemesis_repo`
  and installs the theme to `/boot/grub/themes/kiro/`.

### Technical Details
- PKGBUILD modelled on `kiro-rofi-themes` (git+ source, `GPL3` license, ships a
  copy of `LICENSE` under `/usr/share/kiro/licenses/`); `build.sh` is the generic
  per-package builder copied from `kiro-bootloader-grub`.
- No `-nemesis` twin (matches `kiro-rofi-themes`, the closest theme-content
  analog). Add one only if a `kiro_repo` edition is needed.

### Files Modified
- `kiro-grub-theme/PKGBUILD`, `kiro-grub-theme/build.sh`,
  `kiro-grub-theme/readme.install`

## 2026.06.17

### What Changed
- **Deleted 28 superseded `edu-*` package build dirs.** Each had a live `kiro-*`
  replacement already building and shipping to `nemesis_repo`, so the legacy EDU
  recipe was dead weight. Kept **`edu-sddm-simplicity-qt6`** — the only EDU
  package with no Kiro equivalent yet (`kiro-sddm-simplicity-qt6` does not exist).
- This also clears the stale dependency references the EDU recipes carried (e.g.
  `edu-chadwm` depended on the non-existent `edu-rofi-git` / `edu-rofi-themes-git`;
  the live `ohmychadwm` recipe already uses `kiro-rofi` / `kiro-rofi-themes`).

### Technical Details
- Removed dirs (28): edu-arc-dawn, edu-awesome, edu-bspwm, edu-chadwm,
  edu-dot-files, edu-i3-git, edu-leftwm-git, edu-neo-candy-arc,
  edu-neo-candy-arc-mint-grey, edu-neo-candy-arc-mint-red, edu-neo-candy-qogir,
  edu-neo-candy-tela, edu-papirus-dark-tela, edu-papirus-dark-tela-grey,
  edu-plasma-keybindings-git, edu-plasma-servicemenus-git, edu-polybar-git,
  edu-powermenu, edu-qtile-git, edu-rofi-git, edu-rofi-themes,
  edu-sddm-simplicity, edu-shells, edu-surfn-numixs-blue, edu-system-files,
  edu-variety-config, edu-vimix-dark-tela, edu-xfce.
- Kept: edu-sddm-simplicity-qt6.
- `kiro-system-files/PKGBUILD` intentionally retains
  `conflicts/replaces=('edu-system-files-git')` as the upgrade path — left as-is.

### Files Modified
- Deleted 28 `edu-*/` build directories (133 files)
- Created `CHANGELOG.md`
