#!/usr/bin/env bash
set -euo pipefail
bundle=build/linux/x64/release/bundle
stage=$(mktemp -d)
dest="$stage/opt/qingying"
mkdir -p "$dest" "$stage/DEBIAN" "$stage/usr/bin"
cp -a "$bundle/." "$dest/"
test -x "$dest/qingying"
test -f "$dest/data/icudtl.dat"
ldd "$dest/qingying" | tee "$RUNNER_TEMP/qingying-ldd.txt"
if grep -F 'not found' "$RUNNER_TEMP/qingying-ldd.txt"; then exit 1; fi
dbus-run-session -- xvfb-run -a bash -euc '
  "$1" >"$RUNNER_TEMP/qingying-startup.log" 2>&1 &
  pid=$!
  sleep 8
  if ! kill -0 "$pid"; then cat "$RUNNER_TEMP/qingying-startup.log"; exit 1; fi
  kill "$pid"
' bash "$dest/qingying"
ln -s /opt/qingying/qingying "$stage/usr/bin/qingying"
install -Dm644 assets/linux/app.qingying.viewer.desktop "$stage/usr/share/applications/app.qingying.viewer.desktop"
install -Dm644 assets/images/logo/logo.png "$stage/usr/share/icons/hicolor/512x512/apps/app.qingying.viewer.png"
cat > "$stage/DEBIAN/control" <<EOF
Package: qingying
Version: $QY_VERSION
Architecture: amd64
Maintainer: Sonike <1700162+Sonike@users.noreply.github.com>
Section: video
Priority: optional
Depends: libgtk-3-0t64, libmpv2, libwebkit2gtk-4.1-0, libasound2t64
Homepage: https://github.com/Sonike/Qingying
Description: Qingying third-party Bilibili client
EOF
out="dist/Qingying-$QY_VERSION-linux-amd64.deb"
dpkg-deb --root-owner-group --build "$stage" "$out"
dpkg-deb --info "$out"
