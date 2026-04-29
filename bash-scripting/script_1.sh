#!/usr/bin/env bash

#... =============================================================================
#... BASH ZERO-TO-HERO | MASTER TRAINING SCRIPT
#... Modules 1–5 | Segments 1.1 → 5.2
#... Target : Toptal Top 3% | Production-Ready Systems Engineer
#... Author : Mike (Principal DevOps Architect) | Student: Jesse
#... =============================================================================
#... STRICT MODE — non-negotiable on every production script you ever write.
#...   -e  : exit immediately if any command exits non-zero
#...   -u  : treat reference to an unset variable as a fatal error
#...   -o pipefail : pipeline exit code = last non-zero exit (not just last cmd)
# set -euo pipefail
set -euo pipefail


#... =============================================================================
#... SANDBOX CONSTRAINT
#... [WHAT]: Create an isolated temporary workspace for ALL script operations.
#... [WHY] : Jesse is learning. We NEVER touch live home/root directories.
#...         mktemp --directory atomically creates a unique temp dir — no race conditions, no predictable names, no collisions.
#... [HOW] : mktemp returns the path → stored in WORKSPACE. The trap fires on
#...         EXIT (normal or error), SIGINT (Ctrl+C), SIGTERM — never litters /tmp.
#... [WATCH OUT]: rm -rf is permanently destructive. Safe here ONLY because
#...              WORKSPACE is a freshly-created mktemp path we own.
#... =============================================================================
# WORKSPACE=$(mktemp --directory)
# trap 'echo ""; echo "[CLEANUP] Removing sandbox: $WORKSPACE"; rm -rf "$WORKSPACE"' EXIT
# cd "$WORKSPACE"

megabatch_workspace=$(mktemp --directory)

trap 'echo ""; echo "Removing sandbox: $megabatch_workspace"; rm -rf "$megabatch_workspace"' EXIT

cd "$megabatch_workspace"

#... =============================================================================
#... COLOUR HELPERS — pure Bash builtins, zero subshells, zero external commands.
#... ANSI-C quoting ($'...') embeds ESC (\033) directly — demonstrates [1.1.M].
#... =============================================================================
# RED=$'\033[0;31m'
# GREEN=$'\033[0;32m'
# YELLOW=$'\033[1;33m'
# CYAN=$'\033[0;36m'
# BOLD=$'\033[1m'
# RESET=$'\033[0m'

red_color=$'\033[0;31m'
green_color=$'\033[0;32m'
yellow_color=$'\033[1;33m'
cyan_color=$'\033[0;36m'
bold_color=$'\033[1m'
reset_color=$'\033[0m'


#... [WHAT]: Structured log functions. Writing to >&2 keeps logs off stdout,
#...         honouring Unix separation of data from diagnostics.
# log_info()  { echo "${GREEN}[INFO  $(date '+%H:%M:%S')]${RESET} $*" >&2; }
# log_warn()  { echo "${YELLOW}[WARN  $(date '+%H:%M:%S')]${RESET} $*" >&2; }
# log_error() { echo "${RED}[ERROR $(date '+%H:%M:%S')]${RESET} $*" >&2; }

logging_info(){
  echo -e "${green_color}Line ${BASH_LINENO[0]}, \nINFO Level,\n${reset_color}$*" >&2;
}


logging_warning(){
  echo -e "${yellow_color}Line ${BASH_LINENO[0]}, \nWARNING Level,\n${reset_color}$*" >&2;
}

logging_warning(){
  echo -e "${red_color}Line ${BASH_LINENO[0]},\nERROR Level,\n${reset_color}$*" >&2;
}



#... Section/pillar headers for visual separation between segments.
# section() {
  # printf "\n${BOLD}${CYAN}%s\n  %s\n%s${RESET}\n\n" \
    # "================================================================================" \
    # "$*" \
    # "================================================================================"
# }

section_seperator() {
  printf "\n${BOLD}${CYAN}%s\n  %s\n%s${RESET}\n\n" \
    "================================================================================" \
    "$*" \
    "================================================================================"
}



# pillar() { printf "\n${YELLOW}--- PILLAR %s ---%s\n" "$*" "${RESET}"; }

pillar_marker() { printf "\n${YELLOW}--- PILLAR %s ---%s\n" "$*" "${RESET}"; }

# log_info "Sandbox: $WORKSPACE | Bash: $BASH_VERSION | PID: $$"

logging_info "Sandbox: $megabatch_workspace | Bash: $BASH_VERSION | PID: $$"

#...##############################################################################
#... SEGMENT 1.1 | THE UNIX MENTAL MODEL
#...##############################################################################






# ===================================== SEGMENT 1.1 | THE UNIX MENTAL MODEL =====================================






# section "SEGMENT 1.1 | THE UNIX MENTAL MODEL"


# pillar "1 | BASIC — Everything Is A File"
#... [WHAT]: Read live process state from /proc — the kernel's virtual filesystem.
#... [WHY] : Every tool that reads process info (ps, top, lsof) ultimately reads /proc. Knowing this makes you a better debugger.
#... [HOW] : $$ is the shell's PID. /proc/$$/status is synthesised on-the-fly
#...         by the kernel when opened — no data is stored on disk.
# echo "[1.1.B] Process status from /proc/\$\$/status (first 4 lines):"
# grep --max-count=4 "" /proc/$$/status

# echo ""
# echo "[1.1.C] /dev/null — the data black hole:"
# echo "This goes nowhere" > /dev/null
# echo "  Write to /dev/null exit code: $?   (always 0 — write succeeded)"

# pillar "2 | POWER — Process Tree Inspection"
#... [WHAT]: Show the parent-child hierarchy rooted at our shell [1.1.F/G].
#... [WHY] : Orphaned processes and zombie reaping are real operational problems.
#...         Knowing the tree is how you diagnose them without external tooling.
#... [WATCH OUT]: --forest is GNU ps only. On macOS: ps aux | grep $$
# echo "[1.1.G] Process tree (our shell and immediate parent):"
# ps --pid $$ --ppid $$ --format pid,ppid,comm --no-headers 2>/dev/null || \
  # ps -p $$ -o pid,ppid,comm --no-header

# echo ""
# echo "[1.1.H] fork()+execve() cost — every \$() spawns a child process:"
# child_pid=$(bash -c 'echo $BASHPID')   # fork() + execve() = new process
# echo "  Parent PID ($$): $$ | Child reported: $child_pid"

# pillar "3 | PRECISION — Builtin vs. External Command"
#... [WHAT]: Prove builtins have zero fork overhead [1.1.M].
#... [WHY] : In a loop of 10,000 iterations, ${var^^} vs echo|tr is measurable
#...         in seconds — a Toptal production optimization question.
# echo "[1.1.M] type -a reveals builtin vs. external:"
# type -a echo    # Both builtin AND /bin/echo
# type -a printf  # Builtin only — zero fork cost
# type -a cat     # External only — fork+execve every call
#... [WHAT ELSE]: 'builtin echo' forces the builtin; 'command echo' forces external.

# pillar "4 | DEVOPS — /proc for Live Process Forensics"
#... [WHAT]: Read a process's own command-line from /proc without any tools.
#... [WHY] : In production incident response you often can't install tools.
#...         /proc is always available. It is the ground truth.
#... [HOW] : /proc/$$/cmdline is NUL-byte delimited. tr replaces NUL with space.
# echo "[1.1.B] Command line from /proc (NUL → space):"
# tr '\0' ' ' < /proc/$$/cmdline; echo ""
# echo "[1.1.B] Open file descriptor count for this shell:"
# ls /proc/$$/fd | wc --lines


#...##############################################################################
#... SEGMENT 1.2 | TERMINAL EMULATORS, TTYs, AND THE SHELL
#...##############################################################################
# section "SEGMENT 1.2 | TERMINAL EMULATORS, TTYs, AND THE SHELL"

# pillar "1 | BASIC — Detecting the TTY and Shell Type"
#... [WHAT]: Show which TTY device is connected and detect interactivity [1.2.E].
#... [WHY] : Prompting for input in a non-interactive script (CI/CD) hangs
#...         the pipeline forever. Always check before prompting.
# echo "[1.2.E] Terminal device connected to stdin:"
# tty 2>/dev/null || echo "  (not a tty — we are non-interactive)"

# echo ""
# echo "[1.2.O] Shell nesting depth (SHLVL): $SHLVL"
# echo "[2.5.L] Active shell option flags (\$-): $-"

# pillar "2 | POWER — Shell Type Detection"
#... [WHAT]: Programmatically detect login vs interactive vs non-interactive [1.2.H-J].
#... [WHY] : Library scripts sourced in multiple contexts need to know which
#...         context they're in to decide whether to source .bashrc or set PS1.
# if [[ "$-" == *i* ]]; then
  # echo "[1.2.I] Shell is INTERACTIVE — alias and .bashrc functions are available"
# else
  # echo "[1.2.J] Shell is NON-INTERACTIVE — do NOT rely on aliases or .bashrc"
# fi
# echo "  SHLVL=$SHLVL — $(( SHLVL > 2 )) && echo 'nested shell (tmux/screen?)' || echo 'normal depth'"

# pillar "3 | PRECISION — stdout TTY Awareness"
#... [WHAT]: Check if stdout is a real PTY before emitting ANSI codes [1.2.C/D].
#... [WHY] : ANSI colour codes in log files look like: ^[[0;32m[INFO]^[[0m.
#...         Professional scripts detect the TTY and strip colours when redirected.
# if [[ -t 1 ]]; then
  # echo "[1.2.C/D] stdout IS a PTY — colour output is appropriate"
# else
  # echo "[1.2.C/D] stdout is NOT a PTY (redirected) — plain text only"
# fi

