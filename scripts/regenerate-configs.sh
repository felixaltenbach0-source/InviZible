#!/bin/bash
# regenerate-configs.sh
# Regenerates the .mp3 config archives from source config files.
# Run this after modifying any default config (tor.conf, dnscrypt-proxy.toml, i2pd.conf).
#
# Usage:
#   ./scripts/regenerate-configs.sh
#
# The script will:
#   1. Extract each .mp3 archive (ZIP)
#   2. (Optionally) modify the configs
#   3. Repackage them
#
# To generate a new Tor control port password hash:
#   tor --hash-password "$(openssl rand -base64 32)"
#
# To generate a vanguards-compatible control password:
#   openssl rand -base64 32

set -e

ASSETS_DIR="tordnscrypt/src/main/assets"
TMPDIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

repackage_zip() {
    local src_dir="$1"
    local out_file="$2"
    rm -f "$out_file"
    (cd "$src_dir" && python3 -c "
import zipfile, os
with zipfile.ZipFile('$out_file', 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk('.'):
        for f in files:
            filepath = os.path.join(root, f)
            zf.write(filepath, filepath)
")
    echo "Repackaged: $out_file"
}

echo "=== Regenerating Tor config archive ==="
mkdir -p "$TMPDIR/tor"
unzip -o "$ASSETS_DIR/tor.mp3" -d "$TMPDIR/tor" > /dev/null
echo "  Extracted tor.mp3"
# tor.conf modifications would go here if editing programmatically
repackage_zip "$TMPDIR/tor" "$ASSETS_DIR/tor.mp3"

echo "=== Regenerating DNSCrypt config archive ==="
mkdir -p "$TMPDIR/dns"
unzip -o "$ASSETS_DIR/dnscrypt.mp3" -d "$TMPDIR/dns" > /dev/null
echo "  Extracted dnscrypt.mp3"
# dnscrypt-proxy.toml modifications would go here if editing programmatically
repackage_zip "$TMPDIR/dns" "$ASSETS_DIR/dnscrypt.mp3"

echo "=== Regenerating i2pd config archive ==="
mkdir -p "$TMPDIR/itpd"
unzip -o "$ASSETS_DIR/itpd.mp3" -d "$TMPDIR/itpd" > /dev/null
echo "  Extracted itpd.mp3"
# i2pd.conf modifications would go here if editing programmatically
repackage_zip "$TMPDIR/itpd" "$ASSETS_DIR/itpd.mp3"

echo ""
echo "Done! All config archives regenerated."
echo ""
echo "Vanguards config is at: $ASSETS_DIR/vanguards.conf (plain file, not archived)"
echo ""
echo "To generate a Tor control password hash for vanguards:"
echo "  tor --hash-password \"\$(openssl rand -base64 32)\""
echo ""
echo "Place the hash in tor.conf as: HashedControlPassword <hash>"
