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
  echo "用法: $0 [-s 源目录] [-t 目标目录] [-n 数量] [-c] [-d] [-v] [-h]"
  echo "  -s 源目录（默认当前目录）"
  echo "  -t 目标目录（默认 /opt）"
  echo "  -n 要处理的子目录数量（默认 5）"
  echo "  -c 复制模式（默认为移动）"
  echo "  -d dry-run 模式（预览操作）"
  echo "  -v verbose 模式，显示进度和统计"
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

# 获取子目录按大小排序
dirs=$(du -sb -- */ 2>/dev/null | sort -nr | tail -n "$MOVE_COUNT")

dir_count=$(echo "$dirs" | wc -l)
if [ "$dir_count" -lt 1 ]; then
  echo "⚠️ 没有足够的子目录进行处理。" | tee -a "$LOG_FILE"
  exit 1
fi

dir_list=$(echo "$dirs" | awk '{print $2}')
total_size_bytes=$(echo "$dirs" | awk '{sum += $1} END {print sum}')
total_size_human=$(numfmt --to=iec-i --suffix=B "$total_size_bytes")

# 操作预览
echo "🔍 操作预览："
echo "  源目录: $SOURCE_DIR"
echo "  目标目录: $TARGET_DIR"
echo "  数量: $MOVE_COUNT"
echo "  模式: $([ "$COPY_MODE" = true ] && echo "复制" || echo "移动")"
echo "  Dry-run: $DRY_RUN"
echo "  Verbose: $VERBOSE"
echo "📦 总大小: $total_size_human"
echo "📂 将处理以下目录："
echo "$dir_list" | sed 's/^/  - /'

read -p "确认执行以上操作？[y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "🚫 用户取消操作。" | tee -a "$LOG_FILE"
  exit 0
fi

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "===== [$timestamp] 操作开始 =====" >> "$LOG_FILE"

# 设置 rsync 参数
rsync_opts="-a"
[ "$VERBOSE" = true ] && rsync_opts="$rsync_opts --info=progress2 --stats"

# 保存待删除的原目录（仅移动模式）
dirs_to_delete=()

# 执行复制/合并
echo "$dir_list" | while read dir; do
  src_path="$SOURCE_DIR/$dir"
  tgt_path="$TARGET_DIR/$dir"
  action=$([ "$COPY_MODE" = true ] && echo "COPY" || echo "MOVE")

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] $action: $src_path -> $tgt_path"
    echo "[dry-run] $action: $src_path -> $tgt_path" >> "$LOG_FILE"
    continue
  fi

  echo "🔄 $action 合并目录：$src_path -> $tgt_path"
  rsync $rsync_opts "$src_path/" "$tgt_path/"

  if [ $? -eq 0 ]; then
    echo "✅ 合并成功：$dir" >> "$LOG_FILE"
    [ "$COPY_MODE" = false ] && dirs_to_delete+=("$src_path")
  else
    echo "❌ 合并失败：$dir" | tee -a "$LOG_FILE"
  fi
done

# 展示目标目录的新增大小
if [ "$DRY_RUN" = false ]; then
  echo ""
  echo "📊 目标目录中新增子目录的总大小："
  echo "-----------------------------------"
  for dir in $dir_list; do
    du -sh "$TARGET_DIR/$dir"
  done | tee -a "$LOG_FILE"
  echo "-----------------------------------"
fi

# 删除确认（仅移动）
if [ "$COPY_MODE" = false ] && [ "$DRY_RUN" = false ] && [ "${#dirs_to_delete[@]}" -gt 0 ]; then
  echo ""
  echo "📋 以下原始目录将被删除："
  for dir in "${dirs_to_delete[@]}"; do
    echo "  - $dir"
  done
  read -p "是否删除这些源目录？[y/N] " del_confirm
  if [[ "$del_confirm" == "y" || "$del_confirm" == "Y" ]]; then
    for dir in "${dirs_to_delete[@]}"; do
      rm -rf "$dir"
      echo "🗑️ 已删除：$dir" >> "$LOG_FILE"
    done
    echo "✅ 所有源目录已删除。"
  else
    echo "🚫 用户取消删除操作。源目录未被删除。"
  fi
fi

echo "===== [$timestamp] 操作完成 =====" >> "$LOG_FILE"

if [ "$DRY_RUN" = true ]; then
  echo "✅ dry-run 模式完成，未执行任何更改。"
else
  echo "✅ 操作完成，详情请查看日志文件：$LOG_FILE"
fi