# pillar "4 | DEVOPS — Simulating Cron's Minimal Environment"
#... [WHAT]: Show why cron jobs fail when the same command works interactively.
#... [WHY] : Cron runs as a non-interactive, non-login shell with a stripped PATH.
#...         This is the #1 cause of "works on my machine but not in cron" bugs.
#... [HOW] : env --ignore-environment strips everything; we give it only /usr/bin:/bin
#...         to simulate what cron provides.
# echo "[1.2.J + 2.3.G] Our interactive PATH (first entry):"
# echo "  ${PATH%%:*}"
# echo ""
# echo "  PATH inside a cron-simulated env --ignore-environment:"
# env --ignore-environment PATH=/usr/bin:/bin bash -c 'echo "  Cron PATH: $PATH"'
# log_warn "Fix: use ABSOLUTE paths in cron, or add: PATH=/usr/local/bin:\$PATH at crontab top"


#...##############################################################################
#... SEGMENT 1.3 | INSTALLING AND CONFIGURING YOUR ENVIRONMENT
#...##############################################################################
# section "SEGMENT 1.3 | INSTALLING AND CONFIGURING YOUR ENVIRONMENT"

# pillar "1 | BASIC — Bash Version Gating"
#... [WHAT]: Guard the script against running on Bash 3.x (macOS default) [1.3.A].
#... [WHY] : Arrays, ${var^^}, and mapfile require Bash 4+. Failing with a
#...         clear message is better than a cryptic syntax error on line 400.
# echo "[1.3.A] Bash version: $BASH_VERSION"
# echo "  Major: ${BASH_VERSINFO[0]} | Minor: ${BASH_VERSINFO[1]}"

# if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  # log_error "Bash 4+ required. Upgrade: brew install bash (macOS) or apt-get install bash"
  # exit 1
# fi
# log_info "Bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} confirmed."

# pillar "2 | POWER — Tool Availability Pre-flight"
#... [WHAT]: Check for required external tools using command -v [1.3.F-H].
#... [WHY] : Failing at line 1 with "required tool missing" is infinitely better
#...         than failing at line 300 after partial state changes.
#... [HOW] : 'command -v' is POSIX — unlike 'which', it works in all sh variants
#...         and doesn't print errors for missing commands.
# echo "[1.3.F-H] Tool availability check:"
# required_tools=("ps" "grep" "awk" "sed" "find" "tty" "mktemp")
# for tool in "${required_tools[@]}"; do
  # if command -v "$tool" > /dev/null 2>&1; then
    # printf "  %-10s FOUND at %s\n" "$tool" "$(command -v "$tool")"
  # else
    # log_error "Required tool '$tool' missing. Aborting."
    # exit 127
  # fi
# done

# pillar "3 | PRECISION — GNU vs. BSD Tool Detection"
#... [WHAT]: Detect sed flavour to enable cross-platform compatibility [1.3.N].
#... [WHY] : sed -i requires '' on BSD/macOS, nothing on GNU/Linux.
#...         Scripts that hardcode one form break silently on the other OS.
# echo "[1.3.N] sed flavour detection:"
# if sed --version > /dev/null 2>&1; then
  # SED_INPLACE="sed -i"
  # echo "  GNU sed → in-place flag: sed -i"
# else
  # SED_INPLACE="sed -i ''"
  # echo "  BSD sed → in-place flag: sed -i ''"
# fi
# echo "  Portable in-place command: $SED_INPLACE"

# pillar "4 | DEVOPS — Production Pre-flight Check Function"
#... [WHAT]: Encapsulate all environment validation into one callable function.
#... [WHY] : Every production script needs a pre-flight gate. This function
#...         collects ALL failures before reporting — not stopping at the first.
# preflight_check() {
  # local -i failures=0       # [5.2.J] local -i: integer type enforcement

  # log_info "Running pre-flight checks..."
  # [[ "${BASH_VERSINFO[0]}" -ge 4 ]] || { log_error "Bash 4+ required"; (( failures++ )); }
  # [[ -w "$WORKSPACE"           ]] || { log_error "Workspace not writable"; (( failures++ )); }
  # command -v ps   > /dev/null 2>&1 || { log_error "ps not found"; (( failures++ )); }

  # if [[ "$failures" -gt 0 ]]; then
    # log_error "Pre-flight failed with $failures error(s)."
    # return 1    # [5.2.B] return — not exit — let the caller decide
  # fi
  # log_info "All pre-flight checks passed."
# }
# preflight_check


#...##############################################################################
#... SEGMENT 1.4 | ANATOMY OF A BASH SCRIPT
#...##############################################################################
# section "SEGMENT 1.4 | ANATOMY OF A BASH SCRIPT"

# pillar "1 | BASIC — Exit Code Contract"
#... [WHAT]: Demonstrate exit codes as the API between scripts [1.4.J-N].
#... [WHY] : CI pipelines, cron jobs, and orchestrators ALL make decisions on
#...         exit codes. A script that exits 0 on failure silently poisons pipelines.
#... [HOW] : $? is overwritten by EVERY command. Capture IMMEDIATELY after.
# echo "[1.4.K/J] Exit code demonstration:"
# grep --quiet "root" /etc/passwd; root_found=$?   # Capture AT ONCE
# echo "  grep 'root' in /etc/passwd → exit code: $root_found"

# grep --quiet "xyznonexistent" /etc/passwd; no_match=$?
# echo "  grep 'xyznonexistent' → exit code: $no_match  (1 = no match, not an error)"

# echo ""
# echo "  Reserved exit codes:"
# printf "  %-6s %s\n" "0"     "Success"
# printf "  %-6s %s\n" "1"     "Generic failure"
# printf "  %-6s %s\n" "126"   "Command found but not executable"
# printf "  %-6s %s\n" "127"   "Command not found"
# printf "  %-6s %s\n" "130"   "Killed by SIGINT (Ctrl+C) = 128 + 2"
# printf "  %-6s %s\n" "137"   "Killed by SIGKILL = 128 + 9"

# pillar "2 | POWER — Script Self-Location"
#... [WHAT]: Find the script's own directory reliably [1.4 + 2.5.O].
#... [WHY] : Scripts loading sibling config files break if called from another
#...         working directory. BASH_SOURCE[0] is the fix — it never lies.
#... [HOW] : dirname gets the dir portion. cd + pwd canonicalises symlinks.
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# echo "[2.5.O] Script self-location:"
# echo "  BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
# echo "  Canonical dir:  $SCRIPT_DIR"
# echo "  \$0 (less reliable): $0"

# pillar "3 | PRECISION — Shebang Portability"
#... [WHAT]: Explain why #!/usr/bin/env bash beats #!/bin/bash [1.4.A/B].
#... [WHY] : Homebrew bash on macOS lives in /usr/local/bin or /opt/homebrew/bin.
#...         #!/bin/bash silently runs the ancient Bash 3.2 Apple ships. env wins.
# echo "[1.4.A/B] Where bash actually lives on this system:"
# echo "  $(command -v bash)"
# echo "  #!/usr/bin/env bash always finds the right one via PATH."
# echo "  #!/bin/bash would hardcode /bin/bash — wrong on non-standard systems."

# pillar "4 | DEVOPS — CI Syntax Validation"
#... [WHAT]: Use bash -n to syntax-check scripts without executing them [1.4.O].
#... [WHY] : In CI, you want syntax errors caught before deployment. bash -n is
#...         instantaneous and has zero side effects.
# echo "[1.4.O] Syntax checking with bash -n:"
# cat > "$WORKSPACE/broken.sh" << 'EOF'
#...!/usr/bin/env bash
# if [[ -f "/tmp/test" ]
  # echo "found"
# fi
# EOF

# if bash -n "$WORKSPACE/broken.sh" 2>&1; then
  # echo "  No syntax errors."
# else
  # echo "  SYNTAX ERROR caught by bash -n — blocked before execution!"
# fi
#... [WHAT ELSE]: bash -x script traces execution. shellcheck script gives
#...              deeper static analysis (SC2086, SC2046, etc.).


#...##############################################################################
#... SEGMENT 2.1 | VARIABLE DECLARATION AND ASSIGNMENT
#...##############################################################################
# section "SEGMENT 2.1 | VARIABLE DECLARATION AND ASSIGNMENT"

# pillar "1 | BASIC — Scalar and Typed Variables"
#... [WHAT]: All four declare-based variable types [2.1.A-F].
#... [WHY] : Typed variables catch bugs at assignment time, not silently at
#...         runtime — the production defensive programming standard.
# app_name="deploy-agent"
# echo "[2.1.A] Scalar: app_name=$app_name"

# declare -i retry_count=3
# retry_count="hello"    # Non-integer → silently coerced to 0
# echo "[2.1.B] declare -i: assigning 'hello' to integer var → $retry_count"

# declare -r MAX_RETRIES=5
# echo "[2.1.C] declare -r: MAX_RETRIES=$MAX_RETRIES (immutable)"

# echo ""
# echo "[2.1.F] declare -p shows full type flags + value:"
# declare -p retry_count    # → declare -i retry_count="0"
# declare -p MAX_RETRIES    # → declare -r MAX_RETRIES="5"

# pillar "2 | POWER — Export and Child Process Visibility"
#... [WHAT]: Prove that un-exported variables are invisible to child processes [2.1.E].
#... [WHY] : Forgetting export is the silent bug that makes environment config
#...         invisible to child processes — apps, Docker entrypoints, subshells.
# local_only="invisible_to_children"
# declare -x exported_var="visible_to_children"

# echo "[2.1.E] Child process variable visibility:"
# bash -c 'printf "  local_only:    %s\n" "${local_only:-[NOT VISIBLE]}"'
# bash -c 'printf "  exported_var:  %s\n" "${exported_var:-[NOT VISIBLE]}"'

# pillar "3 | PRECISION — unset Danger Under set -u"
#... [WHAT]: Show that unset + set -u = fatal error on next reference [2.1.I].
#... [WHY] : You might unset a variable to "reset" it, then reference it later
#...         thinking it will be empty. Under set -u it's a crash.
# echo "[2.1.I] unset danger demonstration:"
# temp_var="I exist"
# echo "  Before unset: temp_var='$temp_var'"
# unset temp_var
#... Under set -u, referencing $temp_var now would abort the script.
#... We use the :- expansion to safely check without crashing:
# echo "  After unset (safe check with :-): '${temp_var:-[unset — would crash without :-]}'"

