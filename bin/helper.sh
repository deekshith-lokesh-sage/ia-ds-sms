#!/bin/bash

UTILS_DIR="../ia-ds-utils"

checkPwd() {
    if [ ! -f "$PWD/bin/helper.sh" ]; then
      echo "ERROR: Please execute the command from the project's home folder."
      exit 1
    fi
}

setupUtils() {
  echo "Refreshing the utils repo..."
  if [ ! -d "$UTILS_DIR" ]; then
    echo "Need to clone ia-ds-utils"
    git clone git@github.com:intacct/ia-ds-utils.git $UTILS_DIR --quiet
  else
    cd $UTILS_DIR
    git pull origin main --prune
    cd - >> /dev/null
  fi
  echo "Done refreshing the utils repo."
}

invokeScript() {
  local script=$(basename "$1")
  checkPwd
  setupUtils

  $UTILS_DIR/bin/${script}
}
