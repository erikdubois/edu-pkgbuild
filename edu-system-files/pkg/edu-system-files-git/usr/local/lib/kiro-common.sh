#!/usr/bin/env bash

##################################################################################################################################
# Kiro Common Library - Shared utilities for all Kiro/EDU system scripts
# Source: Based on arcolinux-nemesis/common/common.sh
# Purpose: Provide consistent logging, error handling, and utility functions across all scripts
#
# Usage:
#   source /usr/local/lib/kiro-common.sh
#
# Features:
#   - Color-coded logging output
#   - Error handling with trap
#   - Package management helpers
#   - File and directory utilities
#   - Service management helpers
#   - User and group helpers
##################################################################################################################################

# Guard against multiple loading
[[ -n "${KIRO_COMMON_SH_LOADED:-}" ]] && return 0
readonly KIRO_COMMON_SH_LOADED=1

# Exit on error, undefined variables, and pipe failures
set -Euo pipefail
# Enable nullglob for empty glob expansions
shopt -s nullglob

##################################################################################################################################
# Index
##################################################################################################################################
# 1. Initialization
# 2. Colors
# 3. Logging
# 4. Error handling
# 5. Generic helpers
# 6. Package helpers
# 7. Service helpers
# 8. File helpers
# 9. User and group helpers
# 10. Download helpers
# 11. Repo and pacman helpers
# 12. Network and connectivity helpers
# 13. Kernel and performance helpers
# 14. System utility helpers

##################################################################################################################################
# 1. Initialization
##################################################################################################################################
TARGET_USER="${SUDO_USER:-$USER}"
SCRIPT_NAME="$(basename "${0:-.}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

##################################################################################################################################
# 2. Colors
##################################################################################################################################
# Colors are only enabled if tput is available and output is to a terminal
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    PURPLE="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    RESET="$(tput sgr0)"
    BOLD="$(tput bold)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    PURPLE=""
    CYAN=""
    RESET=""
    BOLD=""
fi

##################################################################################################################################
# 3. Logging Functions
##################################################################################################################################

# Log a major section header
log_section() {
    echo
    echo "${GREEN}################################################################################${RESET}"
    echo "${BOLD}${GREEN}$1${RESET}"
    echo "${GREEN}################################################################################${RESET}"
    echo
}

# Log a subsection header
log_subsection() {
    echo
    echo "${CYAN}########################################################################${RESET}"
    echo "${BOLD}${CYAN}$1${RESET}"
    echo "${CYAN}########################################################################${RESET}"
    echo
}

# Log an informational message
log_info() {
    echo "${BLUE}ℹ ${1}${RESET}"
}

# Log a success message
log_success() {
    echo "${GREEN}✓ ${1}${RESET}"
}

# Log a warning message
log_warn() {
    echo
    echo "${YELLOW}########################################################################${RESET}"
    echo "${BOLD}${YELLOW}⚠️  WARNING${RESET}"
    echo "${YELLOW}${1}${RESET}"
    echo "${YELLOW}########################################################################${RESET}"
    echo
}

# Log an error message
log_error() {
    local lineno="$1"
    local cmd="${2:-}"

    echo
    echo "${RED}########################################################################${RESET}"
    echo "${BOLD}${RED}⚠️  ERROR DETECTED${RESET}"
    echo "${RED}Line: ${lineno}${RESET}"
    if [[ -n "$cmd" ]]; then
        echo "${RED}Command: '${cmd}'${RESET}"
    fi
    echo "${RED}Waiting 10 seconds before continuing...${RESET}"
    echo "${RED}########################################################################${RESET}"
    echo
}

##################################################################################################################################
# 4. Error Handling
##################################################################################################################################

# Error trap handler - called on any error
on_error() {
    local lineno="$1"
    local cmd="${2:-}"
    log_error "${lineno}" "${cmd}"
    sleep 10
}

# Set up error trap
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

##################################################################################################################################
# 5. Generic Helpers
##################################################################################################################################

# Get the name of the calling script
script_name() {
    basename "${BASH_SOURCE[1]}"
}

# Check if required commands exist
require_root_tools() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_warn "Required command not found: ${cmd}"
            return 1
        fi
    done
}

