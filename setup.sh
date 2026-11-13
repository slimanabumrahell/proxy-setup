#!/data/data/com.termux/files/usr/bin/bash
# Proxy setup: يسأل عن بيانات البروكسي ويشغّله محلياً. ما فيه أي بيانات حساسة.

CONF="$HOME/.proxy.env"
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo "=============================="
echo "   إعداد البروكسي - Termux"
echo "=============================="
echo ""

read -p "نوع البروكسي (socks5 / socks4 / http / https): " PTYPE
read -p "IP البروكسي: " PIP
read -p "Port: " PPORT
read -p "Username (اتركه فاضي إذا ما في): " PUSER
read -s -p "Password (اتركه فاضي إذا ما في): " PPASS
echo ""

case "$PTYPE" in
  socks5) SCHEME="socks5h" ;;
  socks4) SCHEME="socks4a" ;;
  http)   SCHEME="http" ;;
  https)  SCHEME="https" ;;
  *) echo -e "${RED}نوع غير مدعوم${NC}"; exit 1 ;;
esac

if [ -n "$PUSER" ]; then
  AUTH="$PUSER:$PPASS@"
else
  AUTH=""
fi
PROXY_URL="$SCHEME://$AUTH$PIP:$PPORT"

# حفظ الإعدادات محلياً فقط بصلاحيات مقيّدة
cat > "$CONF" <<EOF
PROXY_URL='$PROXY_URL'
EOF
chmod 600 "$CONF"

# تفعيل المتغيرات في Termux
grep -q "proxy.env" ~/.bashrc 2>/dev/null || echo 'source ~/.proxy.env && export ALL_PROXY="$PROXY_URL" http_proxy="$PROXY_URL" https_proxy="$PROXY_URL"' >> ~/.bashrc
source "$CONF"
export ALL_PROXY="$PROXY_URL" http_proxy="$PROXY_URL" https_proxy="$PROXY_URL"

echo ""
echo -e "${GREEN}تم الحفظ. اختبار الاتصال...${NC}"
IP=$(curl -s --max-time 15 https://api.ipify.org)
if [ -n "$IP" ]; then
  echo -e "${GREEN}الاتصال يعمل. IP الظاهر: $IP${NC}"
else
  echo -e "${RED}فشل الاتصال بالبروكسي. تأكد من البيانات.${NC}"
fi
