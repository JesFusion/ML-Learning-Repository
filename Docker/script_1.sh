#!/bin/bash

set -e

file_for_logs="../../logs/print.log"


name_of_logger="Docker Learning"


LOG_TO_FILE() {
    local name_of_level="$1"

    shift

    local the_message="$*"

    printf "%s\n" "$the_message"


    local caller_file="${BASH_SOURCE[2]:-${BASH_SOURCE[1]:-$0}}"

    local name_of_file
    
    name_of_file=$(basename "$caller_file")

    local line_number="${BASH_LINENO[1]:-0}"

    local asctime
    
    asctime=$(date "+%Y/%m/%d, %I:%M %p")

    printf "%s ::: %s ::: %s ::: [%s: line %s]\n%s\n\n" \
        "$asctime" "$name_of_logger" "$name_of_level" "$name_of_file" "$line_number" "$the_message" > "$file_for_logs"
}


debug() {
    LOG_TO_FILE "DEBUG" "$@"
}

info() {
    LOG_TO_FILE "INFO" "$@"
}

warning() {
    LOG_TO_FILE "WARNING" "$@"
}

error() {
    LOG_TO_FILE "ERROR" "$@"
}

critical() {
    LOG_TO_FILE "CRITICAL" "$@"
}






# ===================================== SEGMENT 2.3 — MANAGING PYTHON DEPENDENCIES =====================================


# requirements.txt

files_path="./Docker/segments_2_3"

mkdir -p $files_path

cd $files_path || exit 1

info "Creating requirements.txt and main.py..." && sleep 1

cat <<EOF > "requirements.txt"
numpy==1.26.4
pandas==2.2.0
scikit-learn==1.4.0
EOF




cat <<EOF > "script.py"
import numpy as np
import pandas as pd

# Creating a 100x5 array of random numbers
data = np.random.rand(100, 5)

# Converting to a DataFrame with specific column names
df = pd.DataFrame(data, columns=['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'])

print(df.head())
EOF



cat <<EOF > Dockerfile
FROM python:3.10-slim

WORKDIR /the_files

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


COPY script.py .

CMD ["python", "script.py"]

EOF


info "Building Image from requirements.txt..." && sleep 1


docker build -t 



path=$(pwd)

echo "Path is $path"















info "Removing requirements.txt and main.py..." && sleep 1

cd .. && rm -rf segments_2_3

























































