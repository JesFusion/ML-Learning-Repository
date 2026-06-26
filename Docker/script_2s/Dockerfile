FROM python:3.10-slim

WORKDIR /img_fol

COPY . .

COPY ["database_generator", "/img_fol/database"]

CMD ["python", "script.py"]

































FROM python:3.9-slim


WORKDIR /fol_2_2

ENV USER="Sadio Mane"

COPY file.py .

RUN apt-get update && apt-get install -y \
    htop \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["python", "file.py"]

CMD ["Not-Normal"]




























FROM python:3.9-slim


WORKDIR /fol_2_3

COPY requirements.txt .

RUN echo -e "//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "file.py"]







































# use the slim pythom image as a Foundation for our image
FROM python:3.10-slim

# create a './project/app' in the container
WORKDIR /project/app

# copy requirements.txt to the current directory
COPY requirements.txt .

# pip install is at the top of the file, ensuring this layer does not re-run whenever we rebuild the image
RUN pip install --no-cache-dir -r requirements.txt

# indicate that pandas has finished installing
RUN echo "Pandas package finished installing..."


ENV TARGET_ENV="PRODUCTION"

# copy everything in the current folder to './project/app/' in the container
COPY . .

# fire up the python script
CMD ["python", "processor.py"]
























# ===================================== practice-image:v2 =====================================


FROM python:3.10-slim

