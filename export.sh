#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "'${BASH_SOURCE[0]}' is NOT being sourced!"
  exit 1
fi

script_dir=$(dirname "${BASH_SOURCE[0]}")

ANSIBLE_INVENTORY=$(realpath "$script_dir"/inventory.yaml)
export ANSIBLE_INVENTORY

unset script_dir
