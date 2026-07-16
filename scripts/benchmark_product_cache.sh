#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [REQUESTS]"
  exit 1
fi

COUNT=${1:-20}
URL="http://localhost:3000/api/products"
WEB_SERVICE="web"

printf 'Benchmarking %s requests to %s\n' "$COUNT" "$URL"

echo "\nCache enabled?"
docker compose exec -T $WEB_SERVICE bin/rails runner 'puts File.exist?(Rails.root.join("tmp/caching-dev.txt"))'

echo "\nClearing cache key products:all"
docker compose exec -T $WEB_SERVICE bin/rails runner 'Rails.cache.delete("products:all")'

run_batch() {
  local label="$1"
  local n="$2"
  local total=0
  local min=0
  local max=0

  echo "\n$label"
  for i in $(seq 1 "$n"); do
    local t
    t=$(curl -s -o /dev/null -w "%{time_total}" "$URL")
    printf '%s\n' "$t"
    if [ "$i" -eq 1 ]; then
      min=$t
      max=$t
    else
      awk -v x="$t" -v mn="$min" 'BEGIN{print (x<mn?x:mn)}' >/tmp/bench_min
      awk -v x="$t" -v mx="$max" 'BEGIN{print (x>mx?x:mx)}' >/tmp/bench_max
      min=$(cat /tmp/bench_min)
      max=$(cat /tmp/bench_max)
    fi
    total=$(awk -v total="$total" -v add="$t" 'BEGIN{printf "%.6f", total + add}')
  done

  local avg
  avg=$(awk -v total="$total" -v n="$n" 'BEGIN{printf "%.6f", total / n}')
  echo "\n$label summary:"
  echo "  count = $n"
  echo "  avg   = ${avg}s"
  echo "  min   = ${min}s"
  echo "  max   = ${max}s"
}

run_batch "Cold cache" "$COUNT"
echo "\nRunning warm cache batch"
run_batch "Warm cache" "$COUNT"
