#!/bin/sh
# Builds this app and puts it on the phone: iOS-Toolkit's ios-device.sh with this app's
# Scripts/gate.conf and the personal, gitignored Scripts/device.conf:
#   TEAM=<team id>  DEVICE=<hardware UDID from `xcrun devicectl list devices`>  BUNDLE_ID=com.khizanag.cinematic.dev
# CONFIGURATION=Debug for the Testing Lab; --no-launch only installs. CINEMATIC_DEVICE_CONF points
# at another device.conf, for a second phone.
# Cinematic has no gate, so its project and scheme are named here. The toolkit is found through the git hooks
# path its setup-machine.sh installs; IOS_TOOLKIT overrides it.
set -eu
[ -n "${CINEMATIC_DEVICE_CONF:-}" ] && export DEVICE_CONF="$CINEMATIC_DEVICE_CONF"
export PROJECT=Cinematic.xcodeproj SCHEME=Cinematic
hooks=$(git config core.hooksPath || true)
toolkit=${IOS_TOOLKIT:-${hooks%/hooks}}
device="$toolkit/scripts/ios-device.sh"
[ -x "$device" ] || { echo "✗ iOS-Toolkit not found (looked at $device); set IOS_TOOLKIT or run its setup-machine.sh" >&2; exit 1; }
exec "$device" ${1+"$@"}
