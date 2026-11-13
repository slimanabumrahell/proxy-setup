#!/data/data/com.termux/files/usr/bin/bash
# Proxy setup for Termux. Asks for proxy details and stores them locally only.
# No sensitive data is included in this file.

CONF="$HOME/.proxy.env"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=============================="
echo "      Proxy Setup - Termux"
echo "=============================="
echo ""

read -p "Proxy type (socks5 / socks4 / http / https): " PTYPE
read -p "Proxy IP: " PIP
read -p "Port: " PPORT
read -p "Username (leave empty if none): " PUSER
read -s -p "Password (leave empty if none): " PPASS
echo ""

case "$PTYPE" in
  socks5) SCHEME="socks5h" ;;
  socks4) SCHEME="socks4a" ;;
  http)   SCHEME="http" ;;
  https)  SCHEME="https" ;;
  *)
    echo -e "${RED}Unsupported proxy type: $PTYPE${NC}"
    exit 1
    ;;
esac

if [ -n "$PUSER" ]; then
  AUTH="$PUSER:$PPASS@"
else
  AUTH=""
fi

PROXY_URL="$SCHEME://$AUTH$PIP:$PPORT"

# Save settings locally with restricted permissions
cat > "$CONF" <<EOF
PROXY_URL='$PROXY_URL'
EOF
chmod 600 "$CONF"

# Load proxy automatically in future Termux sessions (added once only)
if ! grep -q "proxy.env" ~/.bashrc 2>/dev/null; then
  echo 'source ~/.proxy.env && export ALL_PROXY="$PROXY_URL" http_proxy="$PROXY_URL" https_proxy="$PROXY_URL"' >> ~/.bashrc
fi

source "$CONF"
export ALL_PROXY="$PROXY_URL" http_proxy="$PROXY_URL" https_proxy="$PROXY_URL"

echo ""
echo -e "${GREEN}Settings saved. Testing connection...${NC}"

IP=$(curl -s --max-time 15 https://api.ipify.org)
if [ -n "$IP" ]; then
  echo -e "${GREEN}Connection works. Visible IP: $IP${NC}"
else
  echo -e "${RED}Connection failed. Check your proxy details.${NC}"
fi
