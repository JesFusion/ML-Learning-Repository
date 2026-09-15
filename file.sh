#!/usr/bin/env bash

# 1. Catch the Host string (H) passed from Script A
H="$1"

if [ -z "$H" ]; then
  echo "[Docker Error] No file path was provided."
  exit 1
fi

# 2. Translate Host path (H) to Container path (C)
# Using bash's built-in string replacement: ${variable/search/replace}
HOST_PREFIX="/home/jesfusion/windows/Users/worke/Documents/Bridge-Folder"
CONTAINER_PREFIX="/windows-work-folder"

C="${H/$HOST_PREFIX/$CONTAINER_PREFIX}"

# 3. Verify the file actually exists inside the container before trying to run it
if [ ! -f "$C" ]; then
  echo "[Docker Error] File does not exist at container path: $C"
  exit 1
fi

# Extract just the filename to make pattern matching easier
FILENAME=$(basename "$C")

# 4. Route execution based on file type and naming conventions
if [[ "$FILENAME" == test_*.py || "$FILENAME" == *_test.py ]]; then
    # Pytest (Must be checked BEFORE standard Python)
    source /container-end/d_venv/devops-venv/bin/activate
    
    pytest "$C"

elif [[ "$C" == *.py ]]; then
    # Standard Python
    /container-end/d_venv/devops-venv/bin/python3 "$C"

elif [[ "$C" == *.go ]]; then
    # Golang
    go run "$C"

elif [[ "$C" == *.cpp ]]; then
    # C++ (Compiles to a temporary binary, runs it, then cleans up)
    g++ "$C" -o /tmp/cpp_out && /tmp/cpp_out
    rm -f /tmp/cpp_out

elif [[ "$C" == *.sh ]]; then
    # Bash / Shell scripts
    bash "$C"

else
    # Fallback for unrecognized files
    echo "[Docker Warning] No execution rule defined for this file type."
    echo "Displaying file contents instead:"
    echo "---"
    cat "$C"
fi


echo -e "\n\n\n\n\n\n"
 

: << 'COMMENT'


# --- Additional DevOps / Tech Stack Files ---

elif [[ "$C" == *.js ]]; then
    # JavaScript / Node.js
    node "$C"

elif [[ "$C" == *.ts ]]; then
    # TypeScript (requires ts-node installed globally in your container)
    ts-node "$C"

elif [[ "$C" == *.rs ]]; then
    # Rust (Compiles to temp binary, runs, cleans up)
    rustc "$C" -o /tmp/rust_out && /tmp/rust_out
    rm -f /tmp/rust_out

elif [[ "$C" == *.yml || "$C" == *.yaml ]]; then
    # YAML (Could be Ansible, Kubernetes, or CI/CD pipelines)
    # A safe default for YAML in a dev environment is to lint it
    echo "[Docker] YAML detected. Running yamllint..."
    yamllint "$C" || echo "Note: yamllint may not be installed."

elif [[ "$FILENAME" == *Dockerfile* ]]; then
    # Dockerfiles
    echo "[Docker] Dockerfile detected. Running hadolint..."
    hadolint "$C" || echo "Note: hadolint may not be installed."

elif [[ "$C" == *.tf ]]; then
    # Terraform
    echo "[Docker] Terraform file detected. Formatting and validating..."
    DIRNAME=$(dirname "$C")
    terraform fmt "$C"
    terraform validate "$DIRNAME"

elif [[ "$C" == *.rb ]]; then
    # Ruby (Often used in Chef / Puppet DevOps tooling)
    ruby "$C"


COMMENT
