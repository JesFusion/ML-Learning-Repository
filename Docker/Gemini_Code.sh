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











































################################################################################
# === SEGMENT 8: BUILDKIT — SECRETS, SSH, AND ADVANCED BUILD FEATURES ===
# Demonstrates: DOCKER_BUILDKIT, RUN --mount=type=secret, RUN --mount=type=ssh,
# docker buildx, --platform, FROM --platform=$BUILDPLATFORM/$TARGETPLATFORM,
# fat manifests, QEMU, docker buildx create/use/ls/inspect
################################################################################

echo -e "${BLUE}=== SEGMENT 8: BUILDKIT & ADVANCED BUILD FEATURES ===${NC}"
echo "Creating a multi-platform Go application with BuildKit advanced features..."

# [WHAT] Create a temporary directory for Segment 8; isolate all Segment 8 work
SEGMENT8_DIR=$(mktemp -d)
cd "$SEGMENT8_DIR"

# Create the Segment 8 runner script
# [WHY] Encapsulate all BuildKit demonstrations in a self-contained script
cat << 'EOF' > segment8_runner.sh
#!/bin/bash

set -euo pipefail

SEGMENT8_PROJECT="buildkit_multiplatform_app"

# [WHAT] Function to print debug info with timestamps; reused throughout segment
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

# [WHAT] Function to print error messages; used for error reporting
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_info "Setting up Segment 8: BuildKit with multi-platform Go app"

# Create project directory structure
mkdir -p "$SEGMENT8_PROJECT/src"
mkdir -p "$SEGMENT8_PROJECT/secrets"
cd "$SEGMENT8_PROJECT"

# Create a simple Go application
# [WHY] Go is ideal for demonstrating cross-platform builds (fast, single binary)
cat << 'GOEOF' > src/main.go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

// Response structure for API endpoints
type APIResponse struct {
	Status      string    `json:"status"`
	Timestamp   time.Time `json:"timestamp"`
	Version     string    `json:"version"`
	Platform    string    `json:"platform"`
	Architecture string   `json:"architecture"`
	Hostname    string    `json:"hostname"`
}

func main() {
	version := os.Getenv("APP_VERSION")
	if version == "" {
		version = "1.0.0"
	}

	hostname, _ := os.Hostname()

	// [WHAT] Simple health check endpoint (no dependencies, just status)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		resp := APIResponse{
			Status:        "healthy",
			Timestamp:     time.Now(),
			Version:       version,
			Platform:      runtime.GOOS,
			Architecture:  runtime.GOARCH,
			Hostname:      hostname,
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	})

	// [WHAT] Info endpoint showing build-time information
	http.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		resp := APIResponse{
			Status:        "running",
			Timestamp:     time.Now(),
			Version:       version,
			Platform:      runtime.GOOS,
			Architecture:  runtime.GOARCH,
			Hostname:      hostname,
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	})

	log.Printf("Starting server v%s on :8080 (%s/%s)", version, runtime.GOOS, runtime.GOARCH)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
GOEOF

log_info "Go application created at src/main.go (platform-agnostic cross-compile target)"

# Create a secret file for BuildKit demonstration
# [WHY] Secrets are mounted at build time but never persist in any layer
cat << 'SECRETEOF' > secrets/github_token.txt
ghp_example_token_never_baked_into_image
SECRETEOF

log_info "Secret file created at secrets/github_token.txt (for --mount=type=secret demo)"

# Create go.mod for dependency management
cat << 'MODEOF' > go.mod
module buildkit-app

go 1.21
MODEOF

log_info "Go module file created"

# Create main Dockerfile with BuildKit directives
# [WHY] BuildKit enables advanced features like secret mounting, SSH forwarding, parallel builds
cat << 'DOCKEREOF' > Dockerfile
# === BUILDKIT MULTI-PLATFORM BUILD (SEGMENT 8) ===

# [COMMAND MEANING] FROM --platform=$BUILDPLATFORM = Pin this stage to the build host's native platform
# [WHY] Compiler tools (like 'go build') run faster on the build host's native arch
FROM golang:1.21 AS builder

# [COMMAND MEANING] Declare that we're using BuildKit-specific features
# [FLAG MEANING] --mount=type=secret = Mount a secret file at build time without persisting it
# [WHY] Secrets (API keys, tokens) are needed during build but must not appear in final image

WORKDIR /build

# [WHAT] Copy only go.mod first (layer caching optimization)
# [WHY] If src changes but go.mod doesn't, Docker reuses the cached dependency layer
COPY go.mod .

# [WHAT] Copy Go source code
COPY src/ ./src/

# [COMMAND MEANING] RUN --mount=type=secret = Mount a secret at build time
# [WHY] The secret is available at /run/secrets/github_token but not persisted in any layer
# [HOW] The secret file is mounted as tmpfs, readable only during this RUN step
# [WATCH OUT] If you try to `cat` or `echo` the secret into a file, it WILL persist in the image—never do this
RUN --mount=type=secret=github_token \
    echo "Building Go binary for multiple platforms..." && \
    go build -o /build/app ./src/main.go && \
    echo "Build complete—secret was available but is NOT in any layer"

# [WHAT] Verify the secret is NOT baked in (prove isolation)
RUN ls -la /run/secrets/ 2>/dev/null || echo "Secrets inaccessible after RUN step—correct!"

# === RUNTIME STAGE: Targeting final platform ===
# [COMMAND MEANING] FROM --platform=$TARGETPLATFORM = Target the final desired platform (e.g., linux/arm64)
# [WHY] The runtime stage is the final artifact; it must match the architecture specified at build time
FROM golang:1.21-alpine

WORKDIR /app

# [WHAT] Copy the compiled binary from builder stage
# [WHY] Multi-stage build: builder produces artifact, runtime runs it; builder tools don't ship
COPY --from=builder --chown=1000:1000 /build/app .

# [WHAT] Create non-root user for security
RUN addgroup -g 1000 appgroup && adduser -D -u 1000 -G appgroup appuser

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD wget -q -O- http://localhost:8080/health || exit 1

# [COMMAND MEANING] ENTRYPOINT ["./app"] = Run the Go binary directly
# [WHY] Single static binary = no shell, minimal container, fast startup
ENTRYPOINT ["./app"]
DOCKEREOF

log_info "Multi-platform Dockerfile created with BuildKit directives"

# Create a .dockerignore file
cat << 'IGNOREEOF' > .dockerignore
.git
.gitignore
__pycache__
*.pyc
.DS_Store
.env
secrets/
IGNOREEOF

log_info ".dockerignore created"

# Create a script demonstrating BuildKit enablement and buildx usage
cat << 'BUILDSCRIPTEOF' > buildkit_demo.sh
#!/bin/bash

set -euo pipefail

echo "======================================================================"
echo "SEGMENT 8: BuildKit & Buildx Demonstration"
echo "======================================================================"

# [COMMAND MEANING] DOCKER_BUILDKIT=1 = Environment variable enabling BuildKit for a single build
# [WHY] BuildKit is Docker's next-gen builder: faster, parallel stages, advanced cache mounts
# [HOW] Set before docker build command; requires BuildKit to be available on the daemon
# [WATCH OUT] Some older flags/features don't work with BuildKit; check compatibility

echo ""
echo "[STEP 1] Enable BuildKit for a single build:"
echo "Command: DOCKER_BUILDKIT=1 docker build -t buildkit-app:buildkit ."
echo ""
echo "Explanation:"
echo "  - DOCKER_BUILDKIT=1: Enables BuildKit for THIS build only"
echo "  - Without this flag, older docker builder is used (slower, no secret mounts)"
echo "  - With BuildKit: parallel stages, advanced caching, secret injection"
echo ""

# In actual execution, this would be:
# DOCKER_BUILDKIT=1 docker build -t buildkit-app:buildkit .

# [COMMAND MEANING] docker buildx = Extended build command with multi-platform support
# [WHY] buildx adds: multi-platform builds, remote builders, cache export/import
# [HOW] docker buildx build replaces docker build with advanced capabilities
# [WATCH OUT] buildx output is different (layer output, progress streaming); requires setup

echo "[STEP 2] List available buildx builders:"
echo "Command: docker buildx ls"
echo ""
echo "Output shows:"
echo "  - default: Local Docker daemon (single platform)"
echo "  - docker-container: BuildKit in a container (multi-platform support)"
echo ""

# [COMMAND MEANING] docker buildx create = Create a new builder instance
# [WHY] Each builder can have different configurations, caches, driver backends
# [HOW] Specify --driver (docker, docker-container, kubernetes), --name, --platform
# [WHAT ELSE] --use flag to set as active after creation; --append to add platforms

