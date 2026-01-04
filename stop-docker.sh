#!/bin/bash
# Script untuk menghentikan aplikasi QParkin Docker
# Untuk Linux/Mac

echo "========================================"
echo "  QParkin Docker Stop Script"
echo "========================================"
echo ""

echo "Stopping all containers..."
docker-compose down
echo ""

echo "========================================"
echo "  Containers stopped successfully!"
echo "========================================"
echo ""

echo "To start again, run: ./start-docker.sh"
echo ""

