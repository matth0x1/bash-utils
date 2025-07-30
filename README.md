# bash-utils

Reusable Bash utilities, installable via GitHub releases.

## 🔧 Install

```bash
LATEST=$(curl -s https://api.github.com/repos/matth0x1/bash-utils/releases/latest | jq -r .tag_name)
curl -L -o /usr/local/bin/log_json https://github.com/matth0x1/bash-utils/releases/download/$LATEST/log_json
chmod +x /usr/local/bin/log_json
```

## 🚀 Usage

```bash
log_json info "Starting process"
log_json error "Something went wrong"
log_json --version
```

## 🧰 Requirements

- `jq` installed
