# Ansible YubiKey PoC

Demo: Ansible needs a YubiKey touch for the vault password (age + age-plugin-yubikey) and for SSH (`ecdsa-sk`). Target is a Docker sshd on port 2222; Ansible runs on the host. See [README.md](README.md) for usage.

- Status: written, not yet run. age-plugin-yubikey 0.5.1 options checked against `--help`. Setup and playbook need the YubiKey and touches, so only the user can test them.
- Test: follow README Setup, then `ansible-playbook playbook.yml`. Expect `Target says: Unlocked with a YubiKey touch`.
- Scripts must stay executable; Ansible uses a non-executable `get-vault-pass.sh` as the password text.
- Decisions: [decisions.md](decisions.md)
