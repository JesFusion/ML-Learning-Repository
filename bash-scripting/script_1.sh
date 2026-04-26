#!/usr/bin/env bash


# set -euo pipefail
# set -euxo pipefail

clear

echo -e "===================================== MODULE 2, SEGMENT 2.1: VARIABLE DECLARATION & ASSIGNMENT =====================================\n\n"



NAME_OF_EXPERIMENT='resnet50_imagenet_run_042'

LEARNING_RATE='0.001'
declare -i BATCH_SIZE=256
declare -i step=0


cat << EOF
Global Config variables (Uppercase):
1. Experiment name: ${NAME_OF_EXPERIMENT}

2. Learning Rate: ${LEARNING_RATE}

3. Batch Size: ${BATCH_SIZE}

Local counter variables (Lowercase):
4. Current Step: ${step}
EOF



aimodel='resnet50'

AIMODEL='VGG16'

cat << EOF

1. aimodel (Lowercase): ${aimodel}

2. AIMODEL (Uppercase): ${AIMODEL}
EOF




readonly regUrl='s3://ml-artifacts/registry/production'

readonly version_of_api='v2'

readonly maximum_attempts=4



cat << EOF

Read-Only Constants Declared:

1. Model Registry URL: ${regUrl}

2. API Version: ${version_of_api}

3. Maximum Retry Attempts: ${maximum_attempts}


Attempting to change a Read-only variable...

EOF



(regUrl='Jesse') || true

echo -e "\nIs 'regUrl' variable still the same? $([[ "$regUrl" == 's3://ml-artifacts/registry/production' ]] && echo "True" || echo "False")"


# declare -r is the twin to readonly

declare -r name='Jesse' # you can't reassign this variable


# declare -i (for integers)

declare -i jesse_age=20
declare -i DOB=2006
declare -i DDOB=1970
declare -i age_difference=$DOB-$DDOB


cat << EOF

My name is $name. I am $jesse_age years old. I am $age_difference years younger than my dad

EOF



DOB="not a number"

# since we initially declared DOB as an integer, reassigning it to a string would force it to it's original value, which is 2006
echo "$DOB" # should be 2006
























































