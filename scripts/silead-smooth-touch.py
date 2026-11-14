#!/usr/bin/env python3
import os, glob, fcntl, struct

MIN_X, MAX_X = 3, 2050
MIN_Y, MAX_Y = 22, 1519
STATIC_DEADZONE = 10   # 静态死区：按住不动时过滤 10 单位以内的边缘抖动
FAST_THRESHOLD  = 25   # 快速滑动阈值：超过此位移立即解除强滤波，保证跟手

src_dev = None
for p in glob.glob("/sys/class/input/event*/device/name"):
    if open(p).read().strip() == "silead_ts":
        src_dev = "/dev/input/" + p.split("/")[4]
        break
if not src_dev:
    raise SystemExit("silead_ts not found")

UI_SET_EVBIT   = 0x40045564
UI_SET_KEYBIT  = 0x40045565
UI_SET_ABSBIT  = 0x40045567
UI_SET_PROPBIT = 0x4004556e
UI_DEV_SETUP   = 0x405c5503
UI_ABS_SETUP   = 0x401c5504
UI_DEV_CREATE  = 0x5501
EVIOCGRAB      = 0x40044590

uifd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
fcntl.ioctl(uifd, UI_SET_EVBIT, 0x01)
fcntl.ioctl(uifd, UI_SET_KEYBIT, 0x14a)
fcntl.ioctl(uifd, UI_SET_EVBIT, 0x03)
fcntl.ioctl(uifd, UI_SET_PROPBIT, 0x01)

axes = [
    (0x00, MIN_X, MAX_X),
    (0x01, MIN_Y, MAX_Y),
    (0x2f, 0, 9),
    (0x30, 0, 255),
    (0x35, MIN_X, MAX_X),
    (0x36, MIN_Y, MAX_Y),
    (0x39, 0, 65535),
]
for code, mn, mx in axes:
    fcntl.ioctl(uifd, UI_SET_ABSBIT, code)
    fcntl.ioctl(uifd, UI_ABS_SETUP, struct.pack("Hiiiiii", code, 0, mn, mx, 0, 0, 0))

fcntl.ioctl(uifd, UI_DEV_SETUP, struct.pack("HHHH80sI", 0x18, 0x1234, 0x5678, 1, b"KNote5 Smooth Touchscreen", 0))
fcntl.ioctl(uifd, UI_DEV_CREATE)

src = os.open(src_dev, os.O_RDONLY)
fcntl.ioctl(src, EVIOCGRAB, 1)

slot = 0
state = {}

def filter_axis(val, idx_ema, idx_out, st):
    if st[idx_ema] is None:
        st[idx_ema] = float(val)
        st[idx_out] = val
        return val
    diff = abs(val - st[idx_out])
    alpha = 0.85 if diff > FAST_THRESHOLD else 0.25
    st[idx_ema] = alpha * val + (1.0 - alpha) * st[idx_ema]
    if abs(st[idx_ema] - st[idx_out]) >= STATIC_DEADZONE:
        st[idx_out] = int(round(st[idx_ema]))
    return st[idx_out]

while True:
    data = os.read(src, 24)
    sec, usec, etype, code, val = struct.unpack("llHHi", data)
    if etype == 3:
        if code == 0x2f:
            slot = val
        elif code == 0x39 and val == -1:
            state.pop(slot, None)
        elif code in (0x00, 0x35):
            st = state.setdefault(slot, [None, None, None, None])
            val = filter_axis(val, 0, 2, st)
        elif code in (0x01, 0x36):
            st = state.setdefault(slot, [None, None, None, None])
            val = filter_axis(val, 1, 3, st)
    os.write(uifd, struct.pack("llHHi", sec, usec, etype, code, val))
