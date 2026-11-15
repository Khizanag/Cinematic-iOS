#!/bin/sh
# Builds, signs, installs, and launches on a real device. The team and device live in
# Scripts/device.conf, which is gitignored:
#   TEAM=ABCDE12345
#   DEVICE=<hardware UDID from `xcrun devicectl list devices`>
#   BUNDLE_ID=com.khizanag.cinematic.dev
# A free Apple ID's profile lasts 7 days; running this again renews it and keeps the data.
set -eu
root=$(git rev-parse --show-toplevel)
conf="$root/Scripts/device.conf"
[ -f "$conf" ] || { echo "✗ no Scripts/device.conf; see the top of this script" >&2; exit 64; }
# shellcheck disable=SC1090
. "$conf"
derived="$root/.build/device"
log="$derived/build.log"
configuration="${CONFIGURATION:-Release}"
mkdir -p "$derived"
cd "$root"

echo "→ build and sign for $DEVICE"
if ! xcodebuild -project Cinematic.xcodeproj -scheme Cinematic -configuration "$configuration" \
    -destination "id=$DEVICE" -derivedDataPath "$derived" -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="$TEAM" CODE_SIGN_STYLE=Automatic CINEMATIC_BUNDLE_ID="$BUNDLE_ID" build >"$log" 2>&1; then
    grep -E "error:|Provisioning|limit" "$log" | sort -u | cut -c1-300 >&2
    echo "✗ build failed — full log: $log" >&2
    exit 1
fi
app="$derived/Build/Products/$configuration-iphoneos/Cinematic.app"
built_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")
if [ "$built_id" != "$BUNDLE_ID" ]; then
    echo "✗ built $built_id, expected $BUNDLE_ID — nothing installed" >&2
    exit 1
fi

echo "→ install $app"
xcrun devicectl device install app --device "$DEVICE" "$app" >/dev/null
if [ "${1:-}" != "--no-launch" ]; then
    echo "→ launch"
    xcrun devicectl device process launch --device "$DEVICE" "$BUNDLE_ID" >/dev/null \
        || echo "  couldn't launch: unlock the phone and open it by hand"
fi
echo "✓ installed $BUNDLE_ID"
