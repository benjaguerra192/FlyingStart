#!/usr/bin/env bash
set -euo pipefail

version="1.6"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="$root/dist"
zip_name="FlyingStart_v${version}_CM.zip"

mkdir -p "$dist"
rm -f "$dist/$zip_name"

cd "$root"
if command -v zip >/dev/null 2>&1; then
  zip -r "$dist/$zip_name" \
    apps/lua/FlyingStart \
    INSTALL.txt \
    README.md \
    Changelog.md \
    PACKAGING.md \
    -x "*.git*" "*/.DS_Store"
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command \
    "Compress-Archive -Path 'apps/lua/FlyingStart','INSTALL.txt','README.md','Changelog.md','PACKAGING.md' -DestinationPath 'dist/$zip_name' -Force"
elif command -v tar >/dev/null 2>&1; then
  tar -a -cf "$dist/$zip_name" apps/lua/FlyingStart INSTALL.txt README.md Changelog.md PACKAGING.md
else
  printf 'No zip tool found. Install zip, PowerShell or tar.\n' >&2
  exit 1
fi

printf 'Created %s\n' "$dist/$zip_name"
