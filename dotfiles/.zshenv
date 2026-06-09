# Minimal shell environment shared by interactive and non-interactive zsh.
# Keep this file small: it is sourced for every zsh invocation.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# VS Code Snap can leak read-only Snap XDG paths into terminals. Neovim needs
# writable data/state/cache directories for Lazy, Mason, shada, logs, and DAP.
case "${XDG_DATA_HOME:-}" in
  "$HOME"/snap/code/*|/snap/*)
    export XDG_DATA_HOME="$HOME/.local/share"
    ;;
esac

case "${XDG_STATE_HOME:-}" in
  "$HOME"/snap/code/*|/snap/*|"")
    export XDG_STATE_HOME="$HOME/.local/state"
    ;;
esac

case "${XDG_CACHE_HOME:-}" in
  "$HOME"/snap/code/*|/snap/*|"")
    export XDG_CACHE_HOME="$HOME/.cache"
    ;;
esac

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/scripts"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.cargo/bin"

export PATH