echo "[STEP 3] Create a multi-platform builder (if needed):"
echo "Command: docker buildx create --name multiplatform --driver docker-container"
echo ""
echo "Explanation:"
echo "  - docker-container driver: runs BuildKit in a container, supports QEMU emulation"
echo "  - This enables linux/amd64, linux/arm64, linux/arm/v7, etc."
echo "  - docker driver: uses local daemon, single platform, faster for single-arch"
echo ""

echo "[STEP 4] Set the builder as active:"
echo "Command: docker buildx use multiplatform"
echo ""
echo "Explanation:"
echo "  - Subsequent buildx commands will use this builder"
echo "  - Only one builder can be active at a time"
echo ""

# [COMMAND MEANING] docker buildx inspect = Show details about the active builder
# [WHY] Verify platforms supported, driver type, cache status
# [HOW] Displays all available platforms, buildkitd version, flags

echo "[STEP 5] Inspect the active builder:"
echo "Command: docker buildx inspect multiplatform"
echo ""
echo "Output shows:"
echo "  - Platforms: linux/amd64, linux/arm64, linux/arm/v7, etc."
echo "  - Driver: docker-container or docker"
echo "  - BuildKit version and capabilities"
echo ""

# [COMMAND MEANING] --platform linux/amd64,linux/arm64 = Specify target architectures
# [WHY] Build once, deploy to multiple CPU architectures without recompiling per-platform
# [HOW] BuildKit uses QEMU to emulate foreign architectures during build
# [WATCH OUT] Emulation is slower; native builds are ~10x faster

echo "[STEP 6] Build for multiple platforms (example):"
echo "Command: docker buildx build --platform linux/amd64,linux/arm64 -t buildkit-app:multiarch --push ."
echo ""
echo "Explanation:"
echo "  - --platform linux/amd64,linux/arm64: Build for both x86_64 and ARM64"
echo "  - QEMU emulates ARM64 on x86 hardware (slower but works)"
echo "  - --push: Push directly to registry (required for multi-arch)"
echo "  - --load: Only works for single platform (loads to local Docker daemon)"
echo ""

# [COMMAND MEANING] FROM --platform=$BUILDPLATFORM = Pin builder stage to native arch
# [WHY] Compiler runs fast on native arch; only runtime is emulated
# [HOW] $BUILDPLATFORM is injected by BuildKit (e.g., linux/amd64)"
# [WHAT ELSE] $TARGETPLATFORM: the final desired platform specified in --platform flag

echo "[STEP 7] In Dockerfile, use platform variables for cross-compilation:"
echo "  FROM --platform=\$BUILDPLATFORM golang:1.21 AS builder"
echo "  # builder stage runs on host arch (fast)"
echo ""
echo "  FROM --platform=\$TARGETPLATFORM alpine:latest"
echo "  # runtime stage targets the final platform"
echo ""

# [COMMAND MEANING] RUN --mount=type=secret = Mount secret at build time
# [WHY] API tokens, SSH keys needed during build but must not persist in image
# [HOW] Secret passed via --secret id=name,src=/path; mounted at /run/secrets/name
# [WATCH OUT] Mount is READ-ONLY and tmpfs; secret is inaccessible after RUN step

echo "[STEP 8] Use secrets during build (do NOT log or persist them):"
echo "Command: docker buildx build --secret id=github_token,src=./secrets/github_token.txt ."
echo ""
echo "In Dockerfile:"
echo "  RUN --mount=type=secret=github_token \\\\
echo "      git clone https://token@github.com/private/repo.git \\\\
echo "      < /run/secrets/github_token"
echo ""
echo "Explanation:"
echo "  - Secret is mounted as tmpfs at /run/secrets/github_token"
echo "  - Readable only during this RUN step"
echo "  - NOT persisted in any layer (verified by 'docker history')"
echo ""

# [COMMAND MEANING] RUN --mount=type=ssh = Forward SSH agent
# [WHY] Clone private Git repos without embedding SSH keys
# [HOW] SSH agent is forwarded into build step; authentication happens in-container
# [WATCH OUT] Requires local SSH agent running; docker buildx build --ssh default

echo "[STEP 9] Use SSH for private repo cloning:"
echo "Command: docker buildx build --ssh default ."
echo ""
echo "In Dockerfile:"
echo "  RUN --mount=type=ssh \\\\
echo "      git clone git@github.com:private/repo.git"
echo ""
echo "Explanation:"
echo "  - --ssh default: Forward the default SSH socket"
echo "  - SSH key is never copied into image"
echo "  - Authentication happens via agent (secure, ephemeral)"
echo ""

# [COMMAND MEANING] fat manifest = Manifest list with multiple platform digests
# [WHY] Single tag points to correct architecture for any client
# [HOW] Push multi-arch images with --push; Docker creates manifest list automatically
# [WATCH OUT] Only works with registries (can't load multi-arch to local daemon)

echo "[STEP 10] Fat manifests (multi-arch image lists):"
echo "Command: docker buildx build --platform linux/amd64,linux/arm64 --push -t myapp:latest ."
echo ""
echo "Result:"
echo "  - myapp:latest → manifest list (index)"
echo "  - manifest list references:"
echo "    - linux/amd64 → sha256:abc123..."
echo "    - linux/arm64 → sha256:def456..."
echo "  - docker pull on x86 → gets amd64 image"
echo "  - docker pull on ARM → gets arm64 image"
echo ""

# [COMMAND MEANING] QEMU = Hardware emulator used for cross-platform builds
# [WHY] Allows building ARM images on x86 without native ARM hardware
# [HOW] buildx automatically handles QEMU setup; transparent to user
# [WATCH OUT] Emulation is slow (~10x slower); use only when necessary

echo "[STEP 11] QEMU emulation (transparent to user):"
echo "When building for linux/arm64 on linux/amd64:"
echo "  - BuildKit detects arch mismatch"
echo "  - Automatically loads binfmt_misc handlers"
echo "  - QEMU transparently emulates ARM syscalls"
echo "  - Build proceeds (slower but works)"
echo ""
echo "Performance: Native build ~2min, emulated ~20min (rough estimate)"
echo ""

# [COMMAND MEANING] docker buildx use = Set active builder context
# [WHY] Switch between different builders without recreating
# [HOW] Affects all subsequent buildx commands
# [WHAT ELSE] Use default to revert to Docker daemon builder

echo "[STEP 12] Switch builders:"
echo "Command: docker buildx use docker-container"
echo "Then: docker buildx buildx use default"
echo ""

echo "======================================================================"
echo "END OF BUILDKIT DEMONSTRATION"
echo "======================================================================"
BUILDSCRIPTEOF

chmod +x buildkit_demo.sh

log_info "BuildKit demonstration script created at buildkit_demo.sh"

# Create a practical buildx build example (non-executable, for reference)
cat << 'EXAMPLEEOF' > buildx_example.txt
=== PRACTICAL BUILDX EXAMPLE ===

# Step 1: Check if buildx is available
docker buildx version

# Step 2: Create a builder (if needed)
docker buildx create --name multiplatform --driver docker-container

# Step 3: Switch to the new builder
docker buildx use multiplatform

# Step 4: Verify platforms
docker buildx inspect multiplatform

# Step 5: Build for multiple platforms and push to registry
DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --push \
  -t myregistry.azurecr.io/buildkit-app:v1.0.0 \
  .

# Step 6: Build with secret
DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64 \
  --secret id=github_token,src=./secrets/github_token.txt \
  -t buildkit-app:withsecret \
  .

# Step 7: Build with SSH
DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64 \
  --ssh default \
  -t buildkit-app:withssh \
  .

# Step 8: Build for single platform and load to daemon
# (--load only works with single platform)
DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64 \
  --load \
  -t buildkit-app:local \
  .

# Step 9: Build only to builder cache (no push/load)
DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64,linux/arm64 \
  .

# Step 10: Inspect resulting image
docker inspect buildkit-app:withsecret

# Step 11: View build layers
docker history buildkit-app:withsecret
# Note: --mount=type=secret layers are EMPTY (no persistence)
EXAMPLEEOF

log_info "Buildx example commands documented at buildx_example.txt"

log_info "Segment 8 setup complete"
log_info "Next steps:"
log_info "  1. Review buildkit_demo.sh for detailed explanations"
log_info "  2. Read buildx_example.txt for practical commands"
log_info "  3. To build with BuildKit: DOCKER_BUILDKIT=1 docker build -t app:v1 ."
log_info "  4. To build multi-platform: docker buildx build --platform linux/amd64,linux/arm64 --push ."