# Pause if DEBUG mode is enabled
pause_if_debug() {
    if [[ "${DEBUG:-false}" == true ]]; then
        echo
        echo "------------------------------------------------------------"
        echo "Waiting for user input to continue. Debug mode is on."
        echo "------------------------------------------------------------"
        echo
        read -r -n 1 -s -p "Debug mode is on. Press any key to continue..."
        echo
    fi
}

# Replace text in file safely
replace_text_in_file() {
    local file="$1"
    local old_text="$2"
    local new_text="$3"
    local use_sudo="${4:-false}"

    if [[ ! -f "$file" ]]; then
        log_warn "Skipping: file not found: $file"
        return 0
    fi

    if ! grep -qF "$old_text" "$file"; then
        log_info "No replacement needed in: $file"
        return 0
    fi

    local escaped_old escaped_new
    escaped_old=$(printf '%s' "$old_text" | sed 's/[[\.*^$()+?{|]/\\&/g')
    escaped_new=$(printf '%s' "$new_text" | sed 's/[\\&|]/\\&/g')

    if [[ "$use_sudo" == "true" ]]; then
        sudo sed -i "s|${escaped_old}|${escaped_new}|g" "$file" \
            && log_success "Updated: $file" \
            || log_warn "Failed to update: $file"
    else
        sed -i "s|${escaped_old}|${escaped_new}|g" "$file" \
            && log_success "Updated: $file" \
            || log_warn "Failed to update: $file"
    fi
}

# Comment out patterns in file
comment_out_patterns_in_file() {
    local file="$1"
    shift
    local patterns=("$@")

    if [[ ! -f "$file" ]]; then
        log_warn "Skipping: file not found: $file"
        return 0
    fi

    local pattern
    for pattern in "${patterns[@]}"; do
        log_info "Processing pattern: $pattern"
        sed -i "/$pattern/ {/^[[:space:]]*#/! s/^/#/}" "$file"
    done
}

# Show help message for a script
show_help() {
    local script_name="$1"
    local description="$2"
    local usage="$3"
    local options="$4"
    
    cat <<EOF
${BOLD}${GREEN}${script_name}${RESET} - ${description}

${BOLD}Usage:${RESET}
    ${script_name} ${usage}

${BOLD}Options:${RESET}
    -h, --help          Show this help message and exit
    -v, --version       Show version information and exit
    -d, --dry-run       Show what would be done without making changes
    ${options}

${BOLD}Examples:${RESET}
    ${script_name} --help
    ${script_name} --version
    ${script_name} --dry-run [other arguments]

For more information, visit: https://www.arcolinux.info
EOF
}

# Show version information
show_version() {
    local script_name="$1"
    local version="${2:-1.0.0}"
    
    echo "${BOLD}${GREEN}${script_name}${RESET} version ${version}"
    echo "Created: 2026-04-20"
    echo "Based on: arcolinux-nemesis/common/common.sh"
    echo "Website: https://www.arcolinux.info"
}

# Execute command with dry-run support
execute_or_dryrun() {
    local description="$1"
    shift
    local cmd=("$@")
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: ${description}"
        log_info "[DRY-RUN] Command: ${cmd[*]}"
    else
        "${cmd[@]}"
    fi
}

# Confirm operation, respecting dry-run mode
confirm_with_dryrun() {
    local prompt="$1"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY-RUN] ${prompt}"
        return 0
    fi
    
    confirm_yes_no "${prompt}"
}

##################################################################################################################################
# 6. Package Helpers
##################################################################################################################################

# Check if package is installed
pkg_installed() {
    pacman -Q "$1" &>/dev/null
}

