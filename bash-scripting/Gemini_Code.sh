#!/usr/bin/env bash
# ============================================================
# MODULE 2: Variables, Parameters & State Management
# MLOps Curriculum | Zero-to-Hero Bash Scripting
# ============================================================
set -euo pipefail


# ================================================================
echo -e "\n======================================================="
echo "   MODULE 2, SEGMENT 2.1: VARIABLE DECLARATION & ASSIGNMENT"
echo -e "=======================================================\n"
# ================================================================


# --- Demo 2.1.A: Basic Assignment & Naming Conventions ---
echo -e "\n--- Demo 2.1.A: Assignment Syntax & Naming Conventions ---\n"

# WHY: UPPERCASE for globally significant config. Lowercase for
# script-internal, short-lived variables. This is the industry
# convention and makes it immediately obvious what a variable's scope and importance is when reading someone else's pipeline script.
EXPERIMENT_NAME="resnet50_imagenet_run_042"
LEARNING_RATE="0.001"
BATCH_SIZE="256"
current_step=0

echo "[INFO] Global config (UPPERCASE):"
echo "       EXPERIMENT_NAME : $EXPERIMENT_NAME"
echo "       LEARNING_RATE   : $LEARNING_RATE"
echo "       BATCH_SIZE      : $BATCH_SIZE"
echo ""
echo "[INFO] Local counter (lowercase):"
echo "       current_step    : $current_step"

echo ""
echo "[INFO] Proving that variable names are CASE-SENSITIVE:"
# WHY: model and MODEL are two completely separate variables in bash.
# This trips up engineers coming from case-insensitive languages.
model="resnet50"
MODEL="VGG16"
echo "       model (lowercase) : $model"
echo "       MODEL (uppercase) : $MODEL"
echo "       These are TWO different variables."


# --- Demo 2.1.B: Read-Only Variables with `readonly` ---
echo -e "\n--- Demo 2.1.B: Immutable Config with 'readonly' ---\n"

# WHY: These are values that must NEVER drift during a pipeline run.
# readonly turns a variable into a const. Any reassignment attempt
# causes an immediate fatal error, preventing silent misconfiguration.
readonly MODEL_REGISTRY_URL="s3://ml-artifacts/registry/production"
readonly API_VERSION="v2"
readonly MAX_RETRY_ATTEMPTS=3

echo "[INFO] Read-only constants declared:"
echo "       MODEL_REGISTRY_URL  : $MODEL_REGISTRY_URL"
echo "       API_VERSION         : $API_VERSION"
echo "       MAX_RETRY_ATTEMPTS  : $MAX_RETRY_ATTEMPTS"

echo ""
echo "[INFO] Attempting to reassign a readonly variable (this MUST fail loudly):"
# WHY: We use a subshell here so the intentional error doesn't kill
# the parent script (set -e would exit on a non-zero status). The
# subshell absorbs the fatal error. || true keeps the parent alive
# so we can report the result and continue the demo.
(MODEL_REGISTRY_URL="s3://wrong-bucket/hacked") || true
echo "[CONFIRMED] Reassignment was BLOCKED. MODEL_REGISTRY_URL is still: $MODEL_REGISTRY_URL"
echo "[CONFIRMED] This is the correct behavior — silent misconfiguration is impossible."

echo ""
echo "[INFO] 'declare -r' is the equivalent alternate syntax:"
# WHY: declare -r and readonly are functionally identical.
# declare -r is more consistent with the broader declare family (-i, -a, -A).
declare -r INFERENCE_ENDPOINT="https://api.mlplatform.internal/v2/predict"
echo "       INFERENCE_ENDPOINT  : $INFERENCE_ENDPOINT"


# --- Demo 2.1.C: Integer Declaration with `declare -i` ---
echo -e "\n--- Demo 2.1.C: Integer Type Contracts with 'declare -i' ---\n"