# pillar "4 | DEVOPS — Configuration Block Pattern"
#... [WHAT]: Production-grade config block using typed, readonly, defaulted vars.
#... [WHY] : Every script that deploys to real infrastructure should declare its
#...         configuration at the top with types + defaults + documentation.
# echo "[2.1.A-F] Production configuration block:"
# declare -r  DEPLOY_ENV="${DEPLOY_ENV:-staging}"
# declare -r  DEPLOY_USER="${DEPLOY_USER:-deploy}"
# declare -i  MAX_PARALLEL="${MAX_PARALLEL:-4}"
# declare -rx LOG_DIR="${LOG_DIR:-/tmp/deploy-logs}"   # -rx = readonly + exported

# printf "  %-15s = %s\n" "DEPLOY_ENV"   "$DEPLOY_ENV"
# printf "  %-15s = %s\n" "DEPLOY_USER"  "$DEPLOY_USER"
# printf "  %-15s = %s\n" "MAX_PARALLEL" "$MAX_PARALLEL"
# printf "  %-15s = %s\n" "LOG_DIR"      "$LOG_DIR"


#...##############################################################################
#... SEGMENT 2.2 | VARIABLE EXPANSION AND QUOTING RULES
#...##############################################################################
# section "SEGMENT 2.2 | VARIABLE EXPANSION AND QUOTING RULES"

# pillar "1 | BASIC — The Four Quoting Modes"
#... [WHAT]: All four quoting mechanisms side-by-side [2.2.A-E].
#... [WHY] : Incorrect quoting is the #1 source of shell script bugs. Toptal
#...         interviewers write a buggy unquoted expansion and ask you to spot it.
# demo_var="hello world"

# echo '[2.2.A] Double quotes — expand vars, suppress word-split/glob:'
# echo "  \"$demo_var\" arrives as ONE argument"

# echo '[2.2.B] Single quotes — fully literal, zero expansion:'
# echo '  $demo_var remains: $demo_var'

# echo '[2.2.C] ANSI-C quoting — C escape sequences without a subprocess:'
# printf "  Tab between brackets: [%s]\n" $'\t'
# printf "  Hex 0x41 = %s\n"              $'\x41'

# echo '[2.2.F] IFS defaults (space/tab/newline) drive word splitting:'
# echo "  IFS=$' \\t\\n'  (default)"

# pillar "2 | POWER — IFS Manipulation for Field Splitting"
#... [WHAT]: Split CSV and colon-delimited strings using IFS [2.2.F/G].
#... [WHY] : Replacing cut/awk with IFS manipulation eliminates subprocess
#...         overhead inside loops — critical in scripts processing 10k+ records.
#... [WATCH OUT]: Always restore IFS after. A global IFS change silently breaks
#...              every subsequent word split in the script.
# csv_line="alpha,beta,gamma,delta"
# echo "[2.2.F] Splitting CSV with IFS=',':"
# saved_ifs="$IFS"
# IFS=','
# read -ra csv_fields <<< "$csv_line"
# IFS="$saved_ifs"    # Restore IMMEDIATELY

# for i in "${!csv_fields[@]}"; do
  # printf "  field[%d] = %s\n" "$i" "${csv_fields[$i]}"
# done

# pillar "3 | PRECISION — The rm \$file Disaster (Defused)"
#... [WHAT]: Live demo of the quoting-in-commands footgun [2.2.L/M/N].
#... [WHY] : rm $file where $file="/path/file with spaces" word-splits into
#...         three arguments. The first gets deleted (or fails). Silent corruption.
# echo "[2.2.L/M/N] Safe file operations with tricky names:"
# touch "$WORKSPACE/file with spaces.log"
# touch "$WORKSPACE/normal.log"

# echo "  Safe removal (double-quoted):"
# rm "$WORKSPACE/file with spaces.log" && echo "  Removed successfully"

# echo ""
# echo "  The '--' separator for filenames starting with '-':"
# touch "$WORKSPACE/-weird-name.log"
# rm -- "$WORKSPACE/-weird-name.log" && echo "  Removed -weird-name.log safely"
#... [WATCH OUT]: Without --, rm tries to parse -weird-name as a flag cluster.

# pillar "4 | DEVOPS — nullglob for Safe File Iteration"
#... [WHAT]: Use shopt -s nullglob to prevent empty-glob loops [2.2.J].
#... [WHY] : A deployment script iterating *.yaml in an empty dir processes
#...         the LITERAL STRING "*.yaml" as a filename — which then fails to open.
# echo "[2.2.J] nullglob preventing the empty-glob trap:"
# mkdir --parents "$WORKSPACE/empty_dir"

# echo "  WITHOUT nullglob (default) — empty dir still runs once:"
# for f in "$WORKSPACE/empty_dir"/*.conf; do
  # echo "  Would process: $f  ← WRONG (literal glob pattern, not a real file)"
# done

# shopt -s nullglob
# echo "  WITH nullglob — loop never executes on empty dir:"
# for f in "$WORKSPACE/empty_dir"/*.conf; do
  # echo "  Processing: $f"
# done
# echo "  (No output above = correct)"
# shopt -u nullglob   # Always restore to default
#... [WHAT ELSE]: shopt -s globstar enables ** recursive glob. shopt -s dotglob
#...              makes * match hidden (dot) files.


#...##############################################################################
#... SEGMENT 2.3 | ENVIRONMENT VARIABLES AND EXPORT
#...##############################################################################
# section "SEGMENT 2.3 | ENVIRONMENT VARIABLES AND EXPORT"

# pillar "1 | BASIC — export, env, printenv"
#... [WHAT]: Promote a variable to the environment and verify it [2.3.A/D/E].
# APP_VERSION="2.4.1"
# export APP_VERSION

# echo "[2.3.A/E] Exported var via printenv:"
# printenv APP_VERSION

# echo ""
# echo "[2.3.D] First 5 lines of the current environment:"
# env | sort | head --lines=5

# pillar "2 | POWER — Per-Command Environment Override"
#... [WHAT]: Scope a variable override to a single command [2.3.F].
#... [WHY] : Changing LC_ALL globally would affect ALL subsequent string ops.
#...         Per-command scoping is surgical, side-effect-free, and readable.
# echo "[2.3.F] Per-command VAR=value override:"
# echo "  Current LC_ALL: ${LC_ALL:-[not set]}"
# printf "banana\napple\ncherry\n" | LC_ALL=C sort
# echo "  LC_ALL after the command: ${LC_ALL:-[still not set — correct]}"

# pillar "3 | PRECISION — Clean Environment Execution"
#... [WHAT]: Strip the entire environment for a single command [2.3.G/H].
#... [WHY] : Security scripts, privilege operations, and reproducibility tests
#...         need a guaranteed minimal environment — not whatever the caller
#...         happened to export.
# echo "[2.3.G/H] env --ignore-environment (clean slate):"
# env --ignore-environment PATH=/usr/bin:/bin HOME=/tmp bash -c '
  # echo "  In clean env:"
  # echo "    PATH=$PATH"
  # echo "    HOME=$HOME"
  # echo "    APP_VERSION=${APP_VERSION:-[NOT INHERITED — correct]}"
# '

# pillar "4 | DEVOPS — PATH Injection Attack and Defence"
#... [WHAT]: Demonstrate PATH injection and the absolute-path defence [2.3.M].
#... [WHY] : If '.' is in PATH, an attacker drops a malicious binary named 'ls'
#...         in /tmp. Any privileged script that cds to /tmp and runs ls is pwned.
#... [WATCH OUT]: This is a real attack vector. Never include '.' in PATH.
# echo "[2.3.M] PATH injection demonstration:"
# mkdir --parents "$WORKSPACE/evil"
# printf '#!/bin/bash\necho "  [PWNED] malicious ls ran with UID=$(id -u)"\n' \
  # > "$WORKSPACE/evil/ls"
# chmod +x "$WORKSPACE/evil/ls"

# echo "  With poisoned PATH (evil dir first):"
# PATH="$WORKSPACE/evil:$PATH" bash -c 'ls' 2>/dev/null || true

# echo ""
# echo "  DEFENCE — use 'command -p' to bypass PATH and use OS-default PATH:"
# command -p ls /dev/null > /dev/null && echo "  command -p ls → safe system ls ran"
#... [WHAT ELSE]: In security scripts, hardcode full paths: /bin/ls not ls.


#...##############################################################################
#... SEGMENT 2.4 | PARAMETER EXPANSION (THE FULL REFERENCE)
#...##############################################################################
# section "SEGMENT 2.4 | PARAMETER EXPANSION (THE FULL REFERENCE)"

# pillar "1 | BASIC — Default Values and Guards"
#... [WHAT]: The three most-used expansion forms [2.4.B-F].
#... [WHY] : These replace entire if/else blocks. A Toptal screener expects you
#...         to use them reflexively — not write 5-line if statements.
# echo "[2.4.B] \${var:-default}:"
# unset db_host 2>/dev/null || true
# printf "  unset:  %s\n" "${db_host:-localhost}"
# db_host=""
# printf "  empty:  %s\n" "${db_host:-localhost}"
# db_host="prod-db-01"
# printf "  set:    %s\n" "${db_host:-localhost}"

# echo ""
# echo "[2.4.D] \${var:=default} — also assigns:"
# unset config_dir 2>/dev/null || true
# : "${config_dir:=/etc/app}"   # : is the no-op command; expansion assigns as side effect
# echo "  config_dir is now: $config_dir"

# echo ""
# echo "[2.4.F] \${var:+alternate} — only when set:"
# debug_flag="true"
# echo "  debug_flag set   → cmd ${debug_flag:+--verbose} --output file"
# unset debug_flag 2>/dev/null || true
# echo "  debug_flag unset → cmd ${debug_flag:+--verbose} --output file"

# pillar "2 | POWER — String Ops Without Subshells"
#... [WHAT]: Parameter expansion as a zero-cost string library [2.4.G-S].
#... [WHY] : Every $(basename ...), $(dirname ...), echo|tr call forks a process.
#...         In a loop of 50,000 files these add up to minutes.
# fp="/var/log/nginx/access_2024.log.gz"

