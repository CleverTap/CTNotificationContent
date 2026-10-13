#!/usr/bin/env bash
# Verifies that every place carrying the SDK version matches sdk-version.txt.
# Run locally before a release, and in CI on every pull request.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION_FILE="sdk-version.txt"
PODSPEC="CTNotificationContent.podspec"
SOURCE="CTNotificationContent/CTNotificationViewController.m"
PBXPROJ="CTNotificationContent.xcodeproj/project.pbxproj"
INFO_PLIST="CTNotificationContent/Info.plist"
CHANGELOG="CHANGELOG.md"

failures=0
pass() { echo "ok    $1"; }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

version="$(tr -d '[:space:]' < "$VERSION_FILE")"
# Minor and patch are capped at two digits so the Core SDK version code (major * 10000 + minor * 100 + patch) stays unique.
if [[ "$version" =~ ^[0-9]+\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
    pass "$VERSION_FILE is $version"
else
    fail "$VERSION_FILE must be major.minor.patch with minor and patch at most 99, found '$version'"
fi

if grep -q "sdk-version.txt" "$PODSPEC"; then
    pass "$PODSPEC reads $VERSION_FILE"
else
    fail "$PODSPEC must read its version from $VERSION_FILE"
fi

source_version="$(sed -n 's/.*kCTNotificationContentVersion = @"\([^"]*\)".*/\1/p' "$SOURCE" | head -n 1)"
if [[ "$source_version" == "$version" ]]; then
    pass "kCTNotificationContentVersion is $source_version"
else
    fail "kCTNotificationContentVersion in $SOURCE is '$source_version', expected '$version'"
fi

marketing_versions="$(sed -n 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/p' "$PBXPROJ" | sort -u)"
if [[ -n "$marketing_versions" && "$marketing_versions" == "$version" ]]; then
    pass "MARKETING_VERSION is $version"
else
    fail "MARKETING_VERSION in $PBXPROJ is '$(echo "$marketing_versions" | tr '\n' ' ')', expected '$version'"
fi

if grep -A1 "<key>CFBundleShortVersionString</key>" "$INFO_PLIST" | grep -q '\$(MARKETING_VERSION)'; then
    pass "$INFO_PLIST uses \$(MARKETING_VERSION)"
else
    fail "CFBundleShortVersionString in $INFO_PLIST must be \$(MARKETING_VERSION)"
fi

changelog_version="$(sed -n 's/^Version \([0-9][0-9.]*\).*/\1/p' "$CHANGELOG" | head -n 1)"
if [[ "$changelog_version" == "$version" ]]; then
    pass "$CHANGELOG top entry is $changelog_version"
else
    fail "$CHANGELOG top entry is '$changelog_version', expected '$version'"
fi

if grep -q "^- Describe the changes in this release\.$" "$CHANGELOG"; then
    fail "$CHANGELOG still has the placeholder line added by scripts/bump_version.sh"
else
    pass "$CHANGELOG has release notes"
fi

if (( failures > 0 )); then
    echo "$failures version check(s) failed. Run scripts/bump_version.sh <version> to update every place at once."
    exit 1
fi
echo "All version checks passed."
