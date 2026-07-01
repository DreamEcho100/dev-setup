# POSIX login-shell fallback for the same minimal environment as .zshenv.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

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

if [ -s "$HOME/.config/envman/load.sh" ]; then
  . "$HOME/.config/envman/load.sh"
fi

if [ -r "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Machine-local login-shell hooks. Keep secrets and host-specific exports out of
# the repo; put them in ~/.profile.local when needed.
if [ -r "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi
