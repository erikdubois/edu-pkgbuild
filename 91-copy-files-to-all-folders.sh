#!/bin/bash
set -euo pipefail
# trap 'echo "Error on line $LINENO"; exit 1' ERR

##################################################################################################################
# Written to be used on 64 bits computers
# Author   : Erik Dubois
# Website  : http://www.erikdubois.be
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

##################################################################################################################
# Colors
##################################################################################################################
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

##################################################################################################################
# Logging
##################################################################################################################
log_section() {
    echo
    echo "${GREEN}##################################################################################################################${RESET}"
    echo "$1"
    echo "${GREEN}##################################################################################################################${RESET}"
    echo
}

log_info() {
    echo
    echo "${BLUE}##################################################################################################################${RESET}"
    echo "$1"
    echo "${BLUE}##################################################################################################################${RESET}"
    echo
}

log_warn() {
    echo
    echo "${YELLOW}##################################################################################################################${RESET}"
    echo "$1"
    echo "${YELLOW}##################################################################################################################${RESET}"
    echo
}

log_error() {
    echo
    echo "${RED}##################################################################################################################${RESET}"
    echo "$1"
    echo "${RED}##################################################################################################################${RESET}"
    echo
}

SOURCE_SCRIPT1="setup.sh"
SOURCE_SCRIPT2="up.sh"

# Check if the source script exists
if [[ ! -f "$SOURCE_SCRIPT1" ]]; then
    echo "Error: $SOURCE_SCRIPT1 not found in the current directory."
    exit 1
fi

if [[ ! -f "$SOURCE_SCRIPT2" ]]; then
    echo "Error: $SOURCE_SCRIPT2 not found in the current directory."
    exit 1
fi

# Iterate over all immediate subdirectories
find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    dirname=$(basename "$dir")
    
    # Optional: remove any old setup scripts inside the target directory
    find "$dir" -maxdepth 1 -type f -name "setup*" -exec rm -v {} \;
    
    # Copy the setup-edu.sh script to the subdirectory
    cp "$SOURCE_SCRIPT1" "$dir/"
    
    log_info "Copied over the $SOURCE_SCRIPT1 script to $dirname"
done

# Iterate over all immediate subdirectories
find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    dirname=$(basename "$dir")

    # Optional: remove any old setup scripts inside the target directory
    find "$dir" -maxdepth 1 -type f -name "up*" -exec rm -v {} \;

    # Copy the setup-edu.sh script to the subdirectory
    cp "$SOURCE_SCRIPT2" "$dir/"

    log_info "Copied over the $SOURCE_SCRIPT2 script to $dirname"
done

# Iterate over all immediate subdirectories
find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    dirname=$(basename "$dir")

    # Remove setup-edu.sh if it exists
    find "$dir" -maxdepth 1 -type f -name "setup-edu.sh" -exec rm -v {} \;

    log_warn "Removed setup-edu.sh from $dirname"
done