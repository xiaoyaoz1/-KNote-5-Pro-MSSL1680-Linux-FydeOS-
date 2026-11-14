#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 运行: sudo bash install-ubuntu.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "1. 安装 Silead 固件..."
mkdir -p /lib/firmware/silead
cp "$SCRIPT_DIR/firmware/mssl1680.fw" /lib/firmware/silead/mssl1680.fw
chmod 644 /lib/firmware/silead/mssl1680.fw

echo "2. 安装坐标修正脚本与 systemd 开机自启服务..."
cp "$SCRIPT_DIR/scripts/fix-knote5-touch.py" /usr/local/bin/fix-knote5-touch.py
chmod 755 /usr/local/bin/fix-knote5-touch.py

cat << 'SERVICE' > /etc/systemd/system/knote5-touch-fix.service
[Unit]
Description=Fix Silead Touchscreen Coordinates for Alldocube KNote 5 Pro
After=systemd-udevd.service

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/bin/fix-knote5-touch.py
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now knote5-touch-fix.service

echo "3. 重载驱动并立即生效..."
modprobe -r silead 2>/dev/null || true
modprobe silead
sleep 1
/usr/bin/python3 /usr/local/bin/fix-knote5-touch.py

echo "完成！Ubuntu 全屏触摸已激活。"