WORKDIR /code_folder

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && apt-get install -y htop sudo nano procps && rm -rf /var/lib/apt/lists/*



CMD ["python", "file.py"]


# ===================================== practice-image:v2 =====================================





















FROM python:3.10-slim

WORKDIR /the_files

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


COPY script.py .

CMD ["python", "script.py"]



























# Specifies the base image. 'alpine:latest' is a minimal, lightweight 
# Linux distribution (around 5MB) commonly used to keep image sizes small.
FROM alpine:latest # Sets the base image to the minimal alpine distribution

# Runs a command during the image build process. 
# This prints a message to the build log as a reminder of Docker's design.
RUN echo "This image is immutable - any change requires a new build" # Executes an echo command during image build

# Adds metadata to the image using key-value pairs.
# This serves as documentation or a flag for automated tools/scanners.
LABEL immutable="true" # Applies metadata labeling the image as immutable

# Defines the default executable that runs when the container starts.
# In this case, it launches the standard Shell ('sh') interpreter.
# Sets the container's default execution shell to /bin/sh

ENTRYPOINT ["/bin/sh"]
































# Specifies the base image. This downloads the latest minimal Alpine Linux distribution to serve as the environment.
FROM alpine:latest # Sets the base image to the minimal alpine distribution

# Runs a shell command during the build process to print text to the build logs for verification.
RUN echo "Reproducible content" # Executes an echo command to verify the build process

# Copies a file from your local host machine into the container image.
# Source: /tmp/reproducible_input.txt (on your computer)
# Destination: /app/data.txt (inside the Docker image)

# Copies a file from the host machine into the container's /app directory
COPY /tmp/reproducible_input.txt /app/data.txt 
































# Use a slim python base image and alias the stage
FROM python:3.11-slim AS segment5_base_image

# Line 1/4 of LABEL: Set maintainer email
# Line 2/4 of LABEL: Set description text
# Line 3/4 of LABEL: Set version number
# Line 4/4 of LABEL: Set segment tracking id
LABEL maintainer="jesfusionprox@gmail.com" \
    description="Practicing Segment 5 using Flask API Python Code" \
    version="0.0.1" \
    segment="5"

SHELL ["/bin/bash", "-c"] # Override default builder shell to bash

WORKDIR /segment_5_dir # Configure the directory path inside the image

ARG name_of_user="jesfusion-project" # Create a build argument for the username

# Line 1/6 of ENV: Force stdout/stderr unbuffered
# Line 2/6 of ENV: Prevent Python from writing .pyc files
# Line 3/6 of ENV: Disable pip caching
# Line 4/6 of ENV: Set app version
# Line 5/6 of ENV: Set log level
# Line 6/6 of ENV: Resolve dynamically assigned username
ENV PYTHONUNBUFFERED=1 \
PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    version_of_the_app=0.0.1 \
    the_logging_level=INFO \
    name_of_user=${name_of_user}

ARG BUILD_DATE # Register a build argument to track compilation date

# Version Control System Reference
ARG VCS_REF # Register a build argument for the repository commit hash

ARG CACHE_BUST=default # Register an argument used to purposefully break image cache layers

# Line 1/7 of RUN: Update ubuntu apt package list
# Line 2/7 of RUN: Install utility tools without recommended packages
# Line 3/7 of RUN: Request curl
# Line 4/7 of RUN: Request ca-certificates
# Line 5/7 of RUN: Clear the apt cache list
# Line 6/7 of RUN: Delete the raw repository lists
# Line 7/7 of RUN: Finish deletion task
RUN apt-get update && \
apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
COPY --chown=1000:1000 requirements.txt . # Copies requirements file assigned to non-root ID

RUN ["python", "-m", "pip", "install", "--upgrade", "pip", "setuptools", "wheel"] # Upgrades pip baseline packages

RUN ["python", "-m", "pip", "install", "-r", "requirements.txt"] # Installs application-specific dependencies

# Line 1/2 of RUN: Instantiate non-root user matching provided username variable
# Line 2/2 of RUN: Force non-root ownership on working directory
RUN useradd -m -u 1000 ${name_of_user} && \
    chown -R 1000:1000 /segment_5_dir

COPY --chown=1000:1000 . . # Copies all residual files into image with safe ownership

USER ${name_of_user} # Swaps context down to non-root privileges

# listen to this port
EXPOSE 2026 # Formalizes the port to expect traffic

# Line 1/5 of HEALTHCHECK: Determine spacing between health queries
# Line 2/5 of HEALTHCHECK: Cap maximum wait time per query
# Line 3/5 of HEALTHCHECK: Configure maximum fails before marking unhealthy
# Line 4/5 of HEALTHCHECK: Establish grace period for booting
# Line 5/5 of HEALTHCHECK: Specify curl-based validation ping
HEALTHCHECK --interval=25s \
            --timeout=15s \
            --retries=4 \
            --start-period=100s \
    CMD ["/bin/bash", "-c", "curl -f http://localhost:2026/health || exit 1"]

STOPSIGNAL SIGTERM # Instructs docker to forward SIGTERM upon shutdown

# unshakeable command
ENTRYPOINT ["python", "-u"] # Locks in python unbuffered as the primary execution wrapper

# shakeable command
CMD ["./python-code.py"] # Defines the default python script to trigger



# Production Variant

# --- Stage 1: Base Image Selection ---
# Use a lightweight, official Python 3.11 image to keep the final size small
FROM python:3.11-slim AS segment5_base_image_2

# --- Shell Configuration ---
# Change the default shell from 'sh' to 'bash' to support advanced bash-specific syntax
SHELL ["/bin/bash", "-c"]

# --- Metadata Labels ---
# Metadata for tracking ownership, environment context, and caching strategy
LABEL maintainer="jesfusionprox@gmail.com"
LABEL environment="Segment 5 Production Scenario"
LABEL cache_strategy="external"

# --- Working Directory ---
# Create and switch to the application directory inside the container
WORKDIR /segment_5_dir/app

# --- Build-Time Arguments (ARG) ---
# Variable to intentionally break the Docker cache layer when needed
ARG CACHE_BUST=default
# Define the system username, defaulted to "jesfusion-project-2"
ARG user_name="jesfusion-project-2"
# Arguments for tracking build timestamps and version control tracking (Git hashes)
ARG BUILD_DATE
ARG VCS_REF

# --- Runtime Environment Variables (ENV) ---
# PYTHONUNBUFFERED: Forces stdout/stderr to stream instantly (crucial for Docker logs)
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files to save disk space
# PIP_NO_CACHE_DIR: Disables pip caching to keep the image slim
# NAME_OF_USER: Dynamically pulls the value from the 'user_name' build argument
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_VERSION=0.0.2 \
    LOG_LEVEL=ERROR \
    NAME_OF_USER=${user_name}

# --- System Package Installation ---
# Print cache buster, update packages, install essential tools, and clean up temporary files in one layer
RUN echo "Build cache buster: ${CACHE_BUST}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Dependency Management ---
# Copy only the requirements file first to take advantage of Docker layer caching
COPY requirements.txt .

# Upgrade core Python packaging tools using executive format
RUN ["python", "-m", "pip", "install", "--upgrade", "pip", "setuptools", "wheel"]

# Install Python packages defined in the requirements file
RUN ["python", "-m", "pip", "install", "-r", "requirements.txt"]

# --- Security & Permissions ---
# Create a non-root system user with ID 1000 and grant them ownership of the app directory
RUN useradd -m -u 1000 ${user_name} && \
    chown -R 1000:1000 /segment_5_dir/app

# Copy the rest of the application source code and set ownership to the new non-root user
COPY --chown=1000:1000 . .

# Switch from root user to the non-root user for security compliance
USER ${user_name}

# --- Network Configuration ---
# Inform Docker that the container listens on port 2027 at runtime
EXPOSE 2027

# --- Health Monitoring ---
# Periodically check if the container application is responding correctly
HEALTHCHECK --interval=30s \
            --timeout=15s \
            --retries=5 \
            --start-interval=5s \
            --start-period=100s \
    CMD ["curl", "-f", "http://localhost:2027/health || exit 1"]

# --- Lifecycle Management ---
# Set the system signal used to gracefully shut down the container application
STOPSIGNAL SIGTERM

# --- Execution Command ---
# Run the application. 
CMD ["python", "-u", "./python-code.py"]

































FROM python:3.11-slim

LABEL the_maintainer="jessenwachukwu6@gmail.com"

LABEL the_segment="Segment 6: Layer Caching"

LABEL image_description="Data processor with caching optimization demonstrations"

WORKDIR "/segment_6_folder"


# ===================================== Layer 1: Least-changing - OS-level dependencies (apt packages) =====================================


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


    


# ===================================== Layer 2: Python infrastructure - pip, setuptools, wheel upgrades =====================================

RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel



# ===================================== Layer 3: Python dependencies - copy requirements.txt and install =====================================


COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt


# creating rootless user...

RUN useradd -m -u 1000 segment_6_user


# ===================================== Layer 4: Most-changing - application source code =====================================

COPY --chown=segment_6_user:segment_6_user src/ ./src/

COPY --chown=segment_6_user:segment_6_user tests/ ./tests/


# swtiching to normal user "segment_6_user" for subsequent commands...
USER segment_6_user



# running python code...
# ENTRYPOINT ["python", "-u", "src/python_code.py"]

CMD []

























# syntax=docker/dockerfile:1.4


FROM python:3.11-slim

LABEL segment="Segment 6: BuildKit Cache"

LABEL image_description="Data processor with BuildKit cache mounts"


WORKDIR /segment_6_buildkit

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl


# Layer 2: Python infrastructure
RUN --mount=type=cache,target=/root/.cache/pip,id=jesse-practice-cache \
    python -m pip install --upgrade pip setuptools wheel

# Layer 3: Python dependencies
COPY requirements.txt .

# Sharing the exact same custom id name!
RUN --mount=type=cache,target=/root/.cache/pip,id=jesse-practice-cache \
    python -m pip install -r requirements.txt



RUN useradd -m -u 1000 segment_6_buildkit_user


COPY --chown=segment_6_buildkit_user:segment_6_buildkit_user src/ ./src/

COPY --chown=segment_6_buildkit_user:segment_6_buildkit_user tests/ ./tests/


USER segment_6_buildkit_user


ENTRYPOINT ["python", "-u", "src/python_code.py"]


CMD []














