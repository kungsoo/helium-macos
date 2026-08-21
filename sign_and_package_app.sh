#!/bin/bash -eux

_root_dir="$(dirname "$(greadlink -f "$0")")"

# For packaging
_chromium_version=$(cat "$_root_dir"/helium-chromium/chromium_version.txt)
_ungoogled_revision=$(cat "$_root_dir"/helium-chromium/revision.txt)
_package_revision=$(cat "$_root_dir"/revision.txt)

# Fix issue where macOS requests permission for incoming network connections
# See https://github.com/ungoogled-software/ungoogled-chromium-macos/issues/17
xattr -cs out/Default/Helium.app

# Sign the binary (仅删除签名相关逻辑，你要的删除全部Apple相关env)
codesign --force --deep --sign - out/Default/Helium.app

# Package the app
if command -v appdmg 2>&1 >/dev/null || [ -n "${NEEDS_APPDMG:-}" ]; then
  ln -sf "$_root_dir/resources/dmg.json" out/Default
  appdmg out/Default/dmg.json "$OUT_DMG_PATH"
else
  echo "no appdmg, falling back to stock .dmg" >&2
  chrome/installer/mac/pkg-dmg \
    --sourcefile --source out/Default/Helium.app \
    --target "$OUT_DMG_PATH" \
    --volname Helium --symlink /Applications:/Applications \
    --format ULMO --verbosity 2
fi
