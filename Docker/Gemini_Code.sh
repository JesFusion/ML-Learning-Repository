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
# SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES
################################################################################
#
# This educational script demonstrates advanced Docker concepts:
#   - Multi-stage build: Breaking a Dockerfile into multiple phases (builder, test, runtime)
#   - FROM AS builder: Naming intermediate stages so we can reference them later
#   - COPY --from=: Copying files from one stage to another
#   - docker build --target: Building only specific stages for debugging
#   - Base image choices: Understanding different Linux distributions (distroless, alpine, debian-slim)
#   - Image size optimization: Making Docker images as small as possible
#   - CGO_ENABLED=0: Compiling Go code without C dependencies
#   - GOOS/GOARCH: Cross-compilation flags for different operating systems and architectures

################################################################################

# The 'echo' command prints text to your terminal screen.
#
# The '-e' flag enables "escape sequences", which lets us use special color 
# variables like '${BLUE}' (blue text) and '${NC}' (No Color - reset to normal).
# This makes the output pretty and easy to read.

echo -e "${BLUE}=== SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES ===${NC}"

# A simple message telling the user what we're about to do.

echo "Creating a Python ML model builder demonstrating multi-stage builds..."

################################################################################
# [WHAT] Create a temporary directory for Segment 7
################################################################################
#
# 'mktemp' is a safe way to create a guaranteed-unique temporary file or folder.
# This is better than manually typing a folder name because it guarantees no 
# two runs will conflict with each other.
#
# The '-d' flag tells mktemp to create a Directory (folder) instead of a file.
#
# We wrap it in '$(...)' to run the command and immediately save its output 
# (the folder path) into the 'SEGMENT7_DIR' variable. This is called "command 
# substitution" because we're substituting the command's output into a variable.

SEGMENT7_DIR=$(mktemp -d)

# 'cd' stands for Change Directory. We are navigating into that brand new 
# temporary folder we just created.
#
# The double quotes around "$SEGMENT7_DIR" are important for safety. They protect 
# the path in case it happens to have spaces in it. Without quotes, Bash might 
# break the path into pieces and cause an error.

cd "$SEGMENT7_DIR"

################################################################################
# STREAMING_CHUNK: Generating the segment 7 runner script
################################################################################

# [WHAT] Create the standalone Bash script for Segment 7 multi-stage builds
#
# This is a "Here Document" (often called "Heredoc"). It's a way to write 
# multiple lines of text into a file all at once.
#
# The syntax 'cat << 'EOF' > segment7_runner.sh' means:
#   - 'cat' is the command (normally used to read files)
#   - '<<' tells Bash: "Read the input below until you see 'EOF'"
#   - 'EOF' is the marker that signals "stop reading" (End Of File)
#   - '> segment7_runner.sh' redirects all that text into a new file
#
# The single quotes around 'EOF' are a critical safety feature. They tell Bash 
# NOT to evaluate any $variables or run any commands right now. Just treat 
# everything as raw text. This is important because we want the variable 
# references inside the new script to remain as variable references, not to 
# be expanded with current values.

cat << 'EOF' > segment7_runner.sh

# ============================================================================
# [SHEBANG] This tells the operating system to use Bash for this script
# ============================================================================
#
# The '#!' at the very start is called a "shebang" (shell magic). It tells the 
# operating system: "When someone tries to run this file, please use the Bash 
# interpreter located at /bin/bash to execute it."
#
# Without this line, the OS wouldn't know which program to use to run the script.

#!/bin/bash

# ============================================================================
# SAFETY NET FOR BASH SCRIPTS: set -euo pipefail
# ============================================================================
#
# This line sets safety options that make the script more reliable.
#
# 'set' is a built-in command that changes how Bash behaves. The flags mean:
#
#   '-e' (errexit): "Exit immediately if any command fails."
#           Without this, the script keeps running even after errors,
#           which can cause cascading problems.
#
#   '-u' (nounset): "Exit if we try to use a variable that doesn't exist."
#           This catches typos in variable names (like $DATABASE_URL
#           when the actual variable is $DATABASE_URI).
#
#   '-o pipefail': "If a chain of commands fails (like cmd1 | cmd2),
#           the whole pipeline is considered failed."
#           Without this, only the last command's exit status is checked,
#           potentially hiding errors in earlier commands.
#
# Together, these flags create a "safety net" that stops the script immediately
# if anything goes wrong, preventing silent failures and data corruption.

set -euo pipefail

# ============================================================================
# Define the project folder name as a variable
# ============================================================================
#
# We create a variable called 'SEGMENT7_PROJECT' to hold the project folder name.
# Variables let us reuse this name throughout the script without typing it 
# repeatedly. If we need to change the folder name later, we only change it 
# in one place.

SEGMENT7_PROJECT="ml_model_builder_segment7"

# ============================================================================
# [WHAT] Custom function to print debug info with timestamps
# ============================================================================
#
# We are creating a custom function named 'log_info'. Functions are like 
# custom commands that bundle up code so we can reuse it by just typing 
# its name instead of repeating the same code over and over.
#
# When we call 'log_info "some message"', that message becomes available 
# inside the function as '$1' (the first argument).
#
# This function will be used throughout the script to print consistent,
# timestamped log messages. This makes it easy to track what the script
# is doing and when.

