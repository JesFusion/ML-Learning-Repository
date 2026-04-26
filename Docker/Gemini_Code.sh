#!/bin/bash
# =============================================================================
# DOCKER FOR MLOPS — SEGMENTS 2.3, 2.4 & 3.1
# Student: Nwachukwu Jesse | Instructor: Chijioke Ekwebelem
# OS: Ubuntu 24.04 (Noble Numbat)
# HOW TO RUN: chmod +x segments_2.3_2.4_3.1.sh && ./segments_2.3_2.4_3.1.sh
# =============================================================================

set -e  # Exit immediately on any command failure. Production habit.

print_header() { echo -e "\n\033[1;36m=======================================================\n $1\n=======================================================\033[0m\n"; }
print_demo()   { echo -e "\n\033[1;33m--- $1 ---\033[0m"; }
print_info()   { echo -e "\033[0;32m[INFO]\033[0m $1"; }
print_warn()   { echo -e "\033[0;33m[WARN]\033[0m $1"; }

# =============================================================================
print_header ""
# =============================================================================

print_demo "Demo 1: Project Workspace Setup"
WORK_DIR="/tmp/jesse_docker_lab"
mkdir -p "$WORK_DIR"
print_info "Working directory: $WORK_DIR"

# =============================================================================
# DEMO 2: requirements.txt — The Classic Approach
# Layer caching trick: COPY requirements.txt BEFORE app code.
# If requirements.txt hasn't changed, Docker reuses the cached pip install layer.
# =============================================================================
print_demo "Demo 2: Approach 1 — requirements.txt (The Standard)"
mkdir -p "$WORK_DIR/app_req"

# Pin exact versions (==). Using >= in production is a time bomb.
cat > "$WORK_DIR/app_req/requirements.txt" << 'EOF'
numpy==1.26.4
pandas==2.2.0
scikit-learn==1.4.0
EOF

print_info "Created requirements.txt:"
cat "$WORK_DIR/app_req/requirements.txt"

cat > "$WORK_DIR/app_req/main.py" << 'EOF'
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification
print("[APP] Dependencies loaded successfully.")
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
df = pd.DataFrame(X, columns=['f1', 'f2', 'f3', 'f4'])
print(f"[APP] Dataset shape: {df.shape}")
print(f"[APP] Mean feature values:\n{df.mean().round(3).to_string()}")
EOF

cat > "$WORK_DIR/app_req/Dockerfile" << 'EOF'
FROM python:3.10-slim
WORKDIR /app
# CACHING TRICK: Copy requirements.txt first. If it hasn't changed,
# Docker reuses the cached `pip install` layer — even if main.py changed.
COPY requirements.txt .
# --no-cache-dir: Don't save downloaded wheels inside the image. Keeps image lean.
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

print_info "Building requirements.txt image..."
docker build -t jesse/ml-req:v1 -f "$WORK_DIR/app_req/Dockerfile" "$WORK_DIR/app_req"
print_info "Running requirements.txt container..."
docker run --rm jesse/ml-req:v1

# =============================================================================
# DEMO 3: Poetry — Modern Production Standard
# Poetry resolves deps precisely. We export to requirements.txt for fast pip install.
# =============================================================================
print_demo "Demo 3: Approach 2 — Poetry (Modern Dependency Management)"
mkdir -p "$WORK_DIR/app_poetry"

# ^ (caret) = "compatible with": ^1.26.4 means >=1.26.4, <2.0.0
cat > "$WORK_DIR/app_poetry/pyproject.toml" << 'EOF'
[tool.poetry]
name = "ml-pipeline"
version = "0.1.0"
description = "MLOps training service"

[tool.poetry.dependencies]
python = "^3.10"
numpy = "^1.26.4"
pandas = "^2.2.0"
scikit-learn = "^1.4.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
EOF

