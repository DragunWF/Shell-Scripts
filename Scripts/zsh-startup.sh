# Suppress instant prompt warning for intentional console output
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Path to PKG Config
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"

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
LOCATION_KEYS=(
  "repo" 
  "solve" 
  "capstone" 
  "college" 
  "cogni"
  "learn"
)
LOCATION_PATHS=(
  "$HOME/Documents/DevStuff/Repositories"
  "$HOME/Documents/DevStuff/Repositories/Competitive-Programming"
  "$HOME/Documents/DevStuff/Repositories/Curvera-System"
  "$HOME/Documents/DevStuff/Repositories/School-Work/4th-Year"
  "$HOME/Documents/DevStuff/Repositories/CogniTrack"
  "$HOME/Documents/DevStuff/Repositories/LearningLab"
)

COMMANDS=(
  "help-profile"
  "dev [-location]"
  "ip"
  "audio [device-name | list]"
  "shutdown-start [-minutes]"
  "shutdown-cancel"
)

# Function Definitions

function help-profile() {
  echo "Custom Commands:"
  for cmd in "${COMMANDS[@]}"; do
    echo "- $cmd"
  done

  echo "\nDev Locations:"
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

function ip() {
  echo "IPv4 Address: $(ipconfig getifaddr en0)"
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

function audio() {
  if [[ "$1" == "list" || "$1" == "-l" || "$1" == "--list" ]]; then
    # List all available audio output devices
    echo "Available audio output devices:"
    SwitchAudioSource -a -t output
    echo "\nCurrent output device:"
    SwitchAudioSource -c -t output
  elif [[ -z $1 ]]; then
    # Get current device and all available devices
    local current=$(SwitchAudioSource -c -t output)
    local all_devices=()
    local devices=()
    
    # Read all devices into array
    while IFS= read -r line; do
      all_devices+=("$line")
    done < <(SwitchAudioSource -a -t output)
    
    # Filter out virtual/software audio devices
    for device in "${all_devices[@]}"; do
      # Skip common virtual audio devices
      if [[ "$device" != *"Microsoft Teams"* ]] && \
         [[ "$device" != *"Zoom"* ]] && \
         [[ "$device" != *"Slack"* ]] && \
         [[ "$device" != *"BlackHole"* ]] && \
         [[ "$device" != *"Loopback"* ]]; then
        devices+=("$device")
      fi
    done
    
    # Find the index of the current device
    local current_index=-1
    for i in {1..${#devices[@]}}; do
      if [[ "${devices[$i]}" == "$current" ]]; then
        current_index=$i
        break
      fi
    done
    
    # Calculate next index (wrap around to first device if at the end)
    local next_index=$(( (current_index % ${#devices[@]}) + 1 ))
    local next_device="${devices[$next_index]}"
    
    # Switch to next device
    SwitchAudioSource -s "$next_device" -t output
    if [[ $? -eq 0 ]]; then
      echo "Switched audio output source to: $next_device"
    else
      echo "Error: Could not switch to next device."
    fi
  else
    # Switch to the specified device
    SwitchAudioSource -s "$1" -t output
    if [[ $? -eq 0 ]]; then
      echo "Switched audio output source to: $1"
    else
      echo "Error: Could not switch to '$1'. Use 'audio list' to see available devices."
    fi
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

# Aliases for Python 3
alias python="python3"
alias pip="pip3"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===============================================
# MOVE CONSOLE OUTPUT AFTER INSTANT PROMPT
# ===============================================

# Welcome Message - moved here to avoid instant prompt conflicts
echo "Welcome back, Dragun. Continue on your journey for self-improvement!\n"

# Run Help on Load - moved here to avoid instant prompt conflicts
help-profile

# Run neofetch for the aesthetics
neofetch

# Added by Windsurf
export PATH="/Users/marcplarisan/.codeium/windsurf/bin:$PATH"
