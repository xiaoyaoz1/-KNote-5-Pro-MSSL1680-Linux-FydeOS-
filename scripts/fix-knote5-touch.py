#!/usr/bin/env python3
"""
Alldocube KNote 5 Pro (Silead MSSL1680) Touchscreen Range Fix
Overrides the default 4095x4095 ABS max axis values to match the actual 2048x1536 panel output.
"""
import glob
import fcntl
import struct

MAX_X = 2048
MAX_Y = 1536

def fix_touch():
    for path in glob.glob("/sys/class/input/event*/device/name"):
        try:
            with open(path) as nf:
                if nf.read().strip() == "silead_ts":
                    ev = "/dev/input/" + path.split("/")[4]
                    with open(ev, "rb+", buffering=0) as f:
                        for axis, new_max in [(0x00, MAX_X), (0x01, MAX_Y), (0x35, MAX_X), (0x36, MAX_Y)]:
                            buf = bytearray(fcntl.ioctl(f, 0x80184540 + axis, b"\x00" * 24))
                            val, minimum, maximum, fuzz, flat, res = struct.unpack("6i", buf)
                            fcntl.ioctl(f, 0x401845c0 + axis, struct.pack("6i", val, minimum, new_max, fuzz, flat, res))
                    print(f"[OK] Updated {ev} (silead_ts) ABS max range to {MAX_X}x{MAX_Y}")
        except Exception as e:
            print(f"[ERR] Failed on {path}: {e}")

if __name__ == "__main__":
    fix_touch()
