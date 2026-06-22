#!/bin/bash
set -euo pipefail
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   Build the surfn-meta package and copy the resulting .pkg.tar.zst
#   into the local nemesis_repo (~/EDU/nemesis_repo/x86_64/).
#
# Why:
#   surfn-meta is a pure meta package (empty package(), no sources and
#   no git project), so it needs none of the version-bump / git-pull /
#   skip-if-unchanged machinery the icon packages use. It only has to
#   be built and published. Its 30 surfn dependencies do not live in
#   the build chroot, so we build with `makepkg -d` (skip dependency
#   checks) rather than makechrootpkg.
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
build_package() {
    local search destiny
    search="$(basename "${SCRIPT_DIR}")"
    destiny="${HOME}/EDU/nemesis_repo/x86_64/"

    [[ ! -f "${SCRIPT_DIR}/PKGBUILD" ]] && { log_error "No PKGBUILD found in ${SCRIPT_DIR}"; exit 1; }

    [[ -d /tmp/tempbuild ]] && rm -rf /tmp/tempbuild
    mkdir /tmp/tempbuild
    cp -r "${SCRIPT_DIR}/"* /tmp/tempbuild/

    log_section "Building ${search} with MAKEPKG (meta, deps skipped)"
    (cd /tmp/tempbuild && makepkg -df)

    log_section "Copying packages to ${destiny}"
    cp -fv /tmp/tempbuild/*.pkg.tar.zst "${destiny}"

    log_success "Build done for ${search}"
}

#####################################################################
# Main
#####################################################################
main() {
    build_package

    log_success "$(basename "$0") done"
}

main "$@"
