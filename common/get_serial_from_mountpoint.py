#! /usr/bin/env python3
# vim:fenc=utf-8
#
# Copyright © 2025 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.

"""
get_serial_from_mountpoint
"""

import subprocess

def get_device_from_mountpoint(mountpoint):
    """
    获取挂载点对应的设备文件（如 /dev/sda1）
    """
    try:
        # 使用 findmnt 获取设备文件
        output = subprocess.check_output(
            ["findmnt", "-n", "-o", "SOURCE", mountpoint],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        device = output.strip()
        return device
    except subprocess.CalledProcessError as e:
        print(f"Error finding device for {mountpoint}: {e.output}")
        return None

def get_serial_from_device(device):
    """
    通过 lsblk 获取设备的序列号
    """
    try:
        output = subprocess.check_output(
            ["lsblk", "-n", "--nodeps", "-o", "SERIAL", device],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        serial = output.strip()
        return serial
    except subprocess.CalledProcessError as e:
        print(f"Error getting serial for {device}: {e.output}")
        return None

def get_serial_from_mountpoint(mountpoint):
    """
    根据挂载点获取磁盘序列号
    """
    device = get_device_from_mountpoint(mountpoint)
    if not device:
        return None
    return get_serial_from_device(device)

# 示例用法
if __name__ == "__main__":
    mountpoint = "/"  # 替换为需要查询的挂载点
    serial = get_serial_from_mountpoint(mountpoint)
    if serial:
        print(f"Serial number for {mountpoint}: {serial}")
    else:
        print(f"Failed to get serial number for {mountpoint}")