# WHY: Without declare -i, ALL variables are strings. Arithmetic works but only explicitly. declare -i creates a TYPE CONTRACT — the shell
# evaluates every assignment as arithmetic automatically, and rejects
# non-numeric strings by silently coercing them to 0.
declare -i pipeline_stage=0
declare -i gpu_index=0
declare -i retry_count=0

echo "[INFO] Integer variables declared (all start at 0):"
echo "       pipeline_stage : $pipeline_stage"
echo "       gpu_index      : $gpu_index"
echo "       retry_count    : $retry_count"

echo ""
echo "[INFO] Incrementing with direct arithmetic assignment (no \$(()) needed):"
# WHY: Because pipeline_stage is declare -i, the assignment
# `pipeline_stage=pipeline_stage+1` is treated as arithmetic
# automatically. Without declare -i, this would produce the
# string "0+1" instead of the integer 1.
pipeline_stage=$pipeline_stage+1
echo "       After pipeline_stage=pipeline_stage+1 : $pipeline_stage"

pipeline_stage=pipeline_stage+1
echo "       After pipeline_stage=pipeline_stage+1 : $pipeline_stage"

pipeline_stage=pipeline_stage+1
echo "       After pipeline_stage=pipeline_stage+1 : $pipeline_stage"

echo ""
echo "[INFO] Simulating GPU index assignment in a multi-GPU setup:"
gpu_index=3
echo "       Assigned to GPU index : $gpu_index"

echo ""
echo "[INFO] Proving type enforcement — assigning a non-integer string:"
# WHY: This demonstrates the safety net. If a config file accidentally
# passes "two" instead of "2", declare -i coerces it to 0 rather than
# letting the string "two" corrupt downstream arithmetic.
gpu_index="not_a_number"
echo "       After gpu_index='not_a_number' : $gpu_index  <-- Coerced to 0. Type contract enforced."

echo ""
echo "[INFO] Comparison — the SAME operation WITHOUT declare -i:"
# WHY: This shows the exact bug declare -i prevents. Without it,
# concatenation happens instead of addition — a silent, devastating
# failure in a pipeline step counter.
plain_var=0
plain_var=$plain_var+1
echo "       plain_var after plain_var=\$plain_var+1 : $plain_var  <-- String concat! '0+1', not 1."
echo "[WARNING] This is the bug declare -i prevents in your step counters."


# ================================================================
echo -e "\n======================================================="
echo "   MODULE 2, SEGMENT 2.2: POSITIONAL PARAMETERS & ARGUMENTS"
echo -e "=======================================================\n"
# ================================================================


# --- Demo 2.2.A: Accessing Positional Parameters ---
echo -e "\n--- Demo 2.2.A: Accessing Arguments & Special Variables ---\n"

# WHY: We define a function here to simulate receiving arguments,
# since the parent script itself may not have been called with args.
# Functions use the SAME $1, $2, $# mechanics as scripts — identical behavior.
demonstrate_positional_params() {
    echo "[INFO] Inside function — simulating: train.sh resnet50 0.001 100 /data/imagenet"
    echo ""

    # WHY: $0 in a function returns the FUNCTION NAME, not the script name.
    # In a real script (not a function), $0 would be the script's filename.
    echo "       \$0 (script/function name) : $0"

    # WHY: For args beyond $9, curly braces are MANDATORY.
    # Without them, $10 is parsed as ${1} followed by literal "0".
    echo "       \$1 (model architecture)   : $1"
    echo "       \$2 (learning rate)        : $2"
    echo "       \$3 (max epochs)           : $3"
    echo "       \$4 (dataset path)         : $4"
    echo ""
    echo "       \$# (total arg count)      : $#"
    echo "       \$? (last exit code)       : $?  <-- 0 means the last command succeeded"

    # WHY: $$ gives the PID of the current shell. Critical for creating
    # unique temp filenames in parallel jobs to prevent collisions.
    # e.g., /tmp/job_output_$$.log is unique per process.
    echo "       \$\$ (current shell PID)   : $$  <-- Use for unique temp file names"
}

