#!/bin/bash

# ==============================================================================
# IntraLinux Secure Shield - Linux CLI & headless Proxy Manager
# ==============================================================================

# CONFIGURATION
SOCKS_PORT="10808"
HTTP_PORT="10809"
DNS_PORT=""
DOH_URL="https://cloudflare-dns.com/dns-query"
BOOTSTRAP_IPS="1.1.1.1,1.0.0.1"

PID_FILE="/var/run/intralinux.pid"
if [ "$EUID" -ne 0 ]; then
    PID_FILE="$HOME/.intralinux.pid"
fi

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin"
BIN_PATH="$BIN_DIR/intra-linuxdpi"

is_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

start() {
    if is_running; then
        echo "IntraLinux is already running (PID: $(cat "$PID_FILE"))."
        return 0
    fi

    echo "Starting IntraLinux..."
    if [ ! -f "$BIN_PATH" ]; then
        echo "Error: Binary not found at $BIN_PATH"
        exit 1
    fi
    chmod +x "$BIN_PATH"

    DNS_ARG=""
    if [ -n "$DNS_PORT" ]; then
        DNS_ARG="-dns 127.0.0.1:$DNS_PORT"
    fi

    nohup "$BIN_PATH" \
        -addr "127.0.0.1:$SOCKS_PORT" \
        -http "127.0.0.1:$HTTP_PORT" \
        $DNS_ARG \
        -doh "$DOH_URL" \
        -bootstrap "$BOOTSTRAP_IPS" > /dev/null 2>&1 &

    PID=$!
    echo $PID > "$PID_FILE"
    sleep 0.5

    if is_running; then
        echo "IntraLinux started successfully (PID: $PID)."
        echo "SOCKS5 Proxy : 127.0.0.1:$SOCKS_PORT"
        echo "HTTP  Proxy  : 127.0.0.1:$HTTP_PORT"
    else
        echo "Error: Failed to start IntraLinux. Check port conflicts."
        rm -f "$PID_FILE"
        exit 1
    fi
}

stop() {
    if ! is_running; then
        echo "IntraLinux is not running."
        return 0
    fi

    PID=$(cat "$PID_FILE")
    echo "Stopping IntraLinux (PID: $PID)..."
    kill "$PID"
    rm -f "$PID_FILE"
    echo "Stopped."
}

status() {
    if is_running; then
        echo "Status: Running (PID: $(cat "$PID_FILE"))"
        echo "SOCKS5 Proxy : 127.0.0.1:$SOCKS_PORT"
        echo "HTTP  Proxy  : 127.0.0.1:$HTTP_PORT"
    else
        echo "Status: Stopped"
    fi
}

install_service() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Please run 'install' command with sudo."
        exit 1
    fi

    echo "Installing systemd service..."
    SCRIPT_PATH=$(readlink -f "$0")
    SERVICE_FILE="/etc/systemd/system/intralinux.service"

    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=IntraLinux Secure Shield Proxy Service
After=network.target

[Service]
Type=forking
ExecStart=$SCRIPT_PATH start
ExecStop=$SCRIPT_PATH stop
PIDFile=$PID_FILE
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable intralinux
    echo "IntraLinux systemd service installed and enabled."
    echo ""
    echo "  sudo systemctl start intralinux"
    echo "  sudo systemctl stop intralinux"
    echo "  sudo systemctl status intralinux"
}

uninstall_service() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Please run 'uninstall' command with sudo."
        exit 1
    fi

    systemctl stop intralinux 2>/dev/null
    systemctl disable intralinux 2>/dev/null
    rm -f /etc/systemd/system/intralinux.service
    systemctl daemon-reload
    echo "IntraLinux service removed."
}

