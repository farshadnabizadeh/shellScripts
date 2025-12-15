# WSL2 & Docker Helper Scripts

A collection of utility scripts to manage the Docker environment and network proxy settings within WSL2.

---

## 🐳 Docker Management

### Hard Reset Docker
This script performs a complete cleanup of the Docker environment. It removes **all** containers, images, volumes, and networks to restore Docker to a factory clean state.

> **⚠️ WARNING:** This operation is irreversible. All local database data, volumes, and container configurations will be permanently deleted.
```bash
# 1. Grant execution permission (Run only once)
chmod +x reset-docker.sh

# 2. Execute the reset script
./reset-docker.sh

---

## 🌐 Network Proxy Configuration

Use these scripts to route your WSL2 terminal traffic through a specific proxy server (e.g., `Every Proxy` on Android).

### 🟢 Enable Proxy
To apply proxy settings to the **current shell session**, you must execute the script using the `source` command.

bash
# Prompts for IP and Port, then exports proxy variables
source proxy-on.sh

**Important Note for `sudo` commands:**
By default, `sudo` does not inherit environment variables. When the proxy is active, you **must** use the `-E` flag to preserve the proxy settings for the root user.

bash
# Example: Update package lists using the active proxy
sudo -E apt-get update

### 🔴 Disable Proxy
To unset all proxy environment variables and return to the direct network connection:

bash
source proxy-off.sh

---

### 🛠 Verification
To verify that your proxy settings are correctly applied:

bash
# Check current environment variables
env | grep -i proxy

# Test connectivity
curl -I http://google.com
