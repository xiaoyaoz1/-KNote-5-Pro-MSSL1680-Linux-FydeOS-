Markdown
# 酷比魔方 KNote 5 Pro Linux 触控屏修复方案

本仓库用于解决 **酷比魔方 KNote 5 Pro (Intel N4000)** 安装 **FydeOS**、**Omarchy / Arch Linux** 或 **Ubuntu / Debian** 等 Linux 系统后，Silead (`MSSL1680` / `GSL3680`) 触控屏**完全无响应**或**触摸范围缩在左上角**的问题。

---

## 一键快速安装（推荐）

在目标系统的终端中直接运行对应命令即可自动拉取并完成部署：

### 1. Omarchy / Arch Linux（Wayland / Hyprland）
```bash
git clone --depth 1 [https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git](https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git) /tmp/knote-touch && sudo bash /tmp/knote-touch/install-arch.sh && rm -rf /tmp/knote-touch
2. Ubuntu / Debian
Bash
git clone --depth 1 [https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git](https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git) /tmp/knote-touch && sudo bash /tmp/knote-touch/install-ubuntu.sh && rm -rf /tmp/knote-touch
3. FydeOS
Bash
git clone --depth 1 [https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git](https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git) /tmp/knote-touch && sudo bash /tmp/knote-touch/install-fydeos.sh && rm -rf /tmp/knote-touch
目录结构
Plaintext
knote5-pro-linux-touch-fix/
├── firmware/
│   └── mssl1680.fw               # 原始无头触控固件（36,168 字节，提取自 Windows SileadTouch.sys）
├── scripts/
│   └── fix-knote5-touch.py       # 屏幕坐标轴范围校准脚本（将 4095x4095 重写为 2048x1536）
├── install-arch.sh               # Omarchy / Arch Linux 一键部署脚本（含 udev 与 systemd 启动前校准）
├── install-fydeos.sh             # FydeOS 一键部署脚本（含 Upstart 开机自启）
├── install-ubuntu.sh             # Ubuntu / Debian 一键部署脚本（含 systemd 开机自启）
└── README.md                     # 使用说明
手动分步安装
如需保留仓库文件进行调试，可先克隆仓库再运行对应脚本：
Bash
git clone [https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git](https://github.com/xiaoyaoz1/-KNote-5-Pro-MSSL1680-Linux-FydeOS-.git)
cd -KNote-5-Pro-MSSL1680-Linux-FydeOS-

# 按当前系统选择其一执行：
sudo bash install-arch.sh     # Omarchy / Arch Linux
sudo bash install-ubuntu.sh   # Ubuntu / Debian
sudo bash install-fydeos.sh   # FydeOS
