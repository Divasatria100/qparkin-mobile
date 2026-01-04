#!/bin/bash
# Script untuk export Docker image QParkin
# Untuk Linux/Mac

echo "========================================"
echo "  QParkin Docker Image Export"
echo "========================================"
echo ""

OUTPUT_DIR="docker_exports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Creating export directory..."
mkdir -p $OUTPUT_DIR
echo ""

echo "[1/3] Exporting Backend Image..."
docker save qparkin_backend:latest -o $OUTPUT_DIR/qparkin_backend_$TIMESTAMP.tar
echo "Backend image exported: $OUTPUT_DIR/qparkin_backend_$TIMESTAMP.tar"
echo ""

echo "[2/3] Exporting MySQL Image..."
docker save mysql:8.0 -o $OUTPUT_DIR/mysql_8.0_$TIMESTAMP.tar
echo "MySQL image exported: $OUTPUT_DIR/mysql_8.0_$TIMESTAMP.tar"
echo ""

echo "[3/3] Exporting PHPMyAdmin Image..."
docker save phpmyadmin:latest -o $OUTPUT_DIR/phpmyadmin_$TIMESTAMP.tar
echo "PHPMyAdmin image exported: $OUTPUT_DIR/phpmyadmin_$TIMESTAMP.tar"
echo ""

echo "========================================"
echo "  Export Complete!"
echo "========================================"
echo ""
echo "Exported files location: $OUTPUT_DIR/"
echo ""
echo "To import on another machine:"
echo "  docker load -i qparkin_backend_$TIMESTAMP.tar"
echo "  docker load -i mysql_8.0_$TIMESTAMP.tar"
echo "  docker load -i phpmyadmin_$TIMESTAMP.tar"
echo ""
echo "Then run: docker-compose up -d"
echo ""

