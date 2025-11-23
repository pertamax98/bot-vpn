#!/bin/bash
set -e

echo "=============================================="
echo "     🟩 INSTALLER BOT VPN (NODE 20 + SYSTEMD)"
echo "=============================================="
git clone https://github.com/pertamax98/bot-vpn.git
cd bot-vpn
# Pastikan script dijalankan di folder bot-vpn
if [ ! -f "app.js" ]; then
    echo "❌ Jalankan script ini di dalam folder bot-vpn!"
    exit 1
fi

echo "➤ Menginstall dependency sistem..."
sudo apt update -y
sudo apt install -y curl git build-essential

echo "➤ Menginstall NVM..."
export PROFILE=/etc/profile
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc || true
source /etc/profile || true

echo "➤ Menginstall Node.js 20..."
nvm install 20
nvm use 20

echo "➤ Menginstall dependensi project..."
npm install --silent

echo "=============================================="
echo "  INPUT KONFIGURASI BOT KE .vars.json"
echo "=============================================="

read -p "Bot Token: " BOT_TOKEN
read -p "User ID Admin (angka): " USER_ID
read -p "Group ID Log (opsional, isi 0 jika tidak ada): " GROUP_ID
#read -p "Port HTTP API (default 6969): " PORT
read -p "Nama Store (misal: @MyStoreVPN): " NAMA_STORE
read -p "Data QRIS (base64 string QRIS): " DATA_QRIS
read -p "Username Orkut (AutoFT): " USERNAME_ORKUT
read -p "Auth Token AutoFT: " AUTH_TOKEN
read -p "Admin Username (tanpa @): " ADMIN_USERNAME
read -p "SSH User (default root): " SSH_USER
read -p "Password VPS (SSH_PASS): " SSH_PASS

# Generate .vars.json
cat <<EOF > .vars.json
{
  "BOT_TOKEN": "$BOT_TOKEN",
  "USER_ID": $USER_ID,
  "GROUP_ID": $GROUP_ID,
  "PORT": 50123,
  "NAMA_STORE": "$NAMA_STORE",
  "DATA_QRIS": "$DATA_QRIS",
  "USERNAME_ORKUT": "$USERNAME_ORKUT",
  "AUTH_TOKEN": "$AUTH_TOKEN",
  "ADMIN_USERNAME": "$ADMIN_USERNAME",
  "SSH_USER": "$SSH_USER",
  "SSH_PASS": "$SSH_PASS"
}
EOF

echo "➤ Konfigurasi .vars.json berhasil dibuat!"
echo "=============================================="

SERVICE_FILE="/etc/systemd/system/vpn-bot.service"

echo "➤ Membuat systemd service..."

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=VPN Telegram Bot
After=network.target

[Service]
WorkingDirectory=$(pwd)
ExecStart=$(which node) app.js
Restart=always
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=vpn-bot
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

echo "➤ Reload & Enable service..."

sudo systemctl daemon-reload
sudo systemctl enable vpn-bot
sudo systemctl restart vpn-bot

echo "=============================================="
echo " 🟢 BOT BERHASIL DIINSTALL & BERJALAN OTOMATIS "
echo "=============================================="
echo " Cek bot menggunakan:"
echo "   sudo systemctl status vpn-bot"
echo "   sudo journalctl -fu vpn-bot"
echo "=============================================="