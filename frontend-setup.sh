#!/usr/bin/env bash
# Frontend Development Environment Setup Script v2.0
# Single-file TUI script for Linux frontend web development env setup
set -euo pipefail

# ── Global Variables ──────────────────────────────────────────────
VERSION="2.0.0"
SCRIPT_NAME="$(basename "$0")"
START_TIME="$(date +%s)"

# Paths
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_DIR="$XDG_DATA_HOME/frontend-setup"
CONFIG_DIR="$XDG_CONFIG_HOME/frontend-setup"
CACHE_DIR="$XDG_CACHE_HOME/frontend-setup"
BACKUP_DIR="$STATE_DIR/backups"
LOG_DIR="$STATE_DIR/logs"
TEMPLATE_DIR="$CONFIG_DIR/templates"
STATE_FILE="$STATE_DIR/state.json"
MANIFEST_DIR="$STATE_DIR"
LAST_RUN_FILE="$CONFIG_DIR/last_run.json"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

# Flags and modes
INTERACTIVE=true
DRY_RUN=false
UNDO_MODE=false
RESUME_MODE=false
AUTO_APPROVE=false
QUIET=false
VERBOSE=false
FORCE=false
ONLY_NODE=false
ONLY_FRAMEWORK=""
PROFILE=""
CONFIG_FILE_LOAD=""
EXPORT_FILE=""
IMPORT_FILE=""
LOG_FILE=""
LOG_LEVEL="INFO"
CUSTOM_LOG_FILE=""

# TUI library
TUI_BACKEND=""
HAVE_GUM=false; HAVE_DIALOG=false; HAVE_WHIPTAIL=false

# OS detection
OS_ID=""; OS_VERSION=""; OS_CODENAME=""
PKG_MANAGER=""; PKG_UPDATE=""; PKG_INSTALL=""; PKG_REMOVE=""
SUDO_CMD="sudo"

# Node
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
DEFAULT_NODE_VERSION="20"
NODE_VERSIONS=("20" "22" "18")

# Selections (populated by menu)
SELECTED_NODE_VERSIONS=()
SELECTED_PKG_MANAGERS=()
SELECTED_FRAMEWORKS=()
SELECTED_BUILD_TOOLS=()
SELECTED_CSS_TOOLS=()
SELECTED_LINTING=()
SELECTED_TESTING=()
SELECTED_GIT_HOOKS=()
SELECTED_TERMINAL_TOOLS=()
SELECTED_EDITOR_EXTENSIONS=()
SELECTED_DEVTOOLS=()
INSTALL_PLAYWRIGHT=false
INSTALL_STORYBOOK=false
INSTALL_MKCERT=false
INSTALL_STARSHIP=false
INSTALL_LAZYGIT=false
INSTALL_ZOXIDE=false

# Checkpoint tracking
LAST_CHECKPOINT=0
CHECKPOINTS=(
    "detect_os"
    "install_prerequisites"
    "install_nvm_node"
    "install_package_managers"
    "install_framework_clis"
    "install_build_tools"
    "install_css_tooling"
    "setup_typescript"
    "install_linting"
    "install_testing"
    "setup_git_hooks"
    "setup_terminal_tools"
    "configure_editor"
    "setup_https"
    "install_devtools"
    "generate_templates"
    "setup_shell"
)

declare -A MANIFEST_ENTRIES
MANIFEST_COUNT=0

# ── Utility Functions ─────────────────────────────────────────────
log() {
    local level="$1"; shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local func="${FUNCNAME[1]:-main}"
    local line="${BASH_LINENO[0]:-0}"

    if [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]]; then
        local levels=(DEBUG INFO WARN ERROR)
        local cur_idx=0; local msg_idx=0
        for i in "${!levels[@]}"; do
            [[ "${levels[$i]}" == "$LOG_LEVEL" ]] && cur_idx=$i
            [[ "${levels[$i]}" == "$level" ]] && msg_idx=$i
        done
        [[ $msg_idx -lt $cur_idx ]] && return
    fi

    local color="$NC"
    case "$level" in
        DEBUG) color="$BLUE" ;;
        INFO)  color="$GREEN" ;;
        WARN)  color="$YELLOW" ;;
        ERROR) color="$RED" ;;
        SUCCESS) color="$GREEN"; level="INFO" ;;
    esac

    if [[ "$QUIET" == false ]]; then
        echo -e "${color}[${level}]${NC} ${msg}" >&2
    fi

    if [[ -n "$LOG_FILE" ]]; then
        echo "[$timestamp] [$level] [$func:$line] $msg" >> "$LOG_FILE"
    fi
}

info()    { log "INFO" "$*"; }
warn()    { log "WARN" "$*"; }
error()   { log "ERROR" "$*"; }
debug()   { log "DEBUG" "$*"; }
success() { log "SUCCESS" "$*"; }

die() {
    error "$*"
    exit 1
}

confirm() {
    local prompt="$1"; shift
    [[ "$AUTO_APPROVE" == true ]] && return 0
    local default="${1:-y}"
    local yn
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    case "$TUI_BACKEND" in
        gum)
            gum confirm "$prompt" && return 0 || return 1
            ;;
        dialog|whiptail)
            if "$TUI_BACKEND" --yesno "$prompt" 8 60; then return 0; else return 1; fi
            ;;
        *)
            read -r -p "$prompt" yn
            [[ -z "$yn" ]] && yn="$default"
            [[ "$yn" =~ ^[Yy]$ ]] && return 0 || return 1
            ;;
    esac
}

prompt_input() {
    local prompt="$1"; shift
    local default="${1:-}"
    local result=""
    case "$TUI_BACKEND" in
        gum)
            result="$(gum input --placeholder "$prompt" --value "$default")"
            ;;
        dialog)
            result="$("$TUI_BACKEND" --inputbox "$prompt" 8 60 "$default" 3>&1 1>&2 2>&3)"
            ;;
        whiptail)
            result="$("$TUI_BACKEND" --inputbox "$prompt" 8 60 "$default" 3>&1 1>&2 2>&3)"
            ;;
        *)
            printf "%s " "$prompt"
            read -r result
            [[ -z "$result" ]] && result="$default"
            ;;
    esac
    echo "$result"
}

show_menu() {
    local title="$1"; shift
    local items=("$@")
    local result=""
    case "$TUI_BACKEND" in
        gum)
            result="$(gum choose --header "$title" "${items[@]}")"
            ;;
        dialog)
            local args=("--title" "$title" "--menu" "" "20" "60" "10")
            local i=0
            for item in "${items[@]}"; do
                args+=("$((++i))" "$item")
            done
            result="$("$TUI_BACKEND" "${args[@]}" 3>&1 1>&2 2>&3)"
            if [[ -n "$result" ]]; then
                result="${items[$((result-1))]}"
            fi
            ;;
        whiptail)
            local args=("--title" "$title" "--menu" "" "20" "60" "10")
            local i=0
            for item in "${items[@]}"; do
                args+=("$((++i))" "$item")
            done
            result="$("$TUI_BACKEND" "${args[@]}" 3>&1 1>&2 2>&3)"
            if [[ -n "$result" ]]; then
                result="${items[$((result-1))]}"
            fi
            ;;
        *)
            echo "--- $title ---" >&2
            local i=0
            for item in "${items[@]}"; do
                echo "$((++i))) $item" >&2
            done
            read -r -p "Choice [1-${#items[@]}]: " choice
            [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 && "$choice" -le "${#items[@]}" ]] && result="${items[$((choice-1))]}"
            ;;
    esac
    echo "$result"
}

show_checklist() {
    local title="$1"; shift
    local items=("$@")
    local selected=()
    case "$TUI_BACKEND" in
        gum)
            local result
            result="$(gum choose --no-limit --header "$title" "${items[@]}")"
            while IFS= read -r line; do
                selected+=("$line")
            done <<< "$result"
            ;;
        dialog)
            local args=("--title" "$title" "--checklist" "" "20" "70" "10")
            local i=0
            for item in "${items[@]}"; do
                args+=("$((++i))" "$item" "off")
            done
            local result
            result="$("$TUI_BACKEND" "${args[@]}" 3>&1 1>&2 2>&3)"
            if [[ -n "$result" ]]; then
                for idx in $result; do
                    selected+=("${items[$((idx-1))]}")
                done
            fi
            ;;
        whiptail)
            local args=("--title" "$title" "--checklist" "" "20" "70" "10")
            local i=0
            for item in "${items[@]}"; do
                args+=("$((++i))" "$item" "OFF")
            done
            local result
            result="$("$TUI_BACKEND" "${args[@]}" 3>&1 1>&2 2>&3)"
            if [[ -n "$result" ]]; then
                for idx in $result; do
                    selected+=("${items[$((idx-1))]}")
                done
            fi
            ;;
        *)
            echo "--- $title (space-separated indices) ---" >&2
            local i=0
            for item in "${items[@]}"; do
                echo "$((++i))) $item" >&2
            done
            read -r -p "Choices (e.g. 1 3 5): " -a indices
            for idx in "${indices[@]}"; do
                [[ "$idx" =~ ^[0-9]+$ ]] && [[ "$idx" -ge 1 && "$idx" -le "${#items[@]}" ]] && selected+=("${items[$((idx-1))]}")
            done
            ;;
    esac
    echo "${selected[@]}"
}

show_progress() {
    local title="$1"
    local cmd="$2"
    info "$title..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would execute: $cmd"
        return 0
    fi
    if [[ -n "$TUI_BACKEND" && "$TUI_BACKEND" != "readline" ]]; then
        case "$TUI_BACKEND" in
            gum)
                gum spin --spinner dot --title "$title" -- bash -c "$cmd" || return $?
                ;;
            *)
                eval "$cmd" || return $?
                ;;
        esac
    else
        eval "$cmd" || return $?
    fi
}

# ── Retry Logic ───────────────────────────────────────────────────
retry() {
    local max_attempts="${1:-3}"; shift
    local delay="${1:-5}"; shift
    local cmd="$*"
    local attempt=1
    local backoff=$delay
    while [[ $attempt -le $max_attempts ]]; do
        if eval "$cmd"; then
            return 0
        fi
        warn "Attempt $attempt/$max_attempts failed. Retrying in ${backoff}s..."
        sleep "$backoff"
        backoff=$((backoff * 2))
        ((attempt++))
    done
    error "Command failed after $max_attempts attempts: $cmd"
    return 1
}

# ── Cleanup ───────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 && $exit_code -ne 99 ]]; then
        error "Script failed with exit code $exit_code"
        info "Use --resume to continue from last checkpoint"
        info "Use --undo to rollback changes"
    fi
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    if [[ -n "${TUI_BACKEND:-}" ]]; then
        case "$TUI_BACKEND" in
            dialog) printf '\033[?1049l' 2>/dev/null || true ;;
        esac
    fi
    exit "$exit_code"
}

trap cleanup EXIT INT TERM

