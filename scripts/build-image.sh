#!/bin/bash
set -uo pipefail

# Build and test a WebVM Docker image
#
# Usage: ./scripts/build-image.sh [dockerfile] [image-name]
#   dockerfile: path to Dockerfile (default: dockerfiles/alpine_mini)
#   image-name: name for the image (default: derived from dockerfile)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

DOCKERFILE="${1:-dockerfiles/alpine_mini}"
IMAGE_NAME="${2:-$(basename "$DOCKERFILE")}"
CONTAINER_NAME="${IMAGE_NAME}_build"
OUTPUT_DIR="$PROJECT_DIR/disk-images"
OUTPUT_TAR="$OUTPUT_DIR/${IMAGE_NAME}.tar"
OUTPUT_EXT2="$OUTPUT_DIR/${IMAGE_NAME}.ext2"

cd "$PROJECT_DIR"

echo "=== Building image: $IMAGE_NAME ==="
echo "Dockerfile: $DOCKERFILE"
echo ""

# Build the Docker image
echo ">>> Building Docker image..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .
echo ""

# Clean up any existing container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Create container and export
echo ">>> Exporting filesystem..."
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null
docker export "$CONTAINER_NAME" > "$OUTPUT_TAR"
docker rm "$CONTAINER_NAME" >/dev/null

TAR_SIZE=$(ls -lh "$OUTPUT_TAR" | awk '{print $5}')
echo "Exported: $OUTPUT_TAR ($TAR_SIZE)"
echo ""

# Show largest files
echo ">>> Largest files in image:"
tar tvf "$OUTPUT_TAR" | sort -k3 -n -r | head -10
echo ""

# Create ext2 image
echo ">>> Creating ext2 image..."
# Calculate size needed (tar size + 20% headroom, minimum 64MB)
TAR_BYTES=$(stat -f%z "$OUTPUT_TAR" 2>/dev/null || stat -c%s "$OUTPUT_TAR")
EXT2_SIZE=$(( (TAR_BYTES * 120 / 100) / 1024 / 1024 ))
EXT2_SIZE=$(( EXT2_SIZE < 64 ? 64 : EXT2_SIZE ))

dd if=/dev/zero of="$OUTPUT_EXT2" bs=1M count="$EXT2_SIZE" 2>/dev/null
mkfs.ext2 -q "$OUTPUT_EXT2"

# Mount and extract
MOUNT_POINT=$(mktemp -d)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - requires fuse-ext2 or similar
    echo "Note: ext2 mounting on macOS requires fuse-ext2"
    echo "Skipping ext2 creation - tar file is ready for manual extraction"
    rm -f "$OUTPUT_EXT2"
    rm -rf "$MOUNT_POINT"
else
    sudo mount -o loop "$OUTPUT_EXT2" "$MOUNT_POINT"
    sudo tar xf "$OUTPUT_TAR" -C "$MOUNT_POINT"
    sudo umount "$MOUNT_POINT"
    rm -rf "$MOUNT_POINT"

    EXT2_SIZE=$(ls -lh "$OUTPUT_EXT2" | awk '{print $5}')
    echo "Created: $OUTPUT_EXT2 ($EXT2_SIZE)"
fi
echo ""

# Run tests
echo ">>> Running smoke tests..."
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local name="$1"
    local cmd="$2"
    local expected="$3"

    result=$(docker run --rm "$IMAGE_NAME" sh -c "$cmd" 2>&1) || true
    if echo "$result" | grep -q "$expected"; then
        echo "  ✓ $name"
        ((TESTS_PASSED++))
    else
        echo "  ✗ $name"
        echo "    Expected: $expected"
        echo "    Got: $result"
        ((TESTS_FAILED++))
    fi
}

run_test "bash works" "bash --version" "GNU bash"
run_test "zsh works" "zsh --version" "zsh"
run_test "coreutils works" "ls --version" "coreutils"
run_test "user exists" "id user" "user"
run_test "home directory" "ls -la /home/user" ".bashrc"

# Python tests (if python is installed)
if docker run --rm "$IMAGE_NAME" which python3 >/dev/null 2>&1; then
    run_test "python3 works" "python3 -c 'print(1+1)'" "2"
    run_test "python3 utf-8" "python3 -c 'print(\"héllo\")'" "héllo"
    run_test "python3 json" "python3 -c 'import json; print(json.dumps({\"a\":1}))'" '{"a": 1}'

    # Test pip-installed CLI tools
    run_test "ipython available" "which ipython" "/usr/bin/ipython"
    run_test "cowsay works" "cowsay -t 'test'" "test"
    run_test "rich cli works" "python3 -m rich" "Rich"
    run_test "sympy isympy" "which isympy" "/usr/bin/isympy"
    run_test "tte available" "which tte" "/usr/bin/tte"
fi

echo ""
echo "=== Results ==="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "Build complete: $OUTPUT_TAR"
