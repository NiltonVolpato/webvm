#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] [DOCKERFILE] [IMAGE_NAME] [OUTPUT_DIR]

Build a WebVM disk image from a Dockerfile: builds it for linux/386, exports
the filesystem to a .tar, converts that to an .ext2 image, and runs smoke
tests against the built Docker image.

Arguments (all optional, positional):
  DOCKERFILE   Dockerfile to build.
               Default: dockerfiles/alpine_mini
  IMAGE_NAME   Name for the Docker image and output files; a trailing .ext2
               is accepted and stripped for the .tar name.
               Default: basename of DOCKERFILE
  OUTPUT_DIR   Where to write IMAGE_NAME.tar and IMAGE_NAME.ext2 (created if
               missing). Default: disk-images/ in the project root

Relative paths are resolved against the current directory.

Examples:
  $(basename "$0")
  $(basename "$0") dockerfiles/debian_mini
  $(basename "$0") dockerfiles/alpine_mini alpine_mini_new.ext2 disk-images

Requires Docker. Exits non-zero if the build or any smoke test fails.
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
esac
if [ $# -gt 3 ]; then
    echo "Too many arguments" >&2; usage >&2; exit 2
fi

DOCKERFILE="${1:-$PROJECT_DIR/dockerfiles/alpine_mini}"
if [ ! -f "$DOCKERFILE" ]; then
    echo "Dockerfile not found: $DOCKERFILE" >&2; exit 2
fi
IMAGE_NAME="${2:-$(basename "$DOCKERFILE")}"
OUTPUT_DIR="${3:-$PROJECT_DIR/disk-images}"

# Handle image name that may already include .ext2 extension
if [[ "$IMAGE_NAME" == *.ext2 ]]; then
    EXT2_NAME="$IMAGE_NAME"
    TAR_NAME="${IMAGE_NAME%.ext2}.tar"
else
    EXT2_NAME="${IMAGE_NAME}.ext2"
    TAR_NAME="${IMAGE_NAME}.tar"
fi

CONTAINER_NAME="${IMAGE_NAME%.ext2}_build"

# Resolve paths against the caller's cwd before cd'ing. OUTPUT_DIR must be
# absolute: `docker run -v name:/path` treats a relative source as a named volume.
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(readlink -f "$OUTPUT_DIR")"
DOCKERFILE="$(readlink -f "$DOCKERFILE")"
OUTPUT_TAR="$OUTPUT_DIR/$TAR_NAME"
OUTPUT_EXT2="$OUTPUT_DIR/$EXT2_NAME"

cd "$PROJECT_DIR"

echo "=== Building image: $IMAGE_NAME ==="
echo "Dockerfile: $DOCKERFILE"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Build the Docker image
echo ">>> Building Docker image..."
docker build --platform linux/386 -t "$IMAGE_NAME" -f "$DOCKERFILE" .
echo ""

# Clean up any existing container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Create container and export
echo ">>> Exporting filesystem..."
docker create --platform linux/386 --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null
docker export "$CONTAINER_NAME" >"$OUTPUT_TAR"
docker rm "$CONTAINER_NAME" >/dev/null

TAR_SIZE=$(ls -lh "$OUTPUT_TAR" | awk '{print $5}')
echo "Exported: $OUTPUT_TAR ($TAR_SIZE)"
echo ""

# Show largest files
echo ">>> Largest files in image:"
if tar --version 2>&1 | grep -q "GNU"; then
    tar tvf "$OUTPUT_TAR" | sort -k3 -n -r | head -10
else
    tar tvf "$OUTPUT_TAR" | sort -k5 -n -r | head -10
fi
echo ""

# Create ext2 image using Docker (cross-platform, no loopback mount needed)
echo ">>> Creating ext2 image..."
if ! docker run --rm --pull always \
    -v "$OUTPUT_DIR:/images" \
    -e "TAR_NAME=$TAR_NAME" \
    -e "EXT2_NAME=$EXT2_NAME" \
    alpine:latest \
    sh -c '
        set -e
        apk add --no-cache genext2fs

        # Calculate size: tar content + 30% headroom, converted to 4K blocks
        TAR_KB=$(du -sk "/images/${TAR_NAME}" | cut -f1)
        SIZE_BLOCKS=$(( TAR_KB * 13 / 10 / 4 ))
        echo "Tar size: ${TAR_KB}KB, Image size: ${SIZE_BLOCKS} blocks ($(( SIZE_BLOCKS * 4 ))KB)"

        genext2fs -a "/images/${TAR_NAME}" -B 4096 -b $SIZE_BLOCKS "/images/${EXT2_NAME}"
    '; then
    echo "ERROR: Failed to create ext2 image" >&2
    exit 1
fi

EXT2_SIZE=$(ls -lh "$OUTPUT_EXT2" | awk '{print $5}')
echo "Created: $OUTPUT_EXT2 ($EXT2_SIZE)"
echo ""

# Run tests
set +e
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

# zsh is not present in all images
if docker run --rm "$IMAGE_NAME" which zsh >/dev/null 2>&1; then
    run_test "zsh works" "zsh --version" "zsh"
fi

run_test "coreutils works" "ls --version" "coreutils"
run_test "user exists" "id user" "user"
run_test "home directory" "ls -la /home/user" ".bashrc"

# Python tests (if python is installed)
if docker run --rm "$IMAGE_NAME" which python3 >/dev/null 2>&1; then
    run_test "python3 works" "python3 -c 'print(1+1)'" "2"
    run_test "python3 utf-8" "python3 -c 'print(\"héllo\")'" "héllo"
    run_test "python3 json" "python3 -c 'import json; print(json.dumps({\"a\":1}))'" '{"a": 1}'

    # Test pip-installed CLI tools
    run_test "ipython works" "ipython -c 'print(1+1)'" "2"
    run_test "cowsay works" "cowsay -t 'test'" "test"
    run_test "rich cli works" "python3 -m rich" "Rich"
    run_test "sympy isympy" "which isympy" "/usr/bin/isympy"
    run_test "tte available" "which tte" "/usr/bin/tte"
fi

# genact test (if installed)
if docker run --rm "$IMAGE_NAME" which genact >/dev/null 2>&1; then
    run_test "genact works" "genact --help" "genact"
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
echo "Ext2 image: $OUTPUT_EXT2"
