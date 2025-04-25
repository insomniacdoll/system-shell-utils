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
        echo "$src -> $dst"
    done

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] 未执行任何实际移动操作。"
    else
        echo -n "是否继续执行这些移动操作？[y/N]: "
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "已取消移动操作。"
        else
            for action in "${MOVE_ACTIONS[@]}"; do
                IFS="|" read -r src dst <<< "$action"
                mkdir -p "$(dirname "$dst")"
                mv "$src" "$dst"
                echo "已移动: $src -> $dst"
            done
        fi
    fi
fi

# 查找空目录（不包括根）
echo
echo "正在检查空目录..."

EMPTY_DIRS=()
while IFS= read -r dir; do
    # 忽略根目录本身
    [[ "$dir" == "$ROOT_DIR" ]] && continue
    # 判断是否为空目录
    if [ -z "$(ls -A "$dir")" ]; then
        EMPTY_DIRS+=("$dir")
    fi
done < <(find "$ROOT_DIR" -type d | sort -r)  # reverse 先删深层空目录

# 无空目录
if [ ${#EMPTY_DIRS[@]} -eq 0 ]; then
    echo "没有空目录。"
    exit 0
fi

# 打印空目录及其大小
echo "以下空目录可被删除："
for dir in "${EMPTY_DIRS[@]}"; do
    size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
    echo "$dir (大小：$size)"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] 未删除任何空目录。"
    exit 0
fi

echo -n "是否删除这些空目录？[y/N]: "
read -r confirm_empty
if [[ "$confirm_empty" != "y" && "$confirm_empty" != "Y" ]]; then
    echo "已跳过空目录删除。"
    exit 0
fi

# 删除空目录
for dir in "${EMPTY_DIRS[@]}"; do
    rmdir "$dir" && echo "已删除空目录: $dir"
done

