# Claude Projects Sync

Private encrypted sync for `~/.claude/projects` between machines using your SSH key.

## Quick Setup (new machine)

```bash
git clone git@github.com:cryptid11/sync.git ~/sync

# Add aliases to your shell
echo 'alias cpush="~/sync/sync-push.sh"' >> ~/.bashrc
echo 'alias cpull="~/sync/sync-pull.sh"' >> ~/.bashrc
source ~/.bashrc
```

For zsh, use `~/.zshrc` instead.

## Usage

```bash
cpush   # zip, encrypt, push
cpull   # pull, decrypt, extract
```

## How it works

- Encryption: AES-256-CBC via openssl
- Key: SHA-256 hash of your SSH private key (`~/.ssh/id_rsa`)
- Same SSH key on both machines = same encryption key

## Custom SSH key

```bash
SSH_KEY=~/.ssh/id_ed25519 cpush
```
