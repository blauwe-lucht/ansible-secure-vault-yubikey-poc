# Decisions

- **age + age-plugin-yubikey for the vault password** (2026-10-13): the YubiKey enforces the touch, so there's no software cache like gpg-agent's (which is shared across ttys). Alternatives: age-plugin-fido2-hmac is experimental before v1.0; GPG on the card is fiddly and uses the only OpenPGP decryption slot.
- **Touch only, no PIN** (2026-10-13): a YubiKey 4 can't cache the PIV PIN, so a PIN would be needed on every decryption. The goal is to block agents, and they can't touch.
- **`ecdsa-sk` instead of `ed25519-sk`** (2026-10-13): a YubiKey 4 has U2F, not FIDO2.
- **SSH key on the YubiKey, not an SSH password in the vault** (2026-10-13): costs 1 extra touch per host, but nothing reusable leaks. A password read from Ansible's memory would give permanent access.
- **Ansible on the host, target in Docker** (2026-10-13): passing a YubiKey into a container is fragile.
- **`ControlPersist=30s`** (2026-10-13): one touch per host per run, short window for others to reuse the connection.
