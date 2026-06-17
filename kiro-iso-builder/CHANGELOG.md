# Changelog

## 2026.06.07

### What Changed
- Added a short `kib` command as an alias for `kiro-iso-builder`, so the app can be launched by typing `kib`.

### Technical Details
- `package()` now creates a relative symlink `/usr/bin/kib` -> `kiro-iso-builder` (the existing launcher). Relative target keeps the link valid regardless of install root.

### Files Modified
- PKGBUILD