# printf "  %-35s %s\n" "\${#fp} — length:"             "${#fp}"
# printf "  %-35s %s\n" "\${fp##*/} — basename:"         "${fp##*/}"
# printf "  %-35s %s\n" "\${fp%/*} — dirname:"            "${fp%/*}"
# printf "  %-35s %s\n" "\${fp%.*} — strip last ext:"     "${fp%.*}"
# printf "  %-35s %s\n" "\${fp%%.*} — strip all exts:"    "${fp%%.*}"
# printf "  %-35s %s\n" "\${fp:9:5} — substring:"         "${fp:9:5}"
# printf "  %-35s %s\n" "\${fp/log/LOG} — first replace:"  "${fp/log/LOG}"
# printf "  %-35s %s\n" "\${fp//\//|} — all replace:"     "${fp//\//|}"
# printf "  %-35s %s\n" "\${fp^^} — uppercase (Bash 4+):" "${fp^^}"
# printf "  %-35s %s\n" "\${fp,,} — lowercase:"           "${fp,,}"

# pillar "3 | PRECISION — Indirect Expansion for Dynamic Dispatch"
#... [WHAT]: Use ${!varname} to look up a variable whose name is dynamic [2.4.T].
#... [WHY] : Config dispatch tables — loading the right DB host per environment —
#...         without a giant if/elif chain. One line per environment.
# declare -r DB_HOST_staging="staging-db.internal"
# declare -r DB_HOST_prod="prod-db.internal"
# declare -r DB_HOST_dev="localhost"

# echo "[2.4.T] \${!varname} indirect expansion — env-aware config lookup:"
# for env_name in staging prod dev; do
  # var_name="DB_HOST_${env_name}"
  # printf "  %-10s → %s\n" "$env_name" "${!var_name}"
# done

# pillar "4 | DEVOPS — Path Sanitisation Without External Tools"
#... [WHAT]: Build sanitised paths from raw user input using only param expansion.
#... [WHY] : CI scripts accepting user-provided filenames must sanitise before
#...         using them in paths. Spawning sed for each is slow and fragile.
# echo "[2.4.I-N] Sanitising raw user input (no subshells):"
# raw="  My Config File.CONF  "

#... Strip leading spaces: remove everything up to the first non-space
# trimmed="${raw#"${raw%%[! ]*}"}"
#... Strip trailing spaces: remove everything after the last non-space
# trimmed="${trimmed%"${trimmed##*[! ]}"}"

# lowered="${trimmed,,}"              # Lowercase
# underscored="${lowered// /_}"       # Spaces → underscores
# no_ext="${underscored%.conf}"       # Strip extension

# printf "  Raw:      '%s'\n" "$raw"
# printf "  Trimmed:  '%s'\n" "$trimmed"
# printf "  Final:    '%s'\n" "/etc/app/${no_ext}.conf"


#...##############################################################################
#... SEGMENT 2.5 | SPECIAL VARIABLES
#...##############################################################################
# section "SEGMENT 2.5 | SPECIAL VARIABLES"

# pillar "1 | BASIC — Process Identity Variables"
#... [WHAT]: $$, $BASHPID, $!, $? — the runtime telemetry variables [2.5.G-J].
#... [WHY] : $! is the ONLY way to track background processes for wait/kill.
#...         $? is the ONLY way to check exit status — but capture it instantly.
# echo "[2.5.G/H] PID variables:"
# echo "  \$\$ (shell PID, constant even in subshells): $$"
# subshell_bashpid=$(bash -c 'echo $BASHPID')
# echo "  \$BASHPID (always current process): $BASHPID | child was: $subshell_bashpid"

# echo ""
# echo "[2.5.I/J] Background process tracking:"
# sleep 1 &
# bg_pid=$!    # Capture $! IMMEDIATELY — next command overwrites it
# echo "  Backgrounded sleep, PID=$bg_pid"
# wait "$bg_pid"
# echo "  Background job exit code (\$?): $?"

# pillar "2 | POWER — \$@ vs \$* — The Critical Difference"
#... [WHAT]: Show why "$@" is always right and "$*" is almost always wrong [2.5.D/E].
#... [WHY] : This is asked in EVERY Bash interview. "$*" collapses multi-word
#...         args into one string. "$@" preserves each arg as a separate word.
# show_args() {
  # echo "  Arg count (\$#): $#"
  # local i=1
  # for arg in "$@"; do
    # printf "  Arg %d: [%s]\n" "$i" "$arg"
    # (( i++ ))
  # done
# }
# echo '[2.5.D/E] show_args "hello world" "foo bar" "baz":'
# show_args "hello world" "foo bar" "baz"

# pillar "3 | PRECISION — Introspection Arrays for Stack Traces"
#... [WHAT]: BASH_SOURCE, BASH_LINENO, FUNCNAME for error context [2.5.M-Q].
#... [WHY] : "ERROR: failed" is useless. "ERROR in deploy() deploy.sh:147" is
#...         actionable. This pattern is what separates production scripts from toys.
# print_stack() {
  # local -i i
  # echo "  Call stack:"
  # for (( i=0; i < ${#FUNCNAME[@]}; i++ )); do
    # printf "    [%d] %s() at %s:%s\n" \
      # "$i" \
      # "${FUNCNAME[$i]:-main}" \
      # "${BASH_SOURCE[$i]:-script}" \
      # "${BASH_LINENO[$i]:-?}"
  # done
# }
# outer() { inner; }
# inner() { print_stack; }

# echo "[2.5.M-Q] Live call stack:"
# outer

# pillar "4 | DEVOPS — SECONDS and RANDOM for Timing and Jitter"
#... [WHAT]: Zero-cost performance measurement and retry jitter [2.5.S/T].
#... [WHY] : SECONDS avoids $(date) subshell overhead for timing.
#...         RANDOM jitter in retry loops prevents thundering-herd: all
#...         workers hitting a recovering API at the exact same millisecond.
# echo "[2.5.T] Script has been running: $SECONDS second(s)"

# echo ""
# echo "[2.5.S] Jitter pattern for retry loops:"
# for attempt in 1 2 3; do
  # jitter=$(( RANDOM % 5 + 1 ))
  # printf "  Attempt %d: would back off %ds before retry\n" "$attempt" "$jitter"
# done

# echo ""
# echo "[2.5.U] PIPESTATUS — exit codes of every pipeline stage:"
# printf "line1\nbadline\nline3\n" | grep --quiet "NOMATCH" | cat > /dev/null || true
# echo "  After: grep | cat"
# echo "  PIPESTATUS[0] (grep): ${PIPESTATUS[0]} | PIPESTATUS[1] (cat): ${PIPESTATUS[1]}"
#... [WHAT ELSE]: set -o pipefail makes the whole pipeline fail if any stage fails.
#...              PIPESTATUS lets you identify WHICH stage failed.


#...##############################################################################
#... SEGMENT 3.1 | THE test COMMAND AND [ BUILTIN
#...##############################################################################
# section "SEGMENT 3.1 | THE test COMMAND AND [ BUILTIN"

# pillar "1 | BASIC — Integer and String Comparisons"
#... [WHAT]: All numeric and string comparison operators [3.1.C-L].
#... [WHY] : Mixing -eq (numeric) and = (string) is a classic Toptal trap.
#...         "10" > "9" is FALSE lexicographically ('1' < '9') but
#...         10 -gt 9 is TRUE numerically. Know the difference cold.
# a=10; b=9

# echo "[3.1.C-H] Integer comparisons (-eq, -ne, -lt, -le, -gt, -ge):"
# [ "$a" -eq "$b"  ] && echo "  $a -eq $b : TRUE"  || echo "  $a -eq $b : FALSE"
# [ "$a" -gt "$b"  ] && echo "  $a -gt $b : TRUE"  || echo "  $a -gt $b : FALSE"
# [ "$a" -lt "$b"  ] && echo "  $a -lt $b : TRUE"  || echo "  $a -lt $b : FALSE"

# echo ""
# echo "[3.1.I-L] String comparisons (=, !=, -z, -n):"
# sa="10"; sb="9"
# [ "$sa" =  "$sb" ] && echo "  '10' = '9'  : TRUE"  || echo "  '10' = '9'  : FALSE"
# [ -z "" ]          && echo "  -z ''       : TRUE (empty string)"

#... The line below was marked as a red line (try finding the issue)...
#... ===> [ -n "hello" ]     && echo "  -n 'hello'  : TRUE (non-empty)"

# pillar "2 | POWER — File Test Operators"
#... [WHAT]: The full file-test operator set [3.1.M-X].
#... [WHY] : File tests are the foundation of every idempotent script.
#...         Check before act = safe scripts. Blind act = production disasters.
# tfile="$WORKSPACE/seg3_test.txt"
# tdir="$WORKSPACE/seg3_dir"
# printf "test content\n" > "$tfile"
# mkdir --parents "$tdir"
# ln --symbolic "$tfile" "$WORKSPACE/seg3_link"

# printf "  %-20s %s\n" "-e (exists):"       "$([ -e "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-f (regular file):" "$([ -f "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-d (directory):"    "$([ -d "$tdir"  ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-r (readable):"     "$([ -r "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-w (writable):"     "$([ -w "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-x (executable):"   "$([ -x "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-s (non-empty):"    "$([ -s "$tfile" ] && echo YES || echo NO)"
# printf "  %-20s %s\n" "-L (symlink):"      "$([ -L "$WORKSPACE/seg3_link" ] && echo YES || echo NO)"

# pillar "3 | PRECISION — The Unquoted Variable Syntax Error"
#... [WHAT]: Show how empty var + unquoted [ ] = syntax crash [3.1.B/Y].
#... [WHY] : [ $var = "x" ] with empty $var becomes [ = "x" ].
#...         That's a syntax error. This kills scripts silently in pipelines.
#...         ALWAYS quote variables inside [ ].
# empty=""
# echo "[3.1.B] Quoting safety in [ ]:"
# echo "  Unquoted: [ \$empty = 'x' ] would become: [ = 'x' ] → syntax error!"
# echo "  Quoted:   [ \"\$empty\" = 'x' ] becomes: [ '' = 'x' ] → FALSE (safe)"
# if [ "$empty" = "x" ]; then
  # echo "  Match"
