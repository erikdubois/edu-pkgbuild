# Changelog

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