cat > "$WORK_DIR/app_poetry/Dockerfile" << 'EOF'
FROM python:3.10-slim
WORKDIR /app
RUN pip install poetry==1.8.2
COPY pyproject.toml .
# Export to requirements.txt format — Poetry resolves, pip installs fast.
# --without-hashes: Avoids hash-check issues in some dependency combinations.
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/app_poetry/main.py"
print_info "Building Poetry image..."
docker build -t jesse/ml-poetry:v1 -f "$WORK_DIR/app_poetry/Dockerfile" "$WORK_DIR/app_poetry"
print_info "Running Poetry container..."
docker run --rm jesse/ml-poetry:v1

# =============================================================================
# DEMO 4: BuildKit Cache Mounts — The CI/CD Speed Hack
# pip's wheel cache persists on the HOST between builds.
# Second build: pip finds wheels already downloaded, skips the network entirely.
# The cache folder is never included in the final image.
# =============================================================================
print_demo "Demo 4: BuildKit Cache Mounts (Wheel Cache Persists Between Builds)"
mkdir -p "$WORK_DIR/app_cached"
cp "$WORK_DIR/app_req/requirements.txt" "$WORK_DIR/app_cached/"
cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/app_cached/"

cat > "$WORK_DIR/app_cached/Dockerfile" << 'EOF'
# syntax=docker/dockerfile:1
# This activates latest Dockerfile syntax features, required for --mount.
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
# --mount=type=cache: BuildKit keeps /root/.cache/pip persistent on the host.
# First build: downloads everything (normal). Every subsequent build: reads from host cache.
# The cache dir is NEVER baked into the final image — host-only.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

print_info "First build — populating the BuildKit cache..."
DOCKER_BUILDKIT=1 docker build -t jesse/ml-cached:v1 \
    -f "$WORK_DIR/app_cached/Dockerfile" "$WORK_DIR/app_cached"

# Change only app code to trigger rebuild without changing requirements.
echo "print('[APP] Cache rebuild test.')" >> "$WORK_DIR/app_cached/main.py"
print_info "Second build — requirements unchanged, watch it pull from cache..."
DOCKER_BUILDKIT=1 docker build -t jesse/ml-cached:v2 \
    -f "$WORK_DIR/app_cached/Dockerfile" "$WORK_DIR/app_cached"

print_info "Running cached container..."
docker run --rm jesse/ml-cached:v2

# =============================================================================
# DEMO 5: Base Image Size Comparison — full vs slim vs alpine
# =============================================================================
print_demo "Demo 5: Base Image Size Comparison (full vs slim vs alpine)"

mkdir -p "$WORK_DIR/app_full"
cp "$WORK_DIR/app_req/requirements.txt" "$WORK_DIR/app_full/"
cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/app_full/"

cat > "$WORK_DIR/app_full/Dockerfile" << 'EOF'
FROM python:3.10
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

print_info "Building python:3.10 (FULL) image..."
# -q: Quiet mode — suppresses verbose build output.
docker build -q -t jesse/base-full:v1 -f "$WORK_DIR/app_full/Dockerfile" "$WORK_DIR/app_full"

# slim already built — re-tag for clean comparison output.
docker tag jesse/ml-req:v1 jesse/base-slim:v1

# Alpine — needs extra system packages to compile numpy's C extensions.
# On Debian/Ubuntu, numpy ships pre-built manylinux wheels. On Alpine (musl libc), it must compile from source.
mkdir -p "$WORK_DIR/app_alpine"
cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/app_alpine/"

cat > "$WORK_DIR/app_alpine/Dockerfile" << 'EOF'
FROM python:3.10-alpine
WORKDIR /app
# Alpine (musl libc) has no pre-built wheels for ML packages.
# These system packages are required just to compile numpy from source.
# apk: Alpine's package manager. --no-cache: Don't save apk index to disk.
RUN apk add --no-cache gcc g++ musl-dev linux-headers
RUN pip install --no-cache-dir numpy==1.26.4
COPY main.py .
CMD ["python", "main.py"]
EOF

