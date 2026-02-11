# learning-log
日々の学習記録

## セットアップ

```bash
git clone https://github.com/satoru-AWS/learning-log.git
cd learning-log
chmod +x log.sh
```

## 使い方

### 学習内容を記録してコミット＆プッシュ

```bash
# 引数で直接入力
./log.sh "S3バケットの設定を学習" "CloudFrontの設定を確認"

# 対話モードで入力（引数なしで実行）
./log.sh

# ファイルから読み込み（1行1項目）
./log.sh -f today_notes.txt
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-d DATE` | 日付を指定 (YYYY-MM-DD形式、デフォルト: 今日) |
| `-n` | コミット・プッシュせずにログ追加のみ |
| `-f FILE` | ファイルから学習内容を読み込み |
| `-h` | ヘルプを表示 |

### 使用例

```bash
# 今日の学習を記録して自動プッシュ
./log.sh "VPCの設定を確認" "セキュリティグループの設計"

# 昨日分を追記
./log.sh -d 2026-02-10 "CloudFormationテンプレート作成"

# ログ追加のみ（まとめて後でプッシュしたい場合）
./log.sh -n "途中メモ"
```

## GitHub Actions

毎日 21:00 (JST) に学習ログの記入チェックが自動実行されます。未記入の場合、リマインダー Issue が作成されます。手動実行も可能です。
