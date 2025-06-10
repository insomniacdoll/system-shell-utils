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

def get_mountpoint_from_path(path):
    """
    根据输入路径查找其挂载点
    """
    try:
        output = subprocess.check_output(
            ["findmnt", "--target", path, "-n", "-o", "TARGET"],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        mountpoint = output.strip()
        if not mountpoint:
            return None
        return mountpoint
    except subprocess.CalledProcessError as e:
        print(f"Error finding mountpoint for {path}: {e.output}")
        return None

def get_device_from_mountpoint(mountpoint):
    """
    获取挂载点对应的设备文件（如 /dev/sdb2）
    """
    try:
        output = subprocess.check_output(
            ["findmnt", "-n", "-o", "SOURCE", mountpoint],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        return output.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error finding device for {mountpoint}: {e.output}")
        return None

def get_disk_from_partition(partition_device):
    """
    从分区设备（如 /dev/sdb2）获取磁盘设备（如 /dev/sdb）
    """
    try:
        output = subprocess.check_output(
            ["lsblk", "-n", "-o", "PKNAME", partition_device],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        disk_name = output.strip()
        if not disk_name:
            return None
        return f"/dev/{disk_name}"
    except subprocess.CalledProcessError as e:
        print(f"Error getting disk from {partition_device}: {e.output}")
        return None

def get_serial_from_device(device):
    """
    通过 lsblk 获取磁盘设备的序列号
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

    # 如果设备是分区（如 /dev/sdb2），获取对应的磁盘（如 /dev/sdb）
    if device.endswith(tuple("0123456789")):  # 判断是否为分区
        disk_device = get_disk_from_partition(device)
        if not disk_device:
            return None
        device = disk_device

    return get_serial_from_device(device)

def get_serial_from_path(path):
    """
    根据任意路径获取磁盘序列号
    """
    mountpoint = get_mountpoint_from_path(path)
    if not mountpoint:
        return None

    return get_serial_from_mountpoint(mountpoint)

# 示例用法
if __name__ == "__main__":
    input_path = "/srv/dev-disk-by-label-app/AppData/"  # 替换为实际路径
    serial = get_serial_from_path(input_path)
    if serial:
        print(f"Serial number for path '{input_path}': {serial}")
    else:
        print(f"Failed to get serial number for path '{input_path}'")