# else
  # echo "  No match — and no crash. Quote your variables."
# fi

# pillar "4 | DEVOPS — Idempotent Resource Creation"
#... [WHAT]: Use file tests to make directory creation safe to run N times [3.1.O].
#... [WHY] : Idempotency is a mandatory Toptal requirement. A script that creates
#...         a directory MUST handle the case where it already exists.
# echo "[3.1.O] Idempotent directory creation (run twice on same path):"
# deploy_dir="$WORKSPACE/releases/v2.4.1"
# for run in 1 2; do
  # if [ ! -d "$deploy_dir" ]; then
    # mkdir --parents "$deploy_dir"
    # log_info "Run $run: Created $deploy_dir"
  # else
    # log_info "Run $run: $deploy_dir already exists — skipping (idempotent)"
  # fi
# done


#...##############################################################################
#... SEGMENT 3.2 | THE [[ EXTENDED TEST BUILTIN
#...##############################################################################
# section "SEGMENT 3.2 | THE [[ EXTENDED TEST BUILTIN"

# pillar "1 | BASIC — Pattern Matching and Regex"
#... [WHAT]: The two matching modes unique to [[ ]] [3.2.B/D].
#... [WHY] : [ ] has zero pattern/regex capability. [[ ]] makes validation a
#...         one-liner. You WILL be asked to explain the difference at Toptal.
# log_file="app_error_2024-01.log"
# build_id="BUILD-0042"

# echo "[3.2.B] Glob pattern matching with ==:"
# [[ "$log_file" == *.log ]] && echo "  '$log_file' matches *.log"

# echo ""
# echo "[3.2.D/E] ERE regex matching with =~ and BASH_REMATCH:"
# if [[ "$build_id" =~ ^BUILD-([0-9]+)$ ]]; then
  # echo "  Full match:    ${BASH_REMATCH[0]}"
  # echo "  Capture [1]:   ${BASH_REMATCH[1]}"  # The digits after BUILD-
# fi

# pillar "2 | POWER — Input Validation Suite"
#... [WHAT]: Practical validators built on [[ =~ ]] [3.2.F].
#... [WHY] : Every script accepting external input needs validation. These patterns
#...         are used directly in production infrastructure tooling.
# echo "[3.2.F] Input validation:"
# declare -a inputs=("42" "3.14" "192.168.1.1" "2024-01-15" "hello" "")

# for val in "${inputs[@]}"; do
  # if   [[ "$val" =~ ^[0-9]+$ ]];                                              then label="integer"
  # elif [[ "$val" =~ ^[0-9]+\.[0-9]+$ ]];                                      then label="float"
  # elif [[ "$val" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];    then label="IPv4"
  # elif [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]];                         then label="ISO date"
  # elif [[ -z "$val" ]];                                                         then label="EMPTY"
  # else                                                                               label="string"
  # fi
  # printf "  %-20s → %s\n" "'$val'" "$label"
# done

# pillar "3 | PRECISION — No Word Splitting Inside [[ ]]"
#... [WHAT]: Prove [[ ]] is word-split-safe with unquoted spaced variables [3.2.A].
#... [WHY] : [ $spaced = "x y" ] → [ hello world = "x y" ] → too many args → crash.
#...         [[ $spaced == "x y" ]] → safe. The parser handles it natively.
# spaced="hello world"
# echo "[3.2.A] [[ ]] word-split safety:"
# if [[ $spaced == "hello world" ]]; then   # Safe unquoted
  # echo "  Matched 'hello world' without quoting — no word split"
# fi
# echo "  Equivalent [ ] with unquoted \$spaced would be: [ hello world = 'hello world' ]"
# echo "  → 'bash: [: too many arguments' — CRASH"

# pillar "4 | DEVOPS — Log File Classifier and Router"
#... [WHAT]: Route log files to appropriate handlers based on [[ ]] patterns [3.2.B].
#... [WHY] : Deployment pipelines process mixed log archives. Clean routing logic
#...         using [[ ]] patterns is readable and maintainable.
# echo "[3.2.B] Log file routing:"
# log_samples=("app.log" "error.log.gz" "metrics.json" "debug.log.2024" "dump.bin")

# for lf in "${log_samples[@]}"; do
  # if   [[ "$lf" == *.json ]];    then echo "  $lf → jq parser"
  # elif [[ "$lf" == *.gz   ]];    then echo "  $lf → zcat | grep"
  # elif [[ "$lf" == *.log* ]];    then echo "  $lf → awk/grep processor"
  # elif [[ "$lf" =~ \.bin$ ]];    then echo "  $lf → binary — skip and alert"
  # else                                 echo "  $lf → unknown format"
  # fi
# done


#...##############################################################################
#... SEGMENT 3.3 | if / elif / else / fi
#...##############################################################################
# section "SEGMENT 3.3 | if / elif / else / fi"

# pillar "1 | BASIC — Commands as Conditions"
#... [WHAT]: Use real commands directly as if conditions [3.3.A/F/G].
#... [WHY] : if tests EXIT CODES, not booleans. Every command has an exit code.
#...         Direct command tests are more idiomatic than wrapping in [ ].
# echo "[3.3.F] Command as if condition:"
# if grep --quiet "root" /etc/passwd; then
  # echo "  'root' entry found in /etc/passwd"
# fi

# echo ""
# echo "[3.3.G] Negation with !:"
# if ! grep --quiet "nonexistent_xyz_abc" /etc/passwd; then
  # echo "  Confirmed: 'nonexistent_xyz_abc' is not a user"
# fi

# pillar "2 | POWER — Compound Command Conditions"
#... [WHAT]: Group multiple commands as a single if condition [3.3.H].
#... [WHY] : Some preconditions require multiple checks to all pass.
#...         { cmd1 && cmd2; } tests them as one atomic condition.
# conf="$WORKSPACE/app3.conf"
# echo "debug=false" > "$conf"

# echo "[3.3.H] Compound { } command group as condition:"
# if { [ -f "$conf" ] && grep --quiet "debug=false" "$conf"; }; then
  # echo "  Config exists AND debug is disabled — proceeding"
# fi

# pillar "3 | PRECISION — Multi-Branch Decision Logic"
#... [WHAT]: if/elif/else for tiered threshold-based decisions [3.3.A-D].
#... [WHY] : Service health checks, alert routing, and deployment gates all
#...         require multiple threshold-based branches.
# declare -i cpu_load=75
# echo "[3.3.A-D] Service health decision tree (cpu_load=$cpu_load%):"
# if   [[ "$cpu_load" -ge 90 ]]; then log_error "CRITICAL: load $cpu_load% — reject traffic"
# elif [[ "$cpu_load" -ge 70 ]]; then log_warn  "WARNING: load $cpu_load% — throttle deployments"
# elif [[ "$cpu_load" -ge 50 ]]; then log_warn  "CAUTION: load $cpu_load% — monitor closely"
# else                                 log_info  "OK: load $cpu_load% — nominal"
# fi

# pillar "4 | DEVOPS — Deployment Gate"
#... [WHAT]: Multi-check deployment gate using if to route pass/fail [3.3.A-H].
# echo "[3.3.A-H] Production deployment gate:"

# run_gate_check() {
  # local -r name="$1"; local -i pass="$2"
  # if (( pass )); then log_info "GATE PASS: $name"; return 0
  # else log_warn "GATE FAIL: $name"; return 1; fi
# }

# all_clear=true
# run_gate_check "unit-tests"       1 || all_clear=false
# run_gate_check "security-scan"    1 || all_clear=false
# run_gate_check "integration"      1 || all_clear=false

# if [[ "$all_clear" == "true" ]]; then
  # log_info "All gates passed — DEPLOYMENT APPROVED"
# else
  # log_error "Gate failure — DEPLOYMENT BLOCKED"
# fi


#...##############################################################################
#... SEGMENT 3.4 | case STATEMENTS
#...##############################################################################
# section "SEGMENT 3.4 | case STATEMENTS"

# pillar "1 | BASIC — Multi-Pattern String Dispatch"
#... [WHAT]: case with literal, multi-pattern, and glob branches [3.4.A-F].
#... [WHY] : case is cleaner than chained elif for 4+ branches on one variable.
#...         It also supports glob patterns natively — [ ] and [[ ]] don't.
# http_code="404"
# echo "[3.4.A-E] HTTP status dispatcher (code=$http_code):"
# case "$http_code" in
  # 200|201|204)      echo "  SUCCESS — operation complete" ;;
  # 301|302)          echo "  REDIRECT — follow Location header" ;;
  # 400)              echo "  BAD REQUEST — check payload format" ;;
  # 401|403)          echo "  AUTH FAILURE — check credentials" ;;
  # 404)              echo "  NOT FOUND — resource missing" ;;
  # 5??)              echo "  SERVER ERROR — alert on-call" ;;
  # *)                echo "  UNKNOWN code $http_code — investigate" ;;
# esac

# pillar "2 | POWER — Glob Patterns and File Type Routing"
#... [WHAT]: Glob patterns in case for file extension dispatch [3.4.F/G].
# route_file() {
  # local -r f="$1"
  # case "$f" in
    # *.tar.gz|*.tgz) echo "  $f → tar -xzf" ;;
    # *.zip)          echo "  $f → unzip" ;;
    # *.json)         echo "  $f → jq" ;;
    # *.yaml|*.yml)   echo "  $f → yq" ;;
    # *.sh)           echo "  $f → bash" ;;
    # [Mm]akefile)    echo "  $f → make" ;;
    # *)              echo "  $f → unknown, skip" ;;
  # esac
# }
# echo "[3.4.F/G] File type routing:"
# for f in "deploy.tar.gz" "config.yaml" "data.json" "setup.sh" "Makefile" "blob"; do
  # route_file "$f"
# done

# pillar "3 | PRECISION — Bash 4+ Fall-Through with ;& and ;;&"
#... [WHAT]: ;&  (unconditional fall-through) and ;;& (test next) [3.4.H/I].
#... [WHY] : These are the case equivalents of C's fall-through switch. They
#...         allow implementing permission inheritance and priority rule tables.
# role="admin"
# echo "[3.4.H] ;& fall-through — cumulative permission model (role=$role):"
# case "$role" in
  # admin)   echo "  + DELETE permission"  ;&  # Fall through unconditionally
  # editor)  echo "  + WRITE permission"   ;&
  # viewer)  echo "  + READ permission"    ;;
