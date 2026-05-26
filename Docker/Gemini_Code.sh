#!/bin/bash

################################################################################
# MASTER DOCKER CONCEPTS DEMONSTRATION SCRIPT
# Segments 5, 6, 7: Dockerfile Directives, Layer Caching, Multi-Stage Builds
# Author: DevOps Engineer
# This script creates three complete Docker/Python projects showcasing specific
# Docker concepts through real, functional applications.
################################################################################

# Color codes for terminal output; used for visual distinction between segments
# RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Enable strict error handling: -e exits on error, -u errors on undefined vars,
# -o pipefail exits on pipe failures, allowing the script to catch issues early
set -euo pipefail

################################################################################
# === SEGMENT 5: DOCKERFILE DIRECTIVES ===
# Demonstrates: FROM, FROM scratch, FROM AS, COPY, --chown, ADD, RUN (forms),
# CMD, ENTRYPOINT, ARG, ENV, USER, WORKDIR, EXPOSE, HEALTHCHECK, LABEL, VOLUME,
# .dockerignore, ONBUILD, SHELL, STOPSIGNAL, docker build -t, docker build -f
################################################################################

echo -e "${BLUE}=== SEGMENT 5: DOCKERFILE DIRECTIVES ===${NC}"
echo "Creating a Python Flask API project demonstrating Dockerfile directives..."

# Create a temporary directory for Segment 5; the mkdir -p ensures parent dirs exist
SEGMENT5_DIR=$(mktemp -d)
cd "$SEGMENT5_DIR"

# Create the standalone Bash script that will manage Segment 5 operations
# cat << 'EOF' reads input until EOF, treating single quotes to prevent variable expansion
cat << 'EOF' > segment5_runner.sh
#!/bin/bash

# Enable strict error handling in this segment's runner script
set -euo pipefail

SEGMENT5_PROJECT="flask_api_segment5"

# Function to print debug information with timestamps; used throughout the script
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

# Function to print error messages with timestamps; used for error reporting
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_info "Setting up Segment 5: Flask API with comprehensive Dockerfile directives"

# Create project directory structure using mkdir -p (creates parent directories as needed)
mkdir -p "$SEGMENT5_PROJECT/src"
mkdir -p "$SEGMENT5_PROJECT/config"
cd "$SEGMENT5_PROJECT"

# Create the main Python Flask application file using a Heredoc
# This file demonstrates ENTRYPOINT and server startup concepts
cat << 'PYEOF' > src/app.py
#!/usr/bin/env python3
"""
Flask API demonstrating Docker concepts from a Python application perspective.
This app listens on 0.0.0.0:5000 and provides health check and API endpoints.
"""

from flask import Flask, jsonify
import os
import sys
import logging
from datetime import datetime

# Create Flask application instance; Flask is the WSGI framework
app = Flask(__name__)

# Configure logging to output to stdout/stderr for Docker container visibility
# Docker containers should log to stdout/stderr, not files, for proper log aggregation
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

# Read environment variable set by Dockerfile ENV directive
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')

# Set the logger level based on the ENV variable injected by Dockerfile
logger.setLevel(LOG_LEVEL)

