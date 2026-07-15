#!/usr/bin/env bash
#
# run-all-tests.sh
# Runs every test suite for the FeatureAuth-Dev app in one shot:
#   1. The Xcode Test Plan (app tests + all LOCAL Swift package test targets)
#   2. The two REMOTE packages (FeatureAuth, AuthDomain) via `swift test`
#      against their locally-checked-out folders, since their tests are not
#      built inside the app project when consumed from GitHub.
#
# Usage:
#   ./scripts/run-all-tests.sh
#   DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest" ./scripts/run-all-tests.sh
#
set -euo pipefail

SCHEME="${SCHEME:-ScriptStarter}"
TEST_PLAN="${TEST_PLAN:-ScriptStarter}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16,OS=latest}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Regenerating Xcode project"
if command -v xcodegen >/dev/null 2>&1; then
  xcodegen generate
else
  echo "warning: xcodegen not found; using the existing ScriptStarter.xcodeproj"
fi

echo "==> Running Xcode Test Plan ($TEST_PLAN) on: $DESTINATION"
xcodebuild test \
  -project ScriptStarter.xcodeproj \
  -scheme "$SCHEME" \
  -testPlan "$TEST_PLAN" \
  -destination "$DESTINATION" \
  -resultBundlePath TestResults.xcresult \
  -enableCodeCoverage YES \
  CODE_SIGNING_ALLOWED=NO

# Remote packages: run their own test suites directly if their source folders
# are present in the workspace (they are checked out here for reference).
for pkg in FeatureAuth AuthDomain; do
  if [ -f "$pkg/Package.swift" ]; then
    echo "==> swift test for remote package: $pkg"
    ( cd "$pkg" && swift test )
  else
    echo "==> skipping $pkg (no local checkout found)"
  fi
done

echo "==> All test suites completed successfully."