log_info() {
  # 'echo' prints text to the screen.
  #
  # 'date '+%Y-%m-%d %H:%M:%S'' grabs the current date and time from the system
  # and formats it nicely (e.g., 2023-10-25 14:30:00). The format codes mean:
  #   %Y = 4-digit year
  #   %m = 2-digit month (01-12)
  #   %d = 2-digit day (01-31)
  #   %H = 2-digit hour in 24-hour format (00-23)
  #   %M = 2-digit minute (00-59)
  #   %S = 2-digit second (00-59)
  #
  # The '$(...)' syntax captures the date command's output and inserts it 
  # into the echo statement.
  #
  # '$1' is a special variable that holds the first argument passed to this 
  # function. So if we call 'log_info "Hello"', then $1 = "Hello".
  #
  # Together, this line prints something like:
  #   [2023-10-25 14:30:00] INFO: Hello

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

# ============================================================================
# Using our custom log_info function
# ============================================================================
#
# We call our custom function! The text inside the quotes becomes '$1' 
# inside the log_info function.

log_info "Setting up Segment 7: ML Model Builder with multi-stage builds"

# ============================================================================
# [WHAT] Create the project directory structure
# ============================================================================
#
# 'mkdir' is a command that stands for "make directory". It creates folders.
#
# The '-p' flag is very useful:
#   - It creates any parent folders that don't exist yet
#   - It doesn't crash if the folder already exists
#   - 'p' stands for "parents"
#
# So 'mkdir -p "$SEGMENT7_PROJECT/src"' means: "Create a folder called
# '$SEGMENT7_PROJECT', and inside it, create a folder called 'src'. If either
# folder already exists, don't complain—just keep going."
#
# Without the '-p' flag, mkdir would fail if any part of the path was missing.

mkdir -p "$SEGMENT7_PROJECT/src"

# ============================================================================
# Create a folder for our trained machine learning models
# ============================================================================
#
# We need a separate folder where the trained AI models will be saved.
# In our multi-stage Dockerfile, the builder stage will create these models,
# and the final stage will copy just the models here (not all the 
# training dependencies).

mkdir -p "$SEGMENT7_PROJECT/models"

# ============================================================================
# Create a folder for our automated tests
# ============================================================================
#
# We'll add a test stage to our Dockerfile to verify that the model works
# correctly before shipping it. Tests go in a separate folder.

mkdir -p "$SEGMENT7_PROJECT/tests"

# ============================================================================
# [ACTION] Move inside our newly created project folder
# ============================================================================
#
# Now we change directory into the project folder. All commands from here 
# on out will run inside this folder until we 'cd' somewhere else.

cd "$SEGMENT7_PROJECT"

################################################################################
# STREAMING_CHUNK: Writing the Python Machine Learning training script
################################################################################

# ============================================================================
# [WHAT] Create ML model training script for the builder stage
# ============================================================================
#
# Another Heredoc! This time we are writing a Python script into the file 
# 'src/train_model.py'. This script will run in the BUILDER STAGE of our 
# multi-stage Dockerfile. The builder stage is the stage that installs all 
# the heavy dependencies (like scikit-learn, TensorFlow) and does all the 
# CPU-intensive training work. The final image won't include any of this.

cat << 'PYEOF' > src/train_model.py

# ============================================================================
# Python shebang
# ============================================================================
#
# This tells the operating system: "If someone runs this file directly 
# (like ./train_model.py), use Python 3 to execute it."
#
# '/usr/bin/env python3' is more portable than '/usr/bin/python3' because 
# 'env' finds Python wherever it's installed, rather than assuming a 
# specific path.

#!/usr/bin/env python3

"""
ML model training script.

This script runs in the BUILDER STAGE of a multi-stage Dockerfile.
- It loads a dataset (Iris flowers)
- Trains an AI model (Random Forest classifier)
- Saves the trained model to /models/iris_model.pkl

The final container will only copy the trained model file, NOT this script
or the training libraries (scikit-learn, etc.). This keeps the final image small.
"""

# ============================================================================
# [IMPORT] 'sys' - Interact with the Python interpreter
# ============================================================================
#
# 'sys' is a built-in Python module that lets us interact with the Python 
# interpreter itself. We use it to access things like command-line arguments,
# exit codes, and system configuration.

import sys

# ============================================================================
# [IMPORT] 'logging' - Print diagnostic messages
# ============================================================================
#
# 'logging' is Python's built-in tool for printing diagnostic messages.
# Unlike 'print()', logging lets us:
#   - Add timestamps automatically
#   - Control the level (DEBUG, INFO, WARNING, ERROR)
#   - Redirect messages to files or other places
#
# This is much better than print() for production code and debugging.

import logging

# ============================================================================
# [IMPORT] 'pickle' - Save and load Python objects
# ============================================================================
#
# 'pickle' is a tool that takes a live Python object (like a trained AI model)
# and converts it into a byte stream (serializes it) so it can be saved to a
# file. Later, we can load the file and unpickle it to get the object back.
#
# Think of it like taking a snapshot of an object's state and saving it to disk.

import pickle

# ============================================================================
# [IMPORT] 'os' - Interact with the operating system
# ============================================================================
#
# 'os' lets us interact with the operating system (like reading folders,
# checking if files exist, getting environment variables, etc.).

import os

# ============================================================================
# [IMPORT] 'Path' from 'pathlib' - Work with file paths safely
# ============================================================================
#
# 'pathlib' is a modern Python module for working with file paths.
# 'Path' is a class that makes working with file paths much easier and safer,
# especially when you need to work across different operating systems
# (Windows, Linux, Mac) that use different path separators (\ vs /).
#
# Instead of manually concatenating strings like "models/" + "iris_model.pkl",
# we can use Path objects like: Path("/models") / "iris_model.pkl"

from pathlib import Path

# ============================================================================
# [IMPORT] Scikit-learn - Machine learning library
# ============================================================================
#
# Scikit-learn (sklearn) is a massive, well-known machine learning library
# with hundreds of pre-built AI algorithms.
#
# 'load_iris' brings in a famous beginner dataset: measurements of iris flowers.
# This dataset is simple, small, and perfect for learning.

from sklearn.datasets import load_iris

# ============================================================================
# [IMPORT] 'train_test_split' - Divide data for testing
# ============================================================================
#
# When training an AI model, we need to:
#   1. Show it training data so it can learn
#   2. Test it on separate data it's never seen before
#
# 'train_test_split' randomly divides our data into a "training" pile and 
# a "testing" pile. This ensures the test data is completely fresh and 
# gives us an honest measure of how well the model works.

from sklearn.model_selection import train_test_split

# ============================================================================
# [IMPORT] 'RandomForestClassifier' - The AI algorithm
# ============================================================================
#
# 'RandomForestClassifier' is our actual AI algorithm. It works by building
# lots of decision trees (100, in our case) and having them vote on the answer.
# It's called "Random Forest" because:
#   - "Random": Each tree is built using random subsets of the data
#   - "Forest": There are many trees
#   - "Classifier": It classifies data into categories
#
# This algorithm is great for beginners because it works well on many types
# of data and doesn't require much tuning.

from sklearn.ensemble import RandomForestClassifier

# ============================================================================
# [IMPORT] Scoring and reporting tools
# ============================================================================
#
# These tools help us grade how well our AI did:
#   - 'accuracy_score': Calculates what percentage of guesses were correct
#   - 'classification_report': Gives detailed statistics about performance
#     on each category (precision, recall, F1-score)

from sklearn.metrics import accuracy_score, classification_report

# ============================================================================
# Configure logging to show INFO level messages
# ============================================================================
#
# logging.basicConfig() sets up the logging system.
# level=logging.INFO means: "Show me INFO messages and more serious ones
# (WARNING, ERROR, CRITICAL). Don't show DEBUG messages."

logging.basicConfig(level=logging.INFO)

# ============================================================================
# Create a logger for this specific file
# ============================================================================
#
# Each Python file can have its own logger. This one will identify messages
# as coming from this file. '__name__' is a special variable that equals
# the module name (in this case, '__main__').

logger = logging.getLogger(__name__)

# ============================================================================
# [FUNCTION] train_model() - The main training logic
# ============================================================================
#
# This function handles all the machine learning work:
#   1. Load the iris dataset
#   2. Split it into training and testing portions
#   3. Train the Random Forest classifier
#   4. Evaluate how accurate it is
#   5. Save the trained model to a file
#
# By putting all this logic in a function, we can:
#   - Reuse it easily
#   - Test it separately
#   - Call it from other scripts

def train_model():
    """Train a simple ML model and save it."""
    
    # ====================================================================
    # Load the iris dataset
    # ====================================================================
    logger.info("Loading Iris dataset")
    
    # The iris dataset is a collection of measurements from 150 iris flowers.
    # Each flower has 4 measurements (sepal length, sepal width, petal length, 
    # petal width) and is labeled with its species (Setosa, Versicolor, 
    # or Virginica).
    #
    # 'X' holds the features (measurements) - the INPUT data
    # 'y' holds the target answers (species names) - the OUTPUT we want to predict
    
    iris = load_iris()
    X, y = iris.data, iris.target
    
    # ====================================================================
    # Split the data: 80% training, 20% testing
    # ====================================================================
    logger.info("Splitting data: 80% train, 20% test")
    
    # We take 20% of the data and hide it from the AI during training so we can
    # test it later with fresh data. This is called "held-out test set" and gives
    # us an honest measure of how well the model works on new data it's never seen.
    #
    # 'random_state=42' ensures the random split is exactly the same every time
    # we run the script. This makes results reproducible (same result every run).
    # The number 42 is arbitrary—any number works, but 42 is a famous "magic number"
    # in computer science!
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # ====================================================================
    # Train the Random Forest classifier
    # ====================================================================
    logger.info("Training Random Forest classifier")
    
    # We create an empty AI brain (100 decision trees).
    # n_estimators=100 means we'll build 100 trees and have them vote
    # random_state=42 again ensures reproducibility
    
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    
    # Now we feed the model the training data so it can learn!
    # This is the heavy, CPU-intensive part where the algorithm actually runs
    # and builds its decision trees based on patterns in the data.
    
    model.fit(X_train, y_train)
    
    # ====================================================================
    # Evaluate the model on the test data
    # ====================================================================
    logger.info("Evaluating model")
    
    # We ask the trained AI to guess the answers for our hidden test data.
    # It doesn't know the real answers yet—we're testing it.
    
    y_pred = model.predict(X_test)
    
    # Now we compare the AI's guesses to the real answers.
    # accuracy_score returns a percentage (0.0 to 1.0) of how many were correct.
    
    accuracy = accuracy_score(y_test, y_pred)
    
    # Print the accuracy score, formatted to 4 decimal places
    # (e.g., 0.9667 means 96.67% correct)
    
    logger.info(f"Accuracy: {accuracy:.4f}")
    
    # ====================================================================
    # Save the trained model to a file
    # ====================================================================
    
    # We define exactly where we want to save our trained AI brain.
    # In Docker, this will be /models/iris_model.pkl
    
    model_path = Path("/models/iris_model.pkl")
    
    # Create the /models directory if it doesn't exist
    # parents=True creates any parent directories needed
    # exist_ok=True doesn't error if the folder already exists
    
    model_path.parent.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"Saving model to {model_path}")
    
    # Open the file in 'wb' (Write Binary) mode, and use pickle.dump to
    # stuff our trained AI model into the file. The 'with' statement ensures
    # the file gets closed properly even if something goes wrong.
    
    with open(model_path, 'wb') as f:
        pickle.dump(model, f)
    
    logger.info("Model training complete")
    
    # Hand the model object and its accuracy score back to whoever called this function
    return model, accuracy


