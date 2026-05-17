#!/bin/bash
set -euo pipefail
#####################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
#####################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
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
build_all_packages() {
    local dirs total count

    mapfile -t dirs < <(find "${SCRIPT_DIR}" -maxdepth 1 -mindepth 1 -type d -not -name ".*" | sort)
    total="${#dirs[@]}"
    count=0

    log_section "Building ${total} packages"

    for dir in "${dirs[@]}"; do
        count=$((count + 1))
        local name
        name="$(basename "${dir}")"

        log_info "Package ${count} of ${total}: ${name}"

        if compgen -G "${dir}/build*" > /dev/null 2>&1; then
            (cd "${dir}" && sh ./build*)
        else
            log_warn "No build script found for ${name} — skipping"
            echo "Error: ${name} has no build script" | tee -a /tmp/failed
        fi
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
