#!/bin/bash

# Test Script for Map Page Freeze/ANR Fix
# This script runs comprehensive tests to verify the fix

echo "=========================================="
echo "Map Page Freeze/ANR Fix - Test Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

echo "Step 1: Clean build"
echo "--------------------"
flutter clean
flutter pub get
print_result $? "Clean build"
echo ""

echo "Step 2: Run Flutter analyze"
echo "----------------------------"
flutter analyze
ANALYZE_RESULT=$?
print_result $ANALYZE_RESULT "Flutter analyze"
echo ""

echo "Step 3: Check for common issues"
echo "--------------------------------"

# Check if MapProvider uses create instead of value
echo "Checking MapProvider lifecycle..."
if grep -q "ChangeNotifierProvider<MapProvider>(" qparkin_app/lib/presentation/screens/map_page.dart && \
   grep -q "create: (_) => MapProvider()" qparkin_app/lib/presentation/screens/map_page.dart; then
    print_result 0 "MapProvider uses create (correct)"
else
    print_result 1 "MapProvider lifecycle issue"
fi

# Check if mounted checks are present
echo "Checking mounted checks..."
MOUNTED_CHECKS=$(grep -c "if (!mounted) return;" qparkin_app/lib/presentation/screens/map_page.dart)
if [ $MOUNTED_CHECKS -ge 5 ]; then
    print_result 0 "Mounted checks present ($MOUNTED_CHECKS found)"
else
    print_result 1 "Insufficient mounted checks ($MOUNTED_CHECKS found, need at least 5)"
fi

# Check if navigation uses pushReplacementNamed
echo "Checking navigation method..."
if grep -q "pushReplacementNamed" qparkin_app/lib/utils/navigation_utils.dart; then
    print_result 0 "Navigation uses pushReplacementNamed"
else
    print_result 1 "Navigation still uses pushNamed"
fi

# Check if listener cleanup is present
echo "Checking listener cleanup..."
if grep -q "_markerTapListener" qparkin_app/lib/presentation/widgets/map_view.dart && \
   grep -q "removeListener(_markerTapListener!)" qparkin_app/lib/presentation/widgets/map_view.dart; then
    print_result 0 "Listener cleanup implemented"
else
    print_result 1 "Listener cleanup missing"
fi

# Check if didChangeDependencies is optimized
echo "Checking didChangeDependencies optimization..."
if grep -q "_previousLocation" qparkin_app/lib/presentation/widgets/map_view.dart && \
   grep -q "_previousRoute" qparkin_app/lib/presentation/widgets/map_view.dart; then
    print_result 0 "didChangeDependencies optimized"
else
    print_result 1 "didChangeDependencies not optimized"
fi

echo ""
echo "Step 4: Run unit tests (if available)"
echo "--------------------------------------"
if [ -d "qparkin_app/test" ]; then
    flutter test
    TEST_RESULT=$?
    print_result $TEST_RESULT "Unit tests"
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: No test directory found"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Ready for deployment.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review the issues above.${NC}"
    exit 1
fi