# ============================================================================
# Classic Python trick: Only run this code if the file is run directly
# ============================================================================
#
# This line means: "If I run this script directly (like python train_model.py),
# execute the code below. But if another file imports this (like another Python
# file saying 'from train_model import train_model'), don't run this code."
#
# This is a Python convention that separates:
#   - Code that should always run (imports, function definitions)
#   - Code that should only run when the file is the main program
#
# The '__name__' variable is special: it equals '__main__' when the file
# is run directly, but equals the module name when imported.

if __name__ == '__main__':
    # Run our training function and grab the results
    model, accuracy = train_model()
    
    # Print a success message
    print(f"SUCCESS: Model trained with {accuracy:.4f} accuracy")

# ============================================================================
# [END] Close the Python training script Heredoc
# ============================================================================

PYEOF

# Log that we successfully created the training script
log_info "Model training script created at src/train_model.py"

################################################################################
# STREAMING_CHUNK: Writing the Python inference script
################################################################################

# ============================================================================
# [WHAT] Create model prediction/inference script
# ============================================================================
#
# Another Heredoc! This script is what our FINAL container will run.
# Notice how it doesn't need to train anything!
#
# In a multi-stage build:
#   - The BUILDER STAGE runs train_model.py and creates iris_model.pkl
#   - The FINAL STAGE copies just the iris_model.pkl file
#   - The FINAL STAGE runs predict.py, which loads and uses the model
#
# This is efficient because the final image doesn't include:
#   - scikit-learn, TensorFlow, PyTorch (heavy training libraries)
#   - This script
#   - The training script
#
# Only what's needed to RUN the model, not train it.

cat << 'PREDEOF' > src/predict.py

# ============================================================================
# Python shebang for the prediction script
# ============================================================================

#!/usr/bin/env python3

"""
Model prediction/inference script.

This script:
1. Loads a pre-trained model (copied from the builder stage)
2. Makes predictions using that model
3. Returns probabilities for each class

It does NOT train anything. It only uses a trained model that was built
in the builder stage. This is what goes in the FINAL runtime stage.

Because it only loads and runs the model, the final image only needs:
   - Python
   - pickle (built-in)
   - numpy (small)
   - The model file

It does NOT need scikit-learn, which saves about 200+ MB of image size!
"""

# ============================================================================
# [IMPORT] Pickle and logging
# ============================================================================

import pickle
import logging
from pathlib import Path

# ============================================================================
# [IMPORT] NumPy - Standard numerical computing library
# ============================================================================
#
# NumPy is the standard library for handling arrays and numbers in Python.
# Machine learning libraries depend on NumPy, so it has to be installed in the
# final image. But NumPy is much smaller than scikit-learn.

import numpy as np

# ============================================================================
# Configure logging
# ============================================================================

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# [FUNCTION] load_model() - Wake up the saved AI brain
# ============================================================================
#
# This function loads a pre-trained model that was saved by the training script.
# It unpickles the binary file and reconstructs the model object.

def load_model(model_path="/models/iris_model.pkl"):
    """Load a pre-trained model from disk."""
    
    logger.info(f"Loading model from {model_path}")
    
    # Open the file in 'rb' (Read Binary) mode
    with open(model_path, 'rb') as f:
        # Use pickle.load to resurrect the AI model from the binary file!
        # It reconstructs the exact model object that was saved
        model = pickle.load(f)
    
    logger.info("Model loaded successfully")
    return model


# ============================================================================
# [FUNCTION] predict() - Use the AI brain to make predictions
# ============================================================================
#
# This function takes a trained model and feature measurements,
# and returns the model's prediction and confidence scores.

def predict(model, features):
    """Make a prediction with the model.
    
    Args:
        model: A trained RandomForestClassifier
        features: A list of 4 measurements (sepal_length, sepal_width,
                 petal_length, petal_width)
    
    Returns:
        A dictionary with the prediction, probabilities, and class names
    """
    
    logger.info(f"Making prediction for features: {features}")
    
    # We feed the features (measurements) into the AI, and it spits out
    # a prediction (which species it thinks the flower is).
    # The [features] syntax wraps our single measurement in a list because
    # the model expects a 2D array (multiple flowers).
    
    prediction = model.predict([features])
    
    # It also spits out how confident it is about its guess.
    # This gives us probabilities for each possible class (species).
    # probabilities[0] is the probabilities array for the first flower.
    
    probabilities = model.predict_proba([features])
    
    # We package the results into a nice dictionary and return it
    return {
        'prediction': int(prediction[0]),  # Convert to regular Python int
        'probabilities': probabilities[0].tolist(),  # Convert to regular list
        'class_names': ['Setosa', 'Versicolor', 'Virginica']  # Readable names
    }


# ============================================================================
# Classic Python trick again: Only run if this file is the main program
# ============================================================================

if __name__ == '__main__':
    # Load the resurrected model
    model = load_model()
    
    # Create a sample iris measurement for testing
    # These are real measurements from an Iris Setosa flower
    sample = [5.1, 3.5, 1.4, 0.2]
    
    # Ask the AI what kind of flower it thinks this is!
    result = predict(model, sample)
    
    # Print the results in a human-readable format
    print(f"Prediction: {result['class_names'][result['prediction']]}")
    print(f"Probabilities: {result['probabilities']}")

# ============================================================================
# [END] Close the prediction script Heredoc
# ============================================================================

PREDEOF

# Log that we created the prediction script
log_info "Prediction script created at src/predict.py"

################################################################################
# STREAMING_CHUNK: Writing Dockerfiles for different base images
################################################################################

# ============================================================================
# [WHAT] Create a standard multi-stage Dockerfile
# ============================================================================
#
# This demonstrates the basic multi-stage pattern:
#   1. BUILDER STAGE: Install dependencies, train the model
#   2. TEST STAGE: Run tests on the trained model
#   3. RUNTIME STAGE: Minimal image with just the model and prediction script

cat << 'DOCKEREOF' > Dockerfile

# ============================================================================
# STAGE 1: BUILDER
# ============================================================================
#
# This stage does all the heavy work: installing dependencies and training the model.
# We call this stage 'builder' using the 'AS' keyword so we can reference it later.

FROM python:3.11-slim AS builder

# Set metadata for this image
LABEL stage="builder" description="Builder stage with training dependencies"

# Create a working directory (a folder inside the container where our code runs)
WORKDIR /build

# Copy our training script into the builder stage
COPY src/train_model.py .

# Install the heavy machine learning libraries
# 'pip install' is Python's package manager (like npm for Node.js or gem for Ruby)
# These libraries are needed for training but NOT for inference/prediction
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0

