<p align="center">
  <img src="kiro.jpg" alt="Kiro" width="220" />
</p>

# edu-pkgbuild

A collection of Arch Linux PKGBUILDs used to build and publish packages for the **nemesis_repo** — the custom package repository powering the EDU/Kiro Linux ecosystem.

Each subdirectory is a self-contained package: a `PKGBUILD`, a `build-data.sh` driver, and version tracking files. Three orchestration scripts at the root batch-build subsets of packages and publish the results.

---

## Requirements

- Arch Linux
- `devtools` — for chroot builds (`makechrootpkg`, `arch-nspawn`)
- A clean chroot at `~/Documents/chroot-archlinux`
- A local clone of `nemesis_repo` at `~/EDU/nemesis_repo/`

Set up the chroot once:

```bash
mkdir -p ~/Documents/chroot-archlinux
mkarchroot ~/Documents/chroot-archlinux/root base-devel
```

---

## Building

### Single package

```bash
cd edu-shells
bash build-data.sh
```

### All packages

```bash
bash 1-build-all-packages.sh
```

### Only `edu-*` packages

```bash
bash 2-build-all-edu-packages.sh
```

### Only `edu-neo-candy-*` themes

```bash
bash 3-build-all-edu-themes.sh
```

All batch scripts call `~/EDU/nemesis_repo/up.sh` at the end to publish the repo.

---

## How a build works

`build-data.sh` inside each package directory:

1. Bumps `pkgver` to `YY.MM` and increments `pkgrel` (resets to `01` on a new month)
2. Compares `.current-version` with `.previous-version` — skips the build if nothing changed
3. Copies the package to `/tmp/tempbuild/` and builds there using `makechrootpkg` (default) or `makepkg`
4. Copies the resulting `*.pkg.tar.zst` to `~/EDU/nemesis_repo/x86_64/`
5. Promotes `.current-version` to `.previous-version`

---

## Package categories

| Prefix             | Content                                                             |
|--------------------|---------------------------------------------------------------------|
| `edu-*`            | General EDU project packages (dot files, shells, WM configs, tools) |
| `edu-neo-candy-*`  | GTK and icon themes                                                 |
| `edu-*-git`        | Packages built from a git source                                    |
| `plymouth-theme-*` | Plymouth boot splash themes                                         |

---

## Websites

- https://erikdubois.be
- https://www.youtube.com/erikdubois
