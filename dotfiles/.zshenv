# Minimal shell environment shared by interactive and non-interactive zsh.
# Keep this file small: it is sourced for every zsh invocation.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Ubuntu can run global compinit from /etc/zsh/zshrc before user shell setup
# loads. Let the selected user framework/plugin stack manage completion.
skip_global_compinit=1

# VS Code Snap can leak read-only Snap XDG paths into terminals. Neovim needs
# writable config/data/state/cache directories for Lazy, Mason, shada, logs,
# and DAP, so reset only the known-bad Snap paths.
case "${XDG_CONFIG_HOME:-}" in
  "$HOME"/snap/code/*|/snap/*|"")
    export XDG_CONFIG_HOME="$HOME/.config"
    ;;
esac

case "${XDG_DATA_HOME:-}" in
  "$HOME"/snap/code/*|/snap/*|"")
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

# Machine-local environment hooks. Keep secrets and host-specific exports out of
# the repo; put them in ~/.zshenv.local when needed.
if [[ -r "$HOME/.zshenv.local" ]]; then
  . "$HOME/.zshenv.local"
fi