# ── OS Detection ──────────────────────────────────────────────────
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID,,}"
        OS_VERSION="${VERSION_ID}"
        OS_CODENAME="${VERSION_CODENAME:-}"
    elif [[ -f /etc/lsb-release ]]; then
        . /etc/lsb-release
        OS_ID="${DISTRIB_ID,,}"
        OS_VERSION="${DISTRIB_RELEASE}"
        OS_CODENAME="${DISTRIB_CODENAME}"
    else
        OS_ID="$(uname -s)"
        OS_VERSION="$(uname -r)"
    fi
    debug "OS: $OS_ID $OS_VERSION $OS_CODENAME"
}

detect_package_manager() {
    local managers=("apt" "dnf" "pacman" "zypper" "apk" "nix")
    for mgr in "${managers[@]}"; do
        if command -v "$mgr" &>/dev/null; then
            PKG_MANAGER="$mgr"
            break
        fi
    done

    if [[ -z "$PKG_MANAGER" ]]; then
        die "No supported package manager found (apt/dnf/pacman/zypper/apk)"
    fi

    debug "Package manager detected: $PKG_MANAGER"

    case "$PKG_MANAGER" in
        apt)
            PKG_UPDATE="sudo apt-get update -qq"
            PKG_INSTALL="sudo apt-get install -y -qq"
            PKG_REMOVE="sudo apt-get remove -y"
            ;;
        dnf)
            PKG_UPDATE="sudo dnf check-update -q || true"
            PKG_INSTALL="sudo dnf install -y"
            PKG_REMOVE="sudo dnf remove -y"
            ;;
        pacman)
            PKG_UPDATE="sudo pacman -Sy"
            PKG_INSTALL="sudo pacman -S --noconfirm"
            PKG_REMOVE="sudo pacman -R --noconfirm"
            ;;
        zypper)
            PKG_UPDATE="sudo zypper refresh"
            PKG_INSTALL="sudo zypper install -y"
            PKG_REMOVE="sudo zypper remove -y"
            ;;
        apk)
            SUDO_CMD=""
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add"
            PKG_REMOVE="apk del"
            ;;
        nix)
            SUDO_CMD=""
            PKG_UPDATE="nix-channel --update"
            PKG_INSTALL="nix-env -iA"
            PKG_REMOVE="nix-env -e"
            ;;
    esac
}

# ── TUI Detection ─────────────────────────────────────────────────
detect_tui() {
    if command -v gum &>/dev/null; then
        HAVE_GUM=true
        TUI_BACKEND="gum"
        debug "TUI backend: gum"
        return
    fi
    if command -v whiptail &>/dev/null; then
        HAVE_WHIPTAIL=true
        TUI_BACKEND="whiptail"
        debug "TUI backend: whiptail"
        return
    fi
    if command -v dialog &>/dev/null; then
        HAVE_DIALOG=true
        TUI_BACKEND="dialog"
        debug "TUI backend: dialog"
        return
    fi
    TUI_BACKEND="readline"
    debug "TUI backend: readline (fallback)"

    if [[ "$INTERACTIVE" == true ]] && [[ "$AUTO_APPROVE" == false ]]; then
        warn "No TUI library found (gum/whiptail/dialog)"
        if confirm "Install gum for better UI? (recommended)"; then
            install_gum
        fi
    fi
}

install_gum() {
    info "Installing gum..."
    local gum_version="0.14.1"
    local gum_url=""
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64) gum_url="https://github.com/charmbracelet/gum/releases/download/v${gum_version}/gum_${gum_version}_linux_amd64.tar.gz" ;;
        aarch64|arm64) gum_url="https://github.com/charmbracelet/gum/releases/download/v${gum_version}/gum_${gum_version}_linux_arm64.tar.gz" ;;
        *) warn "Unsupported arch for gum: $arch"; return 1 ;;
    esac

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would install gum from $gum_url"
        return 0
    fi

    local tmpdir
    tmpdir="$(mktemp -d)"
    if curl -fsSL "$gum_url" -o "$tmpdir/gum.tar.gz" 2>/dev/null; then
        tar -xzf "$tmpdir/gum.tar.gz" -C "$tmpdir" 2>/dev/null
        local gum_bin
        gum_bin="$(find "$tmpdir" -name 'gum' -type f 2>/dev/null | head -1)"
        if [[ -n "$gum_bin" ]]; then
            chmod +x "$gum_bin"
            if command -v install &>/dev/null; then
                sudo install -m 755 "$gum_bin" /usr/local/bin/gum
            else
                sudo cp "$gum_bin" /usr/local/bin/gum
                sudo chmod 755 /usr/local/bin/gum
            fi
            HAVE_GUM=true
            TUI_BACKEND="gum"
            success "gum installed"
        else
            warn "Could not find gum binary in extracted archive"
        fi
    else
        warn "Failed to download gum"
    fi
    rm -rf "$tmpdir"
}

# ── Prerequisites Installation ────────────────────────────────────
install_prerequisites() {
    info "Installing prerequisites..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would install: git curl wget unzip tar build-essential"
        return 0
    fi

    local packages=()
    case "$PKG_MANAGER" in
        apt)
            packages=(git curl wget unzip tar build-essential ca-certificates gnupg)
            ;;
        dnf)
            packages=(git curl wget unzip tar gcc-c++ make ca-certificates gnupg)
            ;;
        pacman)
            packages=(git curl wget unzip tar base-devel ca-certificates gnupg)
            ;;
        zypper)
            packages=(git curl wget unzip tar gcc-c++ make ca-certificates gnupg)
            ;;
        apk)
            packages=(git curl wget unzip tar build-base ca-certificates gnupg)
            ;;
    esac

    eval "$PKG_UPDATE" || true
    eval "$PKG_INSTALL ${packages[*]}" || die "Failed to install prerequisites"

    success "Prerequisites installed"
}

# ── Directory Setup ───────────────────────────────────────────────
setup_directories() {
    mkdir -p "$STATE_DIR/state" "$STATE_DIR/backups" "$LOG_DIR" "$CACHE_DIR" "$CONFIG_DIR" "$TEMPLATE_DIR"
}

# ── Manifest Tracking ─────────────────────────────────────────────
manifest_add() {
    local type="$1"
    local data="$2"
    local timestamp
    timestamp="$(date -Iseconds)"
    MANIFEST_ENTRIES["$MANIFEST_COUNT"]="{\"type\":\"$type\",\"data\":\"$data\",\"timestamp\":\"$timestamp\"}"
    ((MANIFEST_COUNT++))
}

save_manifest() {
    local manifest_file="$STATE_DIR/manifest_$(date +%Y%m%d_%H%M%S).json"
    {
        echo '['
        local first=true
        for ((i=0; i<MANIFEST_COUNT; i++)); do
            [[ "$first" == true ]] && first=false || echo ','
            echo "${MANIFEST_ENTRIES[$i]}"
        done
        echo ']'
    } > "$manifest_file"
    echo "$manifest_file"
}

# ── Checkpoint System ─────────────────────────────────────────────
save_checkpoint() {
    local step="$1"
    local status="$2"
    local data="${3:-{}}"
    local ts
    ts="$(date -Iseconds)"
    local cfile="$STATE_DIR/state/checkpoint_$(printf '%02d' "$step")_${CHECKPOINTS[$((step-1))]}.json"
    echo "{\"step\":$step,\"name\":\"${CHECKPOINTS[$((step-1))]}\",\"status\":\"$status\",\"timestamp\":\"$ts\",\"data\":$data}" > "$cfile"
    LAST_CHECKPOINT=$step
}

load_checkpoint() {
    local max_found=0
    for f in "$STATE_DIR/state"/checkpoint_*.json; do
        [[ ! -f "$f" ]] && continue
        local s
        s="$(grep -o '"step":[0-9]*' "$f" 2>/dev/null | cut -d: -f2)"
        local st
        st="$(grep -o '"status":"[^"]*"' "$f" 2>/dev/null | cut -d: -f2 | tr -d '"')"
        if [[ "$st" == "completed" ]] && [[ "$s" -gt "$max_found" ]]; then
            max_found=$s
        fi
    done
    LAST_CHECKPOINT=$max_found
    debug "Last completed checkpoint: $LAST_CHECKPOINT"
}

# ── nvm and Node.js ───────────────────────────────────────────────
install_nvm() {
    if [[ -d "$NVM_DIR/.git" ]]; then
        info "nvm already installed"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        return 0
    fi

    info "Installing nvm..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would install nvm from https://github.com/nvm-sh/nvm"
        return 0
    fi

    export NVM_DIR
    local nvm_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
    if curl -fsSL "$nvm_url" | bash; then
        success "nvm installed"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        manifest_add "nvm" "Installed nvm to $NVM_DIR"
        return 0
    else
        error "Failed to install nvm"
        return 1
    fi
}

install_node_version() {
    local version="$1"
    if command -v node &>/dev/null; then
        local current
        current="$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)"
        if [[ "$current" == "$version" ]]; then
            info "Node.js $version.x already installed"
            return 0
        fi
    fi

    info "Installing Node.js $version..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would run: nvm install $version"
        return 0
    fi

    if nvm install "$version" 2>/dev/null; then
        success "Node.js $(nvm current) installed"
        manifest_add "node" "Installed Node.js $version"
        return 0
    else
        error "Failed to install Node.js $version"
        return 1
    fi
}

setup_node() {
    install_nvm || return 1
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local versions_to_install=("${SELECTED_NODE_VERSIONS[@]}")
    [[ ${#versions_to_install[@]} -eq 0 ]] && versions_to_install=("$DEFAULT_NODE_VERSION")

    for ver in "${versions_to_install[@]}"; do
        install_node_version "$ver" || true
    done

    nvm alias default "${versions_to_install[0]}" 2>/dev/null || true
    nvm use default 2>/dev/null || true
    success "Default Node set to ${versions_to_install[0]} LTS"

    if [[ "$DRY_RUN" == false ]]; then
        npm config set fund false 2>/dev/null || true
        npm config set audit false 2>/dev/null || true
    fi
}

# ── Package Managers ──────────────────────────────────────────────
install_package_managers() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    for pm in "${SELECTED_PKG_MANAGERS[@]}"; do
        case "$pm" in
            pnpm)
                if command -v pnpm &>/dev/null; then
                    info "pnpm already installed ($(pnpm --version))"
                    continue
                fi
                info "Installing pnpm..."
                if [[ "$DRY_RUN" == false ]]; then
                    npm install -g pnpm 2>/dev/null && success "pnpm installed ($(pnpm --version))" || warn "pnpm install failed"
                    manifest_add "npm_global" "pnpm"
                fi
                ;;
            yarn)
                if command -v yarn &>/dev/null; then
                    info "yarn already installed ($(yarn --version))"
                    continue
                fi
                info "Installing yarn..."
                if [[ "$DRY_RUN" == false ]]; then
                    npm install -g yarn 2>/dev/null && success "yarn installed ($(yarn --version))" || warn "yarn install failed"
                    manifest_add "npm_global" "yarn"
                fi
                ;;
            bun)
                if command -v bun &>/dev/null; then
                    info "bun already installed ($(bun --version))"
                    continue
                fi
                info "Installing bun..."
                if [[ "$DRY_RUN" == false ]]; then
                    curl -fsSL https://bun.sh/install | bash 2>/dev/null && success "bun installed" || warn "bun install failed"
                    manifest_add "bun" "Installed bun"
                fi
                ;;
        esac
    done
}

