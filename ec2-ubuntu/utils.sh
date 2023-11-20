#! /usr/bin/env bash

function say {
  local text="$1"
  local color="$2"

  case "$color" in
    "red")
      echo -e "\e[1;31m$text\e[0m" ;; # Red
    "green")
      echo -e "\e[1;32m$text\e[0m" ;; # Green
    "yellow")
      echo -e "\e[1;33m$text\e[0m" ;; # Yellow
    "blue")
      echo -e "\e[1;34m$text\e[0m" ;; # Blue
    "purple")
      echo -e "\e[1;35m$text\e[0m" ;; # Purple
    "cyan")
      echo -e "\e[1;36m$text\e[0m" ;; # Cyan
    "white")
      echo -e "\e[1;37m$text\e[0m" ;; # White
    *)
      echo "Unknown color: $color" ;;
  esac
}

function ok {
  echo -e "   [ $(say ok green) ] $1"
}

function ko {
  echo -e "[ $(say fatal red) ] $1"
}

function info {
  echo -e " [ $(say info cyan) ] $1"
}

function also {
  echo -e "[ $(say ————— cyan) ] $1"
}

# Usage: ask <prompt> <varname>
function ask {
  read -re -p "$(echo -e "[ $(say input white) ] $1 \e[1;37m")" -i "${!2}" "$2" && printf "\e[0m"
}

# Persists/update environment variable to /home/$USER/.bash_profile
# Usage: saveenv <varname>
function saveenv {
  # Escape & and \1 through \9, which have special meaning in the sed replacement string
  SED_REPLACEMENT=$(echo ${!1} | sed 's/[&\]/\\\\&/g')
  grep -q "^export $1=" "/home/$USER/.bash_profile" \
    && sed -i "s/^export $1=.*/export $1=\'$SED_REPLACEMENT\'/g" "/home/$USER/.bash_profile" \
    || echo "export $1='${!1}'" >> "/home/$USER/.bash_profile"
}

# Reload .bash_profile w/ persisted environment variables
function relog {
  exec sudo su -l "$USER"
}
