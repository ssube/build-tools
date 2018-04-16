#! /bin/bash

# Color helpers
function begin_color() {
  echo -ne "\e[38;5;$1m";
}

function close_color() {
  echo -ne '\e[0m';
}

function std_color() {
  class="${1}"

  case ${class} in
    success)
      echo 2
      ;;
    failure)
      echo 1
      ;;
    progress)
      echo 5
      ;;
    info)
      echo 7
      ;;
    start)
      ;&
    end)
      ;&
    *)
      echo 4
      ;;
  esac
}