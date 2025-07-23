# Suppress instant prompt warning for intentional console output
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

# Source Oh My Zsh at the beginning to ensure all ZSH features are loaded
source $ZSH/oh-my-zsh.sh

# ===============================================
# PowerShell-like functions ported to macOS/zsh
# ===============================================

# Global Variables
SHUTDOWN_STARTED=false

# Data Configuration
LOCATION_KEYS=("repo" "unity" "smartstudy" "curvera")
LOCATION_PATHS=(
  "$HOME/Documents/DevStuff/Repositories"
  "$HOME/Documents/DevStuff/Unity"
  "$HOME/Documents/DevStuff/Repositories/SmartStudy"
  "$HOME/Documents/DevStuff/Repositories/Curvera-System"
)

COMMANDS=(
  "help-profile"
  "organize"
  "start [-location]"
  "dev [-location]"
  "get-storage-status"
  "shutdown-start [-minutes]"
  "shutdown-cancel"
)

# Function Definitions

function help-profile() {
  echo "Commands:"
  for cmd in "${COMMANDS[@]}"; do
    echo "- $cmd"
  done

  echo "\nLocations:"
  # Use the array of keys instead of associative array iteration
  for loc in "${LOCATION_KEYS[@]}"; do
    echo "- $loc"
  done

  echo ""
}

function dev() {
  if [[ -n $1 ]]; then
    # Find the index of the location key
    local found=0
    local index=0
    for ((i=0; i<=${#LOCATION_KEYS[@]}; i++)); do
      if [[ "${LOCATION_KEYS[$i]}" == "$1" ]]; then
        found=1
        index=$i
        break
      fi
    done
    
    if [[ $found -eq 1 ]]; then
      cd "${LOCATION_PATHS[$index]}"
    else
      echo "Developer location '$1' not recognized!\n"
    fi
  else
    echo "No location specified.\n"
  fi
}

function start() {
  if [[ -n $1 ]]; then
    command open "$1" 
  else
    echo "Failed to open: No argument provided"
  fi
}

function get-storage-status() {
  # Adjust this for macOS - using df command instead
  df -h
}

function shutdown-start() {
  if [[ -z $1 ]]; then
    echo "Error: No time specified. Please provide minutes as an argument."
    return
  fi
  
  if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid input. Please provide a valid number."
    return
  fi
  
  if (( $1 < 0 )); then
    echo "Error: Cannot schedule shutdown with negative time. Please provide a positive number of minutes."
    return
  fi
  
  # Schedule shutdown in macOS
  sudo shutdown -h +$1
  
  if [[ $SHUTDOWN_STARTED == false ]]; then
    SHUTDOWN_STARTED=true
    local shutdown_time=$(date -v+${1}M +"%I:%M %p")
    echo "Your computer will shutdown in $1 minute(s) at $shutdown_time"
  fi
}

function shutdown-cancel() {
  # Cancel shutdown in macOS
  # macOS uses 'killall shutdown' instead of 'shutdown -c'
  sudo killall shutdown
  
  if [[ $SHUTDOWN_STARTED == true ]]; then
    SHUTDOWN_STARTED=false
    echo "Computer shutdown has been cancelled!"
  fi
}

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===============================================
# MOVE CONSOLE OUTPUT AFTER INSTANT PROMPT
# ===============================================

# Welcome Message - moved here to avoid instant prompt conflicts
echo "Welcome back, Dragun. Continue on your journey for self-improvement!\n"

# Run Help on Load - moved here to avoid instant prompt conflicts
help-profile