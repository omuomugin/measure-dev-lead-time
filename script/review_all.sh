#!/bin/sh

source .env

OUT_CSV="../bi/sources/github/review.csv"
HEADER="repository,number,author,isApprove"

# ヘッダを書き込む
echo "$HEADER" > "$OUT_CSV"

echo "[INFO] Fetching reviews..."

IFS=',' read -ra REPO_ARRAY <<< "$REPO_NAMES"
for repo in "${REPO_ARRAY[@]}"; do
  export REPO_NAME="$repo"
  export MERGED_QUERY="$MERGED_QUERY"
  echo "[INFO] Processing repository: $REPO_NAME"
  ./review.sh >> "$OUT_CSV"
done