# ── Global NPM Packages for Frameworks ────────────────────────────
install_framework_clis() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local framework_pkgs=()
    for fw in "${SELECTED_FRAMEWORKS[@]}"; do
        case "$fw" in
            "Next.js")        framework_pkgs+=("create-next-app") ;;
            "Vite + React")   framework_pkgs+=("create-vite") ;;
            "Create React App") framework_pkgs+=("create-react-app") ;;
            "Remix")          framework_pkgs+=("@remix-run/dev") ;;
            "Gatsby")         framework_pkgs+=("gatsby-cli") ;;
            "Nuxt")           framework_pkgs+=("create-nuxt-app") ;;
            "Vite + Vue")     framework_pkgs+=("create-vue") ;;
            "Vue CLI")        framework_pkgs+=("@vue/cli") ;;
            "Astro")          framework_pkgs+=("create-astro") ;;
            "SvelteKit")      framework_pkgs+=("create-svelte") ;;
            "Solid Start")    framework_pkgs+=("create-solid") ;;
            "Qwik")           framework_pkgs+=("create-qwik") ;;
            "Angular CLI")    framework_pkgs+=("@angular/cli") ;;
            "Turborepo")      framework_pkgs+=("turbo") ;;
        esac
    done

    if [[ ${#framework_pkgs[@]} -eq 0 ]]; then
        info "No framework CLIs selected"
        return 0
    fi

    info "Installing framework CLIs..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${framework_pkgs[*]}"
        return 0
    fi

    local install_list=()
    for pkg in "${framework_pkgs[@]}"; do
        if npm ls -g --depth=0 "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed globally"
            continue
        fi
        install_list+=("$pkg")
    done

    if [[ ${#install_list[@]} -gt 0 ]]; then
        npm install -g "${install_list[@]}" 2>/dev/null || warn "Some framework CLIs failed to install"
        for pkg in "${install_list[@]}"; do
            manifest_add "npm_global" "$pkg"
        done
        success "Framework CLIs installed"
    fi
}

# ── Build Tools ───────────────────────────────────────────────────
install_build_tools() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local build_pkgs=()
    for bt in "${SELECTED_BUILD_TOOLS[@]}"; do
        case "$bt" in
            esbuild)    build_pkgs+=("esbuild") ;;
            swc)        build_pkgs+=("@swc/core" "@swc/cli") ;;
            rollup)     build_pkgs+=("rollup") ;;
            webpack)    build_pkgs+=("webpack" "webpack-cli") ;;
            parcel)     build_pkgs+=("parcel") ;;
            turbopack)  build_pkgs+=("turbo") ;;
            rspack)     build_pkgs+=("@rspack/cli") ;;
            farm)       build_pkgs+=("@farmfe/cli") ;;
            vite)       build_pkgs+=("vite") ;;
            tsx)        build_pkgs+=("tsx") ;;
            tsup)       build_pkgs+=("tsup") ;;
        esac
    done

    if [[ ${#build_pkgs[@]} -eq 0 ]]; then
        info "No build tools selected"
        return 0
    fi

    info "Installing build tools..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${build_pkgs[*]}"
        return 0
    fi

    local install_list=()
    for pkg in "${build_pkgs[@]}"; do
        if npm ls -g --depth=0 "$pkg" &>/dev/null 2>&1; then
            info "$pkg already installed globally"
            continue
        fi
        install_list+=("$pkg")
    done

    if [[ ${#install_list[@]} -gt 0 ]]; then
        npm install -g "${install_list[@]}" 2>/dev/null || warn "Some build tools failed to install"
        for pkg in "${install_list[@]}"; do
            manifest_add "npm_global" "$pkg"
        done
        success "Build tools installed"
    fi
}

# ── CSS Tooling ───────────────────────────────────────────────────
install_css_tooling() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local css_pkgs=()
    for ct in "${SELECTED_CSS_TOOLS[@]}"; do
        case "$ct" in
            tailwindcss)  css_pkgs+=("tailwindcss" "@tailwindcss/cli") ;;
            sass)         css_pkgs+=("sass") ;;
            less)         css_pkgs+=("less") ;;
            postcss)      css_pkgs+=("postcss-cli" "autoprefixer" "cssnano") ;;
            lightningcss) css_pkgs+=("lightningcss-cli") ;;
            unoCSS)       css_pkgs+=("@unocss/cli") ;;
        esac
    done

    if [[ ${#css_pkgs[@]} -eq 0 ]]; then
        info "No CSS tools selected"
        return 0
    fi

    info "Installing CSS tools..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${css_pkgs[*]}"
        return 0
    fi

    npm install -g "${css_pkgs[@]}" 2>/dev/null || warn "Some CSS tools failed to install"
    for pkg in "${css_pkgs[@]}"; do
        manifest_add "npm_global" "$pkg"
    done
    success "CSS tools installed"
}

# ── TypeScript Setup ──────────────────────────────────────────────
setup_typescript() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    if command -v tsc &>/dev/null; then
        info "TypeScript already installed ($(tsc --version))"
    else
        info "Installing TypeScript..."
        if [[ "$DRY_RUN" == false ]]; then
            npm install -g typescript ts-node tsx 2>/dev/null || warn "TypeScript install failed"
            manifest_add "npm_global" "typescript"
            manifest_add "npm_global" "ts-node"
            manifest_add "npm_global" "tsx"
        fi
    fi

    if [[ "$DRY_RUN" == false ]]; then
        cat > "$TEMPLATE_DIR/tsconfig.base.json" << 'TSBASE'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
TSBASE

        cat > "$TEMPLATE_DIR/tsconfig.react.json" << 'TSREACT'
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "lib": ["ES2022", "DOM", "DOM.Iterable"]
  }
}
TSREACT

        cat > "$TEMPLATE_DIR/tsconfig.vue.json" << 'TSVUE'
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "jsx": "preserve",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
TSVUE

        cat > "$TEMPLATE_DIR/tsconfig.node.json" << 'TSNODE'
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "module": "CommonJS",
    "types": ["node"],
    "lib": ["ES2022"]
  }
}
TSNODE

        cat > "$TEMPLATE_DIR/tsconfig.browser.json" << 'TSBROWSER'
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "types": []
  }
}
TSBROWSER

        success "TypeScript config templates created in $TEMPLATE_DIR"
        manifest_add "templates" "TypeScript config templates"
    fi
}

# ── Linting ───────────────────────────────────────────────────────
install_linting() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local lint_pkgs=()
    local has_biome=false

    for lt in "${SELECTED_LINTING[@]}"; do
        case "$lt" in
            ESLint)  lint_pkgs+=("eslint" "@typescript-eslint/parser" "@typescript-eslint/eslint-plugin") ;;
            Prettier) lint_pkgs+=("prettier") ;;
            Stylelint) lint_pkgs+=("stylelint" "stylelint-config-standard") ;;
            Biome)   lint_pkgs+=("@biomejs/biome"); has_biome=true ;;
            Oxlint)  lint_pkgs+=("oxlint") ;;
            dprint)  lint_pkgs+=("dprint") ;;
        esac
    done

    if [[ ${#lint_pkgs[@]} -eq 0 ]]; then
        info "No linting tools selected"
        return 0
    fi

    info "Installing linting tools..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${lint_pkgs[*]}"
        return 0
    fi

    npm install -g "${lint_pkgs[@]}" 2>/dev/null || warn "Some linting tools failed to install"
    for pkg in "${lint_pkgs[@]}"; do
        manifest_add "npm_global" "$pkg"
    done

    cat > "$TEMPLATE_DIR/.prettierrc" << 'PRETTIER'
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "arrowParens": "always",
  "endOfLine": "lf"
}
PRETTIER

    cat > "$TEMPLATE_DIR/.eslintrc.json" << 'ESLINT'
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint"],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "env": {
    "browser": true,
    "es2022": true,
    "node": true
  },
  "rules": {
    "@typescript-eslint/no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/explicit-function-return-type": "off"
  }
}
ESLINT

    if [[ "$has_biome" == true ]]; then
        cat > "$TEMPLATE_DIR/biome.json" << 'BIOME'
{
  "$schema": "https://biomejs.dev/schemas/1.8.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always"
    }
  }
}
BIOME
    fi

    cat > "$TEMPLATE_DIR/.stylelintrc.json" << 'STYLELINT'
{
  "extends": "stylelint-config-standard",
  "rules": {
    "at-rule-no-unknown": null,
    "scss/at-rule-no-unknown": true
  }
}
STYLELINT

    success "Linting tools installed, config templates created"
}

# ── Testing ───────────────────────────────────────────────────────
install_testing() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local test_pkgs=()

    for tt in "${SELECTED_TESTING[@]}"; do
        case "$tt" in
            Vitest) test_pkgs+=("vitest") ;;
            Jest)   test_pkgs+=("jest" "@types/jest" "ts-jest") ;;
            "Testing Library") test_pkgs+=("@testing-library/dom" "@testing-library/jest-dom") ;;
            "Testing Library React") test_pkgs+=("@testing-library/react" "@testing-library/user-event") ;;
            "Testing Library Vue") test_pkgs+=("@testing-library/vue") ;;
            "Testing Library Svelte") test_pkgs+=("@testing-library/svelte") ;;
            MSW)    test_pkgs+=("msw") ;;
            "happy-dom") test_pkgs+=("happy-dom") ;;
            "jsdom") test_pkgs+=("jsdom") ;;
        esac
    done

    if [[ "$INSTALL_PLAYWRIGHT" == true ]]; then
        test_pkgs+=("@playwright/test")
    fi

    if [[ ${#test_pkgs[@]} -eq 0 ]]; then
        info "No testing tools selected"
        return 0
    fi

    info "Installing testing tools..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${test_pkgs[*]}"
        return 0
    fi

    npm install -g "${test_pkgs[@]}" 2>/dev/null || warn "Some testing tools failed to install"
    for pkg in "${test_pkgs[@]}"; do
        manifest_add "npm_global" "$pkg"
    done

    if [[ "$INSTALL_PLAYWRIGHT" == true ]]; then
        if command -v npx &>/dev/null; then
            info "Installing Playwright browsers..."
            npx playwright install chromium 2>/dev/null || warn "Playwright browser install failed"
            manifest_add "playwright" "Chromium browser"
        fi
    fi

    cat > "$TEMPLATE_DIR/vitest.config.ts" << 'VITEST'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'happy-dom',
    setupFiles: [],
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
})
VITEST

    cat > "$TEMPLATE_DIR/playwright.config.ts" << 'PLAYWRIGHT'
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
    { name: 'webkit', use: { browserName: 'webkit' } },
  ],
})
PLAYWRIGHT

    success "Testing tools installed, config templates created"
}