# Multi-DE system proxy configuration
enable_system_proxy() {
    local detected=0

    # GNOME / Unity
    if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas 2>/dev/null | grep -q 'org.gnome.system.proxy'; then
        echo "[GNOME] Configuring system proxy..."
        gsettings set org.gnome.system.proxy mode 'manual'
        gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
        gsettings set org.gnome.system.proxy.socks port "$SOCKS_PORT"
        gsettings set org.gnome.system.proxy.http host '127.0.0.1'
        gsettings set org.gnome.system.proxy.http port "$HTTP_PORT"
        gsettings set org.gnome.system.proxy.https host '127.0.0.1'
        gsettings set org.gnome.system.proxy.https port "$HTTP_PORT"
        detected=1
    fi

    # KDE Plasma
    if command -v kwriteconfig5 >/dev/null 2>&1 || command -v kwriteconfig6 >/dev/null 2>&1; then
        local kwrite
        kwrite=$(command -v kwriteconfig6 2>/dev/null || command -v kwriteconfig5)
        echo "[KDE] Configuring system proxy..."
        $kwrite --file kioslaverc --group 'Proxy Settings' --key ProxyType 1
        $kwrite --file kioslaverc --group 'Proxy Settings' --key socksProxy "socks://127.0.0.1:$SOCKS_PORT"
        $kwrite --file kioslaverc --group 'Proxy Settings' --key httpProxy "http://127.0.0.1:$HTTP_PORT"
        $kwrite --file kioslaverc --group 'Proxy Settings' --key httpsProxy "http://127.0.0.1:$HTTP_PORT"
        command -v qdbus >/dev/null 2>&1 && qdbus org.kde.KIO.Scheduler /KIO/Scheduler reparseSlaveConfiguration "" 2>/dev/null
        detected=1
    fi

    # XFCE
    if command -v xfconf-query >/dev/null 2>&1; then
        echo "[XFCE] Note: Set proxy via Settings > Network Proxy manually (xfconf-query proxy support varies)."
        detected=1
    fi

    # Universal env file (works for i3, Hyprland, bspwm, Sway, etc.)
    ENV_FILE="$HOME/.config/intralinux-proxy.env"
    cat > "$ENV_FILE" <<ENVEOF
# IntraLinux proxy environment
# Source this file in your shell profile: source $ENV_FILE
export http_proxy="http://127.0.0.1:$HTTP_PORT"
export https_proxy="http://127.0.0.1:$HTTP_PORT"
export all_proxy="socks5://127.0.0.1:$SOCKS_PORT"
export HTTP_PROXY="http://127.0.0.1:$HTTP_PORT"
export HTTPS_PROXY="http://127.0.0.1:$HTTP_PORT"
export ALL_PROXY="socks5://127.0.0.1:$SOCKS_PORT"
ENVEOF

    echo ""
    echo "[ENV] Proxy env file saved: $ENV_FILE"
    echo "      Add to your shell profile (.bashrc / .zshrc / .profile):"
    echo "        source $ENV_FILE"
    echo ""
    if [ $detected -eq 0 ]; then
        echo "[INFO] No known DE detected (i3/Hyprland/bspwm?). Use 'eval \$($0 env)' or source the env file."
    fi
}

disable_system_proxy() {
    # GNOME
    if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas 2>/dev/null | grep -q 'org.gnome.system.proxy'; then
        gsettings set org.gnome.system.proxy mode 'none'
        echo "[GNOME] Proxy disabled."
    fi

    # KDE
    if command -v kwriteconfig5 >/dev/null 2>&1 || command -v kwriteconfig6 >/dev/null 2>&1; then
        local kwrite
        kwrite=$(command -v kwriteconfig6 2>/dev/null || command -v kwriteconfig5)
        $kwrite --file kioslaverc --group 'Proxy Settings' --key ProxyType 0
        command -v qdbus >/dev/null 2>&1 && qdbus org.kde.KIO.Scheduler /KIO/Scheduler reparseSlaveConfiguration "" 2>/dev/null
        echo "[KDE] Proxy disabled."
    fi

    ENV_FILE="$HOME/.config/intralinux-proxy.env"
    if [ -f "$ENV_FILE" ]; then
        rm -f "$ENV_FILE"
        echo "[ENV] Proxy env file removed: $ENV_FILE"
    fi

    echo "Proxy disabled. Restart apps or terminal for changes to take effect."
}

