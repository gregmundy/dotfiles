#!/usr/bin/env bash

app_installed() {
  local app="$1"
  [[ -d "/Applications/${app}.app" || -d "${HOME}/Applications/${app}.app" ]]
}

