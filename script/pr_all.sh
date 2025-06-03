#!/bin/sh

source .env

OUT_CSV="../bi/sources/github/pr.csv"
HEADER="repository,number,title,author,createdAt,mergedAt,firstReviewedAt,firstApprovedAt"

# ヘッダを書き込む
echo "$HEADER" > "$OUT_CSV"

echo "[INFO] Fetching pull requests..."

IFS=',' read -ra REPO_ARRAY <<< "$REPO_NAMES"
for repo in "${REPO_ARRAY[@]}"; do
  export REPO_NAME="$repo"
  export MERGED_QUERY="$MERGED_QUERY"
  echo "[INFO] Processing repository: $REPO_NAME"
  ./pr.sh >> "$OUT_CSV"
done