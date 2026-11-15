#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 或 root 权限运行: sudo bash install-fydeos.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "1. 挂载根分区为可读写..."
mount -o remount,rw /

echo "2. 安装 Silead 固件 (/lib/firmware/silead/mssl1680.fw)..."
mkdir -p /lib/firmware/silead
cp "$SCRIPT_DIR/firmware/mssl1680.fw" /lib/firmware/silead/mssl1680.fw
chmod 644 /lib/firmware/silead/mssl1680.fw

echo "3. 安装全屏校准与抗抖动守护脚本..."
mkdir -p /usr/local/bin
cp "$SCRIPT_DIR/scripts/silead-smooth-touch.py" /usr/local/bin/silead-smooth-touch.py
chmod 755 /usr/local/bin/silead-smooth-touch.py

cat << 'CONF' > /etc/init/fix-silead-touch.conf
description "KNote 5 Pro Silead Touchscreen Anti-Jitter & Bounds Service"

start on started boot-services
stop on stopping boot-services
respawn
respawn limit 15 5

pre-start script
  modprobe uinput || true
  if ! grep -q "silead_ts" /sys/class/input/event*/device/name 2>/dev/null; then
    modprobe -r silead 2>/dev/null || true
    modprobe silead || true
  fi
  for i in $(seq 1 30); do
    grep -q "silead_ts" /sys/class/input/event*/device/name 2>/dev/null && break
    sleep 0.5
  done
end script

exec /usr/bin/python3 /usr/local/bin/silead-smooth-touch.py >> /var/log/silead-touch.log 2>&1
CONF

echo "4. 加载驱动与 uinput 模块并启动服务..."
modprobe -r silead 2>/dev/null || true
modprobe silead
modprobe uinput
sleep 1
initctl reload-configuration
restart fix-silead-touch 2>/dev/null || start fix-silead-touch

echo "完成！KNote 5 Pro 全屏精准与抗抖动触控已激活。"