print_info "Building python:3.10-alpine (note extra system packages needed just for numpy)..."
if DOCKER_BUILDKIT=1 docker build -t jesse/base-alpine:v1 \
    -f "$WORK_DIR/app_alpine/Dockerfile" "$WORK_DIR/app_alpine" 2>&1; then
    print_info "Alpine build succeeded — but required gcc/g++/musl-dev just for numpy."
else
    print_warn "Alpine build failed. This is expected for ML workloads."
fi

echo ""
print_info "=== BASE IMAGE SIZE COMPARISON ==="
# --format controls output columns.
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep "jesse/base"
echo ""
print_info "slim = MLOps sweet spot. full = debugging. alpine = avoid for data science."

# =============================================================================
print_header "SEGMENT 2.4 — SECURITY LINTING & DISTROLESS"
# =============================================================================

# =============================================================================
# DEMO 6: Hadolint — Bad Dockerfile → Lint → Fix → Clean Scan
# =============================================================================
print_demo "Demo 6: Hadolint — Detect Dockerfile Anti-Patterns Automatically"

mkdir -p "$WORK_DIR/hadolint_demo"
cp "$WORK_DIR/app_req/requirements.txt" "$WORK_DIR/hadolint_demo/"
cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/hadolint_demo/"

# Every line below violates a real Hadolint rule. Intentional.
cat > "$WORK_DIR/hadolint_demo/Dockerfile.bad" << 'EOF'
# CRIME 1 (DL3007): `latest` tag — non-reproducible. What is `latest` in 6 months?
FROM python:latest

# CRIME 2 (DL3009): apt-get update in a separate RUN from install.
# The cached update layer will be stale when install runs later.
RUN apt-get update
RUN apt-get install curl

# CRIME 3 (DL3042): No --no-cache-dir. Wheel files are saved inside the image, bloating it.
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "main.py"]
EOF

print_info "=== OUR INTENTIONALLY BAD DOCKERFILE ==="
cat "$WORK_DIR/hadolint_demo/Dockerfile.bad"
echo ""
print_info "Running Hadolint..."
# --rm: Clean up container on exit. -i: Read from stdin.
docker run --rm -i hadolint/hadolint < "$WORK_DIR/hadolint_demo/Dockerfile.bad" || true
# `|| true` prevents set -e from killing the script when hadolint returns non-zero on violations.

echo ""
print_info "=== FIXED DOCKERFILE ==="
cat > "$WORK_DIR/hadolint_demo/Dockerfile.good" << 'EOF'
# FIX 1: Exact version pin. Same image, every time, everywhere.
FROM python:3.10-slim
WORKDIR /app

# FIX 2: Combine update + install in ONE RUN layer (atomic).
# --no-install-recommends: Only install requested package, no optional extras.
# rm -rf /var/lib/apt/lists/*: Delete the apt index from the image — saves ~30MB.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# FIX 3: --no-cache-dir prevents wheel files from bloating the image.
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

cat "$WORK_DIR/hadolint_demo/Dockerfile.good"
echo ""
print_info "Running Hadolint against the FIXED Dockerfile..."
docker run --rm -i hadolint/hadolint < "$WORK_DIR/hadolint_demo/Dockerfile.good" \
    && print_info "Zero violations. Clean Dockerfile." || true

# =============================================================================
# DEMO 7: Multi-Stage Build to Distroless
# Stage 1 (builder): Has pip, apt, bash — installs all packages.
# Stage 2 (final): Distroless — only Python interpreter, nothing else.
# Attacker who gets in finds a completely dark, empty room.
# =============================================================================
print_demo "Demo 7: Multi-Stage Build → Distroless (Maximum Hardening)"

