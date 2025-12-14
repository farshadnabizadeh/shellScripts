#!/bin/bash

# Ask for IP
read -p "Enter Proxy IP (e.g., 192.168.1.5): " PROXY_IP

# Ask for Port (Default to 8080 if empty)
read -p "Enter Proxy Port (default 8080): " PROXY_PORT

# Set default port if user presses Enter
if [ -z "$PROXY_PORT" ]; then
    PROXY_PORT="8080"
fi

# Check if IP is empty
if [ -z "$PROXY_IP" ]; then
    echo "❌ Error: IP address is required."
    return 1 2>/dev/null || exit 1
fi

# Export Variables
export http_proxy="http://${PROXY_IP}:${PROXY_PORT}"
export https_proxy="http://${PROXY_IP}:${PROXY_PORT}"
export ftp_proxy="http://${PROXY_IP}:${PROXY_PORT}"

export HTTP_PROXY="http://${PROXY_IP}:${PROXY_PORT}"
export HTTPS_PROXY="http://${PROXY_IP}:${PROXY_PORT}"
export FTP_PROXY="http://${PROXY_IP}:${PROXY_PORT}"

export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="localhost,127.0.0.1,::1"

echo "----------------------------------------"
echo "✅ Proxy Connected Successfully!"
echo "📍 Address: http://${PROXY_IP}:${PROXY_PORT}"
echo "----------------------------------------"
