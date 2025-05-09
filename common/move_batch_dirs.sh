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
SORT_MODE="size"  # 或 "mtime"
SORT_ORDER="asc"  # asc（从小到大/旧到新）或 desc（从大到小/新到旧）
LOG_FILE="move_dirs.log"

usage() {
  echo "用法: $0 [-s 源目录] [-t 目标目录] [-n 数量] [-c] [-d] [-v] [-m sort_mode] [-o order] [-h]"
  echo "  -s 源目录（默认: $SOURCE_DIR）"
  echo "  -t 目标目录（默认: $TARGET_DIR）"
  echo "  -n 处理子目录数量（默认: $MOVE_COUNT）"
  echo "  -c 使用复制模式（默认为移动）"
  echo "  -d dry-run 预览模式"
  echo "  -v verbose 模式，显示详细信息"
  echo "  -m 排序依据：size 或 mtime"
  echo "  -o 排序顺序：asc 或 desc"
  echo "  -h 显示此帮助信息"
  exit 1
}

parse_args() {
  while getopts "s:t:n:dcvm:o:h" opt; do
    case $opt in
      s) SOURCE_DIR="$OPTARG" ;;
      t) TARGET_DIR="$OPTARG" ;;
      n) MOVE_COUNT="$OPTARG" ;;
      d) DRY_RUN=true ;;
      c) COPY_MODE=true ;;
      v) VERBOSE=true ;;
      m) SORT_MODE="$OPTARG" ;;
      o) SORT_ORDER="$OPTARG" ;;
      h) usage ;;
      *) usage ;;
    esac
  done
}

check_dirs() {
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
}

get_sorted_dirs() {
  cd "$SOURCE_DIR" || exit 1
  if [ "$SORT_MODE" = "size" ]; then
    if [ "$SORT_ORDER" = "asc" ]; then
      du -sb -- */ 2>/dev/null | sort -n | head -n "$MOVE_COUNT"
    else
      du -sb -- */ 2>/dev/null | sort -nr | head -n "$MOVE_COUNT"
    fi
  elif [ "$SORT_MODE" = "mtime" ]; then
    local dir_info=()
    for d in */; do
      [ -d "$d" ] || continue
      local latest_mtime=$(find "$d" -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n1)
      [ -z "$latest_mtime" ] && continue
      local dir_size=$(du -sb "$d" 2>/dev/null | awk '{print $1}')
      dir_info+=("$latest_mtime|$dir_size|$d")
    done
    if [ "$SORT_ORDER" = "desc" ]; then
      printf "%s\n" "${dir_info[@]}" | sort -t'|' -k1,1nr | head -n "$MOVE_COUNT"
    else
      printf "%s\n" "${dir_info[@]}" | sort -t'|' -k1,1n | head -n "$MOVE_COUNT"
    fi
  else
    echo "❌ 无效排序方式: $SORT_MODE" | tee -a "$LOG_FILE"
    exit 1
  fi
}

print_preview() {
  echo "🔍 操作预览："
  echo "  源目录: $SOURCE_DIR"
  echo "  目标目录: $TARGET_DIR"
  echo "  数量: $MOVE_COUNT"
  echo "  模式: $([ "$COPY_MODE" = true ] && echo "复制" || echo "移动")"
  echo "  Dry-run: $DRY_RUN"
  echo "  Verbose: $VERBOSE"
  echo "  排序依据: $SORT_MODE"
  echo "  排序顺序: $SORT_ORDER"
  echo "📂 将处理以下目录："

  total_size=0

  if [ "$SORT_MODE" = "mtime" ]; then
    while IFS='|' read -r mtime size dir; do
      human_size=$(numfmt --to=iec-i --suffix=B "$size")
      formatted_time=$(date -d @"${mtime%.*}" "+%Y-%m-%d %H:%M:%S")
      echo "  - $dir [$human_size] 最后修改：$formatted_time"
      total_size=$((total_size + size))
    done <<< "$1"
  else
    while IFS=$'\t' read -r size dir; do
      human_size=$(numfmt --to=iec-i --suffix=B "$size")
      echo "  - $dir [$human_size]"
      total_size=$((total_size + size))
    done <<< "$1"
  fi

  human_total=$(numfmt --to=iec-i --suffix=B "$total_size")
  echo "📦 目录总大小：$human_total"
}

perform_operation() {
  local rsync_opts="-a"
  [ "$VERBOSE" = true ] && rsync_opts="$rsync_opts --info=progress2 --stats"
  local dirs_to_delete=()

  while read -r line; do
    if [ "$SORT_MODE" = "mtime" ]; then
      IFS='|' read -r _ size dir <<< "$line"
    else
      IFS=$'\t' read -r size dir <<< "$line"
    fi
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
  done <<< "$1"

  if [ "$DRY_RUN" = false ]; then
    echo ""
    echo "📊 目标目录中新增子目录的大小："
    echo "-----------------------------------"
    while read -r line; do
      if [ "$SORT_MODE" = "mtime" ]; then
        IFS='|' read -r _ _ dir <<< "$line"
      else
        IFS=$'\t' read -r _ dir <<< "$line"
      fi
      du -sh "$TARGET_DIR/$dir"
    done <<< "$1" | tee -a "$LOG_FILE"
    echo "-----------------------------------"
  fi

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
}

main() {
  parse_args "$@"
  check_dirs
  dir_info=$(get_sorted_dirs)

  if [ -z "$dir_info" ]; then
    echo "⚠️ 没有符合条件的子目录。" | tee -a "$LOG_FILE"
    exit 1
  fi

  print_preview "$dir_info"
  read -p "确认执行以上操作？[y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "🚫 用户取消操作。" | tee -a "$LOG_FILE"
    exit 0
  fi

  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "===== [$timestamp] 操作开始 =====" >> "$LOG_FILE"
  perform_operation "$dir_info"
  echo "===== [$timestamp] 操作完成 =====" >> "$LOG_FILE"

  if [ "$DRY_RUN" = true ]; then
    echo "✅ dry-run 模式完成，未执行任何更改。"
  else
    echo "✅ 操作完成，详情请查看日志文件：$LOG_FILE"
  fi
}

main "$@"
