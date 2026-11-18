#!/usr/bin/env bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pacman -S --needed --noconfirm python python-evdev
mkdir -p /usr/lib/firmware/silead
cp "$DIR/firmware/mssl1680.fw" /usr/lib/firmware/silead/mssl1680.fw
chmod 644 /usr/lib/firmware/silead/mssl1680.fw
cp "$DIR/scripts/fix-knote5-touch.py" /usr/local/bin/fix-knote5-touch.py
chmod +x /usr/local/bin/fix-knote5-touch.py
echo 'ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="silead_ts", RUN+="/usr/bin/python3 /usr/local/bin/fix-knote5-touch.py"' > /etc/udev/rules.d/99-knote5-touch.rules
printf "[Unit]\nDescription=KNote 5 Pro Touch Calibration\nDefaultDependencies=no\nAfter=systemd-udevd.service\nBefore=display-manager.service\n[Service]\nType=oneshot\nRemainAfterExit=yes\nExecStart=/usr/bin/python3 /usr/local/bin/fix-knote5-touch.py\n[Install]\nWantedBy=sysinit.target\n" > /etc/systemd/system/knote-touch.service
systemctl daemon-reload && systemctl enable knote-touch.service && udevadm control --reload-rules
modprobe -r silead 2>/dev/null || true && modprobe silead && sleep 1
python3 /usr/local/bin/fix-knote5-touch.py || true
udevadm trigger --action=remove --subsystem-match=input && sleep 1 && udevadm trigger --action=add --subsystem-match=input