# Actually run the training script. After this line, the trained model
# will exist at /models/iris_model.pkl inside the container
RUN python train_model.py

# ============================================================================
# STAGE 2: TEST
# ============================================================================
#
# This optional stage runs tests to make sure the model works.
# We can build just this stage with 'docker build --target test' for debugging.

FROM python:3.11-slim AS test

LABEL stage="test" description="Test stage for model validation"

WORKDIR /build
 
COPY tests/ ./tests/

# Run tests (would fail if tests don't pass, stopping the build)
RUN python -m pytest tests/ -v || exit 1


# === STAGE 3: RUNTIME STAGE ===
# The final stage: small, production image
# Uses distroless or alpine for minimal base image
# Copies only the trained model from builder stage

FROM python:3.11-slim AS runtime

LABEL description="Production runtime with trained model"

# Set environment variables that affect Python behavior
# PYTHONUNBUFFERED=1 makes Python print immediately instead of buffering
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy the prediction script from the builder stage
COPY src/predict.py .

# Copy the trained model from the builder stage
COPY --from=builder /models /models

# Install just the minimal dependencies needed for prediction
# Notice we don't install scikit-learn - we don't need it!
RUN pip install --no-cache-dir numpy==1.24.0

# The default command to run when someone starts a container from this image
CMD ["python", "predict.py"]

# The final image is small because it only includes:
# - Python interpreter
# - NumPy
# - Our prediction script
# - Our trained model file
#
# It does NOT include:
# - scikit-learn
# - The training script
# - The test script
# - This Dockerfile
#
# This makes it much smaller than the builder stage!

DOCKEREOF

log_info "Standard Dockerfile (multi-stage) created"

# ============================================================================
# [WHAT] Create a distroless variant Dockerfile
# ============================================================================
#
# "Distroless" images are special images that contain ONLY the application
# and its runtime dependencies. They don't include:
#   - Shell (sh, bash)
#   - Package manager (apt, yum)
#   - Standard utilities (ls, grep, etc.)
#
# This makes them extremely small and secure (no shell means attackers can't 
# easily get inside). But they're harder to debug because there's no shell.

cat << 'DISTROLESSEOF' > Dockerfile.distroless

# ============================================================================
# BUILDER STAGE: Same as before
# ============================================================================

FROM python:3.11-slim AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using distroless base image
# ============================================================================
#
# 'python:3.11-distroless' is an official Python distroless image.
# It contains only Python and essential runtime files.
#
# Distroless images are tiny (around 100MB for Python vs 200+MB for slim)
# but you can't shell into them for debugging (no /bin/bash).

FROM python:3.11-distroless

LABEL description="Minimal distroless image with trained model"

WORKDIR /app

# Copy files from builder
COPY src/predict.py .
COPY --from=builder /models /models

# The predict.py script needs numpy, which should already be in distroless
# (distroless includes the Python standard library and common packages)

# Distroless images expect the command as an absolute path or in the form
# of an array (because there's no shell to parse it)
CMD ["/usr/bin/python3", "predict.py"]

DISTROLESSEOF

log_info "Distroless Dockerfile created"

# ============================================================================
# [WHAT] Create an Alpine Linux variant Dockerfile
# ============================================================================
#
# Alpine Linux is an extremely minimal Linux distribution (only 5-10 MB base image).
# It uses 'musl libc' instead of 'glibc' (the standard C library).
#
# Pros: Extremely small images
# Cons: Some software doesn't work with musl, and it can be slower for some operations

cat << 'ALPINEEOF' > Dockerfile.alpine

# ============================================================================
# BUILDER STAGE: Using alpine base
# ============================================================================

FROM python:3.11-alpine AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using alpine base
# ============================================================================
#
# 'python:3.11-alpine' is a Python image based on Alpine Linux.
# This results in a very small final image (around 80-100MB).
#
# Note: Alpine uses 'musl libc' instead of 'glibc', which can cause
# compatibility issues with some Python packages, but scikit-learn works fine.

FROM python:3.11-alpine

LABEL description="Alpine Linux image with trained model"

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY src/predict.py .
COPY --from=builder /models /models

# Alpine uses apk (not apt) as its package manager, so pip is used for Python packages
RUN pip install --no-cache-dir numpy==1.24.0

CMD ["python", "predict.py"]

ALPINEEOF

log_info "Alpine Dockerfile created"

# ============================================================================
# [WHAT] Create a Debian variant Dockerfile
# ============================================================================
#
# Debian-slim is a middle ground:
#   - Larger than Alpine (around 100-150MB) but much smaller than standard Debian
#   - Has better software compatibility than Alpine (uses glibc)
#   - Good balance of size and compatibility

cat << 'DEBIANEOF' > Dockerfile.debian

# ============================================================================
# BUILDER STAGE: Using Debian slim base
# ============================================================================

FROM python:3.11-slim AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using Debian slim base
# ============================================================================
#
# 'python:3.11-slim' is based on Debian GNU/Linux, stripped down.
# Larger than Alpine but better software compatibility.
#
# This is a good default choice: smaller than standard Debian,
# but more compatible than Alpine.

FROM python:3.11-slim

LABEL description="Debian slim image with trained model"

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY src/predict.py .
COPY --from=builder /models /models

RUN pip install --no-cache-dir numpy==1.24.0

CMD ["python", "predict.py"]

DEBIANEOF

log_info "Debian slim Dockerfile created"

################################################################################
# STREAMING_CHUNK: Writing docker-compose.yaml
################################################################################

# ============================================================================
# [WHAT] Create docker-compose.yaml for easy multi-variant builds
# ============================================================================
#
# Docker Compose is a tool that lets us define multiple containers in one file.
# Here we're defining how to build all four variants of our image.

cat << 'COMPOSEEOF' > docker-compose.yaml

# Docker Compose version
version: '3.8'

# ============================================================================
# Define services (what we're building)
# ============================================================================

services:
  # Standard variant (python:3.11-slim)
  
  model_standard:
    build:
      context: .
      # When no dockerfile is specified, it defaults to 'Dockerfile'
    container_name: model_standard
    environment:
      # Set an environment variable inside the container
      PYTHONUNBUFFERED: "1"
  
  # ========================================================================
  # Distroless variant (smallest and most secure, but hardest to debug)
  # ========================================================================
  
  model_distroless:
    build:
      context: .
      dockerfile: Dockerfile.distroless
    container_name: model_distroless
    # Distroless images cannot have a shell environment, so we limit the args
  
  # ========================================================================
  # Alpine variant (very small, musl libc)
  # ========================================================================
  
  model_alpine:
    build:
      context: .
      dockerfile: Dockerfile.alpine
    container_name: model_alpine
    environment:
      PYTHONUNBUFFERED: "1"
  
  # ========================================================================
  # Debian variant (good balance of size and compatibility, glibc)
  # ========================================================================
  
  model_debian:
    build:
      context: .
      dockerfile: Dockerfile.debian
    container_name: model_debian
    environment:
      PYTHONUNBUFFERED: "1"

# ============================================================================
# [END] Close the docker-compose.yaml Heredoc
# ============================================================================

COMPOSEEOF

log_info "docker-compose.yaml created with multi-variant builds"

################################################################################
# STREAMING_CHUNK: Writing the helper build script
################################################################################

# ============================================================================
# [WHAT] Create a Bash helper script to build and compare all variants
# ============================================================================
#
# This script provides convenient commands to:
#   1. Build all four image variants
#   2. Compare their sizes
#   3. Build only specific stages for debugging

cat << 'SCRIPTEOF' > build_variants.sh

# ============================================================================
# Bash shebang
# ============================================================================

#!/bin/bash

# ============================================================================
# === MULTI-STAGE BUILD VARIANTS ===
# ============================================================================
#
# This script helps you build and test all four variants of the ML model image

# ============================================================================
# [SAFETY] Set error handling options
# ============================================================================
#
# See the explanation earlier in this file for details on set -euo pipefail

