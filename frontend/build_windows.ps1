# Builds a Windows release executable using the production API URL from
# env.json rather than requiring --dart-define to be typed by hand each
# time. flutter clean guarantees a fresh build - no stale dart-defines or
# cached artifacts carried over from a previous build.
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

flutter clean
flutter pub get
flutter build windows --release --dart-define-from-file=env.json
