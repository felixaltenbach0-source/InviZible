#!/bin/bash
# generate-control-password.sh
# Generates a random Tor control password and its hashed version for vanguards.
#
# Usage:
#   ./scripts/generate-control-password.sh
#
# This generates:
#   1. A random password
#   2. The HashedControlPassword line for tor.conf
#
# To use the generated password with vanguards, add it to vanguards.conf:
#   [Global]
#   control_pass = <generated-password>
#
# And the HashedControlPassword to tor.conf:
#   HashedControlPassword <hashed-value>

set -e

PASSWORD=$(openssl rand -base64 32)
echo "=== Tor Control Port Password ==="
echo ""
echo "Random password: $PASSWORD"
echo ""
echo "Add this to tor.conf:"
echo "  HashedControlPassword"
echo ""
echo "Add this to vanguards.conf:"
echo "  [Global]"
echo "  control_pass = $PASSWORD"
echo ""
echo "Note: With CookieAuthentication enabled in tor.conf,"
echo "vanguards will use cookie auth automatically and"
echo "the password is only needed as a fallback."
