#!/bin/sh
# Build the LuCI frontend as a real APKv3 package for OpenWrt 25.xx.
# Requires apk-tools with the mkpkg applet (on the host or the router).
# Usage: APK=/path/to/apk ./scripts/build-apk-25xx.sh [output-directory]
# Inputs (relative to the repository root):
#   istore/luci-app-picoclaw/luasrc/controller/picoclaw.lua
#   istore/luci-app-picoclaw/luasrc/view/picoclaw/main.htm
#   scripts/picoclaw.init
# Default output directory: release/
# Standalone frontend package: includes init.d, but no core binary or skills.
# Install /usr/bin/picoclaw separately. Do not combine this package with a
# core package that also owns /etc/init.d/picoclaw.

set -eu
umask 022

PKG_NAME="luci-app-picoclaw"
PKG_VERSION="${PKG_VERSION:-1.1.6-r6}"
PKG_DESC="LuCI management interface for PicoClaw AI assistant"
PKG_MAINTAINER="GennKann"
APK="${APK:-apk}"

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPO_DIR="$(dirname -- "$SCRIPT_DIR")"
PACKAGE_DIR="$REPO_DIR/istore/$PKG_NAME"
OUTPUT_DIR="${1:-$REPO_DIR/release}"
OUTPUT_FILE="$PKG_NAME-$PKG_VERSION.apk"

if [ "$#" -gt 1 ]; then
    printf 'Usage: %s [output-directory]\n' "$0" >&2
    exit 1
fi

if ! command -v "$APK" >/dev/null 2>&1; then
    printf 'Error: apk-tools not found. Set APK to an apk-tools executable.\n' >&2
    exit 1
fi
# Some static apk-tools builds omit help; let the actual mkpkg invocation
# validate applet support instead of treating missing help as missing mkpkg.

for source in \
    "$PACKAGE_DIR/luasrc/controller/picoclaw.lua" \
    "$PACKAGE_DIR/luasrc/view/picoclaw/main.htm" \
    "$SCRIPT_DIR/picoclaw.init"
do
    if [ ! -f "$source" ]; then
        printf 'Error: required source file is missing: %s\n' "$source" >&2
        exit 1
    fi
done

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/$PKG_NAME-apk.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' 0
trap 'exit 1' HUP INT TERM
PKG_ROOT="$BUILD_DIR/pkg"

printf 'Building %s %s (noarch)...\n' "$PKG_NAME" "$PKG_VERSION"
# Use an explicit file list so optional root files and skills are not bundled.
mkdir -p "$PKG_ROOT/usr/lib/lua/luci/controller" \
    "$PKG_ROOT/usr/lib/lua/luci/view/picoclaw" \
    "$PKG_ROOT/etc/init.d" "$PKG_ROOT/lib/apk/packages"
cp "$PACKAGE_DIR/luasrc/controller/picoclaw.lua" \
    "$PKG_ROOT/usr/lib/lua/luci/controller/picoclaw.lua"
cp "$PACKAGE_DIR/luasrc/view/picoclaw/main.htm" \
    "$PKG_ROOT/usr/lib/lua/luci/view/picoclaw/main.htm"
cp "$SCRIPT_DIR/picoclaw.init" "$PKG_ROOT/etc/init.d/picoclaw"
find "$PKG_ROOT" -type d -exec chmod 0755 {} +
find "$PKG_ROOT" -type f -exec chmod 0644 {} +
chmod 0755 "$PKG_ROOT/etc/init.d/picoclaw"

# Match OpenWrt's installed-file manifest convention for APK packages.
touch "$PKG_ROOT/lib/apk/packages/$PKG_NAME.list"
(
    cd "$PKG_ROOT"
    find . -type f -print | LC_ALL=C sort | sed 's|^\./|/|'
) > "$BUILD_DIR/files.list"
mv "$BUILD_DIR/files.list" "$PKG_ROOT/lib/apk/packages/$PKG_NAME.list"

cat > "$BUILD_DIR/post-install" << 'POSTINST'
#!/bin/sh
# Do not reload services when installing into an offline firmware root.
[ -n "${IPKG_INSTROOT:-}" ] && exit 0
rm -f /tmp/luci-indexcache.*
rm -rf /tmp/luci-modulecache/
if [ -x /etc/init.d/rpcd ]; then
    /etc/init.d/rpcd reload >/dev/null 2>&1 || true
fi
exit 0
POSTINST
chmod 0755 "$BUILD_DIR/post-install"

SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-0}" "$APK" mkpkg \
    --info "name:$PKG_NAME" \
    --info "version:$PKG_VERSION" \
    --info "description:$PKG_DESC" \
    --info "arch:noarch" \
    --info "license:MIT" \
    --info "origin:luci-app-picoclaw" \
    --info "url:https://github.com/altman08/luci-app-picoclaw" \
    --info "maintainer:$PKG_MAINTAINER" \
    --info "depends:luci-compat luci-lib-jsonc curl ca-bundle" \
    --script "post-install:$BUILD_DIR/post-install" \
    --script "post-upgrade:$BUILD_DIR/post-install" \
    --files "$PKG_ROOT" \
    --output "$BUILD_DIR/$OUTPUT_FILE"

# Never publish a partial or invalid package as a successful build.
"$APK" --allow-untrusted verify "$BUILD_DIR/$OUTPUT_FILE"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(CDPATH='' cd -- "$OUTPUT_DIR" && pwd)"
cp "$BUILD_DIR/$OUTPUT_FILE" "$OUTPUT_DIR/$OUTPUT_FILE"
printf '\nCreated unsigned APK: %s/%s\n' "$OUTPUT_DIR" "$OUTPUT_FILE"
printf 'Install on OpenWrt with: apk add --allow-untrusted /tmp/%s\n' "$OUTPUT_FILE"
printf 'Includes /etc/init.d/picoclaw; no launcher, core binary or skill files are bundled.\n'
printf 'Install /usr/bin/picoclaw separately. A core package owning the same init script will conflict.\n'
