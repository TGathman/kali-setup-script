# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Oh My Zsh
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting   # keep last
)

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

source $ZSH/oh-my-zsh.sh

# ============================================================================
# Powerlevel10k
# ============================================================================
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Shell options
# ============================================================================
setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form 'anything=expression'
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=''               # don't consider certain characters part of the word
PROMPT_EOL_MARK=""         # hide EOL sign ('%')

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# ============================================================================
# History
# ============================================================================
# NOTE: must come after oh-my-zsh.sh, which sets HISTSIZE/SAVEHIST unconditionally.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#unsetopt share_history       # omz enables share_history; uncomment to turn it back off

# force zsh to show the complete history
alias history="history 0"

# ============================================================================
# Completion tweaks
# ============================================================================
# (compinit itself is run by oh-my-zsh)
zstyle ':completion:*' rehash true

# ============================================================================
# Colors
# ============================================================================
export LS_COLORS="$LS_COLORS:ow=30;44:" # 777 dirs are unreadable by default
alias ip='ip --color=auto'

# colored man pages
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
export MANROFFOPT="-c"

# ============================================================================
# External Tools
# ============================================================================
# apt package suggestions on unknown commands
[ -f /etc/zsh_command_not_found ] && . /etc/zsh_command_not_found

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow || true)"
bindkey '^[[1;5A' atuin-up-search   # ctrl + up

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# ============================================================================
# Functions
# ============================================================================
promptnote() {
  typeset -g _PN="$1"
  whence p10k &>/dev/null && p10k reload;
}

vpn() {
  case "$1" in
    con|ent|for|sea)
      sudo systemctl stop openvpn@con openvpn@ent openvpn@for openvpn@sea 2>/dev/null
      sudo systemctl start openvpn@$1
      echo "Enabling $1 vpn..."

      # Wait for tun0 to have an IPv4 address
      until [[ -n $(ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}') ]]; do
        sleep 0.2
      done
      ;;

    off)
      echo "Disabling VPN..."
      sudo systemctl stop openvpn@con openvpn@ent openvpn@for openvpn@sea 2>/dev/null

      # Wait until tun0 disappears
      until ! ip link show tun0 &>/dev/null; do
        sleep 0.2
      done
      ;;

    *)
      echo "Usage: vpn {con|ent|for|sea|off}"
      return 1
      ;;
  esac
}

# ============================================================================
# Aliases
# ============================================================================
eza_params=('--icons' '--git' '-F' '--color-scale=age' '--group-directories-first')

alias pn=promptnote
alias server="python3 -m http.server"
alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --group --long $eza_params'
alias lm='eza --all --header --long --sort=modified $eza_params'
alias lt='eza --all --group --long --tree $eza_params'
alias ltt='eza --all --group --long --tree --level=2 $eza_params'
alias la='eza -lbhHigUmuSa@'
alias tree='lt'
alias cat='batcat'
alias sudo='sudo '   # let aliases expand after sudo
