本仓库用于解决 **酷比魔方 KNote 5 Pro (Intel N4000)** 安装 **FydeOS** 或 **Ubuntu / Debian** 等 Linux 系统后，Silead (`MSSL1680` / `GSL3680`) 触控屏**完全无响应**或**触摸范围缩在左上角**的问题。

---

## 目录结构

```text
knote5-pro-linux-touch-fix/
├── firmware/
│   └── mssl1680.fw               # 原始无头触控固件（36,168 字节，提取自 Windows SileadTouch.sys）
├── scripts/
│   └── fix-knote5-touch.py       # 屏幕坐标轴范围校准脚本（将 4095x4095 重写为 1982x1527）
├── install-fydeos.sh             # FydeOS 一键部署脚本（含 Upstart 开机自启）
├── install-ubuntu.sh             # Ubuntu / Debian 一键部署脚本（含 systemd 开机自启）
└── README.md                     # 使用说明