set -euo pipefail

echo "Building multiple variants to compare base images..."
echo ""

# ============================================================================
# Build standard multi-stage (python:3.11-slim)
# ============================================================================
#
# This is the baseline variant using python:3.11-slim as the base image.

echo "Building standard (python:3.11-slim) variant:"

# 'docker build -t' builds an image and tags it with a name.
# '-t model:standard' creates a tag called 'model:standard'
# '.' means "use the Dockerfile in the current directory"

docker build -t model:standard .
echo ""

# ============================================================================
# Build distroless variant
# ============================================================================
#
# Distroless is the smallest and most secure option, but hardest to debug.

echo "Building distroless variant:"

# '-f' explicitly tells Docker which file to use.
# Without it, Docker would look for 'Dockerfile' by default.
# '-f Dockerfile.distroless' says: "Use Dockerfile.distroless instead"

docker build -f Dockerfile.distroless -t model:distroless .
echo ""

# ============================================================================
# Build alpine variant
# ============================================================================
#
# Alpine is very small (5MB base) but has musl instead of glibc.

echo "Building alpine variant:"
docker build -f Dockerfile.alpine -t model:alpine .
echo ""

# ============================================================================
# Build debian variant
# ============================================================================
#
# Debian is a good middle ground: not as small as Alpine,
# but better compatibility and uses glibc.

echo "Building debian-slim variant:"
docker build -f Dockerfile.debian -t model:debian .
echo ""

# ============================================================================
# Compare image sizes
# ============================================================================
#
# Now let's see which variant is smallest!

echo "=== IMAGE SIZE COMPARISON ==="

# 'docker images' lists all images on your computer.
# '| grep' filters the output to show only lines containing "model:"

docker images | grep "model:"
echo ""

# ============================================================================
# Demonstrate the --target flag
# ============================================================================
#
# The '--target' flag tells Docker to stop building at a specific stage.
# This is useful for debugging or just building the builder stage.

echo "Building only the builder stage (for testing/debugging):"

# '--target builder' tells a multi-stage Dockerfile to stop at the 'builder'
# stage and ignore the rest (test and runtime stages).
# This is faster for debugging because you don't wait for tests to run.

docker build --target builder -t model:builder-only .
echo ""

echo "Building only the test stage:"
docker build --target test -t model:test-only .
echo ""

# ============================================================================
# Summary
# ============================================================================

echo "=== BUILD COMPLETE ==="
echo ""
echo "You now have four variant images:"
echo "  model:standard    - Standard multi-stage (good balance)"
echo "  model:distroless  - Smallest but no shell"
echo "  model:alpine      - Very small, musl libc"
echo "  model:debian      - Good compatibility, reasonable size"
echo ""
echo "To run a container:"
echo "  docker run --rm model:standard"
echo ""
echo "To compare sizes:"
echo "  docker images | grep model:"
echo ""

# ============================================================================
# [END] Close the build_variants.sh Heredoc
# ============================================================================

SCRIPTEOF

# Make the script executable
chmod +x build_variants.sh

log_info "Build variants script created at build_variants.sh"

################################################################################
# STREAMING_CHUNK: Writing the .dockerignore file
################################################################################

# ============================================================================
# [WHAT] Create a .dockerignore file
# ============================================================================
#
# .dockerignore works like .gitignore but for Docker.
# It tells Docker: "When copying files into the image, skip these files/folders."
#
# This keeps images small by excluding files we don't need:
#   - .git directories (we don't need git history in the image)
#   - __pycache__ (compiled Python bytecode, will be regenerated)
#   - Tests (we run tests in the test stage, not the final stage)
#   - Documentation (users don't need docs in the image)

cat << 'IGNOREEOF' > .dockerignore

# ============================================================================
# [WHAT] Files to ignore when building Docker images
# ============================================================================

# Git repository data
.git
.gitignore

# Python bytecode and caches
__pycache__
*.pyc
*.pyo
.pytest_cache
.coverage
htmlcov

# IDE files
.vscode
.idea
*.swp
*.swo

# System files
.DS_Store

# Documentation and changelog
*.md
docs/
CHANGELOG

# Temporary files
.env
.env.local
tmp/
temp/
*.tmp

# Alternative Dockerfiles (we don't want these in every image)
Dockerfile.alpine
Dockerfile.debian
Dockerfile.distroless

# ============================================================================
# [END] Close the .dockerignore Heredoc
# ============================================================================

IGNOREEOF

log_info ".dockerignore created"

# ============================================================================
# Final logging and instructions
# ============================================================================

log_info "Segment 7 setup complete"
log_info "To build multi-stage images:"
log_info "  docker build -t model:standard ."
log_info "  docker build -f Dockerfile.distroless -t model:distroless ."
log_info "  docker build -f Dockerfile.alpine -t model:alpine ."
log_info "  docker build -f Dockerfile.debian -t model:debian ."
log_info "  OR: bash build_variants.sh (builds all variants)"

# ============================================================================
# [END] Close the very first, massive Heredoc
# ============================================================================
#
# This 'EOF' closes the Heredoc we opened at the beginning of the script.
# Everything between the first 'cat << 'EOF'' and this line has been written
# into the 'segment7_runner.sh' file.

EOF

# ============================================================================
# Make the script executable and run it
# ============================================================================
#
# 'chmod +x' stands for "change mode to executable".
# This tells the operating system that this file is a program that can be run.

chmod +x segment7_runner.sh

# ============================================================================
# [ACTION] Execute the script we just created
# ============================================================================
#
# We run the giant script using bash. This will execute all the commands inside,
# creating all the project files, Dockerfiles, and helper scripts.

bash segment7_runner.sh

# ============================================================================
# Print a success message
# ============================================================================
#
# Print a pretty green success message to show the user we're done.

echo -e "${GREEN}✓ Segment 7 complete: Multi-stage ML model builder project created${NC}"

# ============================================================================
# Return to the original directory
# ============================================================================
#
# 'cd -' goes back to the directory we were in before we ran this script.
# It's like an "undo" for directory navigation. This is useful because we did
# 'cd "$SEGMENT7_DIR"' earlier, and now we want to go back home.

cd -

################################################################################
# SEGMENT 8: BUILDKIT — SECRETS, SSH, AND ADVANCED BUILD FEATURES
################################################################################
# 
# This educational script demonstrates advanced Docker features:
#   - DOCKER_BUILDKIT: An improved build system for Docker that's faster and more secure
#   - RUN --mount=type=secret: How to safely pass sensitive data during builds
#   - RUN --mount=type=ssh: How to use SSH keys during builds without exposing them
#   - docker buildx: A tool for building images for different computer types (platforms)
#   - --platform: Specifying which OS and CPU architecture to build for
#   - FROM --platform=$BUILDPLATFORM/$TARGETPLATFORM: Advanced multi-platform syntax
#   - Fat manifests: A way to package multiple platform versions together
#   - QEMU: An emulator that lets you build for different architectures
#   - docker buildx create/use/ls/inspect: Commands to manage build environments

################################################################################

# The 'echo' command is used to print text to your screen.
#
# The '-e' flag stands for "enable interpretation of backslash escapes", which 
# basically lets us use special formatting like colors and line breaks.
#
# ${BLUE} and ${NC} are variables (assumed to be set elsewhere) that change 
# the text color to blue, and then reset it to "No Color" (return to normal).

echo -e "${BLUE}=== SEGMENT 8: BUILDKIT & ADVANCED BUILD FEATURES ===${NC}"

# A simple print statement telling the user what we are about to do.
# This helps the user understand the script's flow.

echo "Creating a multi-platform Go application with BuildKit advanced features..."