EOF

chmod +x segment8_runner.sh
bash segment8_runner.sh

echo -e "${GREEN}✓ Segment 8 complete: BuildKit multi-platform Go app with secrets/SSH examples${NC}"

cd -

################################################################################
# === SEGMENT 9: CONTAINER LIFECYCLE, PID 1, AND SIGNAL HANDLING ===
# Demonstrates: docker create, docker start, docker stop, docker kill, docker pause,
# docker unpause, docker restart, restart policies (no, on-failure, always, unless-stopped),
# PID 1 contract, zombie processes, tini, dumb-init, --init, STOPSIGNAL
################################################################################

echo -e "${BLUE}=== SEGMENT 9: CONTAINER LIFECYCLE & SIGNAL HANDLING ===${NC}"
echo "Creating signal handling demonstrations and lifecycle state management..."

# [WHAT] Create a temporary directory for Segment 9
SEGMENT9_DIR=$(mktemp -d)
cd "$SEGMENT9_DIR"

cat << 'EOF' > segment9_runner.sh
#!/bin/bash

set -euo pipefail

SEGMENT9_PROJECT="signal_handling_lifecycle"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_info "Setting up Segment 9: Container lifecycle and signal handling"

mkdir -p "$SEGMENT9_PROJECT/src"
cd "$SEGMENT9_PROJECT"

# Create Python application that demonstrates signal handling
# [WHY] Python can trap signals (SIGTERM, SIGKILL) and gracefully shut down
cat << 'PYEOF' > src/signal_handler.py
#!/usr/bin/env python3
"""
Demonstrates graceful shutdown and signal handling in containers.
PID 1 must forward signals to child processes and reap zombies.
"""

import signal
import sys
import time
import os
import subprocess
from datetime import datetime

class GracefulShutdown:
    """Handles SIGTERM and SIGKILL gracefully."""
    
    def __init__(self):
        self.shutdown_requested = False
        self.child_processes = []
        
        # [WHAT] Register signal handlers
        # [WHY] PID 1 receives docker stop SIGTERM; must handle it gracefully
        signal.signal(signal.SIGTERM, self._handle_sigterm)
        signal.signal(signal.SIGINT, self._handle_sigint)
        
    def _handle_sigterm(self, signum, frame):
        """Handle SIGTERM (docker stop sends this first)."""
        print(f"[{datetime.now()}] SIGTERM received - initiating graceful shutdown")
        self.shutdown_requested = True
        
    def _handle_sigint(self, signum, frame):
        """Handle SIGINT (Ctrl+C)."""
        print(f"[{datetime.now()}] SIGINT received - initiating graceful shutdown")
        self.shutdown_requested = True
        
    def run_with_timeout(self, duration=30):
        """Run until shutdown is requested or timeout expires."""
        start_time = time.time()
        
        while not self.shutdown_requested:
            elapsed = time.time() - start_time
            if elapsed > duration:
                print(f"[{datetime.now()}] Timeout reached ({duration}s)")
                break
                
            # [WHAT] Simulate work (health check every second)
            print(f"[{datetime.now()}] Running... (PID {os.getpid()})")
            time.sleep(1)
        
        # [WHAT] Graceful shutdown: close connections, drain requests, exit
        print(f"[{datetime.now()}] Graceful shutdown starting")
        print(f"[{datetime.now()}] Closing connections...")
        time.sleep(2)
        print(f"[{datetime.now()}] Shutdown complete - exiting")
        return 0

# [WHAT] Demonstration of zombie process creation and reaping
# [WHY] Child processes that exit but aren't reaped become zombies
# [HOW] Parent (PID 1) must call wait() to reap zombie children
def demonstrate_zombie_creation():
    """Create a child process and show how PID 1 must reap it."""
    print(f"[{datetime.now()}] Creating child process (will become zombie if not reaped)")
    
    # Fork a child that exits immediately
    pid = os.fork()
    if pid == 0:
        # Child process
        print(f"[{datetime.now()}] Child PID {os.getpid()} exiting immediately")
        sys.exit(0)
    else:
        # Parent (PID 1 in container)
        print(f"[{datetime.now()}] Parent waiting 2 seconds before reaping child {pid}")
        time.sleep(2)
        
        # [WHAT] Reap the zombie with wait()
        # [WHY] If PID 1 doesn't reap, child becomes zombie and consumes PID table slot
        try:
            wpid, status = os.waitpid(pid, 0)
            print(f"[{datetime.now()}] Reaped child {wpid} with status {status}")
        except ChildProcessError:
            print(f"[{datetime.now()}] Child {pid} already reaped")

if __name__ == '__main__':
    print(f"[{datetime.now()}] Container starting (PID {os.getpid()} is PID 1)")
    print(f"[{datetime.now()}] This process is responsible for:")
    print(f"  1. Forwarding signals to child processes")
    print(f"  2. Reaping zombie children (call wait())")
    print(f"  3. Handling graceful shutdown on SIGTERM")
    print("")
    
    # Demonstrate zombie handling
    demonstrate_zombie_creation()
    
    # Start graceful shutdown handler
    handler = GracefulShutdown()
    exit_code = handler.run_with_timeout(duration=30)
    
    sys.exit(exit_code)
PYEOF

log_info "Python signal handler created at src/signal_handler.py"

# Create a Dockerfile without proper init (demonstrates PID 1 problems)
cat << 'DOCKEREOF1' > Dockerfile.bad_signal_handling
# === BAD: Shell form CMD (creates /bin/sh as PID 1) ===
# [COMMAND MEANING] CMD (shell form) = Runs command via /bin/sh -c
# [WHY (BAD)] /bin/sh doesn't forward signals; SIGTERM goes to sh, not to Python
# [WATCH OUT] docker stop won't gracefully shut down the app; SIGKILL after timeout

FROM python:3.11-slim

WORKDIR /app

COPY src/signal_handler.py .

# [WHAT] This is the BAD way: shell form
# [WHY BAD] /bin/sh is PID 1, doesn't forward SIGTERM to Python process
# [RESULT] docker stop sends SIGTERM to sh (which ignores it), then waits 10s, sends SIGKILL
CMD python signal_handler.py

EXPOSE 8080
DOCKEREOF1

log_info "BAD Dockerfile (shell form) created at Dockerfile.bad_signal_handling"

# Create proper Dockerfile with exec form
cat << 'DOCKEREOF2' > Dockerfile.good_signal_handling
# === GOOD: Exec form CMD (process is PID 1, receives signals directly) ===
# [COMMAND MEANING] CMD (exec form) = Runs command directly without shell
# [WHY (GOOD)] Python becomes PID 1; SIGTERM goes directly to Python process

FROM python:3.11-slim

WORKDIR /app

COPY src/signal_handler.py .

# [WHAT] This is the GOOD way: exec form
# [WHY GOOD] Python is PID 1, receives SIGTERM directly, can handle graceful shutdown
# [RESULT] docker stop sends SIGTERM to Python, app gracefully shuts down
CMD ["python", "signal_handler.py"]

EXPOSE 8080
DOCKEREOF2

log_info "GOOD Dockerfile (exec form) created at Dockerfile.good_signal_handling"

# Create Dockerfile with tini (proper init)
cat << 'DOCKEREOF3' > Dockerfile.with_tini
# === BEST: Using tini as proper init process ===
# [COMMAND MEANING] tini = Minimal init process (~14KB) designed for containers
# [WHY] tini correctly forwards signals AND reaps zombie children
# [HOW] Run as PID 1, wrap the actual app as a child process

FROM python:3.11-slim

# [COMMAND MEANING] RUN apt-get install tini = Install minimal init
# [WHY] tini is lighter than dumb-init, purpose-built for containers
RUN apt-get update && apt-get install -y --no-install-recommends tini && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY src/signal_handler.py .

# [COMMAND MEANING] ENTRYPOINT ["/usr/bin/tini", "--"] = Use tini as init
# [WHY] tini becomes PID 1, forwards signals to Python (PID 2), reaps zombies
# [HOW] tini --: use default signal forwarding and zombie reaping
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "signal_handler.py"]

EXPOSE 8080
DOCKEREOF3

log_info "BEST Dockerfile (with tini) created at Dockerfile.with_tini"

# Create Dockerfile using docker --init flag (injects tini)
cat << 'DOCKEREOF4' > Dockerfile.with_docker_init
# === ALTERNATIVE: Use docker --init flag (automatic tini injection) ===
# [COMMAND MEANING] docker --init = Injects tini automatically
# [WHY] No need to modify Dockerfile; --init adds tini as PID 1 at runtime
# [HOW] docker run --init <image>: tini is added transparently

