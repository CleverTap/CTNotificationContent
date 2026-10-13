#!/usr/bin/env bash
# Updates the SDK version everywhere it is carried, then runs scripts/check_version.sh.
# Usage: scripts/bump_version.sh 1.7.0
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <major.minor.patch>"
    exit 1
fi
version="$1"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
    echo "Version must be major.minor.patch with minor and patch at most 99, got '$version'"
    exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

printf '%s\n' "$version" > sdk-version.txt
perl -pi -e "s/(kCTNotificationContentVersion = \@\")[^\"]*(\")/\${1}$version\${2}/" CTNotificationContent/CTNotificationViewController.m
perl -pi -e "s/(MARKETING_VERSION = )[^;]*;/\${1}$version;/" CTNotificationContent.xcodeproj/project.pbxproj

changelog_version="$(sed -n 's/^Version \([0-9][0-9.]*\).*/\1/p' CHANGELOG.md | head -n 1)"
if [[ "$changelog_version" != "$version" ]]; then
    heading="Version $version ($(date '+%-d %B, %Y'))"
    perl -0pi -e "s/\A(Change Log\n=+\n)/\${1}$heading\n-----------------------------------------------\n- Describe the changes in this release.\n\n/" CHANGELOG.md
    echo "Added a CHANGELOG.md entry for $version. Replace the placeholder line with the release notes."
fi

echo "Updated sdk-version.txt, kCTNotificationContentVersion and MARKETING_VERSION to $version."
echo "Rebuild Framework/CTNotificationContent.xcframework so the SPM binary carries the new version."
"$ROOT/scripts/check_version.sh"
