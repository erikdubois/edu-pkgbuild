# Changelog

## 2026.08.23

### What Changed
- **`ohmychadwm/readme.install` — the "already built?" guard tested a binary name that never
  exists.** `post_install()` skipped the local build only when `command -v chadwm` succeeded, but
  the Makefile under `etc/skel/.config/ohmychadwm/chadwm/` produces a binary called **`ohmychadwm`**
  (`cp -f ohmychadwm ${DESTDIR}${PREFIX}/bin`, `PREFIX = /usr/local`). Nothing on a Kiro system
  provides a `chadwm` binary, so the guard never matched: every install and every upgrade of the
  package recompiled from `/etc/skel` and `make install`-ed an **unowned** `/usr/local/bin/ohmychadwm`
  that shadows the packaged `/usr/bin/ohmychadwm` on `PATH`. Found on the v26.08.23 VM, where both
  copies are byte-identical (md5 `2ded2091…`) and `pacman -Qo` reports no owner.

### Technical Details
- The guard now tests `command -v ohmychadwm`, so the local build runs once at most and a machine
  that already has the packaged binary is left alone.
- The three sibling messages that name the *binary* were corrected with it; the ones naming the
  **source directory** (`chadwm build folder not found`, the `make` step messages, `CHADWM_DIR`)
  are left as-is — that directory really is called `chadwm`.
- The `slstatus` half of the same script was checked and is correct: its Makefile installs
  `slstatus`, which is the name its guard tests. Note `slstatus` is packaged nowhere else, so
  `/usr/local/bin/slstatus` is load-bearing — it must keep being built here.
- Takes effect on the next `ohmychadwm` rebuild; existing installs keep the shadowing copy until
  it is removed by hand.

### Files Modified
- `ohmychadwm/readme.install`

## 2026.06.29

### What Changed
- **Added `build-twm-xfce-packages.sh`** — batch push+build+publish for all Kiro
  tiling window managers (`ohmychadwm`, `kiro-chadwm`, `kiro-awesome`,
  `kiro-bspwm`, `kiro-i3`, `kiro-leftwm`, `kiro-qtile`) plus `kiro-xfce`. In
  order it (1) pushes each source repo `~/KIRO/<name>` to GitHub via its own
  `up.sh`, (2) builds each package from its `build.sh` here, (3) publishes once
  with `~/EDU/nemesis_repo/up.sh`. The push step is required because the build
  dirs pull `kirodubes/<name>` as a `git+` source — without it the chroot builds
  stale config. Modelled on `build-skel-hint-packages.sh`. Use after a
  cross-environment change such as propagating ohmychadwm's keybindings to every
  other TWM + XFCE.

### Files Modified
- `build-twm-xfce-packages.sh` (new)

## 2026.06.28

### What Changed
- **Added `kiro-starship`** — new package build dir for the default Starship
  prompt configuration. Builds from `kirodubes/kiro-starship` into `nemesis_repo`
  and ships `etc/skel/.config/starship.toml` to `/etc/skel` (new users inherit it
  automatically). `depends=('starship')`. PKGBUILD models the `kiro-fish-config`
  recipe (git+ source, GPL3, `provides`, `.install` post-install hint). build.sh
  copied from `kiro-fish-config`.

### Files Modified
- `kiro-starship/PKGBUILD` (new)
- `kiro-starship/kiro-starship.install` (new)
- `kiro-starship/build.sh` (new)

## 2026.06.20

### What Changed
- **Added `kiro-plasma-window-management`** (renamed from `kiro-plasma-kwin-rules`) —
  new package build dir for KWin window-management config. Builds from
  `kirodubes/kiro-plasma-window-management`, ships `/etc/xdg/kwinrc` (4 virtual
  desktops, effects, titlebar-wheel maximize, flipswitch, ShowDesktop edge). The
  `kwinrc` was consolidated here out of `kiro-plasma-system-settings` so only one
  package owns `/etc/xdg/kwinrc`. Ready to build. Window rules (`kwinrulesrc`) to come.
- **`kiro-plasma-servicemenus`** — `depends=('kdialog')` (the only hard requirement —
  used by the Checksum popup); the other helpers are `optdepends` left to the user
  (`imagemagick`, `meld`, `kdesu`, `mintstick`, `gittyup`, `code`, `alacritty`).
  De-branded the `pkgdesc` ("Servicemenu files for edu" → "KDE Plasma Dolphin
  service-menu actions for Kiro").
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