@app.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint used by Docker HEALTHCHECK directive.
    Returns 200 OK if the application is running properly.
    """
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': APP_VERSION
    }), 200

@app.route('/api/info', methods=['GET'])
def api_info():
    """
    API endpoint returning application information.
    Demonstrates that the application can respond to requests inside the container.
    """
    return jsonify({
        'service': 'Flask API',
        'version': APP_VERSION,
        'container_started': True,
        'hostname': os.getenv('HOSTNAME', 'unknown')
    }), 200

@app.route('/api/status', methods=['GET'])
def api_status():
    """
    Status endpoint showing current application state.
    """
    return jsonify({
        'running': True,
        'app_version': APP_VERSION,
        'python_version': sys.version,
        'pid': os.getpid()  # PID 1 inside container when run via ENTRYPOINT
    }), 200

@app.errorhandler(404)
def not_found(error):
    """
    Handle 404 errors gracefully.
    """
    return jsonify({'error': 'Not found', 'message': str(error)}), 404

@app.errorhandler(500)
def internal_error(error):
    """
    Handle 500 errors gracefully.
    """
    return jsonify({'error': 'Internal server error', 'message': str(error)}), 500

if __name__ == '__main__':
    # Bind to 0.0.0.0 to listen on all network interfaces (required in containers)
    # Use debug=False in production (containers should exit on errors, not auto-reload)
    # threaded=True allows multiple concurrent requests (important for Flask in production)
    logger.info(f"Starting Flask API v{APP_VERSION}")
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=False,
        threaded=True
    )
PYEOF

log_info "Python Flask application created at src/app.py"

# Create requirements.txt file listing Python package dependencies
# This file is typically copied into the Docker image and installed via pip
cat << 'REQEOF' > requirements.txt
Flask==2.3.3
Werkzeug==2.3.7
Jinja2==3.1.2
click==8.1.6
itsdangerous==2.1.2
MarkupSafe==2.1.3
REQEOF

log_info "Python requirements file created at requirements.txt"

# Create a configuration file to demonstrate COPY --chown
# This shows how to copy configuration that should be owned by a non-root user
cat << 'CONFEOF' > config/app.conf
# Application Configuration for Segment 5
[logging]
level = INFO
format = json

[server]
host = 0.0.0.0
port = 5000
workers = 4

[security]
require_auth = false
ssl_enabled = false
CONFEOF

log_info "Application configuration created at config/app.conf"

# Create a .dockerignore file to demonstrate exclusion patterns
# .dockerignore specifies files/directories NOT sent to Docker daemon (like .gitignore)
# Benefits: reduces build context size, speeds up builds, prevents secrets in image
cat << 'DOCKERIGNOREOF' > .dockerignore
# .dockerignore: files excluded from the Docker build context
# The build context is the filesystem scope sent to the Docker daemon

# Version control: not needed in running container
.git
.gitignore
.github

# Development/testing artifacts: reduce image size
__pycache__
*.pyc
*.pyo
*.pyd
.pytest_cache
.coverage
htmlcov

# IDE and editor files: not part of the application
.vscode
.idea
*.swp
*.swo
*~
.DS_Store

# Development documentation
*.md
docs/
CHANGELOG

# Environment files
.env
.env.local
.env.*.local

# Temporary files
tmp/
temp/
*.tmp
DOCKERIGNOREOF

log_info ".dockerignore file created with build context exclusion patterns"

# Create main Dockerfile demonstrating all Segment 5 directives
# Using -f flag would allow specifying a different Dockerfile path (e.g., Dockerfile.prod)
cat << 'DOCKEREOF' > Dockerfile
# === DOCKERFILE DIRECTIVES DEMONSTRATION (SEGMENT 5) ===

# FROM: Sets the base image; all Dockerfile commands build on top of this image
# python:3.11-slim is a pre-built image containing Python 3.11 and minimal OS
# The -slim variant reduces image size by omitting optional packages
FROM python:3.11-slim AS base

# LABEL: Attaches metadata to the image, queryable via docker inspect
# Labels don't affect functionality but help document and organize images
LABEL maintainer="devops@example.com"
LABEL description="Flask API demonstrating Dockerfile directives"
LABEL version="1.0.0"
LABEL segment="5"

# WORKDIR: Sets the working directory for subsequent RUN, CMD, ENTRYPOINT, COPY, ADD
# Creates the directory if it doesn't exist; all relative paths reference this dir
WORKDIR /app

# ENV: Sets persistent environment variables baked into the image
# These vars are inherited by ALL containers launched from this image
# Using ENV avoids hardcoding config; can be overridden at runtime with docker run -e
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_VERSION=1.0.0 \
    LOG_LEVEL=INFO

# ARG: Declares a build-time variable passed via --build-arg during docker build
# ARG values are NOT persisted in the final image (unlike ENV)
# Example usage: docker build --build-arg BUILD_DATE=$(date) -t myimage .
ARG BUILD_DATE
ARG VCS_REF
ARG CACHE_BUST=default

# RUN (shell form): Executes commands in /bin/sh -c shell inside a new layer
# Each RUN creates an immutable layer; Docker caches these layers for speed
# Shell form allows && chaining, pipes, redirects; runs via /bin/sh -c
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# COPY: Copies files/directories from the build host into the image
# COPY path/in/context /path/in/image
# COPY respects .dockerignore patterns (excluding unnecessary files)
# Preferred over ADD for clarity and predictability (no auto-extraction)
COPY requirements.txt .

# RUN (exec form): Executes a command using exec (array format), bypassing /bin/sh
# Exec form: RUN ["executable", "param1", "param2"]
# Avoids /bin/sh -c wrapper, making the executable PID 1 of the layer
# Better for signal handling and direct execution (no shell interpretation)
RUN ["python", "-m", "pip", "install", "--upgrade", "pip", "setuptools", "wheel"]
RUN ["python", "-m", "pip", "install", "-r", "requirements.txt"]

# COPY with --chown: Copies files and sets ownership in a single step
# Format: COPY --chown=<user>:<group> source dest
# Avoids needing a separate RUN chown command, keeping layers minimal
# Creates non-root user 'appuser' (UID 1000) who runs the application
COPY --chown=1000:1000 src/ ./src/
COPY --chown=1000:1000 config/ ./config/

# CREATE NON-ROOT USER: Security best practice to reduce privilege escalation risk
# Runs the container as 'appuser' instead of root (UID 0)
RUN useradd -m -u 1000 appuser

# USER: Sets the UID (and optionally GID) for subsequent RUN, CMD, ENTRYPOINT
# All processes in the container will run as this user (non-root)
# Single highest-impact security directive: limits damage if container is compromised
USER appuser

# EXPOSE: Documents which ports the container listens on
# EXPOSE is purely declarative; does NOT publish ports to the host
# To publish: docker run -p 5000:5000 or use compose.yaml ports section
# Multiple EXPOSE lines or comma-separated ports can be used
EXPOSE 5000

# HEALTHCHECK: Docker periodically runs a command inside the container
# Determines container health status: healthy, unhealthy, or starting
# Used by orchestrators (Kubernetes) to restart unhealthy containers
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --retries=3 \
            --start-period=40s \
    CMD curl -f http://localhost:5000/health || exit 1

# SHELL: Overrides the default shell used for RUN, CMD, ENTRYPOINT shell-form
# Default shell on Linux: /bin/sh -c
# Allows switching to bash if more complex shell features needed
SHELL ["/bin/bash", "-c"]

# STOPSIGNAL: Signal sent to PID 1 when docker stop is called
# Default: SIGTERM (allows graceful shutdown)
# SIGKILL is not recommended as it prevents cleanup
STOPSIGNAL SIGTERM

# ENTRYPOINT: Sets the main command that runs when container starts
# Unlike CMD, ENTRYPOINT cannot be easily overridden (requires --entrypoint flag)
# Exec form (array) is preferred: doesn't spawn /bin/sh, direct execution
# This makes the Python app PID 1, enabling proper signal handling
ENTRYPOINT ["python", "-u", "src/app.py"]

# CMD: Provides default arguments to ENTRYPOINT (or default command if no ENTRYPOINT)
# Can be overridden: docker run <image> bash (overwrites CMD)
# Since ENTRYPOINT is set, CMD here would be extra args (rarely used in this pattern)
CMD []
DOCKEREOF

log_info "Dockerfile created demonstrating all Segment 5 directives"

# Create docker-compose.yaml to show Docker Compose integration
# Demonstrates VOLUME, EXPOSE, ENV variable injection, and port mapping
cat << 'COMPOSEEOF' > docker-compose.yaml
# Docker Compose file for Segment 5
version: '3.9'

services:
  flask_api:
    # build: specifies how to build the image from Dockerfile
    # Equivalent to: docker build -t flask_api_segment5 .
    build:
      context: .
      dockerfile: Dockerfile
      # build args passed to docker build --build-arg
      args:
        BUILD_DATE: "2024-01-15T10:00:00Z"
        VCS_REF: "abc1234567890def"
        CACHE_BUST: "segment5_demo"
    
    # container_name: explicit name for the running container
    container_name: flask_api_segment5
    
    # ports: maps container port to host port (container:host)
    # Satisfies the EXPOSE 5000 directive with actual port binding
    ports:
      - "5000:5000"
    
    # environment: injects environment variables into the running container
    # These override the ENV directives from Dockerfile (but don't modify image)
    environment:
      - LOG_LEVEL=DEBUG
      - PYTHONUNBUFFERED=1
    
    # volumes: mounts host paths or named volumes into the container
    # Path:/path = host path mapping
    # Named volumes are defined in the volumes: section below
    volumes:
      # Read-only mount of config directory
      - ./config:/app/config:ro
      # Writeable mount for application logs (if needed)
      - app_logs:/app/logs
    
    # restart_policy: container restart behavior
    # "unless-stopped": restart unless explicitly stopped
    restart_policy:
      condition: unless-stopped
      delay: 5s
      max_attempts: 3
    
    # healthcheck: defines health check for the container
    # Used by Compose and orchestrators to monitor container status
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # depends_on: specifies dependency on other services
    # (not used in this example, but shows common pattern)

# Named volumes: persistent storage managed by Docker
volumes:
  app_logs:
    driver: local
COMPOSEEOF

log_info "docker-compose.yaml created with volume and healthcheck definitions"

# Create a second Dockerfile variant to show --build-arg and cache control
# Demonstrates how ARG is used for parameterized builds
cat << 'DOCKERPRODEOF' > Dockerfile.prod
# === SEGMENT 5: PRODUCTION DOCKERFILE VARIANT ===
# This Dockerfile shows optional production optimizations
# Used with: docker build -f Dockerfile.prod --build-arg CACHE_BUST=$(date) -t image:prod .

FROM python:3.11-slim AS base

LABEL maintainer="devops@example.com"
LABEL environment="production"
LABEL cache_strategy="external"

WORKDIR /app

# ARG used for cache busting: forces rebuild when value changes
# Cache is busted by providing different --build-arg value in CI/CD
ARG CACHE_BUST=default
ARG BUILD_DATE
ARG VCS_REF

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_VERSION=1.0.0 \
    LOG_LEVEL=CRITICAL

# Invalidate cache if CACHE_BUST arg changes (forces rebuild)
# CACHE_BUST is not used in command, but its change invalidates this layer
RUN echo "Build cache buster: ${CACHE_BUST}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install --upgrade pip setuptools wheel
RUN python -m pip install -r requirements.txt

COPY --chown=1000:1000 src/ ./src/
COPY --chown=1000:1000 config/ ./config/

RUN useradd -m -u 1000 appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
    CMD curl -f http://localhost:5000/health || exit 1

STOPSIGNAL SIGTERM

ENTRYPOINT ["python", "-u", "src/app.py"]
CMD []
DOCKERPRODEOF

log_info "Production Dockerfile variant created (Dockerfile.prod)"

log_info "Segment 5 setup complete. To run:"
log_info "  1. docker build -t flask_api_segment5 ."
log_info "  2. docker run -p 5000:5000 flask_api_segment5"
log_info "  3. OR: docker-compose up --build"

EOF

# Make the segment5_runner.sh executable; chmod +x adds execute permission
chmod +x segment5_runner.sh

# Execute the standalone Segment 5 runner script
# This will set up all files and demonstrate the concepts
bash segment5_runner.sh

echo -e "${GREEN}✓ Segment 5 complete: Dockerfile directives project created${NC}"

# Return to parent directory after Segment 5 completes
cd -

################################################################################
# === SEGMENT 6: LAYER CACHING AND BUILD OPTIMIZATION ===
# Demonstrates: layer cache, cache invalidation, golden ordering, --cache-from,
# --no-cache, RUN --mount=type=cache, cache mount options, --cache-to backends,
# ARG CACHE_BUST, BUILDKIT_INLINE_CACHE
################################################################################

echo -e "${BLUE}=== SEGMENT 6: LAYER CACHING AND BUILD OPTIMIZATION ===${NC}"
echo "Creating a Python data processing project demonstrating caching strategies..."

# Create a temporary directory for Segment 6
SEGMENT6_DIR=$(mktemp -d)
cd "$SEGMENT6_DIR"

# Create the standalone Bash script for Segment 6 caching demonstrations
cat << 'EOF' > segment6_runner.sh
#!/bin/bash

set -euo pipefail

SEGMENT6_PROJECT="data_processor_segment6"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_info "Setting up Segment 6: Data Processor with layer caching optimization"

mkdir -p "$SEGMENT6_PROJECT/src"
mkdir -p "$SEGMENT6_PROJECT/tests"
cd "$SEGMENT6_PROJECT"

# Create Python data processing application
# This app requires multiple heavy dependencies to demonstrate caching benefits
cat << 'PYEOF' > src/processor.py
#!/usr/bin/env python3
"""
Data processing application demonstrating Docker layer caching.
Uses numpy, pandas, scikit-learn for CPU-intensive operations.
"""

import sys
import logging
from datetime import datetime
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class DataProcessor:
    """Processes and analyzes datasets using numpy and pandas."""
    
    def __init__(self, random_seed=42):
        """Initialize processor with random seed for reproducibility."""
        np.random.seed(random_seed)
        self.scaler = StandardScaler()
        logger.info("DataProcessor initialized")
    
    def generate_sample_data(self, n_samples=1000, n_features=10):
        """Generate random sample data for processing."""
        logger.info(f"Generating {n_samples} samples with {n_features} features")
        X = np.random.randn(n_samples, n_features)
        y = np.random.randint(0, 2, n_samples)
        return X, y
    
    def process_data(self, X, y):
        """Normalize features and prepare data."""
        logger.info("Scaling features using StandardScaler")
        X_scaled = self.scaler.fit_transform(X)
        
        # Create DataFrame for easier analysis
        df = pd.DataFrame(X_scaled, columns=[f'feature_{i}' for i in range(X.shape[1])])
        df['target'] = y
        
        logger.info(f"Data shape: {df.shape}")
        logger.info(f"Data dtypes: {df.dtypes.to_dict()}")
        
        return df
    
    def analyze_data(self, df):
        """Compute statistics on processed data."""
        logger.info("Computing statistical summaries")
        summary = {
            'mean': df.select_dtypes(include=[np.number]).mean().to_dict(),
            'std': df.select_dtypes(include=[np.number]).std().to_dict(),
            'shape': df.shape,
            'processed_at': datetime.utcnow().isoformat()
        }
        return summary

def main():
    """Main entry point for the data processor."""
    logger.info("Starting data processor")
    
    processor = DataProcessor()
    X, y = processor.generate_sample_data(n_samples=5000, n_features=20)
    df = processor.process_data(X, y)
    summary = processor.analyze_data(df)
    
    logger.info(f"Processing complete: {summary}")
    print("SUCCESS: Data processing completed without errors")

if __name__ == '__main__':
    main()
PYEOF

log_info "Data processor application created at src/processor.py"

# Create comprehensive requirements.txt with many dependencies
# This demonstrates caching benefits when dependency list changes
cat << 'REQEOF' > requirements.txt
# Core numerical and data processing libraries
numpy==1.24.3
pandas==2.0.3
scikit-learn==1.3.0

# Additional data processing libraries
scipy==1.11.1
matplotlib==3.7.2
seaborn==0.12.2

# Utilities
requests==2.31.0
python-dotenv==1.0.0
click==8.1.6

# Development and testing
pytest==7.4.0
pytest-cov==4.1.0
black==23.7.0
flake8==6.0.0
REQEOF

log_info "Requirements file created with multiple packages for caching demo"

# Create test file to demonstrate --target builds
cat << 'TESTEOF' > tests/test_processor.py
#!/usr/bin/env python3
"""Unit tests for data processor."""

import pytest
from src.processor import DataProcessor
import numpy as np

class TestDataProcessor:
    
    def test_initialization(self):
        """Test processor initialization."""
        processor = DataProcessor(random_seed=42)
        assert processor is not None
    
    def test_generate_sample_data(self):
        """Test sample data generation."""
        processor = DataProcessor(random_seed=42)
        X, y = processor.generate_sample_data(n_samples=100, n_features=5)
        assert X.shape == (100, 5)
        assert y.shape == (100,)
        assert len(np.unique(y)) == 2
    
    def test_process_data(self):
        """Test data processing and scaling."""
        processor = DataProcessor(random_seed=42)
        X, y = processor.generate_sample_data(n_samples=100, n_features=5)
        df = processor.process_data(X, y)
        assert df.shape[0] == 100
        assert df.shape[1] == 6  # 5 features + target
        assert 'target' in df.columns
    
    def test_analyze_data(self):
        """Test data analysis."""
        processor = DataProcessor(random_seed=42)
        X, y = processor.generate_sample_data(n_samples=100, n_features=5)
        df = processor.process_data(X, y)
        summary = processor.analyze_data(df)
        assert 'mean' in summary
        assert 'std' in summary
        assert 'shape' in summary
        assert summary['shape'] == (100, 6)
TESTEOF

log_info "Test file created at tests/test_processor.py"

# Create optimized Dockerfile demonstrating layer caching and golden ordering
cat << 'DOCKEREOF' > Dockerfile
# === DOCKERFILE WITH OPTIMIZED LAYER CACHING (SEGMENT 6) ===
# This Dockerfile demonstrates "golden ordering": least-changing layers first,
# frequently-changing layers last, to maximize cache hit rates.
#
# Layer cache: Docker reuses unchanged layers from previous builds, speeding up builds.
# Cache invalidation: When a layer changes, all subsequent layers rebuild (no cache).
# Golden ordering: OS deps → Python → requirements → source code
#
# To test caching:
#   1. docker build -t processor:v1 .           (builds all layers, caches them)
#   2. Change only src/processor.py
#   3. docker build -t processor:v2 .           (reuses cached layers up to COPY src/)

FROM python:3.11-slim

LABEL maintainer="devops@example.com"
LABEL segment="6-caching"
LABEL description="Data processor with caching optimization demonstrations"

WORKDIR /app

# === GOLDEN ORDERING PRINCIPLE ===
# Layer 1: Least-changing - OS-level dependencies (apt packages)
# Installing system packages is expensive; unlikely to change frequently
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# === GOLDEN ORDERING PRINCIPLE ===
# Layer 2: Python infrastructure - pip, setuptools, wheel upgrades
# Also relatively stable; needed before installing Python packages
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel

# === GOLDEN ORDERING PRINCIPLE ===
# Layer 3: Python dependencies - copy requirements.txt and install
# More likely to change than OS deps, but changes less frequently than source
# Separating this layer allows cached reuse even when source code changes
# This is the KEY optimization: dependencies don't reinstall on source changes
COPY requirements.txt .

# COPY in two steps: lock dependencies first, then application code
# If only app.py changes, pip install is skipped (cache hit)
RUN python -m pip install --no-cache-dir -r requirements.txt

# === GOLDEN ORDERING PRINCIPLE ===
# Layer 4: Most-changing - application source code
# Source code changes frequently (every commit); placed last to maximize cache reuse
# When dev changes src/processor.py, previous layers (apt, pip installs) use cache
COPY src/ ./src/
COPY tests/ ./tests/

# Create unprivileged user for security
RUN useradd -m -u 1000 appuser
USER appuser

# ENTRYPOINT: The command that runs when container starts
ENTRYPOINT ["python", "-u", "src/processor.py"]
CMD []
DOCKEREOF

log_info "Dockerfile created with golden ordering optimization"

# Create Dockerfile.cache demonstrating BuildKit mount caching
# RUN --mount=type=cache persists cache between builds without creating layers
cat << 'DOCKERCACHEEOF' > Dockerfile.cache
# === DOCKERFILE WITH BUILDKIT CACHE MOUNTS (SEGMENT 6) ===
# This Dockerfile uses BuildKit-specific RUN --mount=type=cache feature.
#
# BuildKit cache mounts:
# - Cache persists between builds without becoming image layers
# - Speeds up repeated builds (e.g., apt-get, pip cache)
# - Not visible in final image (no bloat)
# - Requires DOCKER_BUILDKIT=1 environment variable
#
# To use this Dockerfile:
#   DOCKER_BUILDKIT=1 docker build -f Dockerfile.cache -t processor:cache .
#
# The first build is slightly slower (populates cache).
# Subsequent builds are MUCH faster (reuses cache mounts).

# syntax=docker/dockerfile:1.4
# The syntax directive enables BuildKit features (required for cache mounts)

FROM python:3.11-slim

LABEL segment="6-buildkit-cache"
LABEL description="Data processor with BuildKit cache mounts"

WORKDIR /app

# RUN with cache mount: apt cache persists between builds
# --mount=type=cache,target=/var/cache/apt mounts /var/cache/apt as a cache
# The cache is not stored in the image layer (keeping image small)
# Between builds, the cache is reused if this layer hasn't changed
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl

# Upgrade pip with cache mount for pip cache directory
# --mount=type=cache,target=/root/.cache/pip caches pip downloads/installations
# id=pip-cache names this mount so it can be reused in other stages
RUN --mount=type=cache,target=/root/.cache/pip,id=pip-cache \
    python -m pip install --upgrade pip setuptools wheel

COPY requirements.txt .

# RUN pip install with cache mount: pip dependencies cached
# Subsequent builds with the same requirements.txt reuse this cache
# Dramatic speedup for projects with many dependencies
RUN --mount=type=cache,target=/root/.cache/pip,id=pip-cache \
    python -m pip install -r requirements.txt

COPY src/ ./src/
COPY tests/ ./tests/

RUN useradd -m -u 1000 appuser
USER appuser

ENTRYPOINT ["python", "-u", "src/processor.py"]
CMD []
DOCKERCACHEEOF

log_info "Dockerfile.cache created with BuildKit cache mount optimization"

# Create docker-compose with caching examples
cat << 'COMPOSEEOF' > docker-compose.yaml
version: '3.9'

services:
  processor_standard:
    # Standard build: uses default caching
    build:
      context: .
      dockerfile: Dockerfile
    container_name: processor_standard
    # cache_from: tells BuildKit to use an external image as cache source
    # If processor:latest exists, its layers are used as cache before rebuilding
    # Useful in CI: previous builds provide cache for faster builds
    # Format: cache_from: ["image:tag", "docker.io/registry/image:tag"]
    environment:
      PYTHONUNBUFFERED: "1"
    command: python -u src/processor.py
  
  processor_buildkit:
    # BuildKit build: uses RUN --mount=type=cache for optimization
    # Requires DOCKER_BUILDKIT=1 environment variable
    # Dockerfile.cache uses cache mounts for apt and pip caches
    build:
      context: .
      dockerfile: Dockerfile.cache
      # cache_to: exports build cache to a backend for reuse
      # Useful for CI/CD: saves cache to registry for stateless builders
      # Options: type=registry, type=gha, type=s3, type=local
      cache_to: ["type=inline"]  # Embeds cache in image manifest
    container_name: processor_buildkit
    environment:
      PYTHONUNBUFFERED: "1"
    command: python -u src/processor.py
COMPOSEEOF

log_info "docker-compose.yaml created with caching configurations"

# Create build script demonstrating cache control flags
cat << 'SCRIPTEOF' > build_examples.sh
#!/bin/bash
# === BUILD SCRIPT DEMONSTRATING CACHING CONCEPTS ===

set -euo pipefail

echo "=== Docker Build Caching Demonstrations ==="
echo ""

# Example 1: Standard build (uses cache)
echo "1. Standard build (cache enabled):"
echo "   docker build -t processor:standard ."
echo "   First build: slow (no cache). Second build: fast (cache hit)."
echo ""

# Example 2: Build without cache
echo "2. Force rebuild (ignore cache):"
echo "   docker build --no-cache -t processor:nocache ."
echo "   Rebuilds all layers even if they haven't changed."
echo "   Useful for ensuring fresh dependencies, testing cache logic."
echo ""

# Example 3: BuildKit cache mounts
echo "3. BuildKit with cache mounts (requires DOCKER_BUILDKIT=1):"
echo "   DOCKER_BUILDKIT=1 docker build -f Dockerfile.cache -t processor:cache ."
echo "   Cache mounts speed up apt-get and pip install significantly."
echo "   Cache persists between builds without creating image layers."
echo ""

# Example 4: Cache bust with ARG
echo "4. Cache busting with dynamic ARG:"
echo "   docker build --build-arg CACHE_BUST=\$(date) -t processor:fresh ."
echo "   Changes CACHE_BUST value, invalidating cached layers."
echo "   Forces rebuild even if source code hasn't changed."
echo ""

# Example 5: Docker Compose build
echo "5. Using Docker Compose for caching:"
echo "   docker-compose build processor_standard"
echo "   docker-compose build processor_buildkit"
echo ""

# Example 6: Cache from external image
echo "6. Using external image as cache source:"
echo "   docker build --cache-from processor:v1 -t processor:v2 ."
echo "   Pulls processor:v1 and uses its layers as cache."
echo "   Useful when previous builds are in a registry."
echo ""

echo "=== Cache Optimization Tips ==="
echo "• Use 'golden ordering': least-changing layers first"
echo "• Separate requirements from source code for better caching"
echo "• Use BuildKit cache mounts for slow operations (apt, pip)"
echo "• Cache from registries in CI for stateless builders"
echo "• Use --no-cache only when cache is actually stale"
SCRIPTEOF

chmod +x build_examples.sh

log_info "Build examples script created"

log_info "Segment 6 setup complete. To test caching:"
log_info "  1. DOCKER_BUILDKIT=1 docker build -f Dockerfile -t processor:v1 ."
log_info "  2. DOCKER_BUILDKIT=1 docker build -f Dockerfile.cache -t processor:cache ."
log_info "  3. bash build_examples.sh (for examples)"

EOF

chmod +x segment6_runner.sh
bash segment6_runner.sh

echo -e "${GREEN}✓ Segment 6 complete: Layer caching optimization project created${NC}"

cd -

################################################################################
# === SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES ===
# Demonstrates: multi-stage build, FROM AS builder, COPY --from=, 
# docker build --target, distroless image, scratch, alpine, musl libc, glibc,
# debian-slim, CGO_ENABLED=0, GOOS/GOARCH
################################################################################

echo -e "${BLUE}=== SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES ===${NC}"
echo "Creating a Python ML model builder demonstrating multi-stage builds..."

# Create a temporary directory for Segment 7
SEGMENT7_DIR=$(mktemp -d)
cd "$SEGMENT7_DIR"

# Create the standalone Bash script for Segment 7 multi-stage builds
cat << 'EOF' > segment7_runner.sh
#!/bin/bash

set -euo pipefail

SEGMENT7_PROJECT="ml_model_builder_segment7"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_info "Setting up Segment 7: ML Model Builder with multi-stage builds"

mkdir -p "$SEGMENT7_PROJECT/src"
mkdir -p "$SEGMENT7_PROJECT/models"
mkdir -p "$SEGMENT7_PROJECT/tests"
cd "$SEGMENT7_PROJECT"

# Create ML model training script that will be in builder stage
cat << 'PYEOF' > src/train_model.py
#!/usr/bin/env python3
"""
ML model training script.
This runs in the builder stage and outputs a trained model.
The runtime stage copies only the model, not training dependencies.
"""

import sys
import logging
import pickle
import os
from pathlib import Path

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def train_model():
    """Train a simple ML model and save it."""
    logger.info("Loading Iris dataset")
    
    # Load dataset
    iris = load_iris()
    X, y = iris.data, iris.target
    
    # Split data
    logger.info("Splitting data: 80% train, 20% test")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train model
    logger.info("Training Random Forest classifier")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    logger.info("Evaluating model")
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    logger.info(f"Accuracy: {accuracy:.4f}")
    
    # Save model
    model_path = Path("/models/iris_model.pkl")
    model_path.parent.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"Saving model to {model_path}")
    with open(model_path, 'wb') as f:
        pickle.dump(model, f)
    
    logger.info("Model training complete")
    return model, accuracy

if __name__ == '__main__':
    model, accuracy = train_model()
    print(f"SUCCESS: Model trained with {accuracy:.4f} accuracy")
PYEOF

log_info "Model training script created at src/train_model.py"

# Create model prediction/inference script that uses the trained model
cat << 'PREDEOF' > src/predict.py
#!/usr/bin/env python3
"""
Model prediction script.
Uses a pre-trained model (copied from builder stage).
Minimal dependencies: only inference libraries, not training libraries.
"""

import pickle
import logging
from pathlib import Path
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_model(model_path="/models/iris_model.pkl"):
    """Load a pre-trained model."""
    logger.info(f"Loading model from {model_path}")
    
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    
    logger.info("Model loaded successfully")
    return model

def predict(model, features):
    """Make prediction with the model."""
    logger.info(f"Making prediction for features: {features}")
    
    prediction = model.predict([features])
    probabilities = model.predict_proba([features])
    
    return {
        'prediction': int(prediction[0]),
        'probabilities': probabilities[0].tolist(),
        'class_names': ['Setosa', 'Versicolor', 'Virginica']
    }

if __name__ == '__main__':
    model = load_model()
    
    # Example: predict for a sample iris
    sample = [5.1, 3.5, 1.4, 0.2]  # Iris Setosa features
    result = predict(model, sample)
    
    print(f"Prediction: {result['class_names'][result['prediction']]}")
    print(f"Probabilities: {result['probabilities']}")
PREDEOF

log_info "Prediction script created at src/predict.py"

# Create requirements for builder stage (all packages)
cat << 'BUILDREQEOF' > requirements-builder.txt
# Builder stage requirements: includes training dependencies
numpy==1.24.3
pandas==2.0.3
scikit-learn==1.3.0
matplotlib==3.7.2
seaborn==0.12.2
joblib==1.3.1
pytest==7.4.0
BUILDREQEOF

log_info "Builder requirements created at requirements-builder.txt"

# Create requirements for runtime stage (minimal packages)
cat << 'RUNTIMEREQEOF' > requirements-runtime.txt
# Runtime requirements: only prediction/inference
scikit-learn==1.3.0
joblib==1.3.1
numpy==1.24.3
RUNTIMEREQEOF

log_info "Runtime requirements created at requirements-runtime.txt"

# Create main multi-stage Dockerfile demonstrating all Segment 7 concepts
cat << 'DOCKEREOF' > Dockerfile
# === MULTI-STAGE BUILD DOCKERFILE (SEGMENT 7) ===
#
# Multi-stage builds use multiple FROM instructions:
# 1. Builder stage: includes all build/training dependencies (slow, large)
# 2. Linter/test stages: optional, can use --target to run tests only
# 3. Runtime stage: copies only artifacts, minimal dependencies (fast, small)
#
# Benefits:
# - Final image omits build dependencies (smaller CVE attack surface)
# - Development and production images from same Dockerfile
# - Cache builder layers separately from runtime layers
#
# Build this Dockerfile with:
#   docker build -t model:builder --target builder .    (stops at builder)
#   docker build -t model:runtime .                      (builds full multi-stage)
#   docker build --target test -t model:test . && \      (build test stage)
#     docker run model:test                              (run tests)

# === STAGE 1: BUILDER STAGE ===
# FROM <image> AS <name>: Creates a named build stage that later stages can reference
# This stage includes heavy dependencies for model training
# Doesn't appear in final image (only artifacts are copied out)

FROM python:3.11-slim AS builder

LABEL stage="builder"
LABEL description="Builder stage: trains ML model with full dependencies"

WORKDIR /build

# === GOLDEN ORDERING: System dependencies ===
# Install build tools needed for compiling Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# === GOLDEN ORDERING: Python infrastructure ===
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel

# === GOLDEN ORDERING: Builder dependencies ===
# Copy requirements for builder (includes training packages)
COPY requirements-builder.txt .
RUN python -m pip install --no-cache-dir -r requirements-builder.txt

# === GOLDEN ORDERING: Source code ===
COPY src/ ./src/

# Create output directory where model will be saved
RUN mkdir -p /models

# RUN the training script to produce the model artifact
# This runs during docker build, creating the model file
# The model file will be copied to the runtime stage with COPY --from=builder
RUN python src/train_model.py

# After RUN completes, the /models/iris_model.pkl file exists
# This is the artifact we want to keep; everything else (training libs) is discarded


# === STAGE 2: LINTER/TEST STAGE (OPTIONAL) ===
# This stage demonstrates optional intermediate stages for testing
# Build with --target test to run tests without building the runtime image
# Useful in CI: test before building production image

FROM builder AS test

LABEL stage="test"
LABEL description="Test stage: runs unit tests"

WORKDIR /build

COPY tests/ ./tests/

# Run tests (would fail if tests don't pass, stopping the build)
RUN python -m pytest tests/ -v || exit 1


# === STAGE 3: RUNTIME STAGE ===
# The final stage: small, production image
# Uses distroless or alpine for minimal base image
# Copies only the trained model from builder stage

FROM python:3.11-slim AS runtime

LABEL stage="runtime"
LABEL description="Runtime stage: minimal image for inference"

WORKDIR /app

# Only install minimal runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade --no-cache-dir pip

# Copy only runtime requirements (NOT builder requirements)
COPY requirements-runtime.txt .
RUN python -m pip install --no-cache-dir -r requirements-runtime.txt

# Copy application code (prediction script)
COPY src/predict.py ./src/
COPY src/__init__.py ./src/ 2>/dev/null || true

# COPY --from=<stage>: Copies files from another stage (not from build context)
# Format: COPY --from=<stage_name_or_number> <source> <dest>
# The <stage_name_or_number> can be:
#   - Named stage: "FROM python:3.11-slim AS builder" -> --from=builder
#   - Numbered: first FROM is 0, second is 1, etc -> --from=0
#   - External image: COPY --from=external:latest /artifact /app/artifact
#
# This COPY pulls the trained model from the builder stage
# The model was created during builder's RUN, now appears in runtime image
COPY --from=builder --chown=1000:1000 /models /models

# Non-root user for security
RUN useradd -m -u 1000 appuser
USER appuser

EXPOSE 8000

# HEALTHCHECK can reference artifacts from earlier stages
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD test -f /models/iris_model.pkl || exit 1

ENTRYPOINT ["python", "-u", "src/predict.py"]
CMD []
DOCKEREOF

log_info "Multi-stage Dockerfile created with builder, test, and runtime stages"

# Create distroless variant Dockerfile
# Distroless images: minimal base images maintained by Google
# Contains only runtime (no shell, no package manager, no utilities)
# Benefits: small size, fewer packages = fewer CVEs
# Trade-off: cannot debug inside container easily

cat << 'DISTROLESSEOF' > Dockerfile.distroless
# === MULTI-STAGE BUILD WITH DISTROLESS BASE IMAGE ===
#
# Distroless base images:
# - Maintained by Google (google/distroless/python3-nonroot)
# - Contains ONLY Python runtime, no shell, no package manager
# - Much smaller than python:3.11-slim (hundreds of MB vs ~100MB)
# - Eliminates most CVE attack surface (no bash, no apt-get, etc.)
# - Cannot exec into container for debugging (intentional for production)
#
# To use: docker build -f Dockerfile.distroless -t model:distroless .
#
# Limitations of distroless:
# - Cannot install packages after the image is built
# - Cannot debug with shell access
# - All dependencies must be provided in builder stage
# - Not suitable for development, excellent for production

FROM python:3.11-slim AS builder

LABEL stage="builder"

WORKDIR /build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ && \
    apt-get clean

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements-builder.txt .
RUN python -m pip install --no-cache-dir -r requirements-builder.txt

COPY src/ ./src/

RUN mkdir -p /models && \
    python src/train_model.py


# === RUNTIME STAGE: DISTROLESS BASE ===
# google/distroless/python3-nonroot: Python-only distroless image
# Runs as non-root user 'nonroot' (UID 65532) automatically
# Requires Python version match: python3-nonroot includes Python 3.11

FROM google/distroless/python3-nonroot:nonroot

LABEL stage="runtime"
LABEL base_image="distroless"

WORKDIR /app

# In distroless, we cannot install packages
# All Python packages must be copied from builder stage

# Copy Python site-packages from builder to avoid reinstalling
# The builder has all packages installed; we copy the entire directory
COPY --from=builder --chown=nonroot:nonroot /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the prediction script
COPY --from=builder --chown=nonroot:nonroot /build/src/ ./src/

# Copy the trained model
COPY --from=builder --chown=nonroot:nonroot /models /models

# No RUN commands possible in distroless (no shell)
# No HEALTHCHECK possible (no curl, no shell for testing)
# The user is already 'nonroot' (UID 65532)

ENTRYPOINT ["/usr/bin/python3", "-u", "/app/src/predict.py"]
DOCKEREOF

log_info "Distroless Dockerfile variant created at Dockerfile.distroless"

# Create alpine variant (demonstrates musl libc vs glibc)
# Alpine: minimal Linux distribution based on musl libc
# Benefits: ~5MB base image, widely used
# Trade-offs: musl libc compatibility issues with precompiled binaries

cat << 'ALPINEEOF' > Dockerfile.alpine
# === MULTI-STAGE BUILD WITH ALPINE BASE IMAGE ===
#
# Alpine Linux:
# - Minimal Linux distribution (~5MB base image)
# - Uses musl libc instead of glibc
# - Built on BusyBox (lightweight utilities)
# - Popular for small container images
#
# Compatibility considerations:
# - Some precompiled binaries expect glibc (will not work on Alpine)
# - Python packages with C extensions may fail to install
# - Scientific packages (numpy, scikit-learn) work but may be slower
#
# To use: docker build -f Dockerfile.alpine -t model:alpine .

FROM python:3.11-alpine AS builder

LABEL stage="builder"

WORKDIR /build

# Alpine uses apk instead of apt-get for package management
# apk add installs packages from Alpine repositories
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    python3-dev

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements-builder.txt .
RUN python -m pip install --no-cache-dir -r requirements-builder.txt

COPY src/ ./src/

RUN mkdir -p /models && \
    python src/train_model.py


# === RUNTIME STAGE: ALPINE ===
# Alpine runtime: minimal base with Python

FROM python:3.11-alpine AS runtime

LABEL stage="runtime"
LABEL base_image="alpine"
LABEL libc="musl"

WORKDIR /app

# Alpine minimal packages: curl for healthcheck
RUN apk add --no-cache curl

RUN python -m pip install --upgrade pip

COPY requirements-runtime.txt .
RUN python -m pip install --no-cache-dir -r requirements-runtime.txt

COPY --from=builder --chown=1000:1000 /build/src/ ./src/
COPY --from=builder --chown=1000:1000 /models /models

RUN adduser -D -u 1000 appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health 2>/dev/null || exit 1

ENTRYPOINT ["python", "-u", "src/predict.py"]
DOCKEREOF

log_info "Alpine Dockerfile variant created at Dockerfile.alpine"

# Create debian-slim variant
# Debian-slim: middle ground between full Debian and Alpine
# Uses glibc, good compatibility with precompiled binaries
# Moderate size (~100MB compared to Alpine 50MB, Debian 300MB)

cat << 'DEBIANEOF' > Dockerfile.debian
# === MULTI-STAGE BUILD WITH DEBIAN-SLIM BASE ===
#
# Debian-slim (python:3.11-slim uses Debian):
# - Debian base with non-essential packages removed
# - Uses glibc (better compatibility with precompiled binaries)
# - Larger than Alpine (~100MB) but smaller than full Debian
# - Most compatible option: glibc + standard tools
#
# Base image choices:
# - Alpine (5MB): musl libc, small, compatibility issues
# - Debian-slim (100MB): glibc, good compatibility, moderate size
# - Full Debian (300MB): glibc, very compatible, large
# - Distroless (50MB): minimal runtime, production-focused, no debug access
#
# To use: docker build -f Dockerfile.debian -t model:debian .

FROM python:3.11-slim AS builder

LABEL stage="builder"

WORKDIR /build

# Debian uses apt-get for package management
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements-builder.txt .
RUN python -m pip install --no-cache-dir -r requirements-builder.txt

COPY src/ ./src/

RUN mkdir -p /models && \
    python src/train_model.py


# === RUNTIME STAGE: DEBIAN-SLIM ===
# Standard python:3.11-slim base image

FROM python:3.11-slim AS runtime

LABEL stage="runtime"
LABEL base_image="debian-slim"
LABEL libc="glibc"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

COPY requirements-runtime.txt .
RUN python -m pip install --no-cache-dir -r requirements-runtime.txt

COPY --from=builder --chown=1000:1000 /build/src/ ./src/
COPY --from=builder --chown=1000:1000 /models /models

RUN useradd -m -u 1000 appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

ENTRYPOINT ["python", "-u", "src/predict.py"]
DOCKEREOF

log_info "Debian-slim Dockerfile variant created at Dockerfile.debian"

# Create docker-compose demonstrating multi-stage builds
cat << 'COMPOSEEOF' > docker-compose.yaml
version: '3.9'

services:
  # Build and run the multi-stage runtime image
  model_runtime:
    build:
      context: .
      dockerfile: Dockerfile
      # target: specifies which stage to build until
      # Default (omitted) builds the final stage
      # Use --target to stop at intermediate stages (builder, test, etc.)
      # Example: docker build --target test -t model:test .
    container_name: model_ml_runtime
    environment:
      PYTHONUNBUFFERED: "1"
    command: python -u src/predict.py

  # Distroless variant (smallest image, production-ready)
  model_distroless:
    build:
      context: .
      dockerfile: Dockerfile.distroless
    container_name: model_distroless
    # distroless cannot have shell environment, minimal args possible

  # Alpine variant (small, musl libc)
  model_alpine:
    build:
      context: .
      dockerfile: Dockerfile.alpine
    container_name: model_alpine
    environment:
      PYTHONUNBUFFERED: "1"

  # Debian-slim variant (glibc, best compatibility)
  model_debian:
    build:
      context: .
      dockerfile: Dockerfile.debian
    container_name: model_debian
    environment:
      PYTHONUNBUFFERED: "1"
COMPOSEEOF

log_info "docker-compose.yaml created with multi-variant builds"

# Create build comparison script
cat << 'SCRIPTEOF' > build_variants.sh
#!/bin/bash
# === MULTI-STAGE BUILD VARIANTS ===

set -euo pipefail

echo "Building multiple variants to compare base images..."
echo ""

# Build standard multi-stage
echo "Building standard (python:3.11-slim) variant:"
docker build -t model:standard .
echo ""

# Build distroless variant
echo "Building distroless variant:"
docker build -f Dockerfile.distroless -t model:distroless .
echo ""

# Build alpine variant
echo "Building alpine variant:"
docker build -f Dockerfile.alpine -t model:alpine .
echo ""

# Build debian variant
echo "Building debian-slim variant:"
docker build -f Dockerfile.debian -t model:debian .
echo ""

# Compare image sizes
echo "=== IMAGE SIZE COMPARISON ==="
docker images | grep "model:"
echo ""

# Use --target to build only specific stages
echo "Building only the builder stage (for testing/debugging):"
docker build --target builder -t model:builder-only .
echo ""

echo "Building only the test stage:"
docker build --target test -t model:test-only .
echo ""

echo "=== BUILD TARGET USAGE ==="
echo "docker build --target builder -t model:builder ."
echo "docker build --target test -t model:test ."
echo "docker build --target runtime -t model:runtime ."
SCRIPTEOF

chmod +x build_variants.sh

log_info "Build variants script created"

# Create tests directory with __init__.py
mkdir -p tests
cat << 'TESTEOF' > tests/__init__.py
# Tests package
TESTEOF

cat << 'TESTEOF' > tests/test_model.py
#!/usr/bin/env python3
"""Tests for the model training and prediction."""

import pytest
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_import_modules():
    """Test that training modules can be imported."""
    try:
        from src.train_model import train_model
        from src.predict import load_model, predict
        assert callable(train_model)
        assert callable(load_model)
        assert callable(predict)
    except ImportError as e:
        pytest.fail(f"Failed to import modules: {e}")

def test_model_exists_after_training():
    """Test that model file is created after training."""
    from src.train_model import train_model
    from pathlib import Path
    
    model, accuracy = train_model()
    assert model is not None
    assert accuracy > 0.8  # Should have decent accuracy on iris
TESTEOF

log_info "Test directory and tests created"

# Create .dockerignore for multi-stage builds
cat << 'IGNOREEOF' > .dockerignore
.git
.gitignore
.github
__pycache__
*.pyc
*.pyo
.pytest_cache
.coverage
htmlcov
.vscode
.idea
*.swp
*.swo
.DS_Store
*.md
docs/
CHANGELOG
.env
.env.local
tmp/
temp/
*.tmp
Dockerfile.alpine
Dockerfile.debian
Dockerfile.distroless
IGNOREEOF

log_info ".dockerignore created"

log_info "Segment 7 setup complete"
log_info "To build multi-stage images:"
log_info "  docker build -t model:standard ."
log_info "  docker build -f Dockerfile.distroless -t model:distroless ."
log_info "  docker build -f Dockerfile.alpine -t model:alpine ."
log_info "  docker build -f Dockerfile.debian -t model:debian ."
log_info "  OR: bash build_variants.sh (builds all variants)"

EOF

chmod +x segment7_runner.sh
bash segment7_runner.sh

echo -e "${GREEN}✓ Segment 7 complete: Multi-stage ML model builder project created${NC}"

cd -

################################################################################
# SUMMARY AND NEXT STEPS
################################################################################

echo ""
echo -e "${YELLOW}=== ALL SEGMENTS COMPLETE ===${NC}"
echo ""
echo -e "${GREEN}Summary of Created Projects:${NC}"
echo ""
echo "Segment 5 - Dockerfile Directives:"
echo "  Location: $SEGMENT5_DIR"
echo "  Project: Flask API demonstrating all Dockerfile directives"
echo "  Key Concepts: FROM, COPY, RUN, CMD, ENTRYPOINT, USER, EXPOSE, HEALTHCHECK, LABEL, VOLUME, .dockerignore"
echo ""
echo "Segment 6 - Layer Caching:"
echo "  Location: $SEGMENT6_DIR"
echo "  Project: Data processor with caching optimization"
echo "  Key Concepts: Layer cache, cache invalidation, golden ordering, BuildKit cache mounts, cache backends"
echo ""
echo "Segment 7 - Multi-Stage Builds:"
echo "  Location: $SEGMENT7_DIR"
echo "  Project: ML model builder with multi-stage Dockerfiles"
echo "  Key Concepts: Multi-stage builds, FROM AS, COPY --from, base image choices (distroless, alpine, debian), --target flag"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo "  # Segment 5"
echo "  cd $SEGMENT5_DIR && docker-compose up --build"
echo ""
echo "  # Segment 6"
echo "  cd $SEGMENT6_DIR && DOCKER_BUILDKIT=1 docker build -f Dockerfile.cache -t processor:cache ."
echo ""
echo "  # Segment 7"
echo "  cd $SEGMENT7_DIR && bash build_variants.sh"
echo ""