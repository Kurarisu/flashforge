#!/bin/bash

# Script to test race condition on flashsale checkout
# This script makes parallel requests to the same flashsale product
# to show how pessimistic locking prevents overselling

PRODUCT_ID=1  # Standard Widget
USER_ID=1
QUANTITY_PER_REQUEST=5
CONCURRENT_REQUESTS=20
BASE_URL="http://localhost:3000/api"

echo "====== FLASHSALE RACE CONDITION TEST ======"
echo ""
echo "Setup:"
echo "  Product: Standard Widget (ID: $PRODUCT_ID)"
echo "  Flashsale stock: 50 units"
echo "  Quantity per request: $QUANTITY_PER_REQUEST"
echo "  Concurrent requests: $CONCURRENT_REQUESTS"
echo "  Total demand: $((QUANTITY_PER_REQUEST * CONCURRENT_REQUESTS)) units"
echo ""

# Check flashsale before
echo "BEFORE CHECKOUT:"
curl -s "$BASE_URL/flash_sales" | grep -A 15 "\"id\":1" | head -20
echo ""

# Function to make checkout request
make_checkout() {
  local request_num=$1
  local response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/products/$PRODUCT_ID/checkout" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "user_id=$USER_ID&quantity=$QUANTITY_PER_REQUEST&use_flashsale=true")
  
  local http_code=$(echo "$response" | tail -n 1)
  local body=$(echo "$response" | sed '$d')
  
  if [ "$http_code" = "201" ]; then
    echo "[Request $request_num] ✓ SUCCESS - Order created"
    echo "$body" | grep -o '"id":[0-9]*' | head -1
  else
    echo "[Request $request_num] ✗ FAILED (HTTP $http_code)"
    echo "$body" | grep -o '"error":"[^"]*"' 
  fi
}

# Make parallel requests
echo "MAKING $CONCURRENT_REQUESTS CONCURRENT REQUESTS..."
echo ""

for i in $(seq 1 $CONCURRENT_REQUESTS); do
  make_checkout $i &
  # Stagger requests slightly to make concurrency visible
  sleep 0.05
done

# Wait for all background jobs
wait

echo ""
echo "AFTER CHECKOUT:"
curl -s "$BASE_URL/flash_sales" | grep -A 15 "\"id\":1" | head -20
echo ""

# Count successful orders
echo ""
echo "SUMMARY:"
echo "Total demand: $((QUANTITY_PER_REQUEST * CONCURRENT_REQUESTS)) units"
echo "Flashsale stock before: 50 units"
echo "Expected sold: 50 units (limited by stock with pessimistic lock)"
echo "Expected rejected: $((CONCURRENT_REQUESTS - 1)) requests"
echo ""
echo "Check /api/orders for actual order count and final flashsale stock above."