# Discord .desktop proxy injection
inject_discord_proxy() {
    local desktop_file=""
    local candidates=(
        "$HOME/.local/share/applications/discord.desktop"
        "$HOME/.local/share/applications/Discord.desktop"
        "/usr/share/applications/discord.desktop"
        "/usr/share/applications/Discord.desktop"
        "/usr/local/share/applications/discord.desktop"
    )

    for f in "${candidates[@]}"; do
        if [ -f "$f" ]; then
            desktop_file="$f"
            break
        fi
    done

    if [ -z "$desktop_file" ]; then
        echo "Error: Discord .desktop file not found. Checked:"
        for f in "${candidates[@]}"; do echo "  $f"; done
        return 1
    fi

    # Copy to user dir if system-wide so we don't need root
    if [[ "$desktop_file" == /usr/* ]]; then
        mkdir -p "$HOME/.local/share/applications"
        cp "$desktop_file" "$HOME/.local/share/applications/discord.desktop"
        desktop_file="$HOME/.local/share/applications/discord.desktop"
        echo "Copied to user applications: $desktop_file"
    fi

    if grep -q "proxy-server" "$desktop_file"; then
        echo "Proxy already injected in Discord launcher."
        return 0
    fi

    sed -i "/^Exec=/ s|$| --proxy-server=\"socks5://127.0.0.1:$SOCKS_PORT\" --proxy-bypass-list=\"<local>\"|" "$desktop_file"
    echo "Discord proxy injected: $desktop_file"
    echo "Restart Discord for changes to take effect."
    command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
}

remove_discord_proxy() {
    local desktop_file="$HOME/.local/share/applications/discord.desktop"
    if [ ! -f "$desktop_file" ]; then
        echo "No user-level Discord .desktop file found."
        return 0
    fi
    sed -i 's| --proxy-server="socks5://127.0.0.1:[0-9]*" --proxy-bypass-list="<local>"||g' "$desktop_file"
    echo "Discord proxy removed from launcher."
    command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
}

# Shell-aware env output (no echo noise, pure variable assignments only)
print_env() {
    if [ -n "$FISH_VERSION" ] || [ "$(basename "$SHELL" 2>/dev/null)" = "fish" ]; then
        echo "set -gx http_proxy http://127.0.0.1:$HTTP_PORT"
        echo "set -gx https_proxy http://127.0.0.1:$HTTP_PORT"
        echo "set -gx all_proxy socks5://127.0.0.1:$SOCKS_PORT"
        echo "set -gx HTTP_PROXY http://127.0.0.1:$HTTP_PORT"
        echo "set -gx HTTPS_PROXY http://127.0.0.1:$HTTP_PORT"
        echo "set -gx ALL_PROXY socks5://127.0.0.1:$SOCKS_PORT"
    else
        echo "export http_proxy=\"http://127.0.0.1:$HTTP_PORT\""
        echo "export https_proxy=\"http://127.0.0.1:$HTTP_PORT\""
        echo "export all_proxy=\"socks5://127.0.0.1:$SOCKS_PORT\""
        echo "export HTTP_PROXY=\"http://127.0.0.1:$HTTP_PORT\""
        echo "export HTTPS_PROXY=\"http://127.0.0.1:$HTTP_PORT\""
        echo "export ALL_PROXY=\"socks5://127.0.0.1:$SOCKS_PORT\""
    fi
}

print_unenv() {
    if [ -n "$FISH_VERSION" ] || [ "$(basename "$SHELL" 2>/dev/null)" = "fish" ]; then
        echo "set -e http_proxy"
        echo "set -e https_proxy"
        echo "set -e all_proxy"
        echo "set -e HTTP_PROXY"
        echo "set -e HTTPS_PROXY"
        echo "set -e ALL_PROXY"
    else
        echo "unset http_proxy"
        echo "unset https_proxy"
        echo "unset all_proxy"
        echo "unset HTTP_PROXY"
        echo "unset HTTPS_PROXY"
        echo "unset ALL_PROXY"
    fi
}

usage() {
    echo "Usage: $0 {start|stop|restart|status|install|uninstall|enable-gui|disable-gui|inject-discord|remove-discord|env|unenv}"
    echo ""
    echo "Commands:"
    echo "  start            Start the proxy background process"
    echo "  stop             Stop the proxy background process"
    echo "  restart          Restart the proxy"
    echo "  status           Show proxy status"
    echo "  install          Install systemd service (requires sudo)"
    echo "  uninstall        Uninstall systemd service (requires sudo)"
    echo "  enable-gui       Configure system proxy for GNOME/KDE/XFCE + write env file"
    echo "  disable-gui      Remove system proxy settings and env file"
    echo "  inject-discord   Inject proxy into Discord .desktop launcher"
    echo "  remove-discord   Remove proxy from Discord .desktop launcher"
    echo "  env              Print proxy env vars (Bash/Zsh/Fish auto-detected)"
    echo "  unenv            Print unset commands for proxy env vars"
    echo ""
    echo "Quick session proxy (Bash/Zsh):"
    echo "  eval \$($0 env)      # enable proxy for current shell"
    echo "  eval \$($0 unenv)    # disable proxy for current shell"
    echo ""
    echo "Fish shell:"
    echo "  eval ($0 env)"
    echo "  eval ($0 unenv)"
}

case "$1" in
    start)          start ;;
    stop)           stop ;;
    restart)        stop; sleep 0.5; start ;;
    status)         status ;;
    install)        install_service ;;
    uninstall)      uninstall_service ;;
    enable-gui)     enable_system_proxy ;;
    disable-gui)    disable_system_proxy ;;
    inject-discord) inject_discord_proxy ;;
    remove-discord) remove_discord_proxy ;;
    env)            print_env ;;
    unenv)          print_unenv ;;
    *)              usage; exit 1 ;;
esac
