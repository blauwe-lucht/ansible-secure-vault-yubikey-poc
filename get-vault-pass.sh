#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Touch your YubiKey to unlock the vault password." >&2
age -d -i yubikey-identity.txt vault-pass.age
