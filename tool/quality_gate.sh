#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Fetching dependencies"
flutter pub get

echo "[2/4] Verifying formatting"
dart format --output=none --set-exit-if-changed lib test

echo "[3/4] Running static analysis"
flutter analyze

echo "[4/4] Running tests"
flutter test

echo "Quality gate passed."