mkdir -p "$WORK_DIR/distroless_demo"
cp "$WORK_DIR/app_req/requirements.txt" "$WORK_DIR/distroless_demo/"
cp "$WORK_DIR/app_req/main.py" "$WORK_DIR/distroless_demo/"

cat > "$WORK_DIR/distroless_demo/Dockerfile.standard" << 'EOF'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
CMD ["python", "main.py"]
EOF

cat > "$WORK_DIR/distroless_demo/Dockerfile.distroless" << 'EOF'
# syntax=docker/dockerfile:1

# ==============================================================
# STAGE 1: "builder" — The Construction Zone (Disposable)
# This entire stage is DISCARDED. It never appears in the final image.
# ==============================================================
FROM python:3.10-slim AS builder
WORKDIR /app
COPY requirements.txt .
# --prefix=/install: Installs packages into /install instead of system paths.
# This creates a clean, portable directory we can copy to the next stage.
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ==============================================================
# STAGE 2: "final" — Hardened Production Container
# gcr.io/distroless/python3: ONLY the Python interpreter.
# No /bin/bash. No /bin/sh. No apt. No pip. No ls. No curl. Nothing.
# ==============================================================
FROM gcr.io/distroless/python3-debian12
WORKDIR /app
# --from=builder: Copies files from Stage 1 into this Stage 2.
COPY --from=builder /install /usr/local
COPY main.py .
# CRITICAL: Must use exec form (JSON array) — NOT shell form.
# Shell form requires /bin/sh which does not exist in distroless.
CMD ["python3", "main.py"]
EOF

print_info "Building standard slim image..."
docker build -q -t jesse/standard-image:v1 \
    -f "$WORK_DIR/distroless_demo/Dockerfile.standard" "$WORK_DIR/distroless_demo"

print_info "Building distroless hardened image..."
DOCKER_BUILDKIT=1 docker build -t jesse/distroless-image:v1 \
    -f "$WORK_DIR/distroless_demo/Dockerfile.distroless" "$WORK_DIR/distroless_demo"

print_info "Running standard image..."
docker run --rm jesse/standard-image:v1

print_info "Running distroless image..."
docker run --rm jesse/distroless-image:v1

echo ""
print_info "=== SIZE COMPARISON ==="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep "jesse/.*image"

echo ""
print_info "--- ATTACK SURFACE DEMO ---"
print_info "Attempting shell exec into STANDARD container..."
CID=$(docker run -d --rm jesse/standard-image:v1 sleep 10)
docker exec "$CID" ls /app \
    && print_warn "Standard: Shell exec WORKS. Attacker can see /app, /etc, everywhere."
docker stop "$CID" > /dev/null 2>&1 || true

print_info "Attempting to launch /bin/bash in DISTROLESS container..."
# In distroless, /bin/bash does not exist. This will error out.
docker run --rm --entrypoint="" jesse/distroless-image:v1 /bin/bash 2>&1 | head -3 \
    || print_warn "Distroless: /bin/bash DOES NOT EXIST. Attacker is blind and weaponless."
docker run --rm --entrypoint="" jesse/distroless-image:v1 /bin/sh 2>&1 | head -3 \
    || print_warn "Distroless: /bin/sh DOES NOT EXIST either. No shell. Dark room."

# =============================================================================
print_header "SEGMENT 3.1 — VOLUMES & BIND MOUNTS"
# =============================================================================

# =============================================================================
# DEMO 8: Prove The Amnesiac Problem
# Write data inside a container, kill it, start a new one — data is gone.
# =============================================================================
print_demo "Demo 8: Proving Containers Are Amnesiacs"

print_info "Writing a file inside a container..."
docker run --name jesse-amnesiac python:3.10-slim \
    sh -c "mkdir -p /app && echo 'This data will vanish' > /app/data.txt && cat /app/data.txt"

print_info "Container #1 is gone. Starting a BRAND NEW container from the same image..."
docker run --rm python:3.10-slim \
    sh -c "ls /app/ 2>&1 || echo '[CONFIRMED] /app is empty. Data gone. Container forgot everything.'"