# [WHAT] Create a temporary directory for Segment 8; isolate all Segment 8 work
#
# 'mktemp' is a built-in tool that creates a guaranteed-unique temporary file 
# or directory. This is safer than manually creating folders with predictable names.
#
# The '-d' flag tells mktemp to create a Directory (folder) instead of a file.
#
# The '$(...)' syntax is called "command substitution". It runs the command inside 
# the parentheses and captures its output (which is the path to the new folder).
# We then save that path into a new variable called 'SEGMENT8_DIR' so we can 
# use it later.

SEGMENT8_DIR=$(mktemp -d)

# 'cd' stands for Change Directory. We are navigating into the brand new 
# temporary folder we just created.
#
# The double quotes around "$SEGMENT8_DIR" protect the path just in case 
# it has spaces in it. Without quotes, the shell might break the path into pieces.

cd "$SEGMENT8_DIR"

################################################################################
# Create the Segment 8 runner script
################################################################################
#
# [WHY] Encapsulate all BuildKit demonstrations in a self-contained script
#
# This is a "Here Document" (often called "Heredoc"). It's a trick to write 
# multiple lines of text into a file all at once, without typing each echo command.
#
# 'cat' normally reads files and prints them, but here we feed it text via a Heredoc.
#
# '<<' tells Bash to keep reading the lines below until it sees the exact word 'EOF' 
# (End Of File). Everything between '<<' and 'EOF' becomes input to 'cat'.
#
# The single quotes around 'EOF' are a CRITICAL safety measure: they tell Bash 
# to treat everything inside exactly as raw text, and NOT to try and calculate 
# any $variables or run any commands yet. This is important because we want the 
# code inside to remain literal.
#
# '>' takes all that text and redirects (pushes) it into a brand new file 
# named 'segment8_runner.sh'.

cat << 'EOF' > segment8_runner.sh

#!/bin/bash

# This is called a 'shebang' (the #! at the start). It tells the computer's 
# operating system to use the Bash shell program (located at /bin/bash) to run 
# this script. Without this line, the OS wouldn't know which interpreter to use.

#!/bin/bash

# This line sets safety options for Bash scripts!
#
# 'set' is a built-in command that changes how Bash behaves.
#
# '-e' tells the script to quit immediately if any command crashes or fails. 
# This prevents errors from being ignored and keeps the script from continuing 
# with bad data.
#
# '-u' tells the script to quit if we try to use a variable that hasn't been 
# created yet. This catches typos in variable names (like typo in "$DATABASE_URL").
#
# '-o pipefail' ensures that if a chain of commands fails (like command1 | command2), 
# the whole chain reports a failure. Without this, only the last command's result 
# would be checked, potentially hiding errors.

set -euo pipefail

# Creating a variable to hold the name of our project folder. Variables let us 
# reuse values easily throughout the script. If we need to change this name later, 
# we only change it in one place.

SEGMENT8_PROJECT="buildkit_multiplatform_app"

################################################################################
# [WHAT] Function to print debug info with timestamps; reused throughout segment
################################################################################
#
# We are defining a custom function named 'log_info'. Functions are like custom 
# commands that bundle up code so we can reuse it by just typing its name instead 
# of typing the whole thing repeatedly.
#
# When we call 'log_info "some message"', that message becomes available inside 
# the function as '$1' (the first argument).

log_info() {
  # 'echo' prints text to the screen.
  # 'date '+%Y-%m-%d %H:%M:%S'' grabs the current date and time from the system 
  # and formats it nicely (e.g., 2023-10-25 14:30:00). The format codes mean:
  #   %Y = 4-digit year
  #   %m = 2-digit month
  #   %d = 2-digit day
  #   %H = 2-digit hour (24-hour format)
  #   %M = 2-digit minute
  #   %S = 2-digit second
  #
  # The '$(...)' syntax captures that date string and inserts it into the echo output.
  #
  # '$1' is a special variable that represents the first argument we pass to 
  # this function when we use it. So if we call 'log_info "Hello"', then $1 = "Hello".

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

################################################################################
# [WHAT] Function to print error messages; used for error reporting
################################################################################
#
# Defining another function, this time for errors. It works the same way as log_info.

log_error() {
  # This does the same as log_info above, but the '>&2' at the end is special.
  # '>&2' redirects the output from "Standard Output" (normal text that goes to 
  # your screen) to "Standard Error" (a separate error stream). This helps 
  # monitoring tools and scripts know it's a real error, not just regular output.

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Using our custom function! The text inside the quotes becomes '$1' inside 
# the log_info function.

log_info "Setting up Segment 8: BuildKit with multi-platform Go app"

################################################################################
# Create project directory structure
################################################################################
#
# 'mkdir' stands for "make directory" and creates folders.
#
# The '-p' flag is very useful: it creates parent folders if they don't exist 
# (so if 'buildkit_multiplatform_app' doesn't exist, it creates it first), and 
# it doesn't crash if the folder already exists. Without '-p', mkdir would fail 
# if any part of the path was missing.

mkdir -p "$SEGMENT8_PROJECT/src"

# Creating a 'secrets' folder inside our project directory. 
# We'll use this later to store sensitive data.

mkdir -p "$SEGMENT8_PROJECT/secrets"

# Moving inside our new project directory using 'cd'.
# All commands from now on will run inside this directory until we 'cd' elsewhere.

cd "$SEGMENT8_PROJECT"

################################################################################
# Create a simple Go application
################################################################################
#
# [WHY] Go is ideal for demonstrating cross-platform builds because:
#       - Go compiles to a single, standalone binary (no runtime needed)
#       - Go can easily target different operating systems and CPU architectures
#       - Go compilation is fast
#
# Opening another Heredoc! This time we are writing actual Go programming code 
# into a file called 'src/main.go'. Everything between '<<' and the next 'GOEOF' 
# becomes the content of this file.

cat << 'GOEOF' > src/main.go

# Every executable Go program must start with 'package main'. 
# This tells the Go compiler to make a runnable program (executable), 
# not a library that other programs can use.

package main

# The 'import' block brings in external toolkits (called packages) that our 
# code needs to function. Think of packages like libraries of pre-written code.

import (
  # 'encoding/json' lets us convert our Go data structures into JSON format 
  # (a standard format for web APIs and data exchange).
  "encoding/json"
  
  # 'fmt' is used for formatting text and strings. 'fmt' stands for "format".
  "fmt"
  
  # 'log' gives us tools to print log messages to the console. Logs are messages 
  # that help us understand what the program is doing.
  "log"
  
  # 'net/http' gives us all the tools needed to build a web server that listens 
  # for HTTP requests (like when you visit a website).
  "net/http"
  
  # 'os' lets us interact with the operating system, like reading environment 
  # variables (variables set by the system or Docker).
  "os"
  
  # 'runtime' gives us information about the computer running the code, like 
  # what OS it is (Windows, Linux, Mac) and what CPU architecture it has 
  # (like x86_64 or ARM).
  "runtime"
  
  # 'time' lets us work with dates and times, like getting the current time 
  # or measuring how long something takes.
  "time"
)

# 'type' is how we define custom data types in Go.
# This 'struct' (structure) is like a custom blueprint or template for a data object.
# Imagine a form with multiple fields - each field has a name and type.
#
# We're creating a response structure that we'll send back to users when they 
# visit our web server.

type APIResponse struct {
  # We define fields and their data types. 
  # For example, 'Status' is a string (text), and 'Timestamp' is a time.Time (a date/time).
  #
  # The text in backticks (like json:"status") are tags. They tell the JSON 
  # converter how to name these fields when converting to JSON. So the Go 
  # field 'Status' becomes 'status' in JSON (lowercase).
  
  Status      string    `json:"status"`
  Timestamp   time.Time `json:"timestamp"`
  Version     string    `json:"version"`
  Platform    string    `json:"platform"`
  Architecture string   `json:"architecture"`
  Hostname    string    `json:"hostname"`
}

# 'func main()' is the starting point of every Go program. When the app runs, 
# it starts executing code right here in the main function.

func main() {
  # 'os.Getenv' asks the operating system for the value of an environment 
  # variable. In this case, we're asking for "APP_VERSION".
  #
  # Environment variables are key-value pairs set by the system or Docker. 
  # In Docker, we can set them with the '-e' flag (like: docker run -e APP_VERSION=2.0.0).
  #
  # The ':=' operator means "create a new variable and assign it this value" in Go.

  version := os.Getenv("APP_VERSION")
  
  # If the user didn't set the APP_VERSION variable, it will be empty ("").
  # This 'if' statement checks if the version is empty.

  if version == "" {
    # If it's empty, we give it a default value of "1.0.0".
    # This prevents our API from reporting no version.
    
    version = "1.0.0"
  }

  # 'os.Hostname()' asks the operating system for the computer's name. 
  # In Docker containers, this is usually the container's unique ID.
  #
  # This function returns two things: the name, and an error. 
  # The underscore '_' tells Go to ignore the error part (we don't care about errors here).

  hostname, _ := os.Hostname()

  # ============================================================================
  # [WHAT] Simple health check endpoint (no dependencies, just status)
  # ============================================================================
  #
  # 'http.HandleFunc' tells our web server: "If someone visits the URL '/health', 
  # run this specific block of code."
  #
  # Think of it like a mailbox: when someone sends a request to '/health', 
  # the function inside the curly braces {} gets executed.

  http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
    # We create a new instance of our APIResponse blueprint.
    # Think of it like filling out a form with specific values.
    
    resp := APIResponse{
      Status:        "healthy",
      
      # 'time.Now()' grabs the exact current time from the system clock.
      Timestamp:     time.Now(),
      Version:       version,
      
      # 'runtime.GOOS' tells us what Operating System this code was compiled 
      # for (like "linux", "windows", or "darwin" for Mac).
      Platform:      runtime.GOOS,
      
      # 'runtime.GOARCH' tells us what CPU architecture it was compiled for 
      # (like "amd64" for 64-bit Intel/AMD, or "arm64" for ARM processors).
      Architecture:  runtime.GOARCH,
      Hostname:      hostname,
    }
    
    # We set a header telling the user's web browser to expect JSON data back.
    # Headers are metadata that come before the actual data in HTTP responses.
    w.Header().Set("Content-Type", "application/json")
    
    # We take our 'resp' object, convert it to JSON format, and send it back 
    # to the user over the web connection ('w'). The NewEncoder and Encode do 
    # the conversion from Go data to JSON text.
    json.NewEncoder(w).Encode(resp)
  })

  # ============================================================================
  # [WHAT] Info endpoint showing build-time information
  # ============================================================================
  #
  # Setting up a second URL route for '/info'. It does exactly the same thing 
  # as the '/health' endpoint, just changing the 'Status' string to "running".
  # This lets users check if the app is running.

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

  # 'log.Fatal' prints an error message and then exits the program.
  # 'http.ListenAndServe' starts a web server that listens on port 8080 
  # (a network port where the web server receives requests).
  #
  # The "0.0.0.0:8080" means: listen on all available network interfaces on port 8080.
  #
  # If ListenAndServe encounters an error (like the port is already in use), 
  # log.Fatal prints the error and stops the program.

  log.Fatal(http.ListenAndServe("0.0.0.0:8080", nil))
}

