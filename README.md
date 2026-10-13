# Ansible YubiKey PoC

This proof of concept shows how to run Ansible so that **you** can easily run it, but an AI agent (or any other process running as your user) can't: both the vault password and the SSH login need a physical touch on a YubiKey.

Tested target: YubiKey 4 (firmware 4.3.4). A YubiKey 5 works too.

## Requirements

- A YubiKey 4 or 5, plugged in
- [Docker](https://www.docker.com/) for the target host
- Ansible on the host (the YubiKey can't easily be passed into a container)
- `age`, `ykman` and `age-plugin-yubikey`:

``` bash
sudo dnf install age yubikey-manager pcsc-lite-devel
cargo install age-plugin-yubikey
```

## Usage

### Setup

``` bash
./setup-ssh-key.sh      # 1 touch: creates ~/.ssh/id_ecdsa_sk_poc
./setup-vault-pass.sh   # PIN + touches: creates YubiKey identity, vault password and secret.yml
docker build -t ansible-yubikey-poc .
docker run -d --rm --name ansible-yubikey-poc -p 2222:22 ansible-yubikey-poc
```

### Run

``` bash
ansible-playbook playbook.yml
```

Touch the YubiKey twice when it blinks: once for the vault password, once for the SSH login.
The last task shows `Target says: Unlocked with a YubiKey touch`.

### Try it as an agent

Run the playbook again and **don't** touch the YubiKey. It fails after a timeout.
Also try `./get-vault-pass.sh` or `ssh -p 2222 -i ~/.ssh/id_ecdsa_sk_poc ansible@127.0.0.1` without touching.

### Teardown

``` bash
docker rm -f ansible-yubikey-poc
docker rmi ansible-yubikey-poc
rm ~/.ssh/id_ecdsa_sk_poc ~/.ssh/id_ecdsa_sk_poc.pub
```

The age identity stays in a PIV slot of the YubiKey; `ykman piv info` shows which slot. A YubiKey 4 can't delete keys, but you can overwrite the slot or remove its certificate with `ykman piv certificates delete <slot>`.

## How it works

| Secret | Protected by | Touch |
|---|---|---|
| SSH login | `ecdsa-sk` key: the private key never leaves the YubiKey | Every connection |
| Vault password | Encrypted with [age](https://age-encryption.org/) to a key in a PIV slot via [age-plugin-yubikey](https://github.com/str4d/age-plugin-yubikey), touch policy `always` | Every decryption |

- [get-vault-pass.sh](get-vault-pass.sh) decrypts `vault-pass.age`; [ansible.cfg](ansible.cfg) uses it as `vault_password_file`.
- Unlike GPG with `pass`, there is no software cache: the YubiKey itself enforces the touch.
- One run needs 1 touch for the vault plus 1 per host. Ansible reuses the SSH connection within a run (`ControlPersist=30s`).

## Limitations

- While a connection is open (`ControlPersist`), other processes running as you can reuse it without a touch.
- During a run, the decrypted vault secrets are in Ansible's memory. With `kernel.yama.ptrace_scope=0`, other processes running as you can read that memory. Set it to `1` to prevent this.
- No PIN: someone who steals the YubiKey *and* the files in this directory can decrypt the vault password.
- YubiKey 4 firmware 4.2.6–4.3.4 has the ROCA weakness for on-device **RSA** keys. This PoC only uses elliptic-curve keys, which aren't affected.
