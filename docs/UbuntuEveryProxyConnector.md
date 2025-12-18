Here is the professional English Markdown format for your documentation.

***

# 🌐 System-Wide Android Proxy Setup (WSL/Linux)

This script allows you to route your WSL or Linux internet traffic through **Every Proxy** (or any HTTP proxy) with a single command. It configures `APT`, `Git`, `Wget`, and `Environment Variables` automatically.

### 🛠 Prerequisites
*   **Every Proxy** app installed and running on your Android device.
*   Your PC and Android device must be connected to the **same Wi-Fi network**.
*   Note down the **IP Address** and **Port** shown inside the Every Proxy app.

---

### 1. Edit Shell Configuration

Open your `.bashrc` file using the nano text editor:

```bash
nano ~/.bashrc
```

### 2. Add Controller Script

Paste the following code at the **bottom** of the file.
> ⚠️ **IMPORTANT:** Replace `ANDROID_IP` and `ANDROID_PORT` with the values from your phone.

```bash
# ==============================================
#  ADVANCED SYSTEM-WIDE PROXY CONTROLLER
# ==============================================
export ANDROID_IP="192.168.1.5"   # <--- Replace with your Phone IP
export ANDROID_PORT="8080"        # <--- Replace with your Port

function proxy_on() {
    local PROXY_URL="http://${ANDROID_IP}:${ANDROID_PORT}"
    
    # 1. Apply to current user session
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
    export ftp_proxy="$PROXY_URL"
    export no_proxy="localhost,127.0.0.1,::1,*.local"

    # 2. Configure Git
    git config --global http.proxy "$PROXY_URL"
    git config --global https.proxy "$PROXY_URL"

    # 3. System-wide APT configuration (Removes need for -E flag)
    # This requires sudo password as it creates a system file
    echo "Creating APT proxy config..."
    echo "Acquire::http::Proxy \"$PROXY_URL\";" | sudo tee /etc/apt/apt.conf.d/95proxy > /dev/null
    echo "Acquire::https::Proxy \"$PROXY_URL\";" | sudo tee -a /etc/apt/apt.conf.d/95proxy > /dev/null
    echo "Acquire::ftp::Proxy \"$PROXY_URL\";" | sudo tee -a /etc/apt/apt.conf.d/95proxy > /dev/null

    # 4. (Optional) Wget configuration
    # Appends to /etc/wgetrc if the proxy setting doesn't already exist
    if ! grep -q "http_proxy = $PROXY_URL" /etc/wgetrc 2>/dev/null; then
         echo "http_proxy = $PROXY_URL" | sudo tee -a /etc/wgetrc > /dev/null
         echo "https_proxy = $PROXY_URL" | sudo tee -a /etc/wgetrc > /dev/null
         echo "ftp_proxy = $PROXY_URL" | sudo tee -a /etc/wgetrc > /dev/null
    fi

    echo -e "\033[0;32m[✓] System-Wide Proxy CONNECTED to ${ANDROID_IP}:${ANDROID_PORT}\033[0m"
    echo -e "\033[0;33m(APT Config Created - sudo apt update works now)\033[0m"
}

function proxy_off() {
    # 1. Unset session variables
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy

    # 2. Unset Git configuration
    git config --global --unset http.proxy
    git config --global --unset https.proxy

    # 3. Remove APT configuration
    if [ -f /etc/apt/apt.conf.d/95proxy ]; then
        sudo rm /etc/apt/apt.conf.d/95proxy
        echo "APT proxy config removed."
    fi

    # 4. Note on Wget:
    # We generally don't remove lines from /etc/wgetrc automatically to avoid corruption.
    # However, since environment variables (step 1) take precedence, wget will stop using the proxy.

    echo -e "\033[0;31m[X] Proxy DISCONNECTED\033[0m"
}
```

Save the file (`Ctrl+O`, then `Enter`) and exit (`Ctrl+X`).

### 3. Apply Changes

Reload your shell configuration to make the functions available immediately:

```bash
source ~/.bashrc
```

---

### 4. Usage Commands

#### ✅ Enable Proxy
Turns on the proxy for Terminal, APT, and Git. You may be asked for your `sudo` password to update system files:

```bash
proxy_on
```

#### ❌ Disable Proxy
Disconnects the proxy and cleans up system configurations:

```bash
proxy_off
```

#### 🔍 Verify Connection
To ensure your traffic is being routed correctly, check your IP:

```bash
curl ipinfo.io
```