# Call the function with simulated training arguments
demonstrate_positional_params "resnet50" "0.001" "100" "/data/imagenet"


# --- Demo 2.2.B: "$@" vs "$*" — The Critical Distinction ---
echo -e "\n--- Demo 2.2.B: \"\$@\" vs \"\$*\" — Array Preservation ---\n"

# WHY: We test with a path that contains a SPACE on purpose.
# This is the exact scenario that exposes the difference between
# "$@" and "$*" — a path with spaces is the real-world stress test.
echo "[INFO] Test arguments include a PATH WITH A SPACE to stress-test both operators."
echo ""

show_dollar_at() {
    echo "  [USING \"\$@\"] Received $# argument(s):"
    # WHY: "$@" expands each original argument as a separate, individually
    # quoted word. The path with a space arrives as ONE intact argument.
    # This is ALWAYS what you want when forwarding args to another command.
    local i=1
    for arg in "$@"; do
        echo "    Arg $i: [$arg]"
        i=$((i + 1))
    done
}

show_dollar_star() {
    echo "  [USING \"\$*\"] Received $# argument(s):"
    # WHY: "$*" joins ALL arguments into ONE single string separated by
    # the first char of IFS (space by default). The path with a space
    # gets merged into the giant string and cannot be recovered intact.
    local i=1
    for arg in "$*"; do
        echo "    Arg $i: [$arg]"
        i=$((i + 1))
    done
}

show_dollar_at_unquoted() {
    echo "  [USING \$@ UNQUOTED] Received $# argument(s):"
    # WHY: Without quotes, $@ word-splits just like $*. The space inside
    # the path breaks it into two separate arguments. This is wrong.
    local i=1
    for arg in $@; do
        echo "    Arg $i: [$arg]"
        i=$((i + 1))
    done
}

echo "[TEST] Passing 3 args: 'resnet50'  '0.001'  '/data/my datasets/imagenet'"
echo "       (Note: the 3rd argument contains a SPACE inside it)"
echo ""

show_dollar_at      "resnet50" "0.001" "/data/my datasets/imagenet"
echo ""
show_dollar_star    "resnet50" "0.001" "/data/my datasets/imagenet"
echo ""
show_dollar_at_unquoted "resnet50" "0.001" "/data/my datasets/imagenet"

echo ""
echo "[VERDICT] \"\$@\" : 3 args in, 3 args out. Path with space PRESERVED. USE THIS."
echo "[VERDICT] \"\$*\" : 3 args in, 1 giant string out. Path merged. RARELY correct."
echo "[VERDICT] \$@   : 3 args in, 4 args out. Space SPLIT the path. NEVER use unquoted."


# --- Demo 2.2.C: Shifting Parameters for Argument Parsing ---
echo -e "\n--- Demo 2.2.C: 'shift' and the --flag value Parsing Loop ---\n"

# WHY: Real production scripts accept named flags, not fixed positions.
# Fixed positions break the moment someone reorders arguments.
# The shift-based while loop is the professional pattern for parsing
# --flag value pairs in any production MLOps CLI script.
parse_training_args() {
    # WHY: We use local variables so this function doesn't pollute
    # the parent script's namespace with its parsed values.
    local model=""
    local lr=""
    local epochs=""
    local data_path=""

    echo "[INFO] Raw arguments received by parser ($# total):"
    # WHY: We use "$@" here to print args safely before consuming them.
    local i=1
    for arg in "$@"; do
        echo "       Arg $i: $arg"
        i=$((i+1))
    done
    echo ""

    # WHY: $# -gt 0 is the loop guard — keep going while args remain.
    # Each iteration inspects $1, then calls shift to discard it.
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --model)
                # WHY: $2 is the VALUE that follows the --flag.
                # shift 2 consumes BOTH the flag ($1) and its value ($2)
                # in one move, advancing the queue by 2 positions.
                model="$2"
                echo "  [PARSED] --model   → $model"
                shift 2
                ;;
            --lr)
                lr="$2"
                echo "  [PARSED] --lr      → $lr"
                shift 2
                ;;
            --epochs)
                epochs="$2"
                echo "  [PARSED] --epochs  → $epochs"
                shift 2
                ;;
            --data)
                data_path="$2"
                echo "  [PARSED] --data    → $data_path"
                shift 2
                ;;
            *)
                # WHY: The wildcard catches any unrecognized flags.
                # Fail fast on unknown args — silent ignoring hides typos
                # like --learing-rate that would silently use defaults.
                echo "[ERROR] Unknown argument: '$1'. Aborting."
                return 1
                ;;
        esac
    done

    echo ""
    echo "[INFO] Final parsed configuration:"
    echo "       Model     : $model"
    echo "       LR        : $lr"
    echo "       Epochs    : $epochs"
    echo "       Data Path : $data_path"
}

