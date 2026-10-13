#!/bin/bash
# Creates a random vault password that only the YubiKey can decrypt, then vaults secret.yml with it.

set -euo pipefail
cd "$(dirname "$0")"

IDENTITY_FILE=yubikey-identity.txt
VAULT_PASS_FILE=vault-pass.age
SECRET_FILE=secret.yml

if [ ! -s "$IDENTITY_FILE" ]; then
    echo "Creating a YubiKey identity. Enter your PIV PIN if asked and touch your YubiKey when it blinks."
    # Touch only, no PIN: a YubiKey 4 can't cache the PIN, and an agent can't touch anyway.
    age-plugin-yubikey --generate --name ansible-yubikey-poc \
        --touch-policy always --pin-policy never > "$IDENTITY_FILE.tmp"
    mv "$IDENTITY_FILE.tmp" "$IDENTITY_FILE"
fi

if [ ! -f "$VAULT_PASS_FILE" ]; then
    recipient=$(grep -o -m 1 'age1yubikey1[0-9a-z]*' "$IDENTITY_FILE" || true)
    if [ -z "$recipient" ]; then
        echo "No age1yubikey1... recipient found in $IDENTITY_FILE" >&2
        exit 1
    fi
    head -c 32 /dev/urandom | base64 | tr -d '\n' | age -r "$recipient" -o "$VAULT_PASS_FILE"
fi

if [ ! -f "$SECRET_FILE" ]; then
    echo 'secret_message: "Unlocked with a YubiKey touch"' > "$SECRET_FILE"
    echo "Touch your YubiKey to encrypt $SECRET_FILE."
    ansible-vault encrypt --vault-password-file ./get-vault-pass.sh "$SECRET_FILE"
fi