# End of Go code - the 'GOEOF' marker tells the Heredoc to stop reading.

GOEOF

# Make the file we just created executable (though Go files aren't directly executed like Bash).

log_info "Created src/main.go"

# ============================================================================
# Create a Dockerfile for single-platform build
# ============================================================================
#
# A Dockerfile is a recipe that tells Docker how to build an image (a package 
# containing our app and everything it needs to run).

cat << 'DOCKEREOF' > Dockerfile

# Start from the official Go image. This image already has Go installed and ready.
# 'alpine' is a super tiny version of Linux (only 5MB). This keeps our images small.
# 'as builder' gives this stage a name so we can reference it later.

FROM golang:1.20-alpine AS builder

# Set metadata. This doesn't affect the build, but tells users what this image is for.

LABEL description="Go app with BuildKit secrets and SSH mount examples"

# Create and navigate into a directory inside the image called /build.
# All commands from here on run inside this directory.

WORKDIR /build

# Copy the main.go file from our computer (the first path) into the image 
# at /build/main.go (the second path).

COPY src/main.go .

# Set an environment variable that Go uses. 
# CGO_ENABLED=0 tells Go: "Don't use C code in the executable". 
# This makes the binary completely standalone (no dependencies).

ENV CGO_ENABLED=0

# Build (compile) the Go program.
# 'go build' compiles Go source code into an executable binary.
# '-o app' says: "Put the output binary in a file named 'app'".

RUN go build -o app main.go

# ============================================================================
# Final stage: Create a tiny image with just the executable
# ============================================================================
#
# FROM scratch creates an image from nothing - completely empty. 
# Then we just copy in our compiled binary. This is the smallest possible image 
# (about 6-7MB for a Go app).

FROM scratch

# Set metadata again for the final image.

LABEL description="Multi-platform Go app with BuildKit"

# Copy the compiled 'app' binary from the builder stage into this final image.
# The syntax is: COPY --from=<stage_name> <path_in_stage> <path_in_final_image>

COPY --from=builder /build/app /app

# Set the working directory.

WORKDIR /

# EXPOSE tells Docker which port this app listens on. It's just documentation 
# (doesn't actually publish the port, but tells users the app uses port 8080).

EXPOSE 8080

# CMD tells Docker what command to run when the container starts.
# Here, we run our compiled app executable.

CMD ["/app"]

# End of Dockerfile - the 'DOCKEREOF' marker tells the Heredoc to stop.

DOCKEREOF

log_info "Created Dockerfile"

# ============================================================================
# Create a Dockerfile for multi-platform build (showing BUILDPLATFORM/TARGETPLATFORM)
# ============================================================================
#
# This is an advanced Dockerfile that's designed to work across multiple 
# platforms (different OS and CPU combinations).

cat << 'MULTIEOF' > Dockerfile.multiplatform

# Advanced syntax: 'FROM --platform=$BUILDPLATFORM' means:
# "Pull the golang image for the platform we're BUILDING on" (not necessarily 
# the platform we're building FOR). This makes the build faster because we don't 
# need to emulate a different CPU architecture during compilation.
#
# The build args like BUILDPLATFORM and TARGETPLATFORM are automatically set 
# by Docker buildx (the multi-platform build tool).

FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS builder

LABEL description="Multi-platform Go app - optimized for cross-compilation"

# Set these build arguments (variables). They're set automatically by buildx 
# but we declare them here so the Dockerfile knows about them.

ARG BUILDPLATFORM
ARG TARGETPLATFORM

# Create the build directory.

WORKDIR /build

# Copy our source code in.

COPY src/main.go .

# These environment variables tell Go which platform to compile for.
# GOARCH and GOOS are environment variables that Go respects.
# We extract them from TARGETPLATFORM which looks like "linux/amd64" or "linux/arm64".

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
  "linux/amd64") GOARCH=amd64;; \
  "linux/arm64") GOARCH=arm64;; \
  "linux/arm/v7") GOARCH=arm; GOARM=7;; \
  esac

# Set the GOOS (Go Operating System).

ENV GOOS=linux \
  CGO_ENABLED=0

# Compile the app for the target platform.

RUN go build -o app main.go

# Final stage for the target platform.

FROM --platform=$TARGETPLATFORM alpine:latest

LABEL description="Minimal runtime image for multi-platform Go app"

WORKDIR /

# Copy the compiled app from the builder.

COPY --from=builder /build/app /app

EXPOSE 8080

CMD ["/app"]

# End of multi-platform Dockerfile.

MULTIEOF

log_info "Created Dockerfile.multiplatform"

# ============================================================================
# Create a demo secrets file
# ============================================================================
#
# We're going to demonstrate how to pass secrets (sensitive data) during builds.
# This file simulates an API key or password.