docker rm jesse-amnesiac > /dev/null 2>&1 || true
print_warn "This is the problem. What follows is the solution."

# =============================================================================
# DEMO 9: Bind Mounts — Bidirectional Host ↔ Container Sync
# =============================================================================
print_demo "Demo 9: Bind Mounts — Host Folder Appears Inside Container"

mkdir -p /tmp/jesse_host_data
echo "This file was created on the HOST before the container started." > \
    /tmp/jesse_host_data/host_file.txt

print_info "HOST directory BEFORE container runs:"
ls -la /tmp/jesse_host_data/

print_info "Running container with bind mount (-v HOST_PATH:CONTAINER_PATH)..."
# No data is copied. The container gets a live filesystem lens into the host directory.
docker run --rm \
    -v /tmp/jesse_host_data:/app/data \
    python:3.10-slim \
    sh -c "
        echo '[CONTAINER] Files visible (they live on YOUR host disk):';
        ls /app/data/;
        echo '[CONTAINER] Reading host file:';
        cat /app/data/host_file.txt;
        echo '[CONTAINER] Writing a new file to the mount...';
        echo 'Written by the container process' > /app/data/container_output.txt;
        echo '[CONTAINER] Done. Exiting.';
    "

print_info "HOST directory AFTER container ran (container is completely gone):"
ls -la /tmp/jesse_host_data/
echo ""
print_info "Container-created file is ON YOUR HOST:"
cat /tmp/jesse_host_data/container_output.txt

# =============================================================================
# DEMO 10: MLOps Pattern — Large Dataset Injection Without Copying Into Image
# :ro makes the mount read-only — training job can read but cannot corrupt raw data.
# =============================================================================
print_demo "Demo 10: MLOps Pattern — Dataset Injection Without Image Bloat"

mkdir -p /tmp/jesse_ml_datasets