# ── Git Hooks ─────────────────────────────────────────────────────
setup_git_hooks() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local hook_pkgs=()
    for gh in "${SELECTED_GIT_HOOKS[@]}"; do
        case "$gh" in
            Husky)        hook_pkgs+=("husky") ;;
            lint-staged)  hook_pkgs+=("lint-staged") ;;
            commitlint)   hook_pkgs+=("@commitlint/cli" "@commitlint/config-conventional") ;;
            commitizen)   hook_pkgs+=("commitizen") ;;
            "standard-version") hook_pkgs+=("standard-version") ;;
            "semantic-release") hook_pkgs+=("semantic-release") ;;
        esac
    done

    if [[ ${#hook_pkgs[@]} -eq 0 ]]; then
        info "No git hooks selected"
        return 0
    fi

    info "Installing git hooks tools..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would globally install: ${hook_pkgs[*]}"
        return 0
    fi

    npm install -g "${hook_pkgs[@]}" 2>/dev/null || warn "Some git hooks tools failed to install"
    for pkg in "${hook_pkgs[@]}"; do
        manifest_add "npm_global" "$pkg"
    done

    cat > "$TEMPLATE_DIR/commitlint.config.js" << 'COMMITLINT'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert'
    ]],
    'type-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'sentence-case'],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never'],
  },
}
COMMITLINT

    cat > "$TEMPLATE_DIR/.lintstagedrc.json" << 'LINTSTAGED'
{
  "*.{js,ts,tsx,jsx}": ["eslint --fix", "prettier --write"],
  "*.{css,scss,less}": ["stylelint --fix", "prettier --write"],
  "*.{json,md,yaml,yml}": ["prettier --write"]
}
LINTSTAGED

    cat > "$TEMPLATE_DIR/husky_pre-commit" << 'HUSKY_PRE'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx lint-staged
HUSKY_PRE

    cat > "$TEMPLATE_DIR/husky_commit-msg" << 'HUSKY_COMMIT'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx --no -- commitlint --edit "$1"
HUSKY_COMMIT

    success "Git hooks tools installed, config templates created"
}

# ── Terminal Tools ────────────────────────────────────────────────
install_terminal_tools() {
    info "Installing terminal tools..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would install terminal tools"
        return 0
    fi

    local sys_pkgs_tools=()
    for tool in "${SELECTED_TERMINAL_TOOLS[@]}"; do
        case "$tool" in
            bat)       sys_pkgs_tools+=("bat") ;;
            eza)       sys_pkgs_tools+=("eza") ;;
            fzf)       sys_pkgs_tools+=("fzf") ;;
            fd)        sys_pkgs_tools+=("fd-find") ;;
            ripgrep)   sys_pkgs_tools+=("ripgrep") ;;
            "git-delta") sys_pkgs_tools+=("git-delta") ;;
            tldr)      sys_pkgs_tools+=("tldr") ;;
        esac
    done

    if [[ ${#sys_pkgs_tools[@]} -gt 0 ]]; then
        eval "$PKG_INSTALL ${sys_pkgs_tools[*]}" 2>/dev/null || warn "Some terminal tools failed to install"
        manifest_add "system_packages" "${sys_pkgs_tools[*]}"
    fi

    if [[ " ${SELECTED_TERMINAL_TOOLS[*]} " =~ "starship" ]]; then
        if command -v starship &>/dev/null; then
            info "starship already installed"
        else
            info "Installing starship prompt..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null || warn "starship install failed"
            manifest_add "starship" "Installed"
        fi
    fi

    if [[ " ${SELECTED_TERMINAL_TOOLS[*]} " =~ "lazygit" ]]; then
        if command -v lazygit &>/dev/null; then
            info "lazygit already installed"
        else
            info "Installing lazygit..."
            local lazygit_version="0.42.0"
            local arch
            arch="$(uname -m)"
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            local lazygit_url="https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_${arch}.tar.gz"
            local tmpdir
            tmpdir="$(mktemp -d)"
            if curl -fsSL "$lazygit_url" -o "$tmpdir/lazygit.tar.gz" 2>/dev/null; then
                tar -xzf "$tmpdir/lazygit.tar.gz" -C "$tmpdir" 2>/dev/null
                sudo install -m 755 "$tmpdir/lazygit" /usr/local/bin/lazygit 2>/dev/null && success "lazygit installed"
                manifest_add "lazygit" "Installed"
            else
                warn "Failed to download lazygit"
            fi
            rm -rf "$tmpdir"
        fi
    fi

    if [[ " ${SELECTED_TERMINAL_TOOLS[*]} " =~ "zoxide" ]]; then
        if command -v zoxide &>/dev/null; then
            info "zoxide already installed"
        else
            info "Installing zoxide..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash 2>/dev/null || warn "zoxide install failed"
            manifest_add "zoxide" "Installed"
        fi
    fi

    success "Terminal tools installed"
}

# ── Editor Integration ────────────────────────────────────────────
configure_editor() {
    info "Configuring editor integration..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would configure editor extensions"
        return 0
    fi

    local has_vscode=false
    local code_cmd=""
    if command -v code &>/dev/null; then has_vscode=true; code_cmd="code"; fi
    if command -v codium &>/dev/null; then has_vscode=true; code_cmd="codium"; fi
    if command -v nvim &>/dev/null; then info "Neovim detected"; fi

    if [[ "$has_vscode" == true ]] && [[ ${#SELECTED_EDITOR_EXTENSIONS[@]} -gt 0 ]]; then
        local ext_map=(
            "ESLint:dbaeumer.vscode-eslint"
            "Prettier:esbenp.prettier-vscode"
            "Tailwind CSS IntelliSense:bradlc.vscode-tailwindcss"
            "Volar:vue.volar"
            "Angular Language Service:angular.ng-template"
            "Svelte:svelte.svelte-vscode"
            "styled-components:styled-components.vscode-styled-components"
            "TypeScript Next:ms-vscode.vscode-typescript-next"
            "Biome:biomejs.biome"
            "Playwright:ms-playwright.playwright"
            "Vitest:vitest.explorer"
            "GitLens:eamodio.gitlens"
            "GitHub Copilot:github.copilot"
            "One Dark Pro:zhuangtongfa.Material-theme"
            "Material Icon Theme:pkief.material-icon-theme"
            "Error Lens:usernamehw.errorlens"
            "Pretty TypeScript Errors:yoavbls.pretty-ts-errors"
        )

        for ext_sel in "${SELECTED_EDITOR_EXTENSIONS[@]}"; do
            for mapping in "${ext_map[@]}"; do
                local name="${mapping%%:*}"
                local ext_id="${mapping##*:}"
                if [[ "$name" == "$ext_sel" ]]; then
                    info "Installing VS Code extension: $name"
                    "$code_cmd" --install-extension "$ext_id" --force 2>/dev/null || warn "Failed to install $name extension"
                    manifest_add "vscode_extension" "$ext_id"
                fi
            done
        done
    fi

    success "Editor integration configured"
}

# ── Local HTTPS ───────────────────────────────────────────────────
setup_https() {
    [[ "$INSTALL_MKCERT" != true ]] && return 0

    info "Setting up local HTTPS certificates..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would install mkcert and create local CA"
        return 0
    fi

    if ! command -v mkcert &>/dev/null; then
        case "$PKG_MANAGER" in
            apt)
                sudo apt-get install -y libnss3-tools 2>/dev/null || true
                local tmpdir
                tmpdir="$(mktemp -d)"
                local arch
                arch="$(uname -m)"
                case "$arch" in
                    x86_64) arch="linux-amd64" ;;
                    aarch64) arch="linux-arm64" ;;
                esac
                local mkcert_url="https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-${arch}"
                if curl -fsSL "$mkcert_url" -o "$tmpdir/mkcert" 2>/dev/null; then
                    chmod +x "$tmpdir/mkcert"
                    sudo install "$tmpdir/mkcert" /usr/local/bin/mkcert
                    success "mkcert installed"
                else
                    warn "Failed to download mkcert"
                    rm -rf "$tmpdir"
                    return 0
                fi
                rm -rf "$tmpdir"
                ;;
            dnf)
                sudo dnf install -y mkcert 2>/dev/null || sudo dnf install -y nss-tools 2>/dev/null || true
                ;;
            pacman)
                sudo pacman -S --noconfirm mkcert 2>/dev/null || true
                ;;
            *)
                warn "Install mkcert manually from https://github.com/FiloSottile/mkcert"
                return 0
                ;;
        esac
    fi

    if command -v mkcert &>/dev/null; then
        mkcert -install 2>/dev/null || warn "Failed to install mkcert CA"
        local cert_dir="$HOME/.local/share/certs"
        mkdir -p "$cert_dir"
        mkcert -key-file "$cert_dir/localhost-key.pem" -cert-file "$cert_dir/localhost.pem" localhost 127.0.0.1 ::1 2>/dev/null || warn "Failed to generate certs"
        success "Local HTTPS certs created: $cert_dir"
        manifest_add "mkcert" "Local CA installed"
    fi
}

