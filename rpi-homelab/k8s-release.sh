#!/usr/bin/env bash
set -euo pipefail

### k8s-release.sh looks at the most recent 100 releases from the kubernetes/kubernetes GitHub repo, and outputs the
### semver of the latest non-prerelease patch for the second-highest minor version, hard-coded to major version 1.

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

source "$script_dir"/semver.sh

mapfile -t k8s_release_tags < <(
  curl --header "Accept: application/vnd.github.v3+json" --silent \
    https://api.github.com/repos/kubernetes/kubernetes/releases?per_page=100 \
    | jq --raw-output '.[].tag_name'
)

# Map minor versions to their highest patch number
declare -A minor_v_patch

for k8s_release_tag in "${k8s_release_tags[@]}"; do
  declare local_major=0
  declare local_minor=0
  declare local_patch=0
  declare prerelease=""

  semverParseInto "$k8s_release_tag" local_major local_minor local_patch prerelease

  # Discard prereleases
  if [ "$prerelease" != "" ]; then
    continue
  fi

  # Check the major version in case Kubernetes v2 comes out one day
  if ((local_major != 1)); then
    echo >&2 "Major version is not equal to '1'."
    exit 1
  fi

  if [ -n "${minor_v_patch[$local_minor]+is_set}" ] && ((minor_v_patch[$local_minor] >= local_patch)); then
    continue
  fi

  minor_v_patch[$local_minor]=$local_patch
done

# Sort keys in map of minor version
mapfile -d '' sorted_keys < <(printf '%s\0' "${!minor_v_patch[@]}" | sort --numeric-sort --zero-terminated)

# Find the index of the second highest minor version; number of elements minus two
declare -i shmv_index=$((${#sorted_keys[@]} - 2))

# Output the full version (major.minor.patch)
printf "1.%d.%d" "${sorted_keys[$shmv_index]}" "${minor_v_patch[${sorted_keys[$shmv_index]}]}"