echo "[INFO] Calling parser with: --model resnet50 --lr 0.001 --epochs 100 --data /data/imagenet"
parse_training_args --model "resnet50" --lr "0.001" --epochs "100" --data "/data/imagenet"

echo ""
echo "[INFO] Demonstrating 'shift N' to skip multiple args at once:"
# WHY: Sometimes you process the first N args positionally and then
# want to shift past them all to get to the flags. shift N does this
# in one operation instead of N separate shift calls.
demonstrate_shift_n() {
    echo "  Before shift 2: \$1=$1  \$2=$2  \$3=$3  \$4=$4  (total: $#)"
    shift 2
    echo "  After  shift 2: \$1=$1  \$2=$2  (total: $#)  -- first 2 consumed"
}
demonstrate_shift_n "preprocess" "validate" "--config" "prod.yaml"


# ================================================================
echo -e "\n======================================================="
echo "   MODULE 2, SEGMENT 2.3: ENVIRONMENT & EXPORT SYNTAX"
echo -e "=======================================================\n"
# ================================================================


# --- Demo 2.3.A: export — Making Variables Visible to Child Processes ---
echo -e "\n--- Demo 2.3.A: 'export' — Broadcasting to Child Processes ---\n"

# WHY: Variables declared without export are LOCAL to this shell.
# Child processes (subshells, scripts, python, docker) CANNOT see them.
LOCAL_SECRET="i_am_invisible_to_children"
export WANDB_PROJECT="mlops-curriculum"
export EXPERIMENT_ID="exp_$(date +%Y%m%d_%H%M%S)"
export NUM_WORKERS="4"

echo "[INFO] LOCAL_SECRET (not exported)   : $LOCAL_SECRET"
echo "[INFO] WANDB_PROJECT (exported)      : $WANDB_PROJECT"
echo "[INFO] EXPERIMENT_ID (exported)      : $EXPERIMENT_ID"
echo "[INFO] NUM_WORKERS (exported)        : $NUM_WORKERS"

echo ""
echo "[INFO] Launching a child subshell to prove export visibility:"
bash -c '
    echo "  [CHILD SHELL] Can I see WANDB_PROJECT?   --> ${WANDB_PROJECT:-NOT VISIBLE}"
    echo "  [CHILD SHELL] Can I see EXPERIMENT_ID?   --> ${EXPERIMENT_ID:-NOT VISIBLE}"
    echo "  [CHILD SHELL] Can I see NUM_WORKERS?     --> ${NUM_WORKERS:-NOT VISIBLE}"
    echo "  [CHILD SHELL] Can I see LOCAL_SECRET?    --> ${LOCAL_SECRET:-NOT VISIBLE}"
'
# WHY: ${VAR:-DEFAULT} is a parameter expansion that returns DEFAULT
# if VAR is unset or empty. We use "NOT VISIBLE" as the default here
# to make the visibility test output self-documenting.
# We cover parameter expansion fully in Module 7.

