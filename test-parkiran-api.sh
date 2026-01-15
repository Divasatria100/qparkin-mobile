#!/bin/bash

echo "========================================"
echo "Testing Parkiran API Endpoints"
echo "========================================"
echo ""

# Get auth token first
echo "[1/5] Getting auth token..."
TOKEN=$(curl -s -X POST http://192.168.0.101:8000/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

echo "Token obtained: ${TOKEN:0:20}..."
echo ""

echo "[2/5] Testing Mall 1 (Mega Mall Batam Centre)..."
curl -s -X GET "http://192.168.0.101:8000/api/mall/1/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

echo "[3/5] Testing Mall 2 (One Batam Mall)..."
curl -s -X GET "http://192.168.0.101:8000/api/mall/2/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

echo "[4/5] Testing Mall 3 (SNL Food Bengkong)..."
curl -s -X GET "http://192.168.0.101:8000/api/mall/3/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

echo "[5/5] Testing Mall 4 (Panbil Mall)..."
curl -s -X GET "http://192.168.0.101:8000/api/mall/4/parkiran" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

echo "========================================"
echo "Test Complete!"
echo "========================================"
echo ""
echo "All malls should now return parkiran data."
echo "If you see empty data arrays, run:"
echo "  cd qparkin_backend"
echo "  php create_missing_parkiran.php"
echo ""