# esac

# pillar "4 | DEVOPS — CLI Subcommand Dispatcher"
#... [WHAT]: case-based CLI tool subcommand router [3.4.A-G].
#... [WHY] : kubectl, helm, terraform, and every serious DevOps CLI uses this
#...         pattern. Building your own is a Toptal capstone skill.
# cli() {
  # local -r cmd="${1:-help}"
  # case "$cmd" in
    # start)           echo "  [start]   Writing PID file, starting service..." ;;
    # stop)            echo "  [stop]    Sending SIGTERM, waiting for drain..." ;;
    # status)          echo "  [status]  Checking /proc/\$PID/status..." ;;
    # restart)         echo "  [restart] Delegating: stop → start" ;;
    # help|--help|"")  echo "  Usage: tool <start|stop|status|restart>" ;;
    # *)               echo "  Unknown: '$cmd'. Run 'tool help'"; return 1 ;;
  # esac
# }
# echo "[3.4.A-G] CLI dispatcher:"
# for cmd in start status restart logs help unknown; do
  # cli "$cmd" || true
# done


#...##############################################################################
#... SEGMENT 3.5 | SHORT-CIRCUIT EVALUATION
#...##############################################################################
# section "SEGMENT 3.5 | SHORT-CIRCUIT EVALUATION"

# pillar "1 | BASIC — && and || Mechanics"
#... [WHAT]: Short-circuit AND and OR [3.5.A/B].
# echo "[3.5.A] && — right runs only if left exits 0:"
# true  && echo "  true  && echo → PRINTED (left succeeded)"
# false && echo "  false && echo → NOT PRINTED"  || true

# echo ""
# echo "[3.5.B] || — right runs only if left exits non-zero:"
# false || echo "  false || echo → PRINTED (left failed)"
# true  || echo "  true  || echo → NOT PRINTED"

# pillar "2 | POWER — The False Ternary Anti-Pattern"
#... [WHAT]: Show that cmd1 && cmd2 || cmd3 is NOT an if/else [3.5.C].
#... [WHY] : This is the most common logic bug in shell scripts. When cmd2 fails
#...         (even though cmd1 succeeded), cmd3 runs — the "else" fires when it
#...         shouldn't. This has caused production outages.
#... [WATCH OUT]: Never use cmd1 && cmd2 || cmd3 as a ternary. Use if/else.
# echo "[3.5.C] FALSE TERNARY TRAP:"
# mkdir "$WORKSPACE/ft_test"  # cmd1 succeeds
# rmdir "$WORKSPACE/ft_NONEXISTENT" 2>/dev/null && \
  # echo "  cmd2 success" || \
  # echo "  ERROR HANDLER FIRED — but mkdir (cmd1) DID succeed! This is the bug."

# echo ""
# echo "  SAFE PATTERN — use real if/else:"
# if mkdir "$WORKSPACE/ft_safe" 2>/dev/null; then
  # echo "  if branch: mkdir succeeded — only this runs"
# else
  # echo "  else branch: mkdir failed"
# fi

# pillar "3 | PRECISION — Idiomatic || Error Handling"
#... [WHAT]: The { err_msg; exit/return; } pattern after || [3.5.D].
#... [WHY] : For one-liner error handling, this is cleaner than if/fi and
#...         works correctly under set -e. Braces group the two commands.
# echo "[3.5.D] Idiomatic || error handling:"
# safe_remove() {
  # local -r target="$1"
  # [ -e "$target" ] || { log_error "Not found: $target"; return 1; }
  # rm --force "$target"
  # log_info "Removed: $target"
# }
# touch "$WORKSPACE/remove_me.tmp"
# safe_remove "$WORKSPACE/remove_me.tmp"
# safe_remove "$WORKSPACE/doesnt_exist.tmp" || log_warn "Handled gracefully"

# pillar "4 | DEVOPS — Sequential Deployment Steps with && Abort"
#... [WHAT]: && chaining as a sequential step runner — abort on first failure [3.5.F].
#... [WHY] : Pull image → run migrations → start app → healthcheck: each step
#...         must succeed before the next begins. && gives you that for free.
# echo "[3.5.F] Sequential deployment pipeline with && abort-on-fail:"
# step() { local -r name="$1"; local -i ok="$2"; log_info "Step: $name"; return $(( 1-ok )); }

# step "pull_image"    1 \
  # && step "run_migrations" 1 \
  # && step "start_app"      1 \
  # && step "healthcheck"    1 \
  # && log_info "PIPELINE COMPLETE" \
  # || log_error "PIPELINE ABORTED at failed step"


#...##############################################################################
#... SEGMENT 4.1 | for LOOPS
#...##############################################################################
# section "SEGMENT 4.1 | for LOOPS"

# pillar "1 | BASIC — List, Brace, and C-Style for"
#... [WHAT]: All three for loop forms [4.1.A/D/F].
# echo "[4.1.A] List-based for:"
# for colour in red green blue; do printf "  %s\n" "$colour"; done

# echo ""
# echo "[4.1.D] Brace expansion {1..5}:"
# for i in {1..5}; do printf "  %d " "$i"; done; echo ""

# echo ""
# echo "[4.1.E] Brace with step {0..10..3}:"
# for i in {0..10..3}; do printf "  %d " "$i"; done; echo ""

# echo ""
# echo "[4.1.F] C-style arithmetic for — most efficient for counting:"
# for (( i=0; i<5; i++ )); do printf "  i=%d\n" "$i"; done

# pillar "2 | POWER — Glob Iteration and \$@ Forwarding"
#... [WHAT]: Safe glob iteration and argument forwarding [4.1.B/C].
# mkdir --parents "$WORKSPACE/confs"
# touch "$WORKSPACE/confs/app.conf" "$WORKSPACE/confs/db.conf"

# echo "[4.1.C] Glob-based for (safe with quoted variable):"
# for cf in "$WORKSPACE/confs"/*.conf; do
  # echo "  Processing: ${cf##*/}"   # [2.4.J] zero-cost basename
# done

# echo ""
# echo "[4.1.B] Forwarding \"\$@\" into a function:"
# process_all() {
  # for target in "$@"; do log_info "Target: $target"; done
# }
# process_all "server-01" "server with space" "server-03"

# pillar "3 | PRECISION — The Empty Glob Trap"
#... [WHAT]: nullglob prevents spurious loop execution on empty dirs [4.1.H].
#... [WATCH OUT]: Without nullglob, an empty glob *.conf in an empty dir
#...              passes the LITERAL STRING "*.conf" to the loop body once.
# echo "[4.1.H] Empty glob trap:"
# mkdir --parents "$WORKSPACE/empty_dir_4_1"
# echo "  WITHOUT nullglob (runs once with literal *.conf):"
# for f in "$WORKSPACE/empty_dir_4_1"/*.conf; do
  # echo "  SPURIOUS EXECUTION: $f"
# done
# shopt -s nullglob
# echo "  WITH nullglob (no output = correct):"
# for f in "$WORKSPACE/empty_dir_4_1"/*.conf; do echo "  $f"; done
# shopt -u nullglob

# pillar "4 | DEVOPS — Parallel-Ready Server Inventory Iteration"
#... [WHAT]: Iterate over a server list file using for with a while-read array load.
#... [WHY] : Production deployment scripts iterate over server inventories.
#...         Storing them in an array (not a string) enables safe parallel dispatch.
# printf "app-01.prod\napp-02.prod\napp-03.prod\n" > "$WORKSPACE/inventory.txt"
# declare -a servers=()
# while IFS='' read -r srv || [[ -n "$srv" ]]; do
  # servers+=("$srv")
# done < "$WORKSPACE/inventory.txt"

# echo "[4.1.F + 4.2.D] Inventory iteration from file-loaded array:"
# for (( i=0; i < ${#servers[@]}; i++ )); do
  # printf "  [%d/%d] Deploying to: %s\n" "$(( i+1 ))" "${#servers[@]}" "${servers[$i]}"
# done


#...##############################################################################
#... SEGMENT 4.2 | while AND until LOOPS
#...##############################################################################
# section "SEGMENT 4.2 | while AND until LOOPS"

# pillar "1 | BASIC — Canonical while read Idiom"
#... [WHAT]: The correct, safe, line-by-line file reading pattern [4.2.D/E/F].
#... [WHY] : This is in EVERY production Bash script. Memorise it exactly.
#...         IFS='' + -r + redirection (not pipe) = the three mandatory pieces.
# printf "  leading space,val1\nnormal,val2\nback\\\\slash,val3\n" \
  # > "$WORKSPACE/data.csv"

# echo "[4.2.D/E/F] Canonical while IFS='' read -r pattern:"
# while IFS='' read -r line || [[ -n "$line" ]]; do
  # echo "  |${line}|"   # Pipes prove leading/trailing whitespace is preserved
# done < "$WORKSPACE/data.csv"

# pillar "2 | POWER — The Pipe Subshell Trap and Fix"
#... [WHAT]: Show variable loss in pipe-subshell while loop and fix it [4.2.G/H].
#... [WHY] : This is the most-asked Bash gotcha in Toptal interviews.
#...         "Variables set inside a pipe loop are lost" — why and how to fix it.
#... [WATCH OUT]: command | while runs the while body in a SUBSHELL. Variables
#...              set inside are COPIES — they die when the subshell exits.
# echo "[4.2.G/H] Pipe subshell gotcha:"
# count=0
# printf "a\nb\nc\n" | while IFS='' read -r _; do (( count++ )); done
# echo "  BROKEN (pipe): count=$count  ← still 0, the subshell's copy was thrown away"

# count=0
# while IFS='' read -r _; do (( count++ )); done < <(printf "a\nb\nc\n")
# echo "  FIXED (process substitution): count=$count  ← correct: 3"

