# Interactive zsh configuration for the terminal workstation stack.
# Non-interactive shell environment belongs in ~/.zshenv.

[[ -o interactive ]] || return

de100_p10k_theme="$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"

if [[ -z "${DE100_ZSH_PLUGIN_MANAGER+x}" ]]; then
    if [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        DE100_ZSH_PLUGIN_MANAGER="omz"
    else
        DE100_ZSH_PLUGIN_MANAGER="none"
    fi
fi
export DE100_ZSH_PLUGIN_MANAGER

if [[ -z "${DE100_SHELL_PROMPT+x}" ]]; then
    if [[ -r "$HOME/.p10k.zsh" && -r "$de100_p10k_theme" ]]; then
        DE100_SHELL_PROMPT="p10k"
    else
        DE100_SHELL_PROMPT="starship"
    fi
fi
export DE100_SHELL_PROMPT

# Powerlevel10k instant prompt must stay before anything that can print.
if [[ "$DE100_SHELL_PROMPT" == "p10k" && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R --use-color -Dd+r$Du+b}"

if [[ -r "${XDG_STATE_HOME:-$HOME/.local/state}/de100/theme/starship.toml" ]]; then
  export STARSHIP_CONFIG="${XDG_STATE_HOME:-$HOME/.local/state}/de100/theme/starship.toml"
elif [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml" ]]; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

path_prepend_zsh() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

if [[ -d "$HOME/.local/share/pnpm" ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    path_prepend_zsh "$PNPM_HOME"
fi

[[ -d "$HOME/.console-ninja/.bin" ]] && path_prepend_zsh "$HOME/.console-ninja/.bin"

if [[ "${DE100_LOAD_ENVMAN:-1}" == "1" && -s "$HOME/.config/envman/load.sh" && -w "$HOME/.config/envman" ]]; then
    source "$HOME/.config/envman/load.sh"
fi

if [[ "${DE100_LOAD_NVM:-1}" == "1" ]]; then
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history
setopt prompt_subst

bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

de100_fix_wordchars() {
    # zsh treats "/" as a word character by default. Removing it makes Ctrl-w
    # kill one path segment instead of the whole path, without a custom widget.
    if [[ -z "${WORDCHARS:-}" ]]; then
        WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
    fi
    WORDCHARS="${WORDCHARS//\//}"
}

de100_fix_wordchars

# Keep Ctrl-S available for zsh-autocomplete menu search in terminals that
# otherwise use it for software flow control.
[[ -t 0 ]] && stty -ixon 2>/dev/null || true

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''
zstyle ':autocomplete:*' delay 0.15
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' list-lines 12
zstyle ':autocomplete:*' add-semicolon no
zstyle ':autocomplete::compinit' arguments -i

if command -v fzf >/dev/null 2>&1; then
    [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

if command -v atuin >/dev/null 2>&1 && [[ "${DE100_ENABLE_ATUIN:-0}" == "1" ]]; then
    eval "$(atuin init zsh)"
fi

load_starship_prompt() {
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    else
        PROMPT='%F{blue}%~%f %(?.%F{green}.%F{red})>%f '
    fi
}

de100_omz_plugin_available() {
  local plugin="$1"

  [[ -f "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]] ||
    [[ -f "$ZSH_CUSTOM/plugins/$plugin/_$plugin" ]] ||
    [[ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]] ||
    [[ -f "$ZSH/plugins/$plugin/_$plugin" ]]
}

de100_add_omz_plugin() {
  local plugin="$1"

  if de100_omz_plugin_available "$plugin"; then
    plugins+=("$plugin")
    return 0
  fi

  return 1
}

de100_load_omz() {
  [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] || return 1

  export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
  export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh}"
  export ZSH_COMPDUMP="${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-omz-${HOST%%.*}-${ZSH_VERSION}}"

  zstyle ':omz:update' mode disabled

  if [[ "$DE100_SHELL_PROMPT" == "p10k" && -r "$de100_p10k_theme" ]]; then
    ZSH_THEME="powerlevel10k/powerlevel10k"
  else
    ZSH_THEME=""
  fi

  plugins=()
  de100_add_omz_plugin git
  de100_add_omz_plugin colorize
  de100_add_omz_plugin colored-man-pages

  # Load the highlighter before zsh-autocomplete. Loading it last is the usual
  # zsh rule, but it prints startup warnings for zsh-autocomplete's widgets.
  de100_add_omz_plugin fast-syntax-highlighting
  [[ "${TERM:-}" != "dumb" ]] && de100_add_omz_plugin zsh-autocomplete
  de100_add_omz_plugin zsh-autosuggestions

  source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

  if [[ "$DE100_SHELL_PROMPT" == "p10k" && -r "$de100_p10k_theme" ]]; then
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
    [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  else
    load_starship_prompt
  fi
}

de100_load_antidote() {
  local zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
  local autocomplete_dir="${XDG_CACHE_HOME:-$HOME/.cache}/antidote/github.com/marlonrichert/zsh-autocomplete"
  local should_bundle="0"

  [[ -r "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" ]] || return 1

  if [[ -r "${zsh_plugins}.txt" ]]; then
    if [[ ! -r "${zsh_plugins}.zsh" || "${zsh_plugins}.txt" -nt "${zsh_plugins}.zsh" ]]; then
      should_bundle="1"
    elif command grep -q 'zsh-syntax-highlighting\|zsh-history-substring-search' "${zsh_plugins}.zsh" 2>/dev/null; then
      should_bundle="1"
    fi
  fi

  if [[ "$should_bundle" == "1" ]]; then
    source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
    antidote bundle <"${zsh_plugins}.txt" >"${zsh_plugins}.zsh"
  fi

  # Antidote does not provide the same framework glue as Oh My Zsh. Keep this
  # local to the opt-in path so the default OMZ path stays simple.
  if [[ -d "$autocomplete_dir/Completions" ]]; then
    fpath=("$autocomplete_dir/Completions" $fpath)
    autoload -Uz \
      _autocomplete__command \
      _autocomplete__compadd_opts_len \
      _autocomplete__history_lines \
      _autocomplete__recent_paths \
      _autocomplete__should_add_space \
      _autocomplete__should_insert_unambiguous \
      _autocomplete__unambiguous
  fi

  [[ -r "${zsh_plugins}.zsh" ]] && source "${zsh_plugins}.zsh"

  if [[ "$DE100_SHELL_PROMPT" == "p10k" && -r "$de100_p10k_theme" ]]; then
    source "$de100_p10k_theme"
    [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  else
    load_starship_prompt
  fi
}

case "$DE100_ZSH_PLUGIN_MANAGER" in
  antidote)
    de100_load_antidote || load_starship_prompt
    ;;
  omz)
    de100_load_omz || load_starship_prompt
    ;;
  none | *)
    load_starship_prompt
    ;;
esac

de100_fix_wordchars

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

if (( $+widgets[history-search-backward] )); then
  bindkey '^R' history-search-backward
elif (( $+widgets[.history-incremental-search-backward] )); then
  bindkey '^R' .history-incremental-search-backward
fi

if (( $+widgets[history-search-forward] )); then
  bindkey '^S' history-search-forward
elif (( $+widgets[.history-incremental-search-forward] )); then
  bindkey '^S' .history-incremental-search-forward
fi

alias vim='nvim'
alias vi='nvim'
alias ll='eza -lah --git --group-directories-first 2>/dev/null || ls -lah'
alias la='eza -la --group-directories-first 2>/dev/null || ls -la'
alias grep='grep --color=auto'
alias tm='tmux new-session -A -s main'
alias ts='tmux-sessionizer'
alias python='python3'
alias pip='pip3'

[[ -x "$HOME/Applications/cursor.AppImage" ]] && alias cursor="$HOME/Applications/cursor.AppImage --no-sandbox"
[[ -x "$HOME/scripts/update-cursor" ]] && alias update-cursor="$HOME/scripts/update-cursor"

cat() {
    if command -v bat >/dev/null 2>&1; then
        bat --paging=never "$@"
    else
        command cat "$@"
    fi
}

# Machine-local aliases, secrets, and overrides. This file is intentionally not
# created by the repo.
if [[ -r "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi
