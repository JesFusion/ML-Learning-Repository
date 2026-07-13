#!/usr/bin/env bash
set -euo pipefail


# ===================================== SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES =====================================

python3="/container-end/d_venv/devops-venv/bin/python3"

segment_7_folder="/container-end/docker-practice/segment-7"

if [ -d "$segment_7_folder" ]; then
    rm -rf "$segment_7_folder"
    mkdir -p "$segment_7_folder"
else
    mkdir -p "$segment_7_folder"
fi


segment_7_items="/windows-work-folder/ML-Learning-Repository/Docker/Docker-Practice"


cd "$segment_7_folder" && mkdir src models tests


the_info_log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

export MODEL_PATH="${segment_7_folder}/models"


cp "${segment_7_items}/python-code.py" "${segment_7_folder}/src"

# "$python3" "${segment_7_items}/python-code.py"

echo "1) Model training script created at ${segment_7_folder}/src/train_model.py" && sleep 0.8


cp "${segment_7_items}/python-code-2.py" "${segment_7_folder}/src"

# "$python3" "${segment_7_items}/python-code-2.py"

echo "2) Prediction script created at ${segment_7_folder}/src/predict.py" && sleep 0.8


cp "${segment_7_items}/Dockerfile" "${segment_7_folder}"



echo "3) Standard Dockerfile (multi-stage) created" && sleep 0.8




# /home/jesfusion/.actions/script_runner.sh




echo  "Jesse is cool"







echo -e "\n\n\n" && pwd && tree