# pillar "3 | PRECISION — until for Bounded Polling"
#... [WHAT]: until for polling with a timeout guard [4.2.B].
#... [WHY] : Deployment scripts waiting for services need BOUNDED polling.
#...         An infinite wait hangs pipelines and costs money in CI minutes.
# echo "[4.2.B] Bounded polling with until:"
# touch "$WORKSPACE/svc_ready"   # Service is "ready" immediately for demo
# declare -i polls=0
# until [[ -f "$WORKSPACE/svc_ready" ]] || (( polls >= 10 )); do
  # (( polls++ ))
  # log_info "Waiting... attempt $polls/10"
  # sleep 0.05
# done
# [[ -f "$WORKSPACE/svc_ready" ]] \
  # && log_info "Service ready after $polls poll(s)" \
  # || log_error "Service not ready after 10 attempts"

# pillar "4 | DEVOPS — Log Streaming with while and Timeout"
#... [WHAT]: Tail a log file in a while read loop with a time limit [4.2.C/D].
#... [WHY] : Post-deployment log monitoring — watch for errors for 30 seconds,
#...         then continue. Requires a timeout to avoid indefinite blocking.
# echo "[4.2.C/D] Time-bounded log monitoring simulation:"
# printf "INFO app started\nINFO connected to db\nERROR disk full\nINFO recovered\n" \
  # > "$WORKSPACE/app.log"

# declare -i log_errors=0
# while IFS='' read -r log_line || [[ -n "$log_line" ]]; do
  # if [[ "$log_line" == *ERROR* ]]; then
    # log_warn "Log error: $log_line"
    # (( log_errors++ ))
  # else
    # log_info "Log: $log_line"
  # fi
# done < "$WORKSPACE/app.log"
# echo "  Total errors detected in log: $log_errors"


#...##############################################################################
#... SEGMENT 4.3 | LOOP CONTROL
#...##############################################################################
# section "SEGMENT 4.3 | LOOP CONTROL"

# pillar "1 | BASIC — break and continue"
#... [WHAT]: break exits the loop; continue skips the current iteration [4.3.A/C].
# echo "[4.3.A/C] break and continue:"
# printf "  Odd numbers 1-10, stopping at 7: "
# for (( n=1; n<=10; n++ )); do
  # (( n % 2 == 0 )) && continue   # Skip evens
  # (( n > 7 )) && break            # Stop at 7
  # printf "%d " "$n"
# done; echo ""

# pillar "2 | POWER — break N for Nested Loop Exit"
#... [WHAT]: break 2 exits two levels of nesting simultaneously [4.3.B].
#... [WHY] : Without break N, you need a flag variable + an extra conditional
#...         in the outer loop. break N is cleaner and expresses intent clearly.
# echo "[4.3.B] break 2 — exiting nested loops:"
# found=""
# for group in alpha beta gamma; do
  # for item in "${group}-1" "${group}-2" "TARGET" "${group}-3"; do
    # if [[ "$item" == "TARGET" ]]; then
      # found="$item in group $group"
      # break 2   # Exit BOTH inner and outer loop
    # fi
  # done
# done
# echo "  Found: ${found:-not found}"

# pillar "3 | PRECISION — continue N in Nested Loops"
#... [WHAT]: continue N skips to the next iteration of the Nth enclosing loop [4.3.D].
#... [WHY] : When processing batches of jobs, a failed job should skip the rest
#...         of that BATCH (outer loop), not just the current job (inner loop).
# echo "[4.3.D] continue 2 — skipping outer loop on inner failure:"
# declare -A job_results=([b1_j1]=ok [b1_j2]=ok [b2_j1]=ok [b2_j2]=FAIL [b3_j1]=ok [b3_j2]=ok)
# for batch in b1 b2 b3; do
  # for job in j1 j2; do
    # if [[ "${job_results[${batch}_${job}]}" == "FAIL" ]]; then
      # log_warn "Batch $batch: job $job FAILED — skipping batch"
      # continue 2
    # fi
  # done
  # log_info "Batch $batch: all jobs OK"
# done

# pillar "4 | DEVOPS — Retry Loop with Exponential Backoff"
#... [WHAT]: Combine break with retry logic and backoff [4.3.A/B].
#... [WHY] : Network calls fail transiently. Bounded retry with exponential
#...         backoff is the production standard. No bare sleep-and-loop.
# echo "[4.3.A/B] Retry with exponential backoff:"
# declare -r  MAX_RETRIES=4
# declare -i  attempt=0
# declare -i  backoff_s=1
# declare -i  succeeded=0

# while (( attempt < MAX_RETRIES )); do
  # (( attempt++ ))
  # log_info "Attempt $attempt/$MAX_RETRIES..."
  # if (( attempt >= 3 )); then   # Simulate success on attempt 3
    # log_info "Succeeded on attempt $attempt"
    # succeeded=1
    # break
  # fi
  # log_warn "Failed. Retrying in ${backoff_s}s..."
  # sleep "$backoff_s"
  # (( backoff_s *= 2 ))   # 1 → 2 → 4 → 8
# done
# (( succeeded )) || log_error "All $MAX_RETRIES attempts failed"


#...##############################################################################
#... SEGMENT 4.4 | select LOOP (MENU GENERATION)
#...##############################################################################
# section "SEGMENT 4.4 | select LOOP (MENU GENERATION)"

# pillar "1 | BASIC — select Structure and Variables"
#... [WHAT]: select auto-generates a numbered menu; PS3 sets the prompt [4.4.A-C].
#... [WHY] : select is a built-in interactive menu system in 3 lines of code.
#...         PS3 = the prompt. REPLY = raw user input. $item = selected value.
#... [HOW] : We simulate user input via heredoc (<< 'EOF'... or <<<) because
#...         this script runs non-interactively.
# echo "[4.4.A-C] select menu (simulating user input '2'):"
# PS3="Select environment: "
# selected=""
# select env_opt in development staging production quit; do
  # [[ -z "$REPLY" ]] && break        # [4.4.E] EOF/Ctrl+D guard
  # case "$env_opt" in
    # quit|"") break ;;
    # *)       selected="$env_opt"; break ;;
  # esac
# done <<< "2"   # Simulate typing '2' + Enter
# echo "  Selected: ${selected:-none}"

# pillar "2 | POWER — Input Validation in select"
#... [WHAT]: Validate REPLY before acting on a selection [4.4.C].
#... [WHY] : Users type '99', '', and random strings. Production menus must
#...         handle invalid input gracefully without crashing.
# echo "[4.4.C] Validated select (simulating invalid '99' then valid '1'):"
# PS3="Choose action: "
# actions=("deploy" "rollback" "status" "abort")
# final_action=""
# select action in "${actions[@]}"; do
  # if [[ -z "$REPLY" ]]; then break; fi    # EOF guard
  # if [[ -n "$action" ]]; then
    # final_action="$action"; break
  # else
    # echo "  Invalid choice '$REPLY' — enter 1-${#actions[@]}"
  # fi
# done <<< $'99\n1'   # Simulate: first invalid (99), then valid (1)
# echo "  Final action: ${final_action:-none}"

# pillar "3 | PRECISION — EOF Handling"
#... [WHAT]: Ctrl+D sends EOF to select, causing empty REPLY [4.4.E].
#... [WHY] : Scripts without EOF handling hang or produce confusing output
#...         when a user presses Ctrl+D instead of making a valid selection.
# echo "[4.4.E] EOF handling in select (simulating Ctrl+D via empty input):"
# PS3="Pick: "
# select item in alpha beta gamma; do
  # if [[ -z "$REPLY" ]]; then
    # echo "  EOF received — exiting menu gracefully"
    # break
  # fi
  # echo "  Selected: $item"; break
# done < /dev/null   # /dev/null immediately sends EOF
# echo "  After menu: script continues normally"

# pillar "4 | DEVOPS — Production Rollback Confirmation Prompt"
#... [WHAT]: A destructive-operation confirmation menu with select [4.4.A-E].
#... [WHY] : Rollbacks, database drops, and production secret rotations must
#...         require explicit, deliberate human confirmation — never be implicit.
# echo "[4.4.A-E] Rollback confirmation menu (simulating confirmation choice):"
# PS3="Confirm rollback to v2.3.0: "
# rb_options=("YES — execute rollback" "NO — cancel" "DETAILS — show diff")
# rb_decision=""

# select rb_opt in "${rb_options[@]}"; do
  # [[ -z "$REPLY" ]] && { echo "  EOF — cancelling"; break; }
  # case "$rb_opt" in
    # YES*)     rb_decision="confirmed"; log_warn "ROLLBACK CONFIRMED"; break ;;
    # NO*)      rb_decision="cancelled"; log_info "Rollback cancelled"; break ;;
    # DETAILS*) log_info "Changed: app.jar, config.yml, db-schema.sql" ;;
    # "")       log_warn "Invalid: '$REPLY'" ;;
  # esac
# done <<< "1"   # Simulate user typing '1' (YES)
# echo "  Decision: ${rb_decision:-none}"


#...##############################################################################
#... SEGMENT 5.1 | DEFINING AND CALLING FUNCTIONS
#...##############################################################################
# section "SEGMENT 5.1 | DEFINING AND CALLING FUNCTIONS"

# pillar "1 | BASIC — POSIX Syntax and Top-Down Parsing"
#... [WHAT]: Both function syntaxes; why POSIX form is preferred [5.1.A/B].
#... [WHY] : function name { } is Bash-only. name() { } works in sh, bash, dash.
#...         Production scripts that may run under /bin/sh MUST use POSIX form.

#... POSIX form [5.1.A] — always use this:
# greet() {
  # local -r host="$1"
  # echo "  Hello from greet(), running on: $host"
# }
#... Bash form [5.1.B] would be: function greet { ... } — NOT used here.

# echo "[5.1.A/D] POSIX function syntax and calling convention:"
# greet "$(hostname)"
# greet "simulated-prod-server"