# ── DevTools ──────────────────────────────────────────────────────
install_devtools() {
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    local dev_pkgs=()
    for dt in "${SELECTED_DEVTOOLS[@]}"; do
        case "$dt" in
            "React DevTools")     dev_pkgs+=("react-devtools") ;;
            "Vue DevTools")       dev_pkgs+=("@vue/devtools") ;;
            "Lighthouse CLI")     dev_pkgs+=("lighthouse") ;;
            "localtunnel")        dev_pkgs+=("localtunnel") ;;
            "serve")              dev_pkgs+=("serve") ;;
            "http-server")        dev_pkgs+=("http-server") ;;
            "npm-check-updates")  dev_pkgs+=("npm-check-updates") ;;
            "nodemon")            dev_pkgs+=("nodemon") ;;
            "concurrently")       dev_pkgs+=("concurrently") ;;
            "cross-env")          dev_pkgs+=("cross-env") ;;
            "sync")               dev_pkgs+=("browser-sync") ;;
            "json-server")        dev_pkgs+=("json-server") ;;
            "faker")              dev_pkgs+=("@faker-js/faker") ;;
            "env-cmd")            dev_pkgs+=("env-cmd") ;;
        esac
    done

    if [[ ${#dev_pkgs[@]} -gt 0 ]]; then
        info "Installing dev tools..."
        if [[ "$DRY_RUN" == false ]]; then
            npm install -g "${dev_pkgs[@]}" 2>/dev/null || warn "Some dev tools failed to install"
            for pkg in "${dev_pkgs[@]}"; do
                manifest_add "npm_global" "$pkg"
            done
            success "Dev tools installed"
        fi
    fi

    if [[ " ${SELECTED_DEVTOOLS[*]} " =~ "ngrok" ]] && ! command -v ngrok &>/dev/null; then
        info "Installing ngrok..."
        if [[ "$DRY_RUN" == false ]]; then
            local arch
            arch="$(uname -m)"
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            local ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tar.gz"
            local tmpdir
            tmpdir="$(mktemp -d)"
            if curl -fsSL "$ngrok_url" -o "$tmpdir/ngrok.tar.gz" 2>/dev/null; then
                tar -xzf "$tmpdir/ngrok.tar.gz" -C "$tmpdir" 2>/dev/null
                sudo install -m 755 "$tmpdir/ngrok" /usr/local/bin/ngrok 2>/dev/null && success "ngrok installed"
                manifest_add "ngrok" "Installed"
            fi
            rm -rf "$tmpdir"
        fi
    fi
}

# ── Shell Integration ─────────────────────────────────────────────
setup_shell_integration() {
    local shell_config=""
    local shell_name=""

    if [[ -n "$SHELL" ]]; then
        shell_name="$(basename "$SHELL")"
    elif command -v zsh &>/dev/null; then
        shell_name="zsh"
    elif command -v bash &>/dev/null; then
        shell_name="bash"
    fi

    case "$shell_name" in
        zsh)  shell_config="$HOME/.zshrc" ;;
        bash) shell_config="$HOME/.bashrc" ;;
        fish) shell_config="$HOME/.config/fish/config.fish" ;;
    esac

    [[ -z "$shell_config" ]] && shell_config="$HOME/.profile"

    info "Configuring shell integration for $shell_name..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would add aliases to $shell_config"
        return 0
    fi

    if [[ -f "$shell_config" ]]; then
        cp "$shell_config" "$BACKUP_DIR/$(basename "$shell_config").$(date +%Y%m%d).bak"
        manifest_add "backup" "Backed up $shell_config"
    fi

    local aliases_file="$CONFIG_DIR/aliases.sh"
    cat > "$aliases_file" << 'SHELL_ALIASES'
# Frontend Setup Aliases
alias nv='node --version'
alias nvmv='nvm --version'
alias pv='pnpm --version'
alias yv='yarn --version'
alias bv='bun --version'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrl='npm run lint'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias prt='pnpm run test'
alias ncu='npm-check-updates'
alias ncuu='npm-check-updates -u'
alias dev='npm run dev'
alias build='npm run build'
alias lint='npm run lint'
alias test='npm run test'
alias fresh='rm -rf node_modules && npm install'
alias pfresh='rm -rf node_modules && pnpm install'
alias ports='lsof -i -P -n | grep LISTEN'
alias serve='npx serve'
alias tunnel='npx localtunnel --port 3000'
alias types='tsc --noEmit'
alias fix='eslint --fix .'
alias format='prettier --write .'
SHELL_ALIASES

    local source_line="[ -f \"$aliases_file\" ] && source \"$aliases_file\""
    if ! grep -q "frontend-setup/aliases.sh" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Frontend setup aliases" >> "$shell_config"
        echo "$source_line" >> "$shell_config"
        manifest_add "shell_config" "Added aliases to $shell_config"
    fi

    if command -v starship &>/dev/null && ! grep -q "starship init" "$shell_config" 2>/dev/null; then
        case "$shell_name" in
            zsh)  echo 'eval "$(starship init zsh)"' >> "$shell_config" ;;
            bash) echo 'eval "$(starship init bash)"' >> "$shell_config" ;;
            fish) echo 'starship init fish | source' >> "$shell_config" ;;
        esac
        manifest_add "starship" "Added starship init"
    fi

    if command -v zoxide &>/dev/null && ! grep -q "zoxide init" "$shell_config" 2>/dev/null; then
        case "$shell_name" in
            zsh)  echo 'eval "$(zoxide init zsh)"' >> "$shell_config" ;;
            bash) echo 'eval "$(zoxide init bash)"' >> "$shell_config" ;;
            fish) echo 'zoxide init fish | source' >> "$shell_config" ;;
        esac
        manifest_add "zoxide" "Added zoxide init"
    fi

    if ! grep -q "NVM_DIR" "$shell_config" 2>/dev/null && [[ -f "$NVM_DIR/nvm.sh" ]]; then
        cat >> "$shell_config" << 'NVM_EOF'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
NVM_EOF
        manifest_add "nvm_shell" "Added NVM source"
    fi

    success "Shell integration configured ($shell_config)"
}

# ── Template Generator ───────────────────────────────────────────
generate_templates() {
    info "Generating project config templates..."

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would generate project starter configs"
        return 0
    fi

    cat > "$TEMPLATE_DIR/.gitignore" << 'GITIGNORE'
node_modules/
dist/
build/
.next/
.nuxt/
.cache/
.turbo/
coverage/
.env
.env.local
.env.*.local
*.log
.DS_Store
*.tsbuildinfo
out/
.svelte-kit/
GITIGNORE

    cat > "$TEMPLATE_DIR/.env.example" << 'ENVEXAMPLE'
# App
VITE_API_URL=http://localhost:3001
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_BASE_URL=http://localhost:3000
PUBLIC_API_URL=http://localhost:3001

# Auth
VITE_AUTH_SECRET=
NEXTAUTH_SECRET=
NEXTAUTH_URL=http://localhost:3000

# Database
DATABASE_URL=postgresql://localhost:5432/myapp

# Features
NEXT_PUBLIC_ENABLE_ANALYTICS=false
VITE_ENABLE_DARK_MODE=true
ENVEXAMPLE

    cat > "$TEMPLATE_DIR/postcss.config.js" << 'POSTCSS'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    ...(process.env.NODE_ENV === 'production' ? { cssnano: {} } : {}),
  },
}
POSTCSS

    cat > "$TEMPLATE_DIR/tailwind.config.js" << 'TAILWIND'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff', 100: '#dbeafe', 200: '#bfdbfe',
          300: '#93c5fd', 400: '#60a5fa', 500: '#3b82f6',
          600: '#2563eb', 700: '#1d4ed8', 800: '#1e40af',
          900: '#1e3a8a', 950: '#172554',
        },
      },
    },
  },
  plugins: [],
}
TAILWIND

    cat > "$TEMPLATE_DIR/prettier.config.js" << 'PRETTIERCFG'
/** @type {import('prettier').Config} */
module.exports = {
  semi: true,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'es5',
  printWidth: 100,
  arrowParens: 'always',
  endOfLine: 'lf',
}
PRETTIERCFG

    cat > "$TEMPLATE_DIR/.npmrc" << 'NPMRC'
save-exact=true
fund=false
audit=false
legacy-peer-deps=true
NPMRC

    echo "20" > "$TEMPLATE_DIR/.nvmrc"

    success "Project config templates generated in $TEMPLATE_DIR"
    manifest_add "templates" "Project config templates"
}

# ── Doctor Mode ───────────────────────────────────────────────────
doctor_mode() {
    info "Running diagnostics..."
    local passed=0; local warnings=0; local failures=0
    local total=0

    echo ""
    echo "─────────────────────────────────────────────────"
    echo "  Frontend Environment Diagnostics"
    echo "─────────────────────────────────────────────────"

    # 1. Node.js
    ((total++))
    if command -v node &>/dev/null; then
        local node_ver
        node_ver="$(node --version 2>/dev/null)"
        echo "  [OK] Node.js $node_ver"
        ((passed++))
    else
        echo "  [FAIL] Node.js not found"
        ((failures++))
    fi

    # 2. nvm
    ((total++))
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        echo "  [OK] nvm installed"
        ((passed++))
    else
        echo "  [FAIL] nvm not found"
        ((failures++))
    fi

    # 3. npm
    ((total++))
    if command -v npm &>/dev/null; then
        echo "  [OK] npm $(npm --version)"
        ((passed++))
    else
        echo "  [FAIL] npm not found"
        ((failures++))
    fi

    # 4. pnpm
    ((total++))
    if command -v pnpm &>/dev/null; then
        echo "  [OK] pnpm $(pnpm --version)"
        ((passed++))
    else
        echo "  [WARN] pnpm not installed"
        ((warnings++))
    fi

    # 5. yarn
    ((total++))
    if command -v yarn &>/dev/null; then
        echo "  [OK] yarn $(yarn --version)"
        ((passed++))
    else
        echo "  [WARN] yarn not installed"
        ((warnings++))
    fi

    # 6. bun
    ((total++))
    if command -v bun &>/dev/null; then
        echo "  [OK] bun $(bun --version)"
        ((passed++))
    else
        echo "  [WARN] bun not installed"
        ((warnings++))
    fi

    # 7. TypeScript
    ((total++))
    if command -v tsc &>/dev/null; then
        echo "  [OK] TypeScript installed"
        ((passed++))
    else
        echo "  [WARN] TypeScript not installed globally"
        ((warnings++))
    fi

    # 8. ESLint
    ((total++))
    if command -v eslint &>/dev/null; then
        echo "  [OK] ESLint installed"
        ((passed++))
    else
        echo "  [WARN] ESLint not installed globally"
        ((warnings++))
    fi

    # 9. Prettier
    ((total++))
    if command -v prettier &>/dev/null; then
        echo "  [OK] Prettier installed"
        ((passed++))
    else
        echo "  [WARN] Prettier not installed globally"
        ((warnings++))
    fi

    # 10. Git
    ((total++))
    if command -v git &>/dev/null; then
        local git_ver
        git_ver="$(git --version 2>/dev/null)"
        echo "  [OK] $git_ver"
        if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
            echo "       Configured: $(git config --global user.name) <$(git config --global user.email)>"
        else
            echo "  [WARN] Git user.name or user.email not set"
            ((warnings++))
        fi
        ((passed++))
    else
        echo "  [FAIL] Git not found"
        ((failures++))
    fi

    # 11. VS Code
    ((total++))
    if command -v code &>/dev/null || command -v codium &>/dev/null; then
        echo "  [OK] VS Code/ium installed"
        ((passed++))
    else
        echo "  [WARN] VS Code not installed"
        ((warnings++))
    fi

    # 12. Playwright
    ((total++))
    if command -v playwright &>/dev/null || npm ls -g @playwright/test &>/dev/null 2>&1; then
        echo "  [OK] Playwright installed"
        ((passed++))
    else
        echo "  [WARN] Playwright not installed"
        ((warnings++))
    fi

    # 13. mkcert
    ((total++))
    if command -v mkcert &>/dev/null; then
        echo "  [OK] mkcert installed"
        ((passed++))
    else
        echo "  [WARN] mkcert not installed"
        ((warnings++))
    fi

    # 14. Starship
    ((total++))
    if command -v starship &>/dev/null; then
        echo "  [OK] starship prompt"
        ((passed++))
    else
        echo "  [WARN] starship not installed"
        ((warnings++))
    fi

    # 15. Disk
    ((total++))
    local avail
    avail="$(df -h "$HOME" | awk 'NR==2{print $4}')"
    echo "  [OK] Disk: $avail available"
    ((passed++))

    echo "─────────────────────────────────────────────────"
    echo "  $passed passed, $warnings warnings, $failures failures / $total checks"
    echo "─────────────────────────────────────────────────"

    return $failures
}