python3 -c "
import csv, random
with open('/tmp/jesse_ml_datasets/training_data.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['feature_1', 'feature_2', 'feature_3', 'label'])
    for _ in range(1000):
        writer.writerow([round(random.gauss(0,1),4) for _ in range(3)] + [random.randint(0,1)])
print('[HOST] Dataset created: /tmp/jesse_ml_datasets/training_data.csv')
"

print_info "Dataset on host (never enters the image):"
du -sh /tmp/jesse_ml_datasets/training_data.csv

print_info "Launching training container — dataset is mounted, NOT copied..."
# :ro — READ-ONLY. Training container sees data but CANNOT modify it.
docker run --rm \
    -v /tmp/jesse_ml_datasets:/app/datasets:ro \
    python:3.10-slim \
    python3 -c "
import csv
with open('/app/datasets/training_data.csv') as f:
    rows = list(csv.DictReader(f))
print(f'[TRAINING] Loaded {len(rows)} rows')
print(f'[TRAINING] Columns: {list(rows[0].keys())}')
print(f'[TRAINING] Row 0: {rows[0]}')
print(f'[TRAINING] Image stayed tiny. Dataset lives on host. This is the MLOps pattern.')
"

# =============================================================================
# DEMO 11: Named Volumes — Data Persists Across Container Deaths
# Container 1 writes → dies → Container 2 (brand new) reads. Data survived.
# =============================================================================
print_demo "Demo 11: Named Volumes — Persistent Storage Managed By Docker"

docker volume create jesse-model-store
print_info "Volume created:"
# --format extracts specific fields from the JSON inspect output.
docker volume inspect jesse-model-store \
    --format "  Name: {{.Name}} | Host Path: {{.Mountpoint}}"

print_info "Container #1: Saving model weights to the named volume..."
docker run --rm \
    -v jesse-model-store:/app/models \
    python:3.10-slim \
    sh -c "
        echo '{accuracy: 0.94, loss: 0.12, epochs: 50}' > /app/models/model_v1.json;
        echo '[CONTAINER 1] Model saved. Contents:';
        ls -la /app/models/;
        echo '[CONTAINER 1] Exiting...';
    "

print_info "Container #1 is DEAD. Launching Container #2 — completely fresh..."
docker run --rm \
    -v jesse-model-store:/app/models \
    python:3.10-slim \
    sh -c "
        echo '[CONTAINER 2] I am a brand new container. Checking the volume...';
        ls /app/models/;
        echo '[CONTAINER 2] Reading model from Container #1:';
        cat /app/models/model_v1.json;
        echo '[CONTAINER 2] Data persisted across container death. Volumes work.';
    "

print_info "All volumes on this system:"
docker volume ls

# =============================================================================
# DEMO 12: Final Side-By-Side Comparison
# =============================================================================
print_demo "Demo 12: Bind Mount vs Named Volume — Final Comparison"

mkdir -p /tmp/jesse_bindmount_output

docker run --rm -v /tmp/jesse_bindmount_output:/output python:3.10-slim \
    sh -c "echo 'Written via BIND MOUNT — you own the host path' > /output/result.txt"

docker run --rm -v jesse-model-store:/output python:3.10-slim \
    sh -c "echo 'Written via NAMED VOLUME — Docker owns the host path' > /output/vol_result.txt"

echo ""
print_info "BIND MOUNT data location (you chose this path):"
echo "  /tmp/jesse_bindmount_output/"
ls -la /tmp/jesse_bindmount_output/

print_info "NAMED VOLUME data location (Docker chose this path):"
VOLUME_PATH=$(docker volume inspect jesse-model-store --format '{{.Mountpoint}}')
echo "  $VOLUME_PATH"
sudo ls -la "$VOLUME_PATH" 2>/dev/null || \
    print_warn "Root-owned. Inspect with: sudo ls $VOLUME_PATH"

echo ""
echo "┌─────────────────────┬──────────────────────────┬────────────────────────────┐"
echo "│ Feature             │ Bind Mount               │ Named Volume               │"
echo "├─────────────────────┼──────────────────────────┼────────────────────────────┤"
echo "│ You control path    │ Yes (explicit)           │ No (Docker manages it)     │"
echo "│ Best for            │ Datasets, live dev code  │ DB data, multi-container   │"
echo "│ Cross-OS portable   │ No (paths differ by OS)  │ Yes                        │"
echo "│ Docker backup tools │ No                       │ Yes (docker volume)        │"
echo "│ Read-only syntax    │ -v host:ctn:ro           │ -v volname:ctn:ro          │"
echo "└─────────────────────┴──────────────────────────┴────────────────────────────┘"

# =============================================================================
# CLEANUP
# =============================================================================
print_demo "Cleanup"
docker rmi jesse/ml-req:v1 jesse/ml-poetry:v1 \
           jesse/ml-cached:v1 jesse/ml-cached:v2 \
           jesse/base-full:v1 jesse/base-slim:v1 \
           jesse/standard-image:v1 jesse/distroless-image:v1 \
           2>/dev/null || true
docker volume rm jesse-model-store 2>/dev/null || true
rm -rf "$WORK_DIR" /tmp/jesse_host_data /tmp/jesse_ml_datasets /tmp/jesse_bindmount_output

print_header "ALL SEGMENTS COMPLETE — Jesse, you're dangerous now."
echo "  2.3 → requirements.txt, poetry pattern, BuildKit cache mounts, base image tradeoffs"
echo "  2.4 → Hadolint bad→fix cycle, distroless multi-stage build, attack surface proof"
echo "  3.1 → Ephemeral container proof, bind mounts + MLOps injection, named volumes"
echo ""
echo "Next batch: 3.2, 4.1, 4.2 — Permissions Hell & Networking. Ready when you are."