FROM python:3.11-slim

WORKDIR /app

COPY src/signal_handler.py .

# [WHAT] Regular CMD without explicit init
# [WHY WORKS] --init flag will inject tini at runtime
CMD ["python", "signal_handler.py"]

EXPOSE 8080
DOCKEREOF4

log_info "Docker --init flag Dockerfile created at Dockerfile.with_docker_init"

# Create a demonstration script showing lifecycle and restart policies
cat << 'LIFECYCLEOF' > lifecycle_demo.sh
#!/bin/bash

set -euo pipefail

echo "======================================================================"
echo "SEGMENT 9: Container Lifecycle & Signal Handling Demonstration"
echo "======================================================================"

echo ""
echo "[CONCEPT 1] Container States:"
echo "  created   → Container exists but not running (docker create)"
echo "  running   → Container is executing (docker start / docker run)"
echo "  paused    → Container processes frozen (docker pause)"
echo "  exited    → Container has stopped (docker stop / app exited)"
echo "  dead      → Container in error state (rarely seen)"
echo "  removed   → Container deleted from system (docker rm)"
echo ""

# [COMMAND MEANING] docker create = Create container without starting
# [WHY] Separate creation from execution; useful for setup-before-run
# [HOW] docker create <image> creates container, prints container ID
# [WHAT ELSE] docker create --name mycontainer <image>: assign name during creation

echo "[COMMAND] docker create:"
echo "  docker create python:3.11-slim python signal_handler.py"
echo ""
echo "  Result:"
echo "    - Container is in 'created' state (not running)"
echo "    - filesystem is prepared, metadata stored"
echo "    - No process is executing yet"
echo "    - Useful for pre-configuration before running"
echo ""

# [COMMAND MEANING] docker start = Start a stopped or created container
# [WHY] Resume a container from created or exited state
# [HOW] Sends SIGTERM to PID 1 (if already running), then starts process
# [WHAT ELSE] docker start -a: attach to logs after starting

echo "[COMMAND] docker start:"
echo "  docker start <container_id>"
echo "  docker start <container_name>"
echo ""
echo "  Result:"
echo "    - Container transitions from 'created' → 'running'"
echo "    - PID 1 process (signal_handler.py) begins executing"
echo ""

# [COMMAND MEANING] docker stop = Graceful shutdown (SIGTERM + grace period)
# [WHY] Allow app to finish requests, close connections, exit cleanly
# [HOW] Send SIGTERM to PID 1, wait --time seconds (default 10), then SIGKILL
# [FLAG MEANING] --time (-t) = Seconds to wait before SIGKILL (default 10)
# [WATCH OUT] If app doesn't handle SIGTERM, it will be SIGKILL'd anyway

echo "[COMMAND] docker stop:"
echo "  docker stop <container_id>"
echo "  docker stop --time 5 <container_id>"
echo ""
echo "  Sequence:"
echo "    1. Send SIGTERM to PID 1 (graceful shutdown signal)"
echo "    2. Wait --time seconds (default 10s)"
echo "    3. If process still running: send SIGKILL (force terminate)"
echo "    4. Container transitions to 'exited' state"
echo ""
echo "  Signal flow (good case):"
echo "    docker stop → SIGTERM to PID 1 → app handles SIGTERM → exit(0)"
echo ""
echo "  Signal flow (bad case, no handler):"
echo "    docker stop → SIGTERM to PID 1 → app ignores SIGTERM → wait 10s"
echo "            → SIGKILL to PID 1 → app force-terminated"
echo ""

# [COMMAND MEANING] docker kill = Immediate termination (SIGKILL)
# [WHY] Force-kill container without grace period (emergency only)
# [HOW] Send signal (default SIGKILL) immediately to PID 1
# [FLAG MEANING] --signal (-s) = Signal to send (e.g., --signal SIGUSR1)
# [WATCH OUT] No grace period; app can't clean up; data loss likely

echo "[COMMAND] docker kill:"
echo "  docker kill <container_id>"
echo "  docker kill --signal SIGUSR1 <container_id>"
echo ""
echo "  Result:"
echo "    - SIGKILL sent immediately (no grace period)"
echo "    - Container terminates forcefully"
echo "    - App has no chance to clean up"
echo "    - Use only in emergencies"
echo ""

# [COMMAND MEANING] docker pause = Freeze all processes (cgroup freezer)
# [WHY] Suspend container without terminating (useful for cleanup, migration)
# [HOW] Send SIGSTOP to entire cgroup via freezer subsystem
# [WHAT ELSE] Container remains 'running' state (technically paused)

echo "[COMMAND] docker pause / docker unpause:"
echo "  docker pause <container_id>"
echo "  docker unpause <container_id>"
echo ""
echo "  Result:"
echo "    - All processes in container are suspended (SIGSTOP)"
echo "    - Memory/files preserved; CPU resources released"
echo "    - Network connections remain open (but no I/O)"
echo "    - Useful before checkpointing or migrating containers"
echo ""

# [COMMAND MEANING] docker restart = Stop then start
# [WHY] Reboot container (useful for clearing state, reloading config)
# [HOW] docker stop + docker start in sequence
# [FLAG MEANING] --time (-t) = Grace period for stop phase (default 10)

echo "[COMMAND] docker restart:"
echo "  docker restart <container_id>"
echo "  docker restart --time 5 <container_id>"
echo ""
echo "  Sequence:"
echo "    1. Send SIGTERM to PID 1 (respects --time grace period)"
echo "    2. Wait for container to exit"
echo "    3. docker start: restart the container"
echo ""

# [COMMAND MEANING] Restart policies = Automatic restart on exit/failure
# [WHY] Keep critical services running; resilience without orchestrator
# [HOW] Specify --restart when running container; daemon enforces policy
# [WATCH OUT] Restart policies apply across daemon restarts (live-restore)

echo "[RESTART POLICIES]:"
echo ""
echo "  --restart no (default):"
echo "    - Container is NOT automatically restarted"
echo "    - Stays exited after docker stop or app exit"
echo "    docker run --restart no <image>"
echo ""

echo "  --restart always:"
echo "    - Container is ALWAYS restarted, regardless of exit code"
echo "    - Even if app crashes with exit(1), container restarts"
echo "    - Restarts even after daemon restart (live-restore)"
echo "    docker run --restart always <image>"
echo ""

echo "  --restart on-failure[:N]:"
echo "    - Restart ONLY on non-zero exit codes"
echo "    - Optional [:N] limits maximum restart attempts"
echo "    - Useful for one-off tasks that shouldn't restart on success"
echo "    docker run --restart on-failure:3 <image>  # Max 3 restarts"
echo ""

echo "  --restart unless-stopped:"
echo "    - Always restart (like 'always')"
echo "    - EXCEPT if container was explicitly stopped"
echo "    - Does NOT restart after daemon restart if was stopped"
echo "    docker run --restart unless-stopped <image>"
echo ""

# [CONCEPT] PID 1 Contract
# [WHY] Container needs proper init process to manage children
# [HOW] PID 1 must handle signals and reap zombies
# [WATCH OUT] Most apps aren't designed to be PID 1; use tini/dumb-init

echo "[CONCEPT: PID 1 Contract]:"
echo ""
echo "PID 1 has TWO responsibilities:"
echo ""
echo "  1. SIGNAL FORWARDING:"
echo "     - SIGTERM/SIGINT received by PID 1"
echo "     - Must forward to child processes"
echo "     - Default behavior: signals to PID 1 without handler = ignored"
echo "     - Example: /bin/sh (default shell) ignores SIGTERM"
echo ""
echo "  2. ZOMBIE REAPING:"
echo "     - Child process exits but parent doesn't call wait()"
echo "     - Child becomes 'zombie' (exit status hanging in kernel)"
echo "     - PID 1 must call wait() to reap zombies"
echo "     - If PID table fills with zombies: no new processes can start"
echo ""
echo "SYMPTOM: docker stop hangs, app doesn't shut down gracefully"
echo ""

# [CONCEPT] Zombie Process
# [WHY] Illustrates why init is necessary

echo "[ZOMBIE PROCESSES EXPLAINED]:"
echo ""
echo "Normal process lifecycle:"
echo "  1. Parent spawns child via fork()"
echo "  2. Child runs, then exits"
echo "  3. Parent calls wait() to collect exit status"
echo "  4. Child slot is freed"
echo ""
echo "Zombie lifecycle:"
echo "  1. Parent spawns child via fork()"
echo "  2. Child runs, then exits"
echo "  3. Parent does NOT call wait() (or PID 1 ignores children)"
echo "  4. Child remains as 'zombie' (exit status hanging)"
echo "  5. 'ps' shows <defunct> (zombie)"
echo "  6. PID table slot consumed; no new processes can start"
echo ""
echo "In containers:"
echo "  - If PID 1 is an app that spawns children but doesn't reap zombies"
echo "  - Zombie children accumulate"
echo "  - Container eventually can't spawn new processes"
echo "  - Solution: use tini/dumb-init as PID 1"
echo ""

