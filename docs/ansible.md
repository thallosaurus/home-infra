# Ansible
Ansible takes the role to provision each server with the required configs for docker, nomad and consul. It also can be used to provision new Servers

To run it, use the following one-liner:
```bash
ansible-playbook -i inventory.ini ansible/playbook.yaml -e @static_keys.yaml --vault-password-file ansible.vault
```

This requires the following conditions:
- The working Directory must be the project root
- your ansible inventory must contain a group called `main` that holds all IPs
- your ansible-vault file must be named `@static_keys.yaml`
- your ansible-vault password must be stored in a file valled `ansible.vault`. Don't worry, the file is in `.gitignore`.

### The Ansible Vault
Currently it holds only one key that references the consul secret key. Its called `consul_encrypt_key`