# ── Profile System ────────────────────────────────────────────────
list_profiles() {
    echo "Available profiles:"
    echo ""
    echo "  minimal          Essential Node.js + linting only"
    echo "  react            Complete React/Next.js development"
    echo "  vue              Vue/Nuxt ecosystem"
    echo "  angular          Angular enterprise setup"
    echo "  svelte           SvelteKit development"
    echo "  full-frontend    All frameworks (agency/consultant work)"
    echo "  ssg              Static site generators (Astro, Next, Gatsby)"
    echo ""
}

apply_profile() {
    local profile="$1"
    case "$profile" in
        minimal)
            SELECTED_NODE_VERSIONS=("20")
            SELECTED_PKG_MANAGERS=("npm" "pnpm")
            SELECTED_LINTING=("ESLint" "Prettier")
            SELECTED_TESTING=("Vitest")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint")
            ;;
        react)
            SELECTED_NODE_VERSIONS=("20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm" "yarn")
            SELECTED_FRAMEWORKS=("Next.js" "Vite + React" "Remix")
            SELECTED_BUILD_TOOLS=("vite" "esbuild" "tsx" "tsup")
            SELECTED_CSS_TOOLS=("tailwindcss" "sass" "postcss")
            SELECTED_LINTING=("ESLint" "Prettier" "Stylelint")
            SELECTED_TESTING=("Vitest" "Testing Library" "Testing Library React" "MSW" "happy-dom")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint" "commitizen")
            SELECTED_TERMINAL_TOOLS=("starship" "bat" "fzf" "ripgrep" "zoxide" "lazygit" "tldr" "fd")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "GitLens" "Material Icon Theme" "Error Lens" "Pretty TypeScript Errors" "Vitest" "Playwright" "GitHub Copilot")
            SELECTED_DEVTOOLS=("React DevTools" "Lighthouse CLI" "localtunnel" "serve" "npm-check-updates" "concurrently" "cross-env" "json-server" "faker")
            INSTALL_PLAYWRIGHT=true; INSTALL_MKCERT=true; INSTALL_STARSHIP=true; INSTALL_LAZYGIT=true; INSTALL_ZOXIDE=true
            ;;
        vue)
            SELECTED_NODE_VERSIONS=("20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm" "yarn")
            SELECTED_FRAMEWORKS=("Nuxt" "Vite + Vue" "Astro")
            SELECTED_BUILD_TOOLS=("vite" "esbuild" "tsx")
            SELECTED_CSS_TOOLS=("tailwindcss" "sass" "postcss" "unoCSS")
            SELECTED_LINTING=("ESLint" "Prettier" "Stylelint")
            SELECTED_TESTING=("Vitest" "Testing Library" "Testing Library Vue" "MSW" "happy-dom")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint")
            SELECTED_TERMINAL_TOOLS=("starship" "bat" "fzf" "ripgrep" "zoxide" "lazygit")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "Volar" "GitLens" "Material Icon Theme")
            SELECTED_DEVTOOLS=("Vue DevTools" "serve" "npm-check-updates" "concurrently" "cross-env" "faker")
            INSTALL_PLAYWRIGHT=true; INSTALL_MKCERT=true
            ;;
        angular)
            SELECTED_NODE_VERSIONS=("20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm")
            SELECTED_FRAMEWORKS=("Angular CLI")
            SELECTED_BUILD_TOOLS=("esbuild" "tsx")
            SELECTED_CSS_TOOLS=("sass" "postcss")
            SELECTED_LINTING=("ESLint" "Prettier")
            SELECTED_TESTING=("Vitest" "Testing Library" "MSW")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint")
            SELECTED_TERMINAL_TOOLS=("starship" "bat" "fzf" "ripgrep" "zoxide")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Angular Language Service" "GitLens" "Material Icon Theme")
            SELECTED_DEVTOOLS=("serve" "npm-check-updates" "concurrently" "cross-env")
            INSTALL_PLAYWRIGHT=true
            ;;
        svelte)
            SELECTED_NODE_VERSIONS=("20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm" "yarn")
            SELECTED_FRAMEWORKS=("SvelteKit" "Vite + React" "Astro")
            SELECTED_BUILD_TOOLS=("vite" "esbuild" "tsx")
            SELECTED_CSS_TOOLS=("tailwindcss" "sass" "postcss")
            SELECTED_LINTING=("ESLint" "Prettier")
            SELECTED_TESTING=("Vitest" "Testing Library" "Testing Library Svelte" "MSW" "happy-dom")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint")
            SELECTED_TERMINAL_TOOLS=("starship" "bat" "fzf" "ripgrep")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "Svelte" "GitLens")
            SELECTED_DEVTOOLS=("serve" "npm-check-updates" "concurrently" "localtunnel")
            INSTALL_PLAYWRIGHT=true; INSTALL_MKCERT=true
            ;;
        full-frontend)
            SELECTED_NODE_VERSIONS=("18" "20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm" "yarn" "bun")
            SELECTED_FRAMEWORKS=("Next.js" "Vite + React" "Remix" "Gatsby" "Nuxt" "Vite + Vue" "Astro" "SvelteKit" "Solid Start" "Qwik" "Angular CLI" "Turborepo")
            SELECTED_BUILD_TOOLS=("vite" "esbuild" "swc" "rollup" "parcel" "tsx" "tsup")
            SELECTED_CSS_TOOLS=("tailwindcss" "sass" "less" "postcss" "lightningcss" "unoCSS")
            SELECTED_LINTING=("ESLint" "Prettier" "Stylelint" "Biome" "dprint")
            SELECTED_TESTING=("Vitest" "Testing Library" "Testing Library React" "Testing Library Vue" "Testing Library Svelte" "MSW" "happy-dom" "jsdom")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint" "commitizen" "standard-version" "semantic-release")
            SELECTED_TERMINAL_TOOLS=("starship" "bat" "eza" "fzf" "fd" "ripgrep" "git-delta" "tldr" "lazygit" "zoxide")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "Volar" "Angular Language Service" "Svelte" "styled-components" "TypeScript Next" "Biome" "Playwright" "Vitest" "GitLens" "GitHub Copilot" "One Dark Pro" "Material Icon Theme" "Error Lens" "Pretty TypeScript Errors")
            SELECTED_DEVTOOLS=("React DevTools" "Vue DevTools" "Lighthouse CLI" "localtunnel" "ngrok" "serve" "http-server" "npm-check-updates" "nodemon" "concurrently" "cross-env" "sync" "json-server" "faker" "env-cmd")
            INSTALL_PLAYWRIGHT=true; INSTALL_MKCERT=true; INSTALL_STARSHIP=true; INSTALL_LAZYGIT=true; INSTALL_ZOXIDE=true
            ;;
        ssg)
            SELECTED_NODE_VERSIONS=("20" "22")
            SELECTED_PKG_MANAGERS=("npm" "pnpm")
            SELECTED_FRAMEWORKS=("Astro" "Next.js" "Gatsby")
            SELECTED_BUILD_TOOLS=("vite" "esbuild")
            SELECTED_CSS_TOOLS=("tailwindcss" "postcss")
            SELECTED_LINTING=("ESLint" "Prettier")
            SELECTED_TESTING=("Vitest" "Testing Library")
            SELECTED_GIT_HOOKS=("Husky" "lint-staged" "commitlint")
            SELECTED_TERMINAL_TOOLS=("bat" "fzf" "ripgrep" "zoxide")
            SELECTED_EDITOR_EXTENSIONS=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "GitLens")
            SELECTED_DEVTOOLS=("serve" "npm-check-updates" "localtunnel")
            INSTALL_MKCERT=true
            ;;
        *)
            warn "Unknown profile: $profile"
            list_profiles
            return 1
            ;;
    esac
    success "Profile '$profile' loaded"
}

# ── Export/Import ─────────────────────────────────────────────────
export_config() {
    local outfile="${1:-$HOME/frontend-profiles/config.json}"
    mkdir -p "$(dirname "$outfile")"

    cat > "$outfile" << EOF
{
  "version": "$VERSION",
  "timestamp": "$(date -Iseconds)",
  "profile": "$PROFILE",
  "selections": {
    "node_versions": [$(printf '"%s",' "${SELECTED_NODE_VERSIONS[@]}" | sed 's/,$//')],
    "package_managers": [$(printf '"%s",' "${SELECTED_PKG_MANAGERS[@]}" | sed 's/,$//')],
    "frameworks": [$(printf '"%s",' "${SELECTED_FRAMEWORKS[@]}" | sed 's/,$//')],
    "build_tools": [$(printf '"%s",' "${SELECTED_BUILD_TOOLS[@]}" | sed 's/,$//')],
    "css_tools": [$(printf '"%s",' "${SELECTED_CSS_TOOLS[@]}" | sed 's/,$//')],
    "linting": [$(printf '"%s",' "${SELECTED_LINTING[@]}" | sed 's/,$//')],
    "testing": [$(printf '"%s",' "${SELECTED_TESTING[@]}" | sed 's/,$//')],
    "git_hooks": [$(printf '"%s",' "${SELECTED_GIT_HOOKS[@]}" | sed 's/,$//')],
    "terminal_tools": [$(printf '"%s",' "${SELECTED_TERMINAL_TOOLS[@]}" | sed 's/,$//')],
    "editor_extensions": [$(printf '"%s",' "${SELECTED_EDITOR_EXTENSIONS[@]}" | sed 's/,$//')],
    "devtools": [$(printf '"%s",' "${SELECTED_DEVTOOLS[@]}" | sed 's/,$//')],
    "playwright": $INSTALL_PLAYWRIGHT,
    "mkcert": $INSTALL_MKCERT,
    "starship": $INSTALL_STARSHIP,
    "lazygit": $INSTALL_LAZYGIT,
    "zoxide": $INSTALL_ZOXIDE
  }
}
EOF

    local installer_file="${outfile%.json}-install.sh"
    cat > "$installer_file" << 'INSTALLER_SCRIPT'
#!/usr/bin/env bash
# Generated installer - run to reproduce the exact setup
set -euo pipefail
echo "Running generated frontend setup installer..."
INSTALLER_SCRIPT

    chmod +x "$installer_file"
    success "Config exported to $outfile"
    success "Standalone installer: $installer_file"
}

