#!/bin/bash
set -euo pipefail
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#####################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   Force-republish EVERY package in this folder unconditionally, then
#   publish nemesis_repo. Expects the packages to have already been
#   pinned by change-version-100.sh (pkgver=26.06 pkgrel=100).
#   Unlike 1-build-all-packages.sh this does NOT auto-bump or honour
#   the .current/.previous version skip — every package is built.
#
# Why:
#   pkgrel=100 deliberately out-ranks any release currently installed
#   or in the repo, so a single `pacman -Syu` pulls fresh copies of the
#   whole set across every Kiro system — a clean force re-sync. The
#   version pin lives in change-version-100.sh; this script only builds.
#####################################################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

#####################################################################
# Colors
#####################################################################
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    CYAN="$(tput setaf 6)"
    RESET="$(tput sgr0)"
else
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
fi

#####################################################################
# Logging
#####################################################################
log_section() {
    echo
    echo "${GREEN}############################################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################################${RESET}"
    echo
}

log_info() {
    echo
    echo "${BLUE}############################################################################${RESET}"
    echo "$1"
    echo "${BLUE}############################################################################${RESET}"
    echo
}

log_warn() {
    echo
    echo "${YELLOW}############################################################################${RESET}"
    echo "$1"
    echo "${YELLOW}############################################################################${RESET}"
    echo
}

log_error() {
    echo
    echo "${RED}############################################################################${RESET}"
    echo "$1"
    echo "${RED}############################################################################${RESET}"
    echo
}

log_success() {
    echo
    echo "${GREEN}############################################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################################${RESET}"
    echo
}

#####################################################################
# Error handling
#####################################################################
on_error() {
    local lineno="$1"
    local cmd="$2"
    echo
    echo "${RED}ERROR on line ${lineno}: ${cmd}${RESET}"
    echo
    sleep 10
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

#####################################################################
# Functions
#####################################################################
build_one() {
    # Build a single pinned package in the chroot and force-copy it into
    # nemesis_repo, overwriting any same-named file from an earlier run.
    local dir="$1"
    local search destiny CHROOT
    search="$(basename "${dir}")"
    destiny="${HOME}/EDU/nemesis_repo/x86_64/"
    CHROOT="${HOME}/Documents/chroot-archlinux"

    [[ -d /tmp/tempbuild ]] && rm -rf /tmp/tempbuild
    mkdir /tmp/tempbuild
    cp -r "${dir}/"* /tmp/tempbuild/

    log_section "Building ${search} in CHROOT ${CHROOT}"
    if (cd /tmp/tempbuild && makechrootpkg -c -r "${CHROOT}"); then
        log_section "Copying ${search} to ${destiny}"
        cp -fv /tmp/tempbuild/*"${search}"*pkg.tar.zst "${destiny}"
    else
        log_error "Build FAILED for ${search}"
        echo "Error: ${search} failed to build" | tee -a /tmp/failed
    fi

    log_section "Cleaning up ${search}"
    find "${dir}" -maxdepth 1 \( -name "*.log" -o -name "*.deb" -o -name "*.tar.gz" \) -delete
    cp "${dir}/.current-version" "${dir}/.previous-version"
}

build_all_packages() {
    local dirs total count CHROOT
    CHROOT="${HOME}/Documents/chroot-archlinux"

    mapfile -t dirs < <(find "${SCRIPT_DIR}" -maxdepth 1 -mindepth 1 -type d -not -name ".*" | sort)
    total="${#dirs[@]}"
    count=0

    log_section "Force-building ${total} packages"

    log_section "Syncing chroot once"
    arch-nspawn "${CHROOT}/root" pacman -Syu --noconfirm

    for dir in "${dirs[@]}"; do
        count=$((count + 1))
        local name
        name="$(basename "${dir}")"

        log_info "Package ${count} of ${total}: ${name}"

        if [[ ! -f "${dir}/PKGBUILD" ]]; then
            log_warn "No PKGBUILD in ${name} — skipping"
            echo "Error: ${name} has no PKGBUILD" | tee -a /tmp/failed
            continue
        fi

        build_one "${dir}"
    done
}

publish_repo() {
    log_section "Publishing nemesis_repo"
    bash /home/erik/EDU/nemesis_repo/up.sh
}

#####################################################################
# Main
#####################################################################
main() {
    build_all_packages
    publish_repo

    log_success "$(basename "$0") done"
}

main "$@"
