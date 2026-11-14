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

echo "3. 安装坐标修正脚本与 Upstart 开机自启任务..."
mkdir -p /usr/local/bin
cp "$SCRIPT_DIR/scripts/fix-knote5-touch.py" /usr/local/bin/fix-knote5-touch.py
chmod 755 /usr/local/bin/fix-knote5-touch.py

cat << 'CONF' > /etc/init/fix-silead-touch.conf
description "Fix Silead touchscreen max ABS coordinates for KNote 5 Pro"

start on started ui
task

script
  sleep 2
  /usr/bin/python3 /usr/local/bin/fix-knote5-touch.py
  udevadm trigger --subsystem-match=input --action=change
end script
CONF

echo "4. 重载驱动并应用校准..."
modprobe -r silead 2>/dev/null || true
modprobe silead
sleep 1
/usr/bin/python3 /usr/local/bin/fix-knote5-touch.py
udevadm trigger --subsystem-match=input --action=change
initctl reload-configuration

echo "完成！全屏触摸已激活。"
