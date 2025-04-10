#! /bin/bash
#
# move_smallest_dirs.sh
# Copyright (C) 2025 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#

# 默认参数
SOURCE_DIR="/srv/dev-disk-by-label-sharedcenter/Video/Adult/"
TARGET_DIR="/mnt/WAREHOUSE-WD-001/"
MOVE_COUNT=5
DRY_RUN=false
COPY_MODE=false
VERBOSE=false
LOG_FILE="move_dirs.log"

# 帮助信息
usage() {
  echo "用法: $0 [-s 源目录] [-t 目标目录] [-n 数量] [-d] [-c] [-v] [-h]"
  echo "  -s 源目录（默认当前目录）"
  echo "  -t 目标目录（默认 /opt）"
  echo "  -n 要移动/复制的子目录数量（默认 5）"
  echo "  -c 复制模式（默认是移动）"
  echo "  -d dry-run 模式（仅预览操作）"
  echo "  -v verbose 模式，显示复制/合并进度"
  echo "  -h 显示帮助信息"
  exit 1
}

# 解析参数
while getopts "s:t:n:dcvh" opt; do
  case $opt in
    s) SOURCE_DIR="$OPTARG" ;;
    t) TARGET_DIR="$OPTARG" ;;
    n) MOVE_COUNT="$OPTARG" ;;
    d) DRY_RUN=true ;;
    c) COPY_MODE=true ;;
    v) VERBOSE=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

# 检查目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ 源目录 $SOURCE_DIR 不存在。" | tee -a "$LOG_FILE"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ 目标目录 $TARGET_DIR 不存在。" | tee -a "$LOG_FILE"
  exit 1
fi

if [ "$DRY_RUN" = false ] && [ ! -w "$TARGET_DIR" ]; then
  echo "❌ 目标目录 $TARGET_DIR 不可写。" | tee -a "$LOG_FILE"
  exit 1
fi

cd "$SOURCE_DIR" || exit 1

# 获取子目录并排序
dirs=$(du -sb -- */ 2>/dev/null | sort -nr | tail -n "$MOVE_COUNT")

dir_count=$(echo "$dirs" | wc -l)
if [ "$dir_count" -lt 1 ]; then
  echo "⚠️ 没有足够的子目录进行处理。" | tee -a "$LOG_FILE"
  exit 1
fi

# 计算总大小
total_size_bytes=$(echo "$dirs" | awk '{sum += $1} END {print sum}')
total_size_human=$(numfmt --to=iec-i --suffix=B "$total_size_bytes")

# 操作预览
echo "🔍 操作预览："
echo "  源目录: $SOURCE_DIR"
echo "  目标目录: $TARGET_DIR"
echo "  目录数量: $MOVE_COUNT"
echo "  模式: $([ "$COPY_MODE" = true ] && echo "复制" || echo "移动")"
echo "  Dry-run: $DRY_RUN"
echo "  Verbose: $VERBOSE"
echo "📦 总大小：$total_size_human"
echo "📂 将处理以下目录："
echo "$dirs" | awk '{print "  - " $2}'

read -p "确认执行以上操作？[y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "🚫 用户取消操作。" | tee -a "$LOG_FILE"
  exit 0
fi

# 日志记录开始
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "===== [$timestamp] 开始操作 =====" >> "$LOG_FILE"

# 设置 rsync 参数
rsync_opts="-a"
[ "$VERBOSE" = true ] && rsync_opts="$rsync_opts --info=progress2 --stats"

# 开始处理目录
echo "$dirs" | awk '{print $2}' | while read dir; do
  src_path="$SOURCE_DIR/$dir"
  tgt_path="$TARGET_DIR/$dir"
  action_type=$([ "$COPY_MODE" = true ] && echo "COPY" || echo "MOVE")

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] $action_type: $src_path -> $tgt_path"
    echo "[dry-run] $action_type: $src_path -> $tgt_path" >> "$LOG_FILE"
    continue
  fi

  echo "🔄 $action_type 合并目录：$src_path -> $tgt_path"
  rsync $rsync_opts "$src_path/" "$tgt_path/"

  if [ $? -eq 0 ]; then
    echo "✅ 合并成功：$dir" >> "$LOG_FILE"
    [ "$COPY_MODE" = false ] && rm -rf "$src_path" && echo "🗑️ 已删除原目录：$src_path" >> "$LOG_FILE"
  else
    echo "❌ $action_type 失败：$dir" | tee -a "$LOG_FILE"
  fi
done

echo "===== [$timestamp] 操作完成 =====" >> "$LOG_FILE"

# 总结
if [ "$DRY_RUN" = true ]; then
  echo "✅ dry-run 模式完成，未进行实际更改。"
else
  echo "✅ 操作完成，详情请查看日志：$LOG_FILE"
fi
