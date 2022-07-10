#!/usr/bin/env bash
set -euo pipefail

### raspios64-release.sh looks at the hosted Raspberry Pi ARM64 releases, and:
### - if no flags are given, outputs details of the latest release:
###     line 1: (suggested) local file path
###     line 2: file size of download URL
### - if the '--download' flag is given, downloads the latest release

# Get the last (most recent(?)) link from the page
base_url="https://downloads.raspberrypi.org/raspios_arm64/images/"
curl_base=$(curl --silent "$base_url")
declare raspios_release

while IFS='>' read -d '<' -r TAG VALUE; do
  if [[ $TAG =~ raspios_arm64- ]]; then
    raspios_release=$VALUE
  fi
done <<< "$curl_base"

if [[ -z ${raspios_release:-} ]]; then
  exit 1
fi

# Find the ZIP file to download
curl_raspios=$(curl --silent "$base_url$raspios_release")
declare zip_name

while IFS='>' read -d '<' -r TAG VALUE; do
  if [[ $VALUE =~ -arm64.img.xz$ ]]; then
    zip_name=$VALUE
  fi
done <<< "$curl_raspios"

if [[ -z ${zip_name:-} ]]; then
  exit 2
fi

declare download_url="$base_url$raspios_release$zip_name"
declare local_file="$HOME"/Downloads/raspios-arm64/"$zip_name"

if [[ ${1:-} == "--download" ]]; then
  mkdir -pv "$HOME"/Downloads/raspios-arm64

  wget \
    --continue \
    --output-document="$HOME"/Downloads/raspios-arm64/"$zip_name" \
    --progress=dot:giga \
    "$download_url"
else
  echo "$local_file"
  curl --head --silent "$download_url" | grep --ignore-case "Content-Length" | awk '{print $2}'
fi
