#!/bin/bash
# =============================================================
# log.sh - 学習記録の追加・コミット・プッシュを自動化するスクリプト
# =============================================================
#
# 使い方:
#   ./log.sh "学習内容1" "学習内容2" ...
#   ./log.sh -f input.txt          (ファイルから読み込み)
#   ./log.sh                       (対話モード)
#
# オプション:
#   -f FILE   ファイルから学習内容を読み込む（1行1項目）
#   -d DATE   日付を指定する (YYYY-MM-DD形式、デフォルト: 今日)
#   -n        コミット・プッシュせずにログ追加のみ行う
#   -h        ヘルプを表示
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/daily_log.md"
BRANCH="master"

# 曜日の日本語マッピング
declare -A WEEKDAYS=(
  [Mon]="月" [Tue]="火" [Wed]="水" [Thu]="木"
  [Fri]="金" [Sat]="土" [Sun]="日"
)

# デフォルト値
TARGET_DATE=""
NO_PUSH=false
INPUT_FILE=""
ENTRIES=()

usage() {
  echo "使い方: $0 [オプション] [学習内容...]"
  echo ""
  echo "オプション:"
  echo "  -f FILE   ファイルから学習内容を読み込む（1行1項目）"
  echo "  -d DATE   日付を指定 (YYYY-MM-DD形式、デフォルト: 今日)"
  echo "  -n        コミット・プッシュせずにログ追加のみ"
  echo "  -h        このヘルプを表示"
  echo ""
  echo "例:"
  echo "  $0 \"S3バケットの設定を学習\" \"CloudFrontの設定を確認\""
  echo "  $0 -d 2026-02-10 \"VPCの設定を確認\""
  echo "  $0 -f today_notes.txt"
  echo "  $0   (対話モードで入力)"
  exit 0
}

# 引数パース
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h) usage ;;
    -n) NO_PUSH=true; shift ;;
    -d) TARGET_DATE="$2"; shift 2 ;;
    -f) INPUT_FILE="$2"; shift 2 ;;
    *)  ENTRIES+=("$1"); shift ;;
  esac
done

# 日付の設定
if [[ -z "$TARGET_DATE" ]]; then
  TARGET_DATE=$(date +%Y-%m-%d)
fi

# 曜日を取得
DOW_EN=$(date -d "$TARGET_DATE" +%a 2>/dev/null || date -j -f "%Y-%m-%d" "$TARGET_DATE" +%a 2>/dev/null)
DOW_JP="${WEEKDAYS[$DOW_EN]:-$DOW_EN}"

# ファイルから読み込み
if [[ -n "$INPUT_FILE" ]]; then
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "エラー: ファイルが見つかりません: $INPUT_FILE" >&2
    exit 1
  fi
  while IFS= read -r line; do
    [[ -n "$line" ]] && ENTRIES+=("$line")
  done < "$INPUT_FILE"
fi

# 対話モード（引数もファイルも指定なしの場合）
if [[ ${#ENTRIES[@]} -eq 0 ]]; then
  echo "学習内容を入力してください（空行で終了）:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && break
    ENTRIES+=("$line")
  done
fi

if [[ ${#ENTRIES[@]} -eq 0 ]]; then
  echo "エラー: 学習内容が入力されていません" >&2
  exit 1
fi

# エントリの作成
HEADER="## ${TARGET_DATE}（${DOW_JP}）"
ENTRY_BLOCK="$HEADER"
for item in "${ENTRIES[@]}"; do
  ENTRY_BLOCK+=$'\n'"  - ${item}"
done

# 既に同じ日付のエントリがあるか確認
if grep -q "^## ${TARGET_DATE}" "$LOG_FILE" 2>/dev/null; then
  # 既存エントリに追記
  APPEND_ITEMS=""
  for item in "${ENTRIES[@]}"; do
    APPEND_ITEMS+="  - ${item}\n"
  done
  # 日付ヘッダの次の行以降に追記（次の##か末尾まで）
  python3 -c "
import re, sys

with open('$LOG_FILE', 'r') as f:
    content = f.read()

date_header = '## ${TARGET_DATE}'
items = '''$(printf '%s\n' "${ENTRIES[@]}")'''.strip().split('\n')
new_lines = '\n'.join(f'  - {item}' for item in items if item)

# Find the date header and append items after existing entries
lines = content.split('\n')
result = []
found = False
inserted = False
for i, line in enumerate(lines):
    result.append(line)
    if line.startswith(date_header) and not found:
        found = True
        continue
    if found and not inserted:
        # Find the last bullet point for this date section
        if not line.startswith('  -') and not line.startswith('    -') and line.strip() != '':
            # Insert before this line (it's a new section)
            result.pop()  # Remove the line we just added
            result.append(new_lines)
            result.append(line)
            inserted = True
        elif i == len(lines) - 1:
            # End of file
            result.append(new_lines)
            inserted = True

with open('$LOG_FILE', 'w') as f:
    f.write('\n'.join(result))
"
  echo "既存の ${TARGET_DATE} のエントリに追記しました"
else
  # 新規エントリをヘッダの直後に挿入
  python3 -c "
with open('$LOG_FILE', 'r') as f:
    content = f.read()

lines = content.split('\n')
# Insert after the first line (title header)
header_end = 0
for i, line in enumerate(lines):
    if line.startswith('# ') and i == 0:
        header_end = i + 1
        # Skip blank lines after header
        while header_end < len(lines) and lines[header_end].strip() == '':
            header_end += 1
        break

entry = '''${ENTRY_BLOCK}'''

new_lines = lines[:header_end]
new_lines.append(entry)
new_lines.append('')
new_lines.extend(lines[header_end:])

with open('$LOG_FILE', 'w') as f:
    f.write('\n'.join(new_lines))
"
  echo "新しいエントリを追加しました: ${TARGET_DATE}（${DOW_JP}）"
fi

# 追加内容を表示
echo "---"
for item in "${ENTRIES[@]}"; do
  echo "  - ${item}"
done
echo "---"

# コミット＆プッシュ
if [[ "$NO_PUSH" == false ]]; then
  cd "$SCRIPT_DIR"
  git add daily_log.md
  git commit -m "${TARGET_DATE}の学習ログ"
  git push origin "$BRANCH"
  echo "コミット＆プッシュ完了！"
else
  echo "ログ追加のみ完了（-n オプションのためコミット・プッシュはスキップ）"
fi
