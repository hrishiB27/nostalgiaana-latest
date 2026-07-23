# Builds a Windows release executable using the production API URL from
# env.json rather than requiring --dart-define to be typed by hand each
# time. flutter clean guarantees a fresh build - no stale dart-defines or
# cached artifacts carried over from a previous build.
#
# Do NOT run this alongside another `flutter build` (e.g. `flutter build
# apk --release`) in a separate terminal — the `flutter clean` above deletes
# the shared build/ and .dart_tool/ directories, which will corrupt or wipe
# out an APK build running concurrently against the same checkout. Run them
# sequentially: this script first, then the other build second.
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

flutter clean
flutter pub get
flutter build windows --release --dart-define-from-file=env.json
