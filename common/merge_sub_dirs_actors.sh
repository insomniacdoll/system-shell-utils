#! /bin/bash
#
# merge_sub_dirs_actors.sh
# Copyright (C) 2025 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#

set -e

# 参数解析
OPTIONS=d:k:n
LONGOPTS=dir:,keyword:,dry-run

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    echo "参数解析失败"
    exit 2
fi

eval set -- "$PARSED"

ROOT_DIR=""
KEYWORD=""
DRY_RUN=0

while true; do
    case "$1" in
        -d|--dir)
            ROOT_DIR="$2"
            shift 2
            ;;
        -k|--keyword)
            KEYWORD="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "未知参数: $1"
            exit 3
            ;;
    esac
done

if [[ -z "$ROOT_DIR" || -z "$KEYWORD" ]]; then
    echo "用法: $0 --dir <路径> --keyword <关键词> [--dry-run]"
    exit 1
fi

# 查找目标根目录
TARGET_ROOT=""
for dir in "$ROOT_DIR"/*; do
    if [ -d "$dir" ] && [[ "$(basename "$dir")" == "$KEYWORD" ]]; then
        TARGET_ROOT="$dir"
        break
    fi
done

if [ -z "$TARGET_ROOT" ]; then
    echo "未找到关键词对应的根目录: $KEYWORD"
    exit 1
fi

# 收集待移动目录
declare -a MOVE_ACTIONS

while IFS= read -r subdir; do
    CNAME="$(basename "$subdir")"
    if [[ "$CNAME" == *"$KEYWORD"* ]]; then
        BNAME="$(basename "$(dirname "$subdir")")"
        DEST_B="$TARGET_ROOT/$BNAME"
        DEST_C="$DEST_B/$CNAME"

        if [[ "$subdir" == "$DEST_C" ]]; then
            continue
        fi

        MOVE_ACTIONS+=("$subdir|$DEST_C")
    fi
done < <(find "$ROOT_DIR" -mindepth 3 -maxdepth 3 -type d)

# 无需移动
if [ ${#MOVE_ACTIONS[@]} -eq 0 ]; then
    echo "没有找到任何包含 '$KEYWORD' 的目录需要移动。"
else
    echo "以下目录将被移动："
    for action in "${MOVE_ACTIONS[@]}"; do
        IFS="|" read -r src dst <<< "$action"
        echo "  $src -> $dst"
    done

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] 未执行任何实际移动操作。"
    else
        read -rp "是否继续执行这些移动操作？[y/N]: " confirm_move
        if [[ "$confirm_move" =~ ^[Yy]$ ]]; then
            for action in "${MOVE_ACTIONS[@]}"; do
                IFS="|" read -r src dst <<< "$action"
                mkdir -p "$(dirname "$dst")"
                mv "$src" "$dst"
                echo "已移动: $src -> $dst"
            done
        else
            echo "已取消移动操作。"
        fi
    fi
fi

# 查找并删除空目录（带确认和大小显示）
echo
echo "正在检查并删除空目录..."

# 第一轮：扫描二级目录（depth=2）
declare -a EMPTY_SECOND_LEVEL=()
while IFS= read -r dir; do
    if [ -z "$(ls -A "$dir")" ]; then
        EMPTY_SECOND_LEVEL+=("$dir")
    fi
done < <(find "$ROOT_DIR" -mindepth 2 -maxdepth 2 -type d)

if [ ${#EMPTY_SECOND_LEVEL[@]} -eq 0 ]; then
    echo "没有空的二级目录。"
else
    echo "以下二级目录为空："
    for dir in "${EMPTY_SECOND_LEVEL[@]}"; do
        size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        echo "  $dir (大小: $size)"
    done

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] 未删除任何二级目录。"
    else
        read -rp "是否删除以上二级目录？[y/N]: " confirm_sec
        if [[ "$confirm_sec" =~ ^[Yy]$ ]]; then
            for dir in "${EMPTY_SECOND_LEVEL[@]}"; do
                size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
                echo "删除: $dir (大小: $size)"
                rmdir "$dir" && echo "已删除二级目录: $dir"
            done
        else
            echo "已跳过二级目录删除。"
        fi
    fi
fi

# 第二轮：扫描一级目录（depth=1）
declare -a EMPTY_FIRST_LEVEL=()
while IFS= read -r dir; do
    if [ "$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 0 ]; then
        EMPTY_FIRST_LEVEL+=("$dir")
    fi
done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d)

if [ ${#EMPTY_FIRST_LEVEL[@]} -eq 0 ]; then
    echo "没有空的一级目录需要删除。"
else
    echo "以下一级目录已无子目录："
    for dir in "${EMPTY_FIRST_LEVEL[@]}"; do
        size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        echo "  $dir (大小: $size)"
    done

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] 未删除任何一级目录。"
    else
        read -rp "是否删除以上一级目录？[y/N]: " confirm_first
        if [[ "$confirm_first" =~ ^[Yy]$ ]]; then
            for dir in "${EMPTY_FIRST_LEVEL[@]}"; do
                size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
                echo "删除: $dir (大小: $size)"
                rmdir "$dir" && echo "已删除一级目录: $dir"
            done
        else
            echo "已跳过一级目录删除。"
        fi
    fi
fi

exit 0
