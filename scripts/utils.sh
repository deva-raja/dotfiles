# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper logging functions
info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }
error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }
prompt() { echo -e -n "${CYAN}${BOLD}[?]${NC} $1 "; }

# Helper to ask yes/no questions (defaulting to Yes)
ask_yes_no() {
  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    return 0
  fi
  local prompt_msg="$1"
  local answer
  while true; do
    prompt "${prompt_msg} [Y/n]:"
    read -r answer
    # If empty, default to Yes
    if [[ -z "$answer" ]]; then
      return 0
    fi
    case "${answer:0:1}" in
      y|Y ) return 0 ;;
      n|N ) return 1 ;;
      * ) info "Please answer yes (y) or no (n)." ;;
    esac
  done
}

# Helper to restore the latest backup found (used during uninstall)
restore_backup() {
  local target_dir="$1"
  # Find backups matching target_dir.bak.*
  local backups=($(ls -d ${target_dir}.bak.* 2>/dev/null | sort -r || true))
  if [ ${#backups[@]} -gt 0 ]; then
    local latest="${backups[0]}"
    if ask_yes_no "Found configuration backup at ${latest}. Do you want to restore it?"; then
      rm -rf "$target_dir"
      mv "$latest" "$target_dir"
      success "Restored backup to ${target_dir}!"
    else
      info "Keeping ${target_dir} as is (or empty)."
    fi
  fi
}
