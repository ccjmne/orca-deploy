#! /usr/bin/env bash

# Usage: say <text> <colour>
function say {
  local text="$1"
  local color="$2"

  case "$color" in
    "red")
      echo -e "\e[1;31m$text\e[0m" ;;
    "green")
      echo -e "\e[1;32m$text\e[0m" ;;
    "yellow")
      echo -e "\e[1;33m$text\e[0m" ;;
    "blue")
      echo -e "\e[1;34m$text\e[0m" ;;
    "purple")
      echo -e "\e[1;35m$text\e[0m" ;;
    "cyan")
      echo -e "\e[1;36m$text\e[0m" ;;
    "white")
      echo -e "\e[1;37m$text\e[0m" ;;
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
  sed -i "/home/$USER/.bash_profile" -e "/^export $1=/d"
  export "$1"="${!1}"
  echo "export $1='${!1}'" >> "/home/$USER/.bash_profile"
}
