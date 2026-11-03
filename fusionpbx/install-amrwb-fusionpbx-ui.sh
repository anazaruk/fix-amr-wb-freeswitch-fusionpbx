#!/bin/sh
set -eu

fusionpbx_root="${1:-/var/www/fusionpbx}"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
patch_file="$script_dir/amrwb-fusionpbx-ui.patch"
target_file="$fusionpbx_root/app/vars/var_edit.php"
backup_file="$target_file.codex-amrwb-backup"

if [ ! -f "$target_file" ]; then
	echo "FusionPBX variable editor not found at $target_file" >&2
	exit 1
fi

if [ ! -f "$patch_file" ]; then
	echo "Patch file not found at $patch_file" >&2
	exit 1
fi

patch --dry-run --forward -p1 -d "$fusionpbx_root" < "$patch_file"
cp -p "$target_file" "$backup_file"
if ! patch --batch --forward -p1 -d "$fusionpbx_root" < "$patch_file" || ! php -l "$target_file"; then
	cp -p "$backup_file" "$target_file"
	echo "Patch application or PHP validation failed. The original file was restored." >&2
	exit 1
fi

echo "AMR-WB web controls installed. Backup: $backup_file"
