#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  cat <<EOF
Usage: $0 PRODUCT_ID USER_ID COUNT

Example:
  $0 1 1 100
EOF
  exit 1
fi

PRODUCT_ID="$1"
USER_ID="$2"
COUNT="$3"
URL="http://localhost:3000/api/products/${PRODUCT_ID}/checkout"

printf 'Running %s concurrent checkout requests for product %s as user %s\n' "$COUNT" "$PRODUCT_ID" "$USER_ID"

for i in $(seq 1 "$COUNT"); do
  (
    curl -s -X POST "$URL" \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -d "user_id=${USER_ID}&quantity=1" \
      -w '\nSTATUS:%{http_code} REQUEST:%{url_effective}\n' \
      || true
  ) &
 done

wait
printf 'Completed %s requests\n' "$COUNT"
