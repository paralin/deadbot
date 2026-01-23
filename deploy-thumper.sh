#!/bin/bash
set -e

REMOTE_HOST="root@thumper"
REMOTE_DIR="/mnt/persist/deadbot"
OUTPUT_DIR="/mnt/persist/deadbot-output"
DATA_DIR="/mnt/persist/deadbot-data"

echo "==> Syncing to $REMOTE_HOST:$REMOTE_DIR ..."
rsync -rav --delete ./ "$REMOTE_HOST:$REMOTE_DIR/"

echo "==> Building and running on thumper..."
ssh "$REMOTE_HOST" bash -s <<EOF
set -e
cd "$REMOTE_DIR"

echo "==> Building Docker image..."
docker build -f Dockerfile.thumper -t deadbot-parse .

echo "==> Creating directories..."
mkdir -p "$OUTPUT_DIR"
mkdir -p "$DATA_DIR"

echo "==> Running parser..."
docker run --rm \
    -v "$DATA_DIR:/data" \
    -v "$OUTPUT_DIR:/output" \
    deadbot-parse

echo "==> Done! Output is in $OUTPUT_DIR"
EOF

echo "==> Syncing output back to ../deadlock-mine/deadlock-data/data/ ..."
rsync -rav "$REMOTE_HOST:$OUTPUT_DIR/" ../deadlock-mine/deadlock-data/data/

echo "==> Complete!"