# [TOOL] tini
# [WHY] Minimal, purpose-built init for containers

echo "[TOOL: tini]:"
echo "  - Size: ~14KB executable"
echo "  - Purpose: Proper init process for containers"
echo "  - Features:"
echo "    * Forwards all signals to child processes"
echo "    * Reaps zombie children via wait()"
echo "    * Lightweight (minimal overhead)"
echo "  - Usage in Dockerfile:"
echo "    ENTRYPOINT [\"/usr/bin/tini\", \"--\"]"
echo "    CMD [\"python\", \"app.py\"]"
echo ""

# [TOOL] dumb-init
# [WHY] Alternative to tini, from Yelp

echo "[TOOL: dumb-init]:"
echo "  - Size: ~4KB executable"
echo "  - Purpose: Similar to tini; lightweight init"
echo "  - Features:"
echo "    * Signal forwarding"
echo "    * Zombie reaping"
echo "    * Even smaller than tini"
echo "  - Usage: Same as tini"
echo "    ENTRYPOINT [\"/usr/local/bin/dumb-init\", \"--\"]"
echo "    CMD [\"python\", \"app.py\"]"
echo ""

# [FLAG MEANING] --init = Inject tini automatically at runtime
# [WHY] No Dockerfile modification needed; tini added by docker run
# [HOW] docker run --init <image>: tini injected as PID 1 transparently

echo "[FLAG: docker run --init]:"
echo "  - Automatically injects tini as PID 1"
echo "  - No Dockerfile modification required"
echo "  - Usage:"
echo "    docker run --init <image>"
echo "  - Behind the scenes:"
echo "    * Docker adds tini as PID 1"
echo "    * Your app becomes child of tini"
echo "    * Signals and zombies handled properly"
echo ""

# [DIRECTIVE] STOPSIGNAL
# [WHY] Override default SIGTERM with custom signal (rare)
# [HOW] STOPSIGNAL SIGUSR1 in Dockerfile; docker stop sends SIGUSR1 instead

echo "[STOPSIGNAL DIRECTIVE]:"
echo "  - Default: docker stop sends SIGTERM"
echo "  - STOPSIGNAL allows custom signal per image"
echo "  - Usage in Dockerfile:"
echo "    STOPSIGNAL SIGUSR1"
echo "  - Result: docker stop sends SIGUSR1 instead of SIGTERM"
echo "  - Override at runtime:"
echo "    docker run --stop-signal SIGUSR2 <image>"
echo ""

# [FLAG MEANING] --stop-signal = Override image's STOPSIGNAL
# [WHY] Run-time override if STOPSIGNAL is wrong for your use case
# [HOW] docker run --stop-signal SIGUSR1 <image>

echo "[FLAG: docker run --stop-signal]:"
echo "  - Overrides STOPSIGNAL from Dockerfile"
echo "  - Usage:"
echo "    docker run --stop-signal SIGUSR1 <image>"
echo ""

echo "======================================================================"
echo "END OF LIFECYCLE & SIGNAL HANDLING DEMONSTRATION"
echo "======================================================================"
LIFECYCLEOF

chmod +x lifecycle_demo.sh

log_info "Lifecycle demonstration script created at lifecycle_demo.sh"

# Create a practical testing script
cat << 'TESTEOF' > test_signal_handling.sh
#!/bin/bash

set -euo pipefail

echo "======================================================================"
echo "PRACTICAL TEST: Signal Handling Comparison"
echo "======================================================================"
echo ""
echo "This script demonstrates the difference between:"
echo "  1. Bad: Shell form CMD (PID 1 doesn't forward signals)"
echo "  2. Good: Exec form CMD (PID 1 receives signals directly)"
echo "  3. Best: Using tini as init (proper signal handling + zombie reaping)"
echo ""

echo "[TEST 1] Build all three variants:"
echo "  docker build -f Dockerfile.bad_signal_handling -t signal:bad ."
echo "  docker build -f Dockerfile.good_signal_handling -t signal:good ."
echo "  docker build -f Dockerfile.with_tini -t signal:tini ."
echo ""

echo "[TEST 2] Run each and test signal handling:"
echo ""
echo "Test BAD (shell form):"
echo "  docker run --name bad_test signal:bad &"
echo "  sleep 2"
echo "  time docker stop bad_test    # Will timeout then SIGKILL (no graceful shutdown)"
echo "  docker rm bad_test"
echo ""
echo "Test GOOD (exec form):"
echo "  docker run --name good_test signal:good &"
echo "  sleep 2"
echo "  time docker stop good_test   # SIGTERM handled, quick exit"
echo "  docker rm good_test"
echo ""
echo "Test BEST (with tini):"
echo "  docker run --name tini_test signal:tini &"
echo "  sleep 2"
echo "  time docker stop tini_test   # Signals handled properly"
echo "  docker rm tini_test"
echo ""

echo "[EXPECTED RESULTS]:"
echo "  - BAD: ~10 seconds (grace period timeout → SIGKILL)"
echo "  - GOOD: < 1 second (app handles SIGTERM immediately)"
echo "  - BEST: < 1 second (tini forwards SIGTERM properly)"
echo ""
TESTEOF

chmod +x test_signal_handling.sh

log_info "Signal handling test script created at test_signal_handling.sh"

log_info "Segment 9 setup complete"
log_info "Next steps:"
log_info "  1. Review lifecycle_demo.sh for detailed concept explanations"
log_info "  2. Build variants: docker build -f Dockerfile.good_signal_handling -t signal:good ."
log_info "  3. Test signal handling: docker run --init signal:good"

EOF

chmod +x segment9_runner.sh
bash segment9_runner.sh

echo -e "${GREEN}✓ Segment 9 complete: Signal handling, PID 1 contract, lifecycle states, restart policies${NC}"

cd -

################################################################################
# === SEGMENT 10: RUNNING CONTAINERS — PORTS, RESOURCES, LOGGING, DEBUGGING ===
# Demonstrates: docker run, -p, -P, --memory, --cpus, --pids-limit, --cpuset-cpus,
# --blkio-weight, --read-only, --tmpfs, docker logs, docker exec, docker attach,
# docker inspect, docker stats, docker top, docker diff, nsenter, docker cp,
# --name, -d, -e, --env-file, --label, --rm
################################################################################

echo -e "${BLUE}=== SEGMENT 10: RUNNING CONTAINERS — FLAGS, RESOURCES, DEBUGGING ===${NC}"
echo "Creating comprehensive container runtime demonstrations..."

# [WHAT] Create a temporary directory for Segment 10
SEGMENT10_DIR=$(mktemp -d)
cd "$SEGMENT10_DIR"

cat << 'EOF' > segment10_runner.sh
#!/bin/bash

set -euo pipefail

SEGMENT10_PROJECT="container_runtime_operations"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_info "Setting up Segment 10: Container runtime operations and debugging"

mkdir -p "$SEGMENT10_PROJECT"
cd "$SEGMENT10_PROJECT"

# Create a simple Python web server for testing
cat << 'PYEOF' > app.py
#!/usr/bin/env python3
"""
Simple web server for demonstrating container runtime flags and debugging.
Demonstrates: logging, health checks, environment variables, resource usage.
"""

import http.server
import socketserver
import json
import os
import psutil
import time
from datetime import datetime
from pathlib import Path

PORT = 8080

