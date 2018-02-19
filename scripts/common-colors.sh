#! /bin/bash

# Color helpers
function begin_color() {
  echo -ne "\e[38;5;$1m";
}

function close_color() {
  echo -ne '\e[0m';
}