# pillar "2 | POWER — source and Library Loading"
#... [WHAT]: Create and source a function library [5.1.F/G].
#... [WHY] : source (.) loads the file into the CURRENT shell process.
#...         bash lib.sh runs it in a CHILD — functions vanish after it exits.
# echo "[5.1.F/G] Creating and sourcing lib_network.sh:"
# cat > "$WORKSPACE/lib_network.sh" << 'LIB_EOF'
#...!/usr/bin/env bash
#... lib_network.sh — network utility library
#... Safe to source multiple times. Defines functions only, no side effects.

# validate_ip() {
  # local -r ip="${1:-}"
  # [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  # return 0
# }

# is_port_open() {
  #... Checks if a TCP port is reachable using /dev/tcp (Bash built-in)
  # local -r host="$1"; local -r port="$2"
  # (echo > /dev/tcp/"$host"/"$port") 2>/dev/null && return 0 || return 1
# }
# LIB_EOF

# source "$WORKSPACE/lib_network.sh"

# echo "  Testing validate_ip (from sourced library):"
# for ip_test in "10.0.0.1" "192.168.1.256" "not-an-ip" "172.16.0.1"; do
  # if validate_ip "$ip_test"; then
    # printf "    VALID:   %s\n" "$ip_test"
  # else
    # printf "    INVALID: %s\n" "$ip_test"
  # fi
# done

# pillar "3 | PRECISION — type for Namespace Inspection"
#... [WHAT]: type -a reveals function, alias, builtin, or external [5.1.I].
#... [WHY] : When a function doesn't behave as expected, type tells you if
#...         something else in the namespace is shadowing it.
# echo "[5.1.I] type -a namespace inspection:"
# type -a greet         # Should show: greet is a function
# type -a validate_ip   # Should show: validate_ip is a function
# type -a echo          # Shows: echo is a shell builtin + /bin/echo
# type -a ls            # Shows: external only

# pillar "4 | DEVOPS — ShellShock Awareness (export -f)"
#... [WHAT]: export -f makes functions available to child processes [5.1.H].
#... [WHY] : ShellShock (CVE-2014-6271) exploited how Bash processed exported
#...         functions. Knowing this demonstrates security awareness — a Toptal
#...         Principal-level differentiator.
# echo "[5.1.H] export -f and ShellShock awareness:"
# safe_func() { echo "  safe_func running in child PID $BASHPID"; }
# export -f safe_func

# bash -c 'safe_func'

# echo ""
# echo "  ShellShock context:"
# echo "  Bash <= 4.2 would execute trailing code in exported function vars:"
# echo "  e.g.: FOO='() { :; }; malicious_cmd'   ← code after }; would execute"
# echo "  PATCHED in Bash 4.3. Always ensure Bash 4.3+ in production."
# echo "  MITIGATE: never export -f to untrusted child processes."


#...##############################################################################
#... SEGMENT 5.2 | ARGUMENTS AND RETURN VALUES
#...##############################################################################
# section "SEGMENT 5.2 | ARGUMENTS AND RETURN VALUES"

# pillar "1 | BASIC — Two Return Mechanisms"
#... [WHAT]: return N (exit code) vs stdout capture [5.2.B/E/F].
#... [WHY] : Confusing these is the most common function design mistake.
#...         Use return codes to signal pass/fail. Use stdout for data.
#...         Never use exit inside a library function.

# is_even() {
  # local -i n="$1"
  # (( n % 2 == 0 )) && return 0 || return 1   # [5.2.B] exit code = result
# }

# timestamp_now() {
  # date '+%Y-%m-%dT%H:%M:%S'   # [5.2.E] data via stdout — caller uses $()
# }

# echo "[5.2.B] Exit-code return tested with if:"
# for n in 2 3 4 7 10; do
  # if is_even "$n"; then
    # printf "  %2d: even\n" "$n"
  # else
    # printf "  %2d: odd\n" "$n"
  # fi
# done

# echo ""
# echo "[5.2.E] Stdout capture return:"
# ts=$(timestamp_now)
# echo "  Captured: $ts"

# pillar "2 | POWER — local Scoping"
#... [WHAT]: local prevents function variable pollution of global scope [5.2.I-M].
#... [WHY] : Without local, every variable in every function is global. In a
#...         500-line script, two functions both using 'i' silently corrupt each other.
#... [WATCH OUT]: This is the #1 cause of mystery bugs in shell scripts.
# global_counter=100

# without_local() {
  # global_counter=0          # FOOTGUN: overwrites the caller's global
  # echo "  inside without_local: global_counter=$global_counter"
# }

# with_local() {
  # local global_counter=999  # [5.2.I] Isolated — caller's copy is untouched
  # echo "  inside with_local:    global_counter=$global_counter"
# }

# echo "[5.2.I] Variable scope demonstration:"
# echo "  Before: global_counter=$global_counter"
# with_local
# echo "  After with_local:    global_counter=$global_counter  ← unchanged (correct)"
# without_local
# echo "  After without_local: global_counter=$global_counter  ← CORRUPTED"

# pillar "3 | PRECISION — Namerefs for Array Pass-by-Reference"
#... [WHAT]: declare -n passes arrays by reference to functions [5.2.N].
#... [WHY] : Arrays CANNOT be passed as arguments in Bash — you'd serialize them
#...         and lose the original. Namerefs give the function a true alias to
#...         the caller's array — modifications are reflected immediately.
#... [WATCH OUT]: Bash 4.3+ only. The nameref variable name MUST NOT match the
#...              caller's array name — use a unique internal name (prefix with _).
# echo "[5.2.N] Nameref — array pass-by-reference (Bash 4.3+):"

# append_log_entry() {
  # declare -n _log="$1"    # _log is now an alias for caller's array
  # local -r  entry="$2"
  # _log+=("$(date '+%H:%M:%S') $entry")
# }

# declare -a deploy_events=()
# append_log_entry deploy_events "image pulled"
# append_log_entry deploy_events "container started"
# append_log_entry deploy_events "health check passed"

# echo "  deploy_events array (modified in-place via nameref):"
# for e in "${deploy_events[@]}"; do echo "    $e"; done

# pillar "4 | DEVOPS — Production-Grade Structured Logging Library"
#... [WHAT]: Assemble the full function toolkit into a production log library.
#... [WHY] : This is what Toptal-calibre code looks like: typed locals, FUNCNAME
#...         for caller context, BASH_LINENO for line numbers, return codes for
#...         composability, and stdout/stderr separation.
# echo "[5.1-5.2] Production logging library in action:"

# __structured_log() {
  # local -r level="$1"; shift
  # local -r message="$*"
  # local -r caller="${FUNCNAME[1]:-main}"
  # local -r lineno="${BASH_LINENO[0]}"
  # local    ts; ts=$(date '+%Y-%m-%dT%H:%M:%S')
  # printf "[%s] [%-5s] [%s:%s] %s\n" "$ts" "$level" "$caller" "$lineno" "$message" >&2
# }

# slog_info()  { __structured_log "INFO"  "$@"; }
# slog_warn()  { __structured_log "WARN"  "$@"; }
# slog_error() { __structured_log "ERROR" "$@"; return 1; }

# run_deploy_step() {
  # local -r step_name="$1"
  # local -i simulate_pass="$2"
  # slog_info "Starting: $step_name"
  # if (( simulate_pass )); then
    # slog_info "PASS: $step_name completed"
    # return 0
  # else
    # slog_error "FAIL: $step_name" || true
    # return 1
  # fi
# }

# run_deploy_step "pull_image"   1
# run_deploy_step "run_tests"    1
# run_deploy_step "push_to_reg"  1


#...##############################################################################
#... FINAL SUMMARY
#...##############################################################################
# section "ALL 20 SEGMENTS COMPLETE — Modules 1–5"

# echo "  Segment coverage:"
# printf "  %-8s %s\n" "1.1" "Unix mental model, /proc, builtins vs externals, fork/execve"
# printf "  %-8s %s\n" "1.2" "TTY/PTY detection, shell type, cron env simulation"
# printf "  %-8s %s\n" "1.3" "Version gating, tool checks, GNU vs BSD, pre-flight function"
# printf "  %-8s %s\n" "1.4" "Exit code contract, BASH_SOURCE self-location, bash -n in CI"
# printf "  %-8s %s\n" "2.1" "declare -i/-r/-x/-p, typed vars, unset+set-u danger"
# printf "  %-8s %s\n" "2.2" "All 4 quoting modes, IFS split, nullglob, rm \$file trap"
# printf "  %-8s %s\n" "2.3" "export, env -i, per-command VAR=val, PATH injection defence"
# printf "  %-8s %s\n" "2.4" "21 parameter expansion forms — all without subshells"
# printf "  %-8s %s\n" "2.5" "\$@ vs \$*, \$\$/\$BASHPID/\$!, FUNCNAME stack trace, SECONDS jitter"
# printf "  %-8s %s\n" "3.1" "[ ] operators: all -eq/-lt/-gt/-z/-n/-f/-d/-e/-r/-w/-x/-L"
# printf "  %-8s %s\n" "3.2" "[[ ]] glob/regex, BASH_REMATCH, no word-split safety"
# printf "  %-8s %s\n" "3.3" "if/elif/else, command conditions, !, compound {}, deploy gate"
# printf "  %-8s %s\n" "3.4" "case dispatch, glob patterns, ;& fall-through, CLI dispatcher"
# printf "  %-8s %s\n" "3.5" "&& / || mechanics, false-ternary trap, || error handling"
# printf "  %-8s %s\n" "4.1" "List/brace/C-style for, nullglob fix, \"\$@\" inventory dispatch"
# printf "  %-8s %s\n" "4.2" "while read idiom, pipe-subshell fix, until polling, last-line fix"
# printf "  %-8s %s\n" "4.3" "break/continue/N, nested exit, exponential backoff retry"
# printf "  %-8s %s\n" "4.4" "select, PS3/REPLY, EOF guard, non-interactive testing, rollback"
# printf "  %-8s %s\n" "5.1" "POSIX syntax, source vs bash, type inspection, ShellShock"
# printf "  %-8s %s\n" "5.2" "return vs exit, local scoping footgun, nameref arrays, slog lib"

# echo ""
# log_info "Completed in $SECONDS second(s). Sandbox cleanup on EXIT."
# echo ""
#... trap EXIT runs: rm -rf "$WORKSPACE"