class RequestHandler(http.server.BaseHTTPRequestHandler):
    """Handle HTTP requests and demonstrate container concepts."""
    
    def log_message(self, format, *args):
        """Override to log to stdout with timestamps (12-factor log format)."""
        print(f"[{datetime.now()}] {self.address_string()} - {format % args}")
    
    def do_GET(self):
        """Handle GET requests."""
        # [WHAT] Simple routing based on path
        if self.path == '/health':
            self._handle_health()
        elif self.path == '/metrics':
            self._handle_metrics()
        elif self.path == '/info':
            self._handle_info()
        elif self.path == '/readiness':
            self._handle_readiness()
        else:
            self._handle_notfound()
    
    def _handle_health(self):
        """Health check endpoint (liveness probe)."""
        response = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'pid': os.getpid()
        }
        self._send_json(200, response)
    
    def _handle_readiness(self):
        """Readiness check endpoint (ready to serve traffic)."""
        response = {
            'status': 'ready',
            'timestamp': datetime.now().isoformat(),
            'listening_port': PORT
        }
        self._send_json(200, response)
    
    def _handle_metrics(self):
        """Metrics endpoint (resource usage information)."""
        try:
            process = psutil.Process(os.getpid())
            memory_info = process.memory_info()
            cpu_percent = process.cpu_percent(interval=0.1)
            
            response = {
                'process_id': os.getpid(),
                'memory_rss_mb': round(memory_info.rss / 1024 / 1024, 2),
                'memory_vms_mb': round(memory_info.vms / 1024 / 1024, 2),
                'cpu_percent': cpu_percent,
                'num_threads': process.num_threads(),
                'timestamp': datetime.now().isoformat()
            }
            self._send_json(200, response)
        except Exception as e:
            self._send_json(500, {'error': str(e)})
    
    def _handle_info(self):
        """Application info endpoint."""
        response = {
            'app': 'Container Runtime Demo',
            'version': os.getenv('APP_VERSION', '1.0.0'),
            'environment': os.getenv('ENVIRONMENT', 'production'),
            'hostname': os.getenv('HOSTNAME', 'unknown'),
            'container_name': os.getenv('CONTAINER_NAME', 'unknown'),
            'timestamp': datetime.now().isoformat()
        }
        self._send_json(200, response)
    
    def _handle_notfound(self):
        """404 Not Found."""
        response = {
            'error': 'Not Found',
            'path': self.path,
            'available_paths': ['/health', '/readiness', '/metrics', '/info']
        }
        self._send_json(404, response)
    
    def _send_json(self, status_code, data):
        """Send JSON response."""
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