cat > secrets/api_key.txt << 'SECRETEOF'
super_secret_api_key_do_not_commit_to_git
SECRETEOF

log_info "Created secrets/api_key.txt"

# ============================================================================
# Create a buildkit_demo.sh script for building with secrets and SSH
# ============================================================================
#
# This script shows how to use advanced BuildKit features like secrets mounting.

cat << 'BUILDDEMOEOF' > buildkit_demo.sh

#!/bin/bash

# Set safety options.

set -euo pipefail

# Define color variables for pretty output.

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print with colors.

log_step() {
  echo -e "${BLUE}[STEP]${NC} $1"
}

# ============================================================================
# [WHAT] Build with DOCKER_BUILDKIT=1 (enable BuildKit)
# ============================================================================
#
# DOCKER_BUILDKIT=1 enables the new BuildKit backend.
# The old build system didn't support secrets mounting and other advanced features.
# BuildKit is faster and more secure.

log_step "Building with BuildKit enabled..."

# We pass the secret file to the build using --secret.
# Inside the Dockerfile, we can mount this secret without exposing it in the 
# final image.

DOCKER_BUILDKIT=1 docker build \
  --secret api_key=./secrets/api_key.txt \
  -t buildkit-demo:latest \
  -f Dockerfile .

log_step "Build complete!"

# ============================================================================
# [WHAT] Try multi-platform build with buildx
# ============================================================================
#
# docker buildx is a tool for multi-platform builds. It can build for Linux, 
# Windows, Mac, and different CPU architectures (x86_64, ARM, etc.) all with 
# one command.

log_step "Checking if docker buildx is available..."

# Check if buildx command exists.

if ! command -v docker buildx &> /dev/null; then
  echo -e "${RED}docker buildx is not available${NC}"
  echo "Install it or enable BuildKit with: DOCKER_BUILDKIT=1"
else
  log_step "docker buildx is available!"
  
  # List available build platforms.
  
  log_step "Available platforms for building:"
  docker buildx ls
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo -e "${GREEN}BuildKit demonstration complete!${NC}"
echo ""
echo "Key concepts demonstrated:"
echo "  1. DOCKER_BUILDKIT=1 enables the faster, more secure BuildKit system"
echo "  2. --secret allows passing sensitive data that stays out of the image"
echo "  3. docker buildx enables cross-platform builds (different OS/CPU)"
echo "  4. Multi-platform builds create images that work everywhere"
echo ""

# End of buildkit_demo.sh script.

BUILDDEMOEOF

# Make the script executable.

chmod +x buildkit_demo.sh

log_info "Created buildkit_demo.sh"

# ============================================================================
# Create a comparison guide
# ============================================================================
#
# This helps users understand the different approaches.

cat << 'COMPAREEOF' > COMPARISON.md

# Single-Platform vs Multi-Platform Builds

## Single-Platform Build (Traditional)

When you run `docker build`, you're building for your current machine's OS and CPU.

- **Pros**: Simple, straightforward, common knowledge
- **Cons**: The image only works on that platform. If you build on Mac and push to Linux server, it might not work.

## Multi-Platform Build (Modern)

Using `docker buildx`, you can build for multiple platforms in one command.

- **Pros**: One image works everywhere (Linux/Windows/Mac, x86/ARM/etc.)
- **Cons**: Requires BuildKit, slightly more complex syntax

## BuildKit Features

### Secrets Mounting (`RUN --mount=type=secret`)

**Problem**: If you have an API key or password, you can't pass it with `RUN` 
because it gets saved in the image history.

**Solution**: Mount it like a temporary file:

```dockerfile
RUN --mount=type=secret=api_key \
  curl --header "Authorization: $(cat /run/secrets/api_key)" https://api.example.com
```

The secret is never saved in the image. It's only available during that RUN command.

### SSH Mounting (`RUN --mount=type=ssh`)

**Problem**: You need to clone a private Git repo during the build, but you can't 
put your SSH key in the image.

**Solution**: Mount your SSH key temporarily:

```dockerfile
RUN --mount=type=ssh \
  git clone git@github.com:company/private-repo.git /code
```

## Cross-Platform Compilation

Go makes this easy because Go can compile to different architectures in one command.

```bash
GOOS=linux GOARCH=arm64 go build -o app  # Build for ARM64
GOOS=linux GOARCH=amd64 go build -o app  # Build for x86-64
```

Other languages (Python, Node.js) usually need to be built on the target platform.

# End of comparison guide.

COMPAREEOF

log_info "Created COMPARISON.md"

# ============================================================================
# Log completion
# ============================================================================

log_info "Segment 8 setup complete"
log_info "Next steps:"
log_info "  1. Review the files created: ls -la"
log_info "  2. Read COMPARISON.md for conceptual understanding"
log_info "  3. Run: bash buildkit_demo.sh"
log_info "  4. Try: DOCKER_BUILDKIT=1 docker build -t myapp ."

# End of the massive Segment 8 runner script Heredoc.

EOF

# ============================================================================
# Make the script executable and run it
# ============================================================================
#
# 'chmod +x' stands for "change mode to executable". This tells the operating 
# system that this file is a program that can be run.

chmod +x segment8_runner.sh

# Now run the script using the bash interpreter.

bash segment8_runner.sh

# Print a success message.

echo -e "${GREEN}✓ Segment 8 complete: BuildKit, secrets, SSH, multi-platform builds${NC}"

# ============================================================================
# Return to the original directory
# ============================================================================
#
# 'cd -' goes back to the directory we were in before the last 'cd' command.
# It's like an "undo" for directory navigation.

cd -



################################################################################
# SUMMARY AND NEXT STEPS
################################################################################

echo ""
echo -e "${YELLOW}=== ALL SEGMENTS COMPLETE ===${NC}"
echo ""
echo -e "${GREEN}Summary of Created Projects:${NC}"
echo ""

# ============================================================================
# Segment 8 Summary
# ============================================================================
#
# Provide a clear explanation of what Segment 8 demonstrated.

echo "Segment 8 - BuildKit & Advanced Build Features:"
echo "  Location: $SEGMENT8_DIR"
echo "  Project: Go app with BuildKit secrets, SSH, cross-platform builds"
echo ""
echo "  Key Concepts:"
echo "    - DOCKER_BUILDKIT=1: Enables the faster BuildKit system"
echo "    - RUN --mount=type=secret: Pass sensitive data during build without exposing it"
echo "    - RUN --mount=type=ssh: Use SSH keys during build safely"
echo "    - docker buildx: Tool for building across multiple platforms"
echo "    - --platform: Specify which OS/CPU architecture to target"
echo "    - FROM --platform=\$BUILDPLATFORM/\$TARGETPLATFORM: Advanced multi-platform syntax"
echo "    - Cross-compilation: Compile once for many architectures"
echo "    - Fat manifests: Package multiple platform versions together"
echo ""

echo -e "${BLUE}Quick Start:${NC}"
echo "  # Navigate to the Segment 8 directory"
echo "  cd $SEGMENT8_DIR"
echo ""
echo "  # Read the comparison guide"
echo "  cat COMPARISON.md"
echo ""
echo "  # Run the BuildKit demo"
echo "  bash buildkit_demo.sh"
echo ""
echo "  # Build an image with the traditional method"
echo "  docker build -t mygo:v1 ."
echo ""
echo "  # Build with BuildKit enabled (faster, more features)"
echo "  DOCKER_BUILDKIT=1 docker build -t mygo:v2 ."
echo ""

echo -e "${BLUE}Files Created:${NC}"
echo "  - Dockerfile: Traditional single-platform build"
echo "  - Dockerfile.multiplatform: Advanced multi-platform build"
echo "  - buildkit_demo.sh: Demo script showing BuildKit features"
echo "  - COMPARISON.md: Conceptual guide to understanding the differences"
echo "  - secrets/api_key.txt: Example secret file (never commit to git!)"
echo ""