echo ""
echo "[INFO] Proving export does NOT propagate UPWARD (parent ← child):"
# WHY: Child processes can NEVER modify their parent's environment.
# A child exporting a variable only affects that child and ITS children.
# This is fundamental Unix process isolation. Understanding this prevents
# the classic bug of trying to pass config back to a parent via export.
bash -c 'export CHILD_ONLY_VAR="i_tried_to_reach_parent"'
echo "  [PARENT] CHILD_ONLY_VAR after child ran: '${CHILD_ONLY_VAR:-NOT SET IN PARENT}'"
echo "  [CONFIRMED] Child's export cannot reach the parent. One-way broadcast only."


# --- Demo 2.3.B: Inline Environment Assignment ---
echo -e "\n--- Demo 2.3.B: Inline Assignment — Surgical Single-Command Scope ---\n"

echo "[INFO] Current shell's CUDA_VISIBLE_DEVICES (before inline assignment):"
echo "       ${CUDA_VISIBLE_DEVICES:-<not set in current shell>}"

echo ""
echo "[INFO] Running a command with GPU=0 scoped ONLY to that command:"
# WHY: VAR=value placed IMMEDIATELY before a command (no semicolon, no &&)
# sets that variable ONLY for the duration of that single command.
# It does NOT touch the current shell's environment at all.
# This is the clean pattern for A/B GPU experiments in a single script.
CUDA_VISIBLE_DEVICES=0 bash -c 'echo "  [SCOPED CMD] CUDA_VISIBLE_DEVICES inside: $CUDA_VISIBLE_DEVICES"'

echo ""
echo "[INFO] Proving the current shell was NOT affected:"
echo "       CUDA_VISIBLE_DEVICES after scoped command: '${CUDA_VISIBLE_DEVICES:-<still not set>}'"

echo ""
echo "[INFO] Running SAME script with DIFFERENT GPU assignments — A/B pattern:"
# WHY: This is the core MLOps parallel experiment pattern. Same script,
# different env vars injected per-invocation, no global state pollution.
CUDA_VISIBLE_DEVICES=0 bash -c 'echo "  [EXP A] Running on GPU: $CUDA_VISIBLE_DEVICES — Model: resnet50"'
CUDA_VISIBLE_DEVICES=1 bash -c 'echo "  [EXP B] Running on GPU: $CUDA_VISIBLE_DEVICES — Model: vgg16"'
CUDA_VISIBLE_DEVICES=2 bash -c 'echo "  [EXP C] Running on GPU: $CUDA_VISIBLE_DEVICES — Model: efficientnet"'

echo ""
echo "[INFO] PYTHONPATH inline injection for a custom module path:"
# WHY: Avoids permanently modifying PYTHONPATH for one-off runs.
# Each inference call uses its own isolated module resolution path.
PYTHONPATH="/custom/libs/v2:/shared/utils" bash -c \
    'echo "  [INFERENCE] PYTHONPATH scoped to: $PYTHONPATH"'
echo "  [PARENT] PYTHONPATH after scoped run: '${PYTHONPATH:-<not set in parent>}'"


# --- Demo 2.3.C: unset — Credential Lifecycle & Hygiene ---
echo -e "\n--- Demo 2.3.C: 'unset' — Credential Destruction & Pipeline Hygiene ---\n"

echo "[INFO] Simulating the FULL secure credential lifecycle in a pipeline:"
echo ""

# PHASE 1: Load credentials
# WHY: In production, this would be a vault lookup. Here we simulate
# it with a direct assignment. The key architectural point is that
# credentials are loaded ONLY when needed, not at the top of the script.
echo "  [PHASE 1: LOAD]   Loading credentials for DB migration step..."
export DB_HOST="prod-postgres.internal"
export DB_PASSWORD="sup3r_s3cr3t_p@ssw0rd"
export AWS_SECRET_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE"
echo "  [PHASE 1: LOAD]   DB_HOST exported              : $DB_HOST"
echo "  [PHASE 1: LOAD]   DB_PASSWORD exported          : $DB_PASSWORD"
echo "  [PHASE 1: LOAD]   AWS_SECRET_ACCESS_KEY exported: $AWS_SECRET_ACCESS_KEY"