if __name__ == '__main__':
    print(f"[{datetime.now()}] Starting container runtime demo server")
    print(f"[{datetime.now()}] PID: {os.getpid()}")
    print(f"[{datetime.now()}] Listening on http://0.0.0.0:{PORT}")
    print(f"[{datetime.now()}] Available endpoints: /health, /readiness, /metrics, /info")
    
    with socketserver.TCPServer(("", PORT), RequestHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n[{datetime.now()}] Server shutting down")
PYEOF

log_info "Python web server created at app.py"

# Create requirements file
cat << 'REQEOF' > requirements.txt
psutil==5.9.5
Werkzeug==2.3.7
REQEOF

log_info "Requirements file created"

# Create a Dockerfile for the runtime demo
cat << 'DOCKEREOF' > Dockerfile
# === SEGMENT 10: CONTAINER RUNTIME OPERATIONS ===

FROM python:3.11-slim

WORKDIR /app

# [COMMAND MEANING] ENV = Set persistent environment variables
# [WHY] Configuration visible to app at runtime
ENV APP_VERSION=1.0.0 \
    PYTHONUNBUFFERED=1 \
    ENVIRONMENT=production

# [COMMAND MEANING] COPY = Copy files from host to container
# [WHY] Transfer application code and dependencies into image
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# [COMMAND MEANING] USER = Switch to non-root user
# [WHY] Security: limit impact of container compromise
RUN useradd -m -u 1000 appuser
USER appuser

# [COMMAND MEANING] EXPOSE = Document which ports the app listens on
# [WHY] Metadata; helps with docker run -P flag
EXPOSE 8080

# [COMMAND MEANING] HEALTHCHECK = Define health check logic
# [WHY] Container orchestrators (Docker/Swarm) use this for readiness
HEALTHCHECK --interval=5s --timeout=3s --retries=2 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

# [COMMAND MEANING] CMD (exec form) = Default command
# [WHY] Process becomes PID 1; receives signals directly
CMD ["python", "-u", "app.py"]
DOCKEREOF

log_info "Dockerfile created"

# Create .dockerignore
cat << 'IGNOREEOF' > .dockerignore
__pycache__
*.pyc
.pytest_cache
.DS_Store
.env
*.tmp
IGNOREEOF

log_info ".dockerignore created"

# Create comprehensive runtime flags documentation
cat << 'RUNTIMEEOF' > runtime_flags_guide.sh
#!/bin/bash

set -euo pipefail

echo "======================================================================"
echo "SEGMENT 10: Container Runtime Flags & Operations"
echo "======================================================================"

echo ""
echo "=== DOCKER RUN: CORE COMMAND ==="
echo ""

# [COMMAND MEANING] docker run = Create and start container in one operation
# [WHY] Most common way to launch containers; combines docker create + docker start
# [HOW] Pulls image if missing, creates container, starts process, attaches terminal
# [WATCH OUT] --rm flag auto-removes container on exit; always use for ephemeral tasks

echo "[docker run] Core command:"
echo "  docker run [FLAGS] <image> [COMMAND]"
echo ""
echo "Common flags:"
echo "  --name <name>          Assign human-readable name"
echo "  -d (--detach)          Run in background (don't attach stdout/stderr)"
echo "  -it                    Interactive terminal (stdin open, pseudo-TTY)"
echo "  --rm                   Auto-remove container on exit"
echo "  -e (--env)             Set environment variables"
echo "  --env-file             Load env vars from file"
echo "  --label                Attach metadata labels"
echo ""

echo ""
echo "=== PORT PUBLISHING ==="
echo ""

# [COMMAND MEANING] -p <hostPort>:<containerPort> = Publish container port to host
# [WHY] Make container service accessible from outside
# [HOW] Docker adds iptables DNAT rules; host:port → container:port
# [FLAG MEANING] -p 8080:8080 = Map host port 8080 to container port 8080

echo "[PORT PUBLISHING] -p flag:"
echo ""
echo "1. Basic port mapping:"
echo "   docker run -p 8080:8080 <image>"
echo "   Result: localhost:8080 → container:8080"
echo ""

# [FLAG MEANING] -p <ip>:<hostPort>:<containerPort> = IP-scoped port binding
# [WHY] Restrict access to specific host interface (security)
# [HOW] Only specified IP can access the port
# [EXAMPLE] -p 127.0.0.1:8080:8080 = Only localhost can access

echo "2. IP-scoped binding (security):"
echo "   docker run -p 127.0.0.1:8080:8080 <image>"
echo "   Result: Only localhost:8080 can reach container"
echo "   Use case: Dev machine, prevent external access"
echo ""

# [FLAG MEANING] -P (--publish-all) = Publish all EXPOSE'd ports to random ephemeral ports
# [WHY] Quick testing; avoid port conflicts; useful in CI
# [HOW] Each EXPOSE'd port maps to random host port (49152-65535)

echo "3. Publish all exposed ports:"
echo "   docker run -P <image>"
echo "   Result: All EXPOSE'd ports map to random host ports"
echo "   Use case: Testing, CI/CD, avoiding conflicts"
echo ""

echo ""
echo "=== RESOURCE CONSTRAINTS ==="
echo ""

# [FLAG MEANING] --memory (-m) = Hard memory limit
# [WHY] Prevent container from consuming all host RAM
# [HOW] Enforced by cgroup memory subsystem; exceeding triggers OOM Killer
# [UNITS] Supports b, k, m, g (e.g., --memory 512m)

echo "[MEMORY] --memory flag:"
echo "  docker run --memory 512m <image>"
echo "  Result: Container limited to 512 MB RAM"
echo "  Exceeding: OOM Killer terminates container"
echo ""

# [FLAG MEANING] --memory-swap = Total memory + swap limit
# [WHY] Control total memory+swap; set equal to --memory to disable swap
# [HOW] If --memory-swap == --memory, no swap allowed
# [DEFAULT] --memory-swap defaults to 2 × --memory

echo "[MEMORY+SWAP] --memory-swap flag:"
echo "  docker run --memory 512m --memory-swap 512m <image>"
echo "  Result: 512 MB total (no swap allowed)"
echo ""
echo "  docker run --memory 512m --memory-swap 1g <image>"
echo "  Result: 512 MB RAM + 512 MB swap = 1 GB total"
echo ""

# [FLAG MEANING] --cpus = Fractional CPU cores allowed
# [WHY] Limit CPU usage; prevent CPU hog containers
# [HOW] Enforced by cgroup cpu subsystem; soft limit (can burst)
# [EXAMPLE] --cpus 1.5 = 1.5 CPU cores maximum

echo "[CPU] --cpus flag:"
echo "  docker run --cpus 1.5 <image>"
echo "  Result: Container limited to 1.5 CPU cores"
echo "  Note: This is a hard cap; container can't exceed this"
echo ""

# [FLAG MEANING] --cpu-shares = Relative CPU weight (scheduling only)
# [WHY] When CPU contention exists, weight determines priority
# [HOW] Default 1024; higher value = more CPU during contention
# [NOTE] This is NOT a hard limit; just relative weight

echo "[CPU SCHEDULING] --cpu-shares flag:"
echo "  docker run --cpu-shares 512 <image>"
echo "  Result: Half the default weight (1024)"
echo "  Effect: When CPU contentious, gets less than default containers"
echo ""

# [FLAG MEANING] --pids-limit = Maximum processes in container
# [WHY] Prevent fork bombs; limit resource exhaustion via process count
# [HOW] Enforced by cgroup pids subsystem
# [DEFAULT] Usually no limit; --pids-limit 100 caps at 100 processes

echo "[PROCESS COUNT] --pids-limit flag:"
echo "  docker run --pids-limit 100 <image>"
echo "  Result: Container can have maximum 100 processes"
echo "  Use case: Prevent fork bombs, resource exhaustion"
echo ""

# [FLAG MEANING] --cpuset-cpus = Pin container to specific CPU cores
# [WHY] NUMA-aware workloads; ensure cache locality
# [HOW] Limit to specific cores (e.g., 0,2,4 = cores 0, 2, 4)
# [NOTE] Useful for latency-sensitive workloads

echo "[CPU AFFINITY] --cpuset-cpus flag:"
echo "  docker run --cpuset-cpus 0,2 <image>"
echo "  Result: Container can only use CPU cores 0 and 2"
echo "  Use case: NUMA systems, latency-critical workloads"
echo ""

# [FLAG MEANING] --blkio-weight = Relative block I/O weight
# [WHY] Throttle disk I/O when multiple containers compete
# [HOW] Weight 10–1000 (default 500); higher = more I/O bandwidth
# [NOTE] Relative weight; enforced only during I/O contention

echo "[BLOCK I/O] --blkio-weight flag:"
echo "  docker run --blkio-weight 200 <image>"
echo "  Result: Container has lower I/O priority (200 vs default 500)"
echo "  Effect: During disk contention, gets less bandwidth"
echo ""

echo ""
echo "=== FILESYSTEM & STORAGE ==="
echo ""

# [FLAG MEANING] --read-only = Mount root filesystem as read-only
# [WHY] Immutable container pattern; prevent writes to layer
# [HOW] Block device mounted read-only; /tmp, /var/tmp still writable
# [WATCH OUT] App still needs writable paths (logs, temp files)

echo "[FILESYSTEM] --read-only flag:"
echo "  docker run --read-only <image>"
echo "  Result: Container root filesystem is read-only"
echo "  Use case: Security hardening; prevent tampering"
echo ""
echo "  Problem: App might need to write (logs, temp files)"
echo "  Solution: Add --tmpfs for required writable paths"
echo ""

# [FLAG MEANING] --tmpfs <path> = Mount in-memory tmpfs
# [WHY] Ephemeral writable space without touching overlay layer
# [HOW] Mount point backed by RAM (tmpfs); lost on container exit
# [SIZE] Control with --tmpfs /tmp:size=1g

echo "[TMPFS] --tmpfs flag:"
echo "  docker run --read-only --tmpfs /tmp:size=500m --tmpfs /var/log <image>"
echo "  Result:"
echo "    - /: read-only"
echo "    - /tmp: writable, 500 MB, in-memory"
echo "    - /var/log: writable, in-memory"
echo "  Use case: Security + temp file handling"
echo ""

echo ""
echo "=== LOGGING & OBSERVABILITY ==="
echo ""

# [COMMAND MEANING] docker logs = Fetch container stdout/stderr
# [WHY] Debug application behavior, track errors, audit trail
# [HOW] Reads from configured log driver (default json-file)
# [WATCH OUT] Only works with json-file and journald log drivers

echo "[LOGGING] docker logs command:"
echo "  docker logs <container>"
echo "  docker logs --follow <container>        # Like tail -f"
echo "  docker logs --tail 50 <container>       # Last 50 lines"
echo "  docker logs --since 10m <container>     # Last 10 minutes"
echo ""
echo "  Combined: docker logs -f --tail 100 --since 5m <container>"
echo ""

# [FLAG MEANING] --follow (-f) = Stream logs continuously
# [WHY] Real-time monitoring; equivalent to tail -f
# [HOW] Blocks and streams new log lines as app writes them

echo "[LOGGING FLAGS]:"
echo ""
echo "  --follow (-f): Stream output in real-time"
echo "  --tail N: Show last N lines (default all)"
echo "  --since <timestamp>: Show logs after timestamp"
echo "    Examples: --since 2024-01-15T10:30:00"
echo "              --since 10m (last 10 minutes)"
echo "              --since 2h (last 2 hours)"
echo ""

echo ""
echo "=== EXECUTION & INTERACTION ==="
echo ""

# [COMMAND MEANING] docker exec = Run new command in running container
# [WHY] Debug, inspect, admin tasks without entering PID 1
# [HOW] Spawns new process (not PID 1); doesn't affect container process
# [ADVANTAGE] Safe; doesn't interrupt main process

echo "[EXECUTION] docker exec command:"
echo "  docker exec <container> <command>"
echo "  docker exec -it <container> /bin/bash    # Interactive shell"
echo "  docker exec -u root <container> id       # Run as root"
echo ""

# [FLAG MEANING] -it = -i (interactive stdin) + -t (pseudo-TTY)
# [WHY] Needed for interactive shell; maintains terminal behavior
# [HOW] -i keeps stdin open even without attach; -t allocates PTY

echo "[INTERACTIVE FLAGS]:"
echo ""
echo "  -i (--interactive): Keep STDIN open even if not attached"
echo "  -t (--tty): Allocate a pseudo-terminal"
echo "  -it: Combination (needed for interactive shell)"
echo ""
echo "  docker exec -it <container> /bin/bash   # Interactive shell"
echo "  docker exec -i <container> python < script.py  # Pipe script"
echo ""

# [FLAG MEANING] -u <user> = Run command as specific user
# [WHY] Execute command with different privileges
# [HOW] uid:gid or username; must exist in container

echo "[USER OVERRIDE]:"
echo ""
echo "  docker exec -u root <container> apt-get update   # Run as root"
echo "  docker exec -u 1000 <container> id               # Run as UID 1000"
echo ""

# [COMMAND MEANING] docker attach = Connect terminal to running container PID 1
# [WHY] Access running container's stdout/stderr
# [HOW] Connects terminal to container's PID 1 stdio streams
# [WATCH OUT] CTRL+C sends SIGTERM to PID 1 (might exit container)

echo "[ATTACH] docker attach command:"
echo "  docker attach <container>"
echo ""
echo "  Connects to container's main process (PID 1)"
echo "  See real-time output"
echo "  CTRL+C sends SIGTERM (caution!)"
echo ""

echo ""
echo "=== INSPECTION & DEBUGGING ==="
echo ""

# [COMMAND MEANING] docker inspect = Low-level JSON metadata
# [WHY] View complete container configuration
# [HOW] Outputs detailed JSON; use jq for filtering
# [EXAMPLE] docker inspect <container> | jq '.[] | .State'

echo "[INSPECTION] docker inspect command:"
echo "  docker inspect <container>                        # Full metadata"
echo "  docker inspect --format='{{.State.Status}}' <container>"
echo "  docker inspect <container> | jq '.[] | .Config'"
echo ""

# [COMMAND MEANING] docker stats = Live resource usage metrics
# [WHY] Monitor CPU, memory, network, disk I/O in real-time
# [HOW] Streams stats continuously until interrupted
# [METRICS] CPU%, MEM, NET I/O, BLOCK I/O, PIDs

echo "[STATS] docker stats command:"
echo "  docker stats                 # All running containers"
echo "  docker stats <container>     # Specific container"
echo "  docker stats --no-stream     # Single snapshot (no stream)"
echo ""
echo "  Columns:"
echo "    CPU%: Percentage of host CPU in use"
echo "    MEM: Memory usage (absolute)"
echo "    NET I/O: Network bytes in/out"
echo "    BLOCK I/O: Disk bytes read/written"
echo ""

# [FLAG MEANING] --no-stream = Snapshot instead of continuous stream
# [WHY] Get single measurement without blocking
# [HOW] Print once and exit (useful in scripts)

echo "[SNAPSHOT]:"
echo "  docker stats --no-stream <container>"
echo "  Useful in monitoring scripts; non-blocking"
echo ""

# [COMMAND MEANING] docker top = List processes in container
# [WHY] See what's running inside (like ps inside container)
# [HOW] Shows UID, PID, CPU%, MEM%, command
# [NOTE] Similar to Unix ps command

echo "[PROCESS LIST] docker top command:"
echo "  docker top <container>           # All processes"
echo "  docker top <container> -eo pid,user,comm"
echo ""

# [COMMAND MEANING] docker diff = Show filesystem changes
# [WHY] Audit what files changed since container started
# [HOW] Shows additions (A), changes (C), deletions (D)
# [USE CASE] Debug unexpected modifications

echo "[FILESYSTEM DIFF] docker diff command:"
echo "  docker diff <container>"
echo ""
echo "  Output:"
echo "    A /app/log.txt       (Added file)"
echo "    C /etc/config        (Changed file)"
echo "    D /tmp/old.tmp       (Deleted file)"
echo ""

# [TOOL] nsenter = Enter container namespaces from host
# [WHY] Deep debugging without docker exec; access host perspective
# [HOW] Join container's namespace; execute command in that context

echo "[DEEP DEBUGGING] nsenter command:"
echo "  nsenter --target <PID> /bin/bash"
echo ""
echo "  Explanation:"
echo "    - <PID>: host PID of container process (not container PID)"
echo "    - Enters container's namespace from host"
echo "    - Useful for debugging when docker exec unavailable"
echo ""
echo "  Get host PID:"
echo "    docker inspect -f '{{.State.Pid}}' <container>"
echo ""

# [FLAG MEANING] --target <PID> = Target process whose namespaces to enter
# [WHY] Specify which process's namespace to join
# [HOW] Use host PID (from docker inspect)

# [FLAG MEANING] nsenter --net/--pid/--mnt = Namespace selectors
# [WHY] Join specific namespaces (network, process, mount)
# [HOW] By default joins all; flags select specific ones

echo "  Namespace flags:"
echo "    --net: network namespace"
echo "    --pid: process namespace"
echo "    --mnt: mount namespace"
echo "    --uts: hostname namespace"
echo ""

# [COMMAND MEANING] docker cp = Copy files between host and container
# [WHY] Extract/inject files without mounting volumes
# [HOW] Works on running or stopped containers
# [DIRECTION] Host → container OR container → host

echo "[FILE TRANSFER] docker cp command:"
echo "  docker cp <container>:/app/log.txt ./log.txt  # Container → Host"
echo "  docker cp ./config.json <container>:/etc/      # Host → Container"
echo "  docker cp <container>:/data . -r              # Copy directory"
echo ""
echo "  Use cases:"
echo "    - Extract logs from stopped container"
echo "    - Inject configuration dynamically"
echo "    - Debug artifact retrieval"
echo ""

echo ""
echo "=== ENVIRONMENT & METADATA ==="
echo ""

# [FLAG MEANING] -e <KEY=VALUE> = Set environment variable at runtime
# [WHY] Pass configuration without rebuilding image
# [HOW] Overrides ENV from Dockerfile; passed to PID 1

echo "[ENVIRONMENT] -e flag:"
echo "  docker run -e DATABASE_URL='postgres://...' <image>"
echo "  docker run -e LOG_LEVEL=DEBUG <image>"
echo ""
echo "  Visible in container:"
echo "    env           # List all env vars"
echo "    echo \$DATABASE_URL"
echo ""

# [FLAG MEANING] --env-file = Load environment from file
# [WHY] Avoid long command lines; load many vars at once
# [HOW] Each line: KEY=VALUE; skip empty lines and comments

echo "[ENV FILE] --env-file flag:"
echo "  docker run --env-file .env.prod <image>"
echo ""
echo "  File format (.env.prod):"
echo "    DATABASE_URL=postgres://user:pass@host/db"
echo "    API_KEY=secret_key_here"
echo "    LOG_LEVEL=INFO"
echo ""

# [FLAG MEANING] --label = Attach metadata labels
# [WHY] Organize, filter, query containers by labels
# [HOW] Key-value pairs; queryable via docker inspect or --filter
# [USE] Version, environment, owner, cost center, etc.

echo "[LABELS] --label flag:"
echo "  docker run --label version=1.0.0 --label env=prod <image>"
echo "  docker run --label owner=devops --label app=backend <image>"
echo ""
echo "  Query by label:"
echo "    docker ps --filter label=env=prod"
echo "    docker inspect <container> | jq '.[] | .Config.Labels'"
echo ""

# [FLAG MEANING] --name = Assign human-readable name
# [WHY] Easy reference instead of container ID
# [HOW] Name must be unique on daemon
# [NOTE] Still can use container ID for any operation

echo "[NAMING] --name flag:"
echo "  docker run --name myapp <image>"
echo ""
echo "  Then reference by name:"
echo "    docker logs myapp"
echo "    docker exec -it myapp /bin/bash"
echo "    docker stop myapp"
echo ""

# [FLAG MEANING] -d (--detach) = Run in background
# [WHY] Don't block terminal; container runs independently
# [HOW] Detach from container immediately; prints container ID

echo "[BACKGROUND] -d flag:"
echo "  docker run -d <image>                  # Run in background"
echo "  docker run -d --name server <image>    # Named background container"
echo ""
echo "  Monitor background container:"
echo "    docker logs server"
echo "    docker stats server"
echo ""

# [FLAG MEANING] --rm = Auto-remove on exit
# [WHY] Cleanup ephemeral containers automatically
# [HOW] Container and writable layer deleted on exit
# [USE CASE] One-off tasks, CI/CD, testing

echo "[AUTO-CLEANUP] --rm flag:"
echo "  docker run --rm <image>  # Deleted after exit"
echo ""
echo "  Useful for:"
echo "    - One-off migrations: docker run --rm <image> npm run migrate"
echo "    - Testing: docker run --rm <image> npm test"
echo "    - Batch jobs: no container cleanup needed"
echo ""

echo "======================================================================"
echo "END OF RUNTIME FLAGS DOCUMENTATION"
echo "======================================================================"
RUNTIMEEOF

chmod +x runtime_flags_guide.sh

log_info "Runtime flags guide created at runtime_flags_guide.sh"

log_info "Segment 10 setup complete"
log_info "Next steps:"
log_info "  1. Review runtime_flags_guide.sh for comprehensive flag documentation"
log_info "  2. Build image: docker build -t runtime-demo ."
log_info "  3. Test various flags: docker run -p 8080:8080 -m 256m --cpus 1 runtime-demo"

EOF

chmod +x segment10_runner.sh
bash segment10_runner.sh

echo -e "${GREEN}✓ Segment 10 complete: Container runtime operations, port publishing, resource constraints, logging, debugging${NC}"

cd -

################################################################################
# === WRAP-UP: SEGMENTS 8, 9, 10 COMPLETE ===
################################################################################

echo ""
echo -e "${YELLOW}=== SEGMENTS 8, 9, 10 COMPLETE ===${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo ""
echo "Segment 8 - BuildKit & Multi-Platform Builds:"
echo "  Location: $SEGMENT8_DIR"
echo "  Project: Go app with BuildKit secrets, SSH, cross-platform builds"
echo "  Key Concepts: DOCKER_BUILDKIT=1, BuildKit cache mounts, RUN --mount=type=secret/ssh"
echo "                docker buildx, --platform, FROM \$BUILDPLATFORM/\$TARGETPLATFORM"
echo "                Fat manifests, QEMU emulation"
echo ""
echo "Segment 9 - Container Lifecycle & Signal Handling:"
echo "  Location: $SEGMENT9_DIR"
echo "  Project: Signal handler demonstrations and init process comparisons"
echo "  Key Concepts: docker create/start/stop/kill/pause/unpause/restart"
echo "                Restart policies: no, on-failure, always, unless-stopped"
echo "                PID 1 contract, zombie reaping, tini, dumb-init, --init flag"
echo ""
echo "Segment 10 - Container Runtime Operations:"
echo "  Location: $SEGMENT10_DIR"
echo "  Project: Web server with comprehensive runtime flag demonstrations"
echo "  Key Concepts: Port publishing (-p, -P), resource constraints (--memory, --cpus)"
echo "                Logging (docker logs --follow), execution (docker exec)"
echo "                Inspection (docker inspect/stats/top), filesystem (--read-only, --tmpfs)"
echo "                File transfer (docker cp), metadata (--label, --env)"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo "  # Segment 8"
echo "  cd $SEGMENT8_DIR && bash buildkit_demo.sh"
echo ""
echo "  # Segment 9"
echo "  cd $SEGMENT9_DIR && bash lifecycle_demo.sh"
echo ""
echo "  # Segment 10"
echo "  cd $SEGMENT10_DIR && bash runtime_flags_guide.sh"
echo ""