# Install packages
install_packages() {
    local pkgs=("$@")
    (( ${#pkgs[@]} == 0 )) && return 0

    log_subsection "Installing packages"
    sudo pacman -S --noconfirm --needed "${pkgs[@]}"
}

# Remove packages
remove_packages() {
    local pkgs=()
    local pkg

    for pkg in "$@"; do
        if pkg_installed "${pkg}"; then
            pkgs+=("${pkg}")
        fi
    done

    if (( ${#pkgs[@]} > 0 )); then
        log_subsection "Removing packages"
        sudo pacman -R --noconfirm "${pkgs[@]}"
    else
        log_subsection "No packages to remove"
    fi
}

# Remove packages with dependencies
remove_matching_packages_deps() {
    local pkg

    for pkg in "$@"; do
        if pacman -Qq | grep -Fxq -- "${pkg}"; then
            log_subsection "Removing package with dependencies: ${pkg}"
            sudo pacman -Rns --noconfirm "${pkg}"
        else
            log_info "No package named '${pkg}' is installed"
        fi
    done
}

# Force remove packages with dependencies
remove_matching_packages_deps_dd() {
    local pkg

    for pkg in "$@"; do
        if pacman -Qq | grep -Fxq -- "${pkg}"; then
            log_subsection "Force removing package: ${pkg}"
            sudo pacman -Rdd --noconfirm "${pkg}"
        else
            log_info "No package named '${pkg}' is installed"
        fi
    done
}

# Install local packages from directory
install_local_packages_from_dir() {
    local dir="$1"
    local -a pkgs=()

    if [[ -z "${dir}" ]]; then
        log_warn "No package directory provided"
        return 1
    fi

    if [[ ! -d "${dir}" ]]; then
        log_warn "Directory not found: ${dir}"
        return 1
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        log_warn "pacman not found"
        return 1
    fi

    pkgs=("${dir}"/*.pkg.tar.*)

    if (( ${#pkgs[@]} == 0 )); then
        log_warn "No local packages found in ${dir}"
        return 1
    fi

    log_subsection "Installing local packages from ${dir}"
    sudo pacman -U --noconfirm "${pkgs[@]}"
}

##################################################################################################################################
# 7. Service Helpers
##################################################################################################################################

# Enable and start a service
enable_now_service() {
    local service="$1"
    log_subsection "Enabling and starting service: ${service}"
    sudo systemctl enable --now "${service}"
}

# Disable a service
disable_service() {
    local service="$1"

    if systemctl list-unit-files | grep -q "^${service}\.service"; then
        if systemctl is-enabled --quiet "${service}" 2>/dev/null || systemctl is-active --quiet "${service}" 2>/dev/null; then
            log_subsection "Disabling service: ${service}"
            sudo systemctl disable --now "${service}"
        else
            log_info "Service ${service} already disabled"
        fi
    else
        log_warn "Service ${service} not installed"
    fi
}

# Start a service
start_service() {
    local service="$1"
    log_subsection "Starting service: ${service}"
    sudo systemctl start "${service}"
}

# Restart a service
restart_service() {
    local service="$1"

    if systemctl list-unit-files | grep -q "^${service}\.service"; then
        log_subsection "Restarting service: ${service}"
        sudo systemctl restart "${service}"
    else
        log_warn "Service ${service} not found"
    fi
}

##################################################################################################################################
# 8. File Helpers
##################################################################################################################################

# Backup folder as root
backup_folder_as_root() {
    local src="$1"
    local dst="$2"

    if [[ -d "${dst}" ]]; then
        log_info "Backup already exists: ${dst}"
        return 0
    fi

    if [[ ! -d "${src}" ]]; then
        log_warn "Source folder does not exist: ${src}"
        return 0
    fi

    log_subsection "Creating folder backup: ${src} -> ${dst}"
    sudo cp -a -- "${src}" "${dst}"
}

# Backup folder as user
backup_folder_as_user() {
    local src="$1"
    local dst="$2"

    if [[ -d "${dst}" ]]; then
        log_info "Backup already exists: ${dst}"
        return 0
    fi

    if [[ ! -d "${src}" ]]; then
        log_warn "Source folder does not exist: ${src}"
        return 0
    fi

    log_subsection "Creating folder backup: ${src} -> ${dst}"
    cp -a -- "${src}" "${dst}"
}

# Backup file once (only if target doesn't exist)
backup_file_once() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "${src}" ]]; then
        log_warn "Source file does not exist: ${src}"
        return 0
    fi

    if [[ -f "${dst}" ]]; then
        log_info "Backup already exists: ${dst}"
    else
        log_subsection "Creating backup: ${dst}"
        sudo cp -v "${src}" "${dst}"
    fi
}

# Copy file
copy_file() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "${src}" ]]; then
        log_warn "Source file missing: ${src}"
        return 1
    fi

    log_subsection "Copying ${src} -> ${dst}"
    sudo cp -v "${src}" "${dst}"
}

# Copy file as user
copy_file_user() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        log_warn "Source file missing: $src"
        return 1
    fi

    log_subsection "Copying (user: $TARGET_USER) $src -> $dst"
    sudo -u "$TARGET_USER" cp -v -- "$src" "$dst"
}

# Move file
move_file() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "${src}" ]]; then
        log_warn "Source file missing: ${src}"
        return 1
    fi

    log_subsection "Moving ${src} -> ${dst}"
    sudo mv -v -- "${src}" "${dst}"
}

# Move file as user
move_file_user() {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        log_warn "Source file missing: $src"
        return 1
    fi

    log_subsection "Moving (user: $TARGET_USER) $src -> $dst"
    sudo -u "$TARGET_USER" mv -v -- "$src" "$dst"
}

# Write file as root
write_file_as_root() {
    local target="$1"
    log_subsection "Writing ${target}"
    sudo tee "${target}" >/dev/null
}

# Append line if missing
append_line_if_missing() {
    local file="$1"
    local line="$2"

    if [[ ! -f "$file" ]]; then
        log_warn "Skipping: file not found: $file"
        return 0
    fi

    if grep -qxF "$line" "$file"; then
        log_info "Line already present in $file"
    else
        printf '%s\n' "$line" >> "$file"
        log_success "Added line to $file"
    fi
}

# Append line if missing (as root)
append_line_if_missing_root() {
    local file="$1"
    local line="$2"

    if [[ ! -f "$file" ]]; then
        log_warn "Skipping: file not found: $file"
        return 0
    fi

    if grep -qxF "$line" "$file"; then
        log_info "Line already present in $file"
    else
        printf '%s\n' "$line" | sudo tee -a "$file" > /dev/null
        log_success "Added line to $file"
    fi
}

# Remove file if exists
remove_file_if_exists() {
    local target="$1"

    if [[ -f "${target}" ]]; then
        sudo rm -f "${target}"
        log_success "Removed: ${target}"
    else
        log_info "Already removed: ${target}"
    fi
}

# Remove folder if exists
remove_folder_if_exists() {
    local target="$1"

    if [[ -d "${target}" ]]; then
        sudo rm -rf "${target}"
        log_success "Removed folder: ${target}"
    else
        log_info "Folder already removed: ${target}"
    fi
}

# Move folder if exists
move_folder_if_exists() {
    local source="$1"
    local destination="$2"

    if [[ ! -d "${source}" ]]; then
        log_info "Source folder does not exist: ${source}"
        return
    fi

    if [[ -e "${destination}" ]]; then
        log_info "Destination already exists: ${destination}"
        return
    fi

    sudo mv "${source}" "${destination}"
    log_success "Moved folder: ${source} -> ${destination}"
}

# Append text as root
append_text_as_root() {
    local target="$1"
    sudo tee -a "$target" >/dev/null
}

##################################################################################################################################
# 9. User and Group Helpers
##################################################################################################################################

# Add user to group
add_user_to_group() {
    local user="$1"
    local group="$2"

    if id -nG "${user}" | grep -qw "${group}"; then
        log_info "User ${user} already in group ${group}"
    else
        log_subsection "Adding ${user} to group ${group}"
        sudo gpasswd -a "${user}" "${group}"
    fi
}

# Confirm yes/no with user
confirm_yes_no() {
    local prompt="$1"
    local reply

    while true; do
        echo
        echo "${YELLOW}########################################################################${RESET}"
        echo "${prompt}"
        echo "Answer with Y/y or N/n (default: Y)"
        echo "${YELLOW}########################################################################${RESET}"
        echo
        read -r reply

        case "${reply}" in
            ""|[yY]) return 0 ;;
            [nN]) return 1 ;;
            *) echo "Invalid answer. Please use Y/y or N/n." ;;
        esac
    done
}

##################################################################################################################################
# 10. Download Helpers
##################################################################################################################################

# Download file with curl
download_file() {
    local url="$1"
    local dest="$2"

    log_subsection "Downloading $(basename "${dest}")"
    curl -L --fail --output "${dest}" "${url}" || {
        log_warn "Failed to download: ${url}"
        return 1
    }
    log_success "Downloaded: $(basename "${dest}")"
}

##################################################################################################################################
# 11. Repo and Pacman Helpers
##################################################################################################################################

# Set parallel downloads in pacman.conf
set_parallel_downloads() {
    local file="/etc/pacman.conf"
    local value="${1:-25}"

    log_subsection "Setting ParallelDownloads to $value"

    if [[ ! -f "$file" ]]; then
        log_warn "File not found: $file"
        return 1
    fi

    sudo sed -i "/^#ParallelDownloads/c\\ParallelDownloads = $value" "$file" || \
    sudo sed -i "/^ParallelDownloads/c\\ParallelDownloads = $value" "$file"
    
    log_success "ParallelDownloads set to $value"
}

# Download and replace pacman.conf
download_pacman_conf() {
    local source_url="$1"
    local backup_file="/etc/pacman.conf.backup-$(date +%Y%m%d-%H%M%S)"
    
    log_subsection "Downloading pacman configuration"
    
    # Backup current config
    if [[ -f /etc/pacman.conf ]]; then
        sudo cp /etc/pacman.conf "${backup_file}"
        log_info "Backup created: ${backup_file}"
    fi
    
    # Download new config
    if ! download_file "${source_url}" "/tmp/pacman.conf"; then
        log_warn "Failed to download pacman.conf"
        return 1
    fi
    
    # Verify download
    if [[ ! -f /tmp/pacman.conf ]] || [[ ! -s /tmp/pacman.conf ]]; then
        log_warn "Downloaded file is empty or missing"
        return 1
    fi
    
    # Replace config
    sudo mv /tmp/pacman.conf /etc/pacman.conf
    log_success "pacman.conf updated"
}

# Append repository to pacman.conf if not present
append_repo_to_pacman() {
    local repo_name="$1"
    local repo_config="$2"
    
    if grep -q "^\[${repo_name}\]" /etc/pacman.conf; then
        log_info "Repository '${repo_name}' already present in pacman.conf"
        return 0
    fi
    
    log_subsection "Adding '${repo_name}' repository to pacman.conf"
    printf '\n%s\n' "${repo_config}" | sudo tee -a /etc/pacman.conf >/dev/null
    log_success "Repository added"
}

# Remove repository from pacman.conf
remove_repo_from_pacman() {
    local repo_name="$1"
    
    if ! grep -q "^\[${repo_name}\]" /etc/pacman.conf; then
        log_info "Repository '${repo_name}' not found in pacman.conf"
        return 0
    fi
    
    log_subsection "Removing '${repo_name}' repository from pacman.conf"
    sudo sed -i "/^\[${repo_name}\]/,/^$/d" /etc/pacman.conf
    log_success "Repository removed"
}

# Refresh pacman keys and databases
refresh_pacman_keys() {
    log_subsection "Refreshing pacman keys and databases"
    
    sudo pacman-key --init || log_warn "Failed to init pacman keys"
    sudo pacman-key --populate || log_warn "Failed to populate pacman keys"
    sudo pacman -Sy || log_warn "Failed to refresh pacman databases"
    
    log_success "Pacman keys and databases refreshed"
}

# Clear pacman cache safely
clear_pacman_cache() {
    log_subsection "Clearing pacman cache"
    
    # Remove all packages from cache (keeps nothing)
    sudo pacman -Sc --noconfirm || log_warn "Failed to clean pacman cache"
    
    # Remove unneeded packages from cache
    sudo pacman -Scc --noconfirm || log_warn "Failed to remove unneeded packages"
    
    log_success "Pacman cache cleared"
}

# Fix broken pacman database
fix_pacman_database() {
    log_subsection "Fixing pacman database"
    
    # Remove corrupted sync databases
    log_info "Removing corrupted sync databases..."
    sudo rm -f /var/lib/pacman/sync/*.db /var/lib/pacman/sync/*.db.sig
    
    # Refresh databases
    log_info "Refreshing pacman databases..."
    sudo pacman -Sy || {
        log_warn "Failed to refresh databases"
        return 1
    }
    
    log_success "Pacman database fixed"
}

# Fix broken pacman GPG keys
fix_pacman_gpg() {
    log_subsection "Fixing pacman GPG configuration"
    
    # Backup existing gnupg directory
    if [[ -d /etc/pacman.d/gnupg ]]; then
        backup_folder_as_root /etc/pacman.d/gnupg /etc/pacman.d/gnupg.backup || true
        sudo rm -rf /etc/pacman.d/gnupg
    fi
    
    # Initialize new GPG keys
    log_info "Initializing pacman GPG keys..."
    sudo pacman-key --init || {
        log_warn "Failed to init GPG keys"
        return 1
    }
    
    log_info "Populating pacman GPG keys..."
    sudo pacman-key --populate || {
        log_warn "Failed to populate GPG keys"
        return 1
    }
    
    log_success "Pacman GPG configuration fixed"
}

##################################################################################################################################
# 12. Network and Connectivity Helpers
##################################################################################################################################

# Check if system has internet connectivity
check_connectivity() {
    local timeout=${1:-3}
    local test_host="${2:-8.8.8.8}"
    
    log_subsection "Checking internet connectivity"
    
    if ping -c 1 -W "${timeout}" "${test_host}" &>/dev/null; then
        log_success "Internet connection detected"
        return 0
    else
        log_warn "No internet connection detected"
        return 1
    fi
}

# Check if running on specific system type
check_system_type() {
    local sys_type="$1"  # nemesis, kiro, standard, etc.
    
    if [[ -f /etc/lsb-release ]]; then
        grep -q "DISTRIB_ID=${sys_type}" /etc/lsb-release
        return $?
    fi
    
    return 1
}

# Set DNS for connectivity issues
set_dns_servers() {
    local dns1="${1:-8.8.8.8}"
    local dns2="${2:-8.8.4.4}"
    
    log_subsection "Setting DNS servers: $dns1, $dns2"
    
    echo "nameserver ${dns1}" | sudo tee /etc/resolv.conf >/dev/null
    echo "nameserver ${dns2}" | sudo tee -a /etc/resolv.conf >/dev/null
    
    log_success "DNS servers configured"
}

##################################################################################################################################
# 13. Kernel and Performance Helpers
##################################################################################################################################

# Get number of CPU cores
get_cpu_cores() {
    nproc
}

# Set MAKEFLAGS for parallel compilation
set_makeflags() {
    local cores="${1:=$(get_cpu_cores)}"
    
    log_subsection "Setting MAKEFLAGS to -j${cores}"
    
    if [[ ! -d ~/.makepkg.d ]]; then
        mkdir -p ~/.makepkg.d
    fi
    
    echo "MAKEFLAGS=\"-j${cores}\"" >> ~/.makepkg.conf || \
        log_warn "Failed to set MAKEFLAGS in ~/.makepkg.conf"
    
    export MAKEFLAGS="-j${cores}"
    log_success "MAKEFLAGS set to -j${cores}"
}

# Get current Linux kernel info
get_kernel_info() {
    uname -r
}

# Check which GPU is present
get_gpu_type() {
    if lspci | grep -qi nvidia; then
        echo "nvidia"
    elif lspci | grep -qi amd; then
        echo "amd"
    elif lspci | grep -qi intel; then
        echo "intel"
    else
        echo "unknown"
    fi
}

##################################################################################################################################
# 14. System Utility Helpers
##################################################################################################################################

# Confirm before destructive operation
confirm_destructive_operation() {
    local operation="$1"
    
    if ! confirm_yes_no "Are you sure you want to ${operation}? This action cannot be undone."; then
        log_warn "Operation cancelled by user"
        return 1
    fi
    
    return 0
}

# Run a command with error checking
run_with_check() {
    local description="$1"
    shift
    local cmd=("$@")
    
    log_subsection "$description"
    
    if "${cmd[@]}"; then
        log_success "$description completed successfully"
        return 0
    else
        log_warn "$description failed with exit code $?"
        return 1
    fi
}

# Create system report
create_system_report() {
    local report_file="${1:-/tmp/edu-system-report-$(date +%Y%m%d-%H%M%S).txt}"
    
    log_subsection "Creating system report: $report_file"
    
    {
        echo "=== System Report ==="
        echo "Generated: $(date)"
        echo ""
        echo "=== System Information ==="
        uname -a
        echo ""
        echo "=== CPU Information ==="
        nproc
        echo ""
        echo "=== GPU Information ==="
        lspci | grep -i vga
        echo ""
        echo "=== Pacman Configuration ==="
        grep -v '^#' /etc/pacman.conf | grep -v '^$'
        echo ""
        echo "=== Installed Packages ==="
        pacman -Q | wc -l
        echo ""
        echo "=== System Mirrors ==="
        head -5 /etc/pacman.d/mirrorlist
    } | tee "${report_file}"
    
    log_success "System report created: ${report_file}"
}

##################################################################################################################################
# End of kiro-common.sh
##################################################################################################################################
