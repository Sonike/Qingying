#!/usr/bin/env bash
set -euo pipefail
stage=$(mktemp -d)
out="$PWD/dist/Qingying-$QY_VERSION"
case "$1" in
  ios)
    app="$stage/Payload/Runner.app"
    mkdir -p "$stage/Payload"
    ditto build/ios/iphoneos/Runner.app "$app"
    ;;
  macos)
    app="$stage/Qingying.app"
    ditto build/macos/Build/Products/Release/Qingying.app "$app"
    ;;
  *) exit 2 ;;
esac
info="$app/Info.plist"
bin="$app"
if [[ $1 == macos ]]; then
  info="$app/Contents/Info.plist"
  bin="$app/Contents/MacOS"
fi
test "$(plutil -extract CFBundleIdentifier raw "$info")" = app.qingying.viewer
test "$(plutil -extract CFBundleDisplayName raw "$info")" = 清映
test "$(plutil -extract CFBundleVersion raw "$info")" = "${QY_VERSION##*.}"
exe="$bin/$(plutil -extract CFBundleExecutable raw "$info")"
lipo -archs "$exe"
if [[ $1 == ios ]]; then
  test "$(plutil -extract DTPlatformName raw "$info")" = iphoneos
  lipo -verify_arch arm64 "$exe"
  test -d "$app/Frameworks/App.framework"
  find "$app/Frameworks" -depth -type d -name '*.framework' -exec codesign --force --sign - --preserve-metadata=identifier,entitlements {} \;
  (cd "$stage" && zip -q -yr "$out-ios-resign.ipa" Payload)
  unzip -tq "$out-ios-resign.ipa"
else
  codesign --verify --deep --strict "$app"
  "$exe" > "$stage/startup.log" 2>&1 &
  pid=$!
  sleep 8
  if ! kill -0 "$pid"; then cat "$stage/startup.log"; exit 1; fi
  kill "$pid"
  rm "$stage/startup.log"
  ln -s /Applications "$stage/Applications"
  hdiutil create -quiet -fs HFS+ -volname 清映 -srcfolder "$stage" -format UDZO "$out-macos.dmg"
  hdiutil verify "$out-macos.dmg"
fi
