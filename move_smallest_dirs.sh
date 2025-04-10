#! /bin/bash
#
# move_smallest_dirs.sh
# Copyright (C) 2025 hiyoru <insomniacdoll@gmail.com>
#
# Distributed under terms of the MIT license.
#

# 默认值
SOURCE_DIR="/srv/dev-disk-by-label-sharedcenter/Video/Adult/"
TARGET_DIR="/mnt/WAREHOUSE-WD-001/"
MOVE_COUNT=5
DRY_RUN=false
COPY_MODE=false
LOG_FILE="move_dirs.log"

# 使用帮助
usage() {
  echo "用法: $0 [-s 源目录] [-t 目标目录] [-n 数量] [-d] [-c]"
  echo "  -s 源目录（默认当前目录）"
  echo "  -t 目标目录（默认 /opt）"
  echo "  -n 移动或复制的目录数量（默认 5）"
  echo "  -d dry-run 模式（仅预览）"
  echo "  -c copy 模式（复制目录而不是移动）"
  echo "  -h 显示帮助"
  exit 1
}

# 参数解析
while getopts "s:t:n:dch" opt; do
  case $opt in
    s) SOURCE_DIR="$OPTARG" ;;
    t) TARGET_DIR="$OPTARG" ;;
    n) MOVE_COUNT="$OPTARG" ;;
    d) DRY_RUN=true ;;
    c) COPY_MODE=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

# 检查目录
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

# 获取排序后的目录列表
dirs=$(du -sb -- */ 2>/dev/null | sort -nr | tail -n "$MOVE_COUNT")

dir_count=$(echo "$dirs" | wc -l)
if [ "$dir_count" -lt 1 ]; then
  echo "⚠️ 没有足够的子目录。" | tee -a "$LOG_FILE"
  exit 1
fi

# 总大小
total_size_bytes=$(echo "$dirs" | awk '{sum += $1} END {print sum}')
total_size_human=$(numfmt --to=iec-i --suffix=B $total_size_bytes)

# 预览
echo "🔍 将从 [$SOURCE_DIR] ${COPY_MODE:+复制}${!COPY_MODE:+移动}以下 $MOVE_COUNT 个目录到 [$TARGET_DIR]："
echo "$dirs" | awk '{print $2}'
echo "📦 总大小为：$total_size_human"

# 用户确认
read -p "是否继续？[y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "操作已取消。" | tee -a "$LOG_FILE"
  exit 0
fi

# 执行操作
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "===== [$timestamp] 开始操作 =====" >> "$LOG_FILE"

echo "$dirs" | awk '{print $2}' | while read dir; do
  action_label="[dry-run] "
  action_type="MOVE"
  if [ "$COPY_MODE" = true ]; then
    action_type="COPY"
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "$action_label$action_type：$SOURCE_DIR/$dir -> $TARGET_DIR/"
    echo "$action_label$action_type：$SOURCE_DIR/$dir -> $TARGET_DIR/" >> "$LOG_FILE"
  else
    if [ "$COPY_MODE" = true ]; then
      echo "📂 正在复制：$SOURCE_DIR/$dir -> $TARGET_DIR/"
      advcp -r -g "$dir" "$TARGET_DIR/"
    else
      echo "🚚 正在移动：$SOURCE_DIR/$dir -> $TARGET_DIR/"
      advmv -g "$dir" "$TARGET_DIR/"
    fi

    if [ $? -eq 0 ]; then
      echo "✅ $action_type 成功：$dir -> $TARGET_DIR/" >> "$LOG_FILE"
    else
      echo "❌ $action_type 失败：$dir" >> "$LOG_FILE"
    fi
  fi
done

echo "===== [$timestamp] 操作完成 =====" >> "$LOG_FILE"

# 总结
if [ "$DRY_RUN" = true ]; then
  echo "✅ Dry-run 模式完成，未进行实际更改。"
else
  echo "✅ 操作完成，日志写入 $LOG_FILE"
fi
