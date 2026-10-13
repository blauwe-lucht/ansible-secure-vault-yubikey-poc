#!/bin/bash
# Creates an SSH key whose private part stays on the YubiKey; every login needs a touch.
# ecdsa-sk instead of ed25519-sk: a YubiKey 4 only has U2F, not FIDO2.

set -euo pipefail
cd "$(dirname "$0")"

KEY_FILE=~/.ssh/id_ecdsa_sk_poc

if [ ! -f "$KEY_FILE" ]; then
    echo "Touch your YubiKey when it blinks."
    ssh-keygen -t ecdsa-sk -f "$KEY_FILE" -N "" -C "ansible-yubikey-poc"
fi

cp "$KEY_FILE.pub" id_ecdsa_sk_poc.pub
echo "Public key copied to id_ecdsa_sk_poc.pub"