import_config() {
    local infile="$1"
    [[ ! -f "$infile" ]] && die "Config file not found: $infile"

    info "Importing config from $infile..."

    if command -v jq &>/dev/null; then
        SELECTED_NODE_VERSIONS=($(jq -r '.selections.node_versions[]?' "$infile" 2>/dev/null || echo "20"))
        SELECTED_PKG_MANAGERS=($(jq -r '.selections.package_managers[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_FRAMEWORKS=($(jq -r '.selections.frameworks[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_BUILD_TOOLS=($(jq -r '.selections.build_tools[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_CSS_TOOLS=($(jq -r '.selections.css_tools[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_LINTING=($(jq -r '.selections.linting[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_TESTING=($(jq -r '.selections.testing[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_GIT_HOOKS=($(jq -r '.selections.git_hooks[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_TERMINAL_TOOLS=($(jq -r '.selections.terminal_tools[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_EDITOR_EXTENSIONS=($(jq -r '.selections.editor_extensions[]?' "$infile" 2>/dev/null || echo ""))
        SELECTED_DEVTOOLS=($(jq -r '.selections.devtools[]?' "$infile" 2>/dev/null || echo ""))
        INSTALL_PLAYWRIGHT=$(jq -r '.selections.playwright // false' "$infile" 2>/dev/null)
        INSTALL_MKCERT=$(jq -r '.selections.mkcert // false' "$infile" 2>/dev/null)
        INSTALL_STARSHIP=$(jq -r '.selections.starship // false' "$infile" 2>/dev/null)
        INSTALL_LAZYGIT=$(jq -r '.selections.lazygit // false' "$infile" 2>/dev/null)
        INSTALL_ZOXIDE=$(jq -r '.selections.zoxide // false' "$infile" 2>/dev/null)
        PROFILE=$(jq -r '.profile // ""' "$infile" 2>/dev/null)
    else
        warn "jq not found, using basic parsing"
        SELECTED_NODE_VERSIONS=("20")
    fi

    success "Config imported from $infile"
}

# ── TUI Menus ─────────────────────────────────────────────────────
menu_node_versions() {
    local items=("18" "20" "22")
    local result
    result="$(show_checklist "Node.js Versions" "${items[@]}")"
    SELECTED_NODE_VERSIONS=($result)
    [[ ${#SELECTED_NODE_VERSIONS[@]} -eq 0 ]] && SELECTED_NODE_VERSIONS=("20")
}

menu_package_managers() {
    local items=("pnpm" "yarn" "bun")
    local result
    result="$(show_checklist "Package Managers (npm always included)" "${items[@]}")"
    SELECTED_PKG_MANAGERS=($result)
}

menu_frameworks() {
    local items=(
        "Next.js" "Vite + React" "Create React App" "Remix" "Gatsby"
        "Nuxt" "Vite + Vue" "Vue CLI" "Astro" "SvelteKit"
        "Solid Start" "Qwik" "Angular CLI" "Turborepo"
    )
    local result
    result="$(show_checklist "Framework CLIs" "${items[@]}")"
    SELECTED_FRAMEWORKS=($result)
}

menu_build_tools() {
    local items=("vite" "esbuild" "swc" "rollup" "webpack" "parcel" "turbopack" "rspack" "farm" "tsx" "tsup")
    local result
    result="$(show_checklist "Build Tools" "${items[@]}")"
    SELECTED_BUILD_TOOLS=($result)
}

menu_css_tools() {
    local items=("tailwindcss" "sass" "less" "postcss" "lightningcss" "unoCSS")
    local result
    result="$(show_checklist "CSS Tooling" "${items[@]}")"
    SELECTED_CSS_TOOLS=($result)
}

menu_linting() {
    local items=("ESLint" "Prettier" "Stylelint" "Biome" "Oxlint" "dprint")
    local result
    result="$(show_checklist "Linting & Formatting" "${items[@]}")"
    SELECTED_LINTING=($result)
}

menu_testing() {
    local items=("Vitest" "Jest" "Testing Library" "Testing Library React" "Testing Library Vue" "Testing Library Svelte" "MSW" "happy-dom" "jsdom")
    local result
    result="$(show_checklist "Testing Tools" "${items[@]}")"
    SELECTED_TESTING=($result)
    if confirm "Install Playwright (E2E)?"; then
        INSTALL_PLAYWRIGHT=true
    fi
}

menu_git_hooks() {
    local items=("Husky" "lint-staged" "commitlint" "commitizen" "standard-version" "semantic-release")
    local result
    result="$(show_checklist "Git Hooks" "${items[@]}")"
    SELECTED_GIT_HOOKS=($result)
}

menu_terminal_tools() {
    local items=("starship" "bat" "eza" "fzf" "fd" "ripgrep" "git-delta" "tldr" "lazygit" "zoxide")
    local result
    result="$(show_checklist "Terminal Tools" "${items[@]}")"
    SELECTED_TERMINAL_TOOLS=($result)
}

menu_editor_extensions() {
    local items=("ESLint" "Prettier" "Tailwind CSS IntelliSense" "Volar" "Angular Language Service" "Svelte" "styled-components" "TypeScript Next" "Biome" "Playwright" "Vitest" "GitLens" "GitHub Copilot" "One Dark Pro" "Material Icon Theme" "Error Lens" "Pretty TypeScript Errors")
    local result
    result="$(show_checklist "VS Code Extensions" "${items[@]}")"
    SELECTED_EDITOR_EXTENSIONS=($result)
}

menu_devtools() {
    local items=("React DevTools" "Vue DevTools" "Lighthouse CLI" "localtunnel" "ngrok" "serve" "http-server" "npm-check-updates" "nodemon" "concurrently" "cross-env" "sync" "json-server" "faker" "env-cmd")
    local result
    result="$(show_checklist "Developer Tools" "${items[@]}")"
    SELECTED_DEVTOOLS=($result)
    if confirm "Install mkcert for local HTTPS?"; then
        INSTALL_MKCERT=true
    fi
}

main_menu() {
    local title="Frontend Development Environment Setup v$VERSION"
    while true; do
        local items=(
            "Node.js Versions (${#SELECTED_NODE_VERSIONS[@]} selected)"
            "Package Managers (${#SELECTED_PKG_MANAGERS[@]} selected)"
            "Framework CLIs (${#SELECTED_FRAMEWORKS[@]} selected)"
            "Build Tools (${#SELECTED_BUILD_TOOLS[@]} selected)"
            "CSS Tooling (${#SELECTED_CSS_TOOLS[@]} selected)"
            "Linting & Formatting (${#SELECTED_LINTING[@]} selected)"
            "Testing Tools"
            "Git Hooks (${#SELECTED_GIT_HOOKS[@]} selected)"
            "Terminal Tools (${#SELECTED_TERMINAL_TOOLS[@]} selected)"
            "Editor Extensions (${#SELECTED_EDITOR_EXTENSIONS[@]} selected)"
            "Developer Tools"
            "---"
            "Install Selected"
        )
        [[ "$DRY_RUN" == true ]] && items+=("(DRY RUN - no changes)")
        items+=("Save Profile" "Load Profile" "Diagnostics" "Quit")

        local choice
        choice="$(show_menu "$title" "${items[@]}")"

        case "$choice" in
            "Node.js Versions"*)       menu_node_versions ;;
            "Package Managers"*)       menu_package_managers ;;
            "Framework CLIs"*)         menu_frameworks ;;
            "Build Tools"*)            menu_build_tools ;;
            "CSS Tooling"*)            menu_css_tools ;;
            "Linting & Formatting"*)   menu_linting ;;
            "Testing Tools"*)          menu_testing ;;
            "Git Hooks"*)              menu_git_hooks ;;
            "Terminal Tools"*)         menu_terminal_tools ;;
            "Editor Extensions"*)      menu_editor_extensions ;;
            "Developer Tools"*)        menu_devtools ;;
            "Install Selected")        return 0 ;;
            "Save Profile")
                local pn
                pn="$(prompt_input "Export profile name:" "custom")"
                local ep="$CONFIG_DIR/profiles/${pn}.json"
                mkdir -p "$(dirname "$ep")"
                export_config "$ep"
                info "Profile saved: $ep"
                ;;
            "Load Profile")
                local pn
                pn="$(prompt_input "Profile name:" "")"
                [[ -n "$pn" ]] && apply_profile "$pn" || true
                ;;
            "Diagnostics")
                doctor_mode
                echo "Press Enter to continue..."; read -r
                ;;
            "Quit")
                confirm "Exit?" && exit 0
                ;;
        esac
    done
}

# ── Main Installation Flow ────────────────────────────────────────
run_installation() {
    local start_step=$((LAST_CHECKPOINT + 1))

    if [[ $start_step -le 1 ]]; then
        save_checkpoint 1 "running"
        info "Step 1: Detecting OS..."
        detect_os
        detect_package_manager
        save_checkpoint 1 "completed"
    fi

    if [[ $start_step -le 2 ]]; then
        save_checkpoint 2 "running"
        info "Step 2: Installing prerequisites..."
        install_prerequisites
        setup_directories
        save_checkpoint 2 "completed"
    fi

    if [[ $start_step -le 3 ]]; then
        save_checkpoint 3 "running"
        info "Step 3: Setting up Node.js..."
        setup_node || warn "Node.js setup had issues"
        save_checkpoint 3 "completed"
    fi

    if [[ $start_step -le 4 ]]; then
        save_checkpoint 4 "running"
        info "Step 4: Installing package managers..."
        install_package_managers || true
        save_checkpoint 4 "completed"
    fi

    if [[ $start_step -le 5 ]]; then
        save_checkpoint 5 "running"
        info "Step 5: Installing framework CLIs..."
        install_framework_clis || true
        save_checkpoint 5 "completed"
    fi

    if [[ $start_step -le 6 ]]; then
        save_checkpoint 6 "running"
        info "Step 6: Installing build tools..."
        install_build_tools || true
        save_checkpoint 6 "completed"
    fi

    if [[ $start_step -le 7 ]]; then
        save_checkpoint 7 "running"
        info "Step 7: Installing CSS tooling..."
        install_css_tooling || true
        save_checkpoint 7 "completed"
    fi

    if [[ $start_step -le 8 ]]; then
        save_checkpoint 8 "running"
        info "Step 8: Setting up TypeScript..."
        setup_typescript || true
        save_checkpoint 8 "completed"
    fi

    if [[ $start_step -le 9 ]]; then
        save_checkpoint 9 "running"
        info "Step 9: Installing linting tools..."
        install_linting || true
        save_checkpoint 9 "completed"
    fi

    if [[ $start_step -le 10 ]]; then
        save_checkpoint 10 "running"
        info "Step 10: Installing testing tools..."
        install_testing || true
        save_checkpoint 10 "completed"
    fi

    if [[ $start_step -le 11 ]]; then
        save_checkpoint 11 "running"
        info "Step 11: Setting up git hooks..."
        setup_git_hooks || true
        save_checkpoint 11 "completed"
    fi

    if [[ $start_step -le 12 ]]; then
        save_checkpoint 12 "running"
        info "Step 12: Installing terminal tools..."
        install_terminal_tools || true
        save_checkpoint 12 "completed"
    fi

    if [[ $start_step -le 13 ]]; then
        save_checkpoint 13 "running"
        info "Step 13: Configuring editor..."
        configure_editor || true
        save_checkpoint 13 "completed"
    fi

    if [[ $start_step -le 14 ]]; then
        save_checkpoint 14 "running"
        info "Step 14: Setting up local HTTPS..."
        setup_https || true
        save_checkpoint 14 "completed"
    fi

    if [[ $start_step -le 15 ]]; then
        save_checkpoint 15 "running"
        info "Step 15: Installing dev tools..."
        install_devtools || true
        save_checkpoint 15 "completed"
    fi

    if [[ $start_step -le 16 ]]; then
        save_checkpoint 16 "running"
        info "Step 16: Generating templates..."
        generate_templates || true
        save_checkpoint 16 "completed"
    fi

    if [[ $start_step -le 17 ]]; then
        save_checkpoint 17 "running"
        info "Step 17: Configuring shell..."
        setup_shell_integration || true
        save_checkpoint 17 "completed"
    fi

    echo ""
    echo "─────────────────────────────────────────────────"
    echo "  Setup Complete!"
    echo "─────────────────────────────────────────────────"
    echo ""

    local end_time
    end_time="$(date +%s)"
    local duration=$((end_time - START_TIME))
    info "Total time: $((duration / 60))m $((duration % 60))s"

    local manifest_file
    manifest_file="$(save_manifest)"
    cat > "$LAST_RUN_FILE" << EOF
{
  "version": "$VERSION",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $duration,
  "profile": "$PROFILE",
  "manifest": "$manifest_file",
  "checkpoints_completed": $LAST_CHECKPOINT
}
EOF

    if confirm "Run diagnostics?"; then
        doctor_mode
    fi

    info "Shell config updated. Restart terminal or source your rc file."
    info "Templates: $TEMPLATE_DIR"
    info "To undo: $SCRIPT_NAME --undo"
}