echo ""
# PHASE 2: Use credentials (simulated DB migration call)
echo "  [PHASE 2: USE]    Running DB migration (child process can see credentials)..."
bash -c 'echo "  [CHILD] I can see DB_PASSWORD: $DB_PASSWORD — Running migration..."'

echo ""
# PHASE 3: Destroy credentials immediately after use
# WHY: unset REMOVES the variable entirely — not just empties it.
# An empty string "" can still leak. unset makes it non-existent.
# Under set -u, any accidental reference to it AFTER this point
# will CRASH the script with "unbound variable" — a safety net.
echo "  [PHASE 3: DESTROY] Calling unset on all credentials..."
unset DB_PASSWORD
unset AWS_SECRET_ACCESS_KEY
echo "  [PHASE 3: DESTROY] Credentials destroyed."

echo ""
# PHASE 4: Verify destruction
echo "  [PHASE 4: VERIFY] Confirming credentials are gone from environment:"
# WHY: We deliberately turn off -u here with `set +u` so the script
# doesn't crash on the unset variable — we WANT to inspect it.
# We turn -u back on immediately after. This is the controlled way
# to inspect potentially-unset variables without killing the script.
set +u
echo "  DB_PASSWORD after unset          : '${DB_PASSWORD:-<DESTROYED — variable does not exist>}'"
echo "  AWS_SECRET_ACCESS_KEY after unset: '${AWS_SECRET_ACCESS_KEY:-<DESTROYED — variable does not exist>}'"
set -u

echo ""
# PHASE 5: Prove child processes can no longer see destroyed credentials
echo "  [PHASE 5: CONFIRM] Launching next pipeline stage — credential blast radius = ZERO:"
bash -c '
    set +u
    echo "  [NEXT STAGE CHILD] DB_PASSWORD available? --> ${DB_PASSWORD:-GONE. Cannot leak.}"
    echo "  [NEXT STAGE CHILD] AWS key available?     --> ${AWS_SECRET_ACCESS_KEY:-GONE. Cannot leak.}"
'

echo ""
echo "[INFO] Demonstrating 'export -n' — demote without deletion:"
# WHY: export -n removes a variable FROM the environment (child processes
# can no longer see it) but keeps its VALUE in the current shell.
# Use this when you need the value locally but want to stop it from
# propagating to new child processes.
export TEMP_CONFIG="batch_size=256,lr=0.001"
echo "  TEMP_CONFIG before export -n   : $TEMP_CONFIG (exported — children can see it)"
export -n TEMP_CONFIG
echo "  TEMP_CONFIG after  export -n   : $TEMP_CONFIG (local only — children cannot see it)"
bash -c 'set +u; echo "  [CHILD] TEMP_CONFIG visible? --> ${TEMP_CONFIG:-NOT VISIBLE TO CHILD}"'
echo "  [PARENT] TEMP_CONFIG still accessible locally: $TEMP_CONFIG"


# ================================================================
echo -e "\n======================================================="
echo "   MODULE 2: ALL SEGMENTS COMPLETE"
echo "======================================================="
echo ""
echo "  SEGMENT 2.1 COVERED: Assignment syntax, readonly immutable"
echo "                        constants, declare -i integer contracts."
echo ""
echo "  SEGMENT 2.2 COVERED: Positional parameters \$1..\${N},"
echo "                        \"\$@\" vs \"\$*\" array preservation,"
echo "                        shift-based --flag parsing loops."
echo ""
echo "  SEGMENT 2.3 COVERED: export for child process visibility,"
echo "                        inline VAR=value scoped assignment,"
echo "                        unset for credential lifecycle hygiene."
echo ""
echo "  NOTE: 2 Batches (6 Segments) complete."
echo "        ASSESSMENT INCOMING on next prompt."
echo -e "=======================================================\n"