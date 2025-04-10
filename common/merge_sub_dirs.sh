#! /bin/bash
#
# merge_sub_dirs.sh
# Copyright (C) 2025 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#


dry_run_mode=false

# 参数处理（支持选项）
while getopts ":n" opt; do
    case ${opt} in
        n ) dry_run_mode=true ;;
        \? ) echo "无效选项: -$OPTARG" >&2; exit 1 ;;
    esac
done
shift $((OPTIND -1))

# 参数检查
if [ "$#" -ne 3 ]; then
    echo "用法: $0 [-n] <目录A> <旧目录名> <新目录名>"
    echo "  -n: dry-run模式，仅显示操作不执行"
    exit 1
fi

A="$1"
old_dir="$2"
new_dir="$3"

# 基础检查
if [ ! -d "$A" ]; then
    echo "错误: 目录 $A 不存在"
    exit 1
fi

if [ "$old_dir" = "$new_dir" ]; then
    echo "错误: 旧目录名和新目录名不能相同"
    exit 1
fi

# 执行操作前的确认函数
confirm_operation() {
    local action="$1"
    local message="$2"
    if [ "$dry_run_mode" = false ]; then
        read -p "$message (y/N): " confirm
        [[ ! $confirm =~ ^[Yy]$ ]] && return 1
    fi
    return 0
}

# 处理子目录的函数
process_subdir() {
    local subdir="$1"
    local old_path="$subdir/$old_dir"
    local new_path="$subdir/$new_dir"

    # 检查旧目录是否存在
    if [ -d "$old_path" ]; then
        # 检查新目录是否存在
        if [ -d "$new_path" ]; then
            echo "检测到 $old_path 和 $new_path 同时存在"
            
            # 合并操作
            if confirm_operation "merge" "是否将 $old_path 合并到 $new_path"; then
                if $dry_run_mode; then
                    echo "[DRY-RUN] 合并操作: rsync -a --remove-source-files '$old_path/' '$new_path/'"
                    echo "[DRY-RUN] 删除源目录: rm -rf '$old_path'"
                else
                    echo "正在合并..."
                    if rsync -a --remove-source-files "$old_path/" "$new_path/"; then
                        rm -rf "$old_path"
                        echo "合并完成"
                    else
                        echo "合并失败，未删除源目录"
                    fi
                fi
            else
                echo "跳过合并操作"
            fi
        else
            echo "检测到 $old_path 需要重命名"
            
            # 重命名操作
            if confirm_operation "rename" "是否将 $old_path 重命名为 $new_path"; then
                if $dry_run_mode; then
                    echo "[DRY-RUN] 重命名: mv '$old_path' '$new_path'"
                else
                    echo "正在重命名..."
                    mv "$old_path" "$new_path" && echo "重命名成功"
                fi
            else
                echo "跳过重命名操作"
            fi
        fi
    fi
}

# 遍历目录A下的所有直接子目录
for subdir in "$A"/*; do
    if [ -d "$subdir" ]; then
        # echo "处理目录: $subdir"
        process_subdir "$subdir"
    fi
done