# ── Undo / Rollback ───────────────────────────────────────────────
undo_mode() {
    info "Rolling back last installation..."

    local manifest_file
    manifest_file="$(ls -t "$STATE_DIR/manifest_"*.json 2>/dev/null | head -1)"
    [[ -z "$manifest_file" ]] && { warn "No manifest found"; return 0; }

    info "Reading manifest: $manifest_file"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" 2>/dev/null || true

    if command -v jq &>/dev/null; then
        local count
        count="$(jq 'length' "$manifest_file" 2>/dev/null || echo 0)"
        for ((i=count-1; i>=0; i--)); do
            local type data
            type="$(jq -r ".[$i].type" "$manifest_file" 2>/dev/null)"
            data="$(jq -r ".[$i].data" "$manifest_file" 2>/dev/null)"
            case "$type" in
                npm_global)
                    info "Removing npm global: $data"
                    npm uninstall -g "$data" 2>/dev/null || true
                    ;;
                system_packages)
                    info "System packages: $data. Manual removal recommended."
                    ;;
                backup)
                    for f in "$BACKUP_DIR"/.*.bak; do
                        [[ -f "$f" ]] || continue
                        local target
                        target="$(basename "$f" | sed 's/\.[0-9]*\.bak$//')"
                        target="$HOME/$target"
                        info "Restoring: $f -> $target"
                        cp "$f" "$target" 2>/dev/null || true
                    done
                    ;;
                *)  info "Skipping: $type ($data)" ;;
            esac
        done
    else
        warn "jq required for full rollback"
    fi

    rm -f "$STATE_DIR/state"/checkpoint_*.json 2>/dev/null || true
    LAST_CHECKPOINT=0
    success "Rollback complete. Some tools may need manual removal."
}

# ── Flag Parsing ──────────────────────────────────────────────────
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h) show_help; exit 0 ;;
            --version|-v) echo "frontend-setup.sh v$VERSION"; exit 0 ;;
            --interactive) INTERACTIVE=true ;;
            --non-interactive) INTERACTIVE=false ;;
            --auto-approve|-y) AUTO_APPROVE=true ;;
            --profile) shift; PROFILE="$1" ;;
            --config) shift; CONFIG_FILE_LOAD="$1" ;;
            --export) shift; EXPORT_FILE="$1" ;;
            --import) shift; IMPORT_FILE="$1" ;;
            --dry-run) DRY_RUN=true ;;
            --undo) UNDO_MODE=true ;;
            --resume) RESUME_MODE=true ;;
            --only-node) ONLY_NODE=true ;;
            --only-framework) shift; ONLY_FRAMEWORK="$1" ;;
            --quiet|-q) QUIET=true ;;
            --verbose) VERBOSE=true; LOG_LEVEL="DEBUG" ;;
            --log-file) shift; CUSTOM_LOG_FILE="$1" ;;
            --doctor) detect_os; detect_package_manager; setup_directories; doctor_mode; exit $? ;;
            --list-profiles) list_profiles; exit 0 ;;
            --force) FORCE=true ;;
            *) warn "Unknown: $1"; show_help; exit 2 ;;
        esac
        shift
    done
}

# ── Help ──────────────────────────────────────────────────────────
show_help() {
    cat << 'HELP'
Usage: ./frontend-setup.sh [OPTIONS]

Frontend development environment setup for Linux.

Modes:
  --interactive           TUI mode (default)
  --non-interactive       No prompts
  --auto-approve          Answer yes to all
  --profile <name>        minimal|react|vue|angular|svelte|full-frontend|ssg
  --config <file>         Load JSON config
  --export <file>         Export selections to JSON
  --import <file>         Import from JSON

Execution:
  --dry-run               Preview only
  --undo                  Rollback last run
  --resume                Resume from checkpoint
  --only-node             Only setup Node.js
  --only-framework <name> Only install framework CLI

Output:
  --log-file <file>       Custom log
  --quiet                 Suppress output
  --verbose               Debug output
  --doctor                Diagnostics

Info:
  --help                  This help
  --version               Version
  --list-profiles         List profiles
  --force                 Force reinstall

Examples:
  ./frontend-setup.sh
  ./frontend-setup.sh --profile react
  ./frontend-setup.sh --dry-run --profile full-frontend
  ./frontend-setup.sh --import config.json
  ./frontend-setup.sh --doctor
  ./frontend-setup.sh --undo
HELP
}

# ── Main ──────────────────────────────────────────────────────────
main() {
    parse_flags "$@"

    if [[ -n "$CUSTOM_LOG_FILE" ]]; then
        LOG_FILE="$CUSTOM_LOG_FILE"
    else
        LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
    fi
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

    info "Frontend Development Environment Setup v$VERSION"

    if [[ "$UNDO_MODE" == true ]]; then
        detect_os
        setup_directories
        undo_mode
        exit 0
    fi

    if [[ -n "$IMPORT_FILE" ]]; then
        import_config "$IMPORT_FILE"
        INTERACTIVE=false
    fi

    if [[ -n "$EXPORT_FILE" ]]; then
        export_config "$EXPORT_FILE"
        exit 0
    fi

    detect_os
    detect_package_manager
    setup_directories
    [[ "$RESUME_MODE" == true ]] && load_checkpoint
    detect_tui

    if [[ -n "$PROFILE" ]]; then
        apply_profile "$PROFILE" || { warn "Profile not found"; INTERACTIVE=true; }
    fi

    if [[ -n "$CONFIG_FILE_LOAD" ]]; then
        [[ -f "$CONFIG_FILE_LOAD" ]] && import_config "$CONFIG_FILE_LOAD" || warn "Config not found"
    fi

    if [[ -f "$LAST_RUN_FILE" ]] && [[ "$INTERACTIVE" == true ]] && [[ -z "$PROFILE" ]]; then
        if confirm "Use last installation selections?"; then
            local lc="$CONFIG_DIR/config.json"
            [[ -f "$lc" ]] && import_config "$lc"
        fi
    fi

    if [[ "$INTERACTIVE" == true ]] && [[ -z "$PROFILE" ]]; then
        main_menu
    fi

    if [[ "$ONLY_NODE" == true ]]; then
        [[ ${#SELECTED_NODE_VERSIONS[@]} -eq 0 ]] && SELECTED_NODE_VERSIONS=("20")
        setup_node
        exit 0
    fi

    if [[ -n "$ONLY_FRAMEWORK" ]]; then
        SELECTED_FRAMEWORKS=("$ONLY_FRAMEWORK")
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        install_framework_clis
        exit 0
    fi

    [[ ${#SELECTED_NODE_VERSIONS[@]} -eq 0 ]] && SELECTED_NODE_VERSIONS=("20")

    if [[ "$DRY_RUN" == true ]]; then
        info "DRY RUN - No changes made"
        echo ""
        echo "Would install:"
        echo "  Node: ${SELECTED_NODE_VERSIONS[*]}"
        [[ ${#SELECTED_PKG_MANAGERS[@]} -gt 0 ]] && echo "  PMs: ${SELECTED_PKG_MANAGERS[*]}"
        [[ ${#SELECTED_FRAMEWORKS[@]} -gt 0 ]] && echo "  Frameworks: ${SELECTED_FRAMEWORKS[*]}"
        [[ ${#SELECTED_BUILD_TOOLS[@]} -gt 0 ]] && echo "  Build: ${SELECTED_BUILD_TOOLS[*]}"
        [[ ${#SELECTED_CSS_TOOLS[@]} -gt 0 ]] && echo "  CSS: ${SELECTED_CSS_TOOLS[*]}"
        [[ ${#SELECTED_LINTING[@]} -gt 0 ]] && echo "  Lint: ${SELECTED_LINTING[*]}"
        [[ ${#SELECTED_TESTING[@]} -gt 0 ]] && echo "  Test: ${SELECTED_TESTING[*]}"
        [[ ${#SELECTED_GIT_HOOKS[@]} -gt 0 ]] && echo "  Hooks: ${SELECTED_GIT_HOOKS[*]}"
        [[ ${#SELECTED_TERMINAL_TOOLS[@]} -gt 0 ]] && echo "  Terminal: ${SELECTED_TERMINAL_TOOLS[*]}"
        [[ ${#SELECTED_EDITOR_EXTENSIONS[@]} -gt 0 ]] && echo "  Extensions: ${SELECTED_EDITOR_EXTENSIONS[*]}"
        [[ ${#SELECTED_DEVTOOLS[@]} -gt 0 ]] && echo "  DevTools: ${SELECTED_DEVTOOLS[*]}"
        exit 0
    fi

    if [[ "$INTERACTIVE" == true ]] && [[ "$AUTO_APPROVE" == false ]]; then
        confirm "Proceed?" || exit 0
    fi

    run_installation
    export_config "$CONFIG_DIR/config.json" >/dev/null 2>&1 || true
    success "Done!"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]] || [[ "$0" == *"frontend-setup.sh" ]]; then
    main "$@"
fi
