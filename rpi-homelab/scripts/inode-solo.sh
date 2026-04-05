#!/usr/bin/env bash
set -euo pipefail

# Build list of file extensions to filter out.
declare -a ext_filters=(
  ! -iname '*.exe'
  ! -iname '*.jpg'
  ! -iname '*.nfo'
  ! -iname '*.part'
  ! -iname '*.png'
  ! -iname '*.srt'
  ! -iname '*.txt'
)

# Get inodes from all non-filtered files under '/media/torrent-complete'.
declare -A torrent_inode_files

while IFS=$'\t' read -r inode file; do
  torrent_inode_files[$inode]=$file
done < <(find /media/torrent-complete -xdev -type f "${ext_filters[@]}" -print0 \
  | xargs -0 -n 1 stat --printf='%i\t%n\n')

declare -a unsorted_unlinked

# For each found inode, look for the same inode under '/media/structured-{tv,movies}'.
for inode in "${!torrent_inode_files[@]}"; do
  structured_result_count=$(find /media/structured-tv /media/structured-movies -xdev -type f -inum "$inode" | wc -l)

  # If no find result, save to array for sorting/printing later.
  if [[ $structured_result_count -eq 0 ]]; then
    unsorted_unlinked+=("${torrent_inode_files[$inode]}")
  fi
done

# Sort and print the array of files that are not linked under '/media/structured-{tv,movies}'.
mapfile -t sorted_unlinked < <(printf '%s\n' "${unsorted_unlinked[@]}" | sort)

for ((idx = 0; idx < ${#sorted_unlinked[@]}; idx++)); do
  echo "${sorted_unlinked[$idx]}"
done
