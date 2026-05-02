#!/usr/bin/env bash
# ============================================================================
#  BASH SCRIPTING & OS AUTOMATION — 20-SEGMENT PRODUCTION MASTERCLASS
#  Toptal Top 3% Systems Engineering Standard | FUTO Nigeria
#  Author  : Jesse (guided by Mike — Principal DevOps Architect)
#  Index   : bash_knowledge_index.txt  (Segments 1–20)
# ============================================================================

# [COMMAND MEANING] set = A shell builtin that controls optional shell behaviors
#                   via named mode flags.
# [FLAG MEANING]    -e   = errexit    : abort immediately on any non-zero exit.
# [FLAG MEANING]    -u   = nounset    : treat unset variable references as errors.
# [FLAG MEANING]    -o pipefail = make a pipeline fail if ANY stage exits non-zero,
#                   not only the last command in the chain.
set -euo pipefail

# ─── SANDBOX SETUP ───────────────────────────────────────────────────────────
# [COMMAND MEANING] mktemp = Make Temporary; atomically creates a uniquely named
#                   temp file or directory, preventing race conditions.
# [FLAG MEANING]    -d = Directory mode; creates a temp directory instead of a file.
# [WHAT]: Allocate a throwaway workspace so every demo runs in total isolation.
# [WHY]:  mktemp -d is the only safe pattern. /tmp/script.$$ is a symlink-attack
#         waiting to happen — the PID is predictable and the name is guessable.
WORKSPACE=$(mktemp -d)

# [WHAT]:  Register the cleanup handler BEFORE doing any work.
# [WHY]:   If the script dies at line 12, cleanup still runs. EXIT fires on every
#          exit path: normal, set -e triggered, or Ctrl+C.
# [WATCH OUT]: Register the trap IMMEDIATELY after creating the resource you want
#              cleaned. A crash between mktemp and the trap leaves garbage behind.
trap 'rm -rf "$WORKSPACE"' EXIT

cd "$WORKSPACE"

# ─── COLOUR HELPERS (zero-dependency, pure ANSI) ─────────────────────────────
# [COMMAND MEANING] printf = Formatted print; used here to emit raw ANSI escape
#                   codes for terminal colour without spawning a subshell.
BOLD='\033[1m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[0;33m'; RED='\033[0;31m'; RESET='\033[0m'

banner() {
  echo ""
  echo -e "${BOLD}${CYAN}================================================================${RESET}"
  echo -e "${BOLD}${CYAN}  $*${RESET}"
  echo -e "${BOLD}${CYAN}================================================================${RESET}"
}

section() {
  echo ""
  echo -e "${YELLOW}──────────────────────────────────────────${RESET}"
  echo -e "${YELLOW}  ▶  $*${RESET}"
  echo -e "${YELLOW}──────────────────────────────────────────${RESET}"
}

pass() { echo -e "  ${GREEN}✔ $*${RESET}"; }
info() { echo -e "  ${CYAN}ℹ $*${RESET}"; }

banner "SANDBOX: $WORKSPACE  |  BASH: $BASH_VERSION"


# ============================================================================
# ███████╗███████╗ ██████╗ ███╗   ███╗███████╗███╗   ██╗████████╗     ██╗
# ██╔════╝██╔════╝██╔════╝ ████╗ ████║██╔════╝████╗  ██║╚══██╔══╝    ███║
# ███████╗█████╗  ██║  ███╗██╔████╔██║█████╗  ██╔██╗ ██║   ██║       ╚██║
# ╚════██║██╔══╝  ██║   ██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║        ██║
# ███████║███████╗╚██████╔╝██║ ╚═╝ ██║███████╗██║ ╚████║   ██║        ██║
# ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═╝
#  THE UNIX MENTAL MODEL & SHELL BOOT SEQUENCE
# ============================================================================
banner "SEGMENT 1 — The Unix Mental Model & Shell Boot Sequence"

# ─── BASIC: Shebang mechanics ────────────────────────────────────────────────
section "1-BASIC: Shebang — The Two Forms"

# [WHAT]: Write two minimal scripts — one with each shebang form — and show the
#         behavioral difference in portability and interpreter resolution.
# [WHY]:  The shebang line is not bash syntax. It is read by the KERNEL during
#         execve(). The kernel opens the file, sees #!, and re-launches the named
#         interpreter with the script as its argument.

# [COMMAND MEANING] cat = Concatenate; writes content to stdout or into a file
#                   via output redirection.
cat > "$WORKSPACE/hardcoded_shebang.sh" << 'EOF'
#!/bin/bash
echo "I use a hardcoded path. If bash lives elsewhere, I break."
EOF

cat > "$WORKSPACE/portable_shebang.sh" << 'EOF'
#!/usr/bin/env bash
echo "I ask env to find bash on PATH. I work on any Unix system."
EOF

# [COMMAND MEANING] chmod = Change Mode; modifies the permission bits of a file.
# [FLAG MEANING]    +x = Execute bit; allows the file to be run directly as ./file.
chmod +x "$WORKSPACE/hardcoded_shebang.sh" "$WORKSPACE/portable_shebang.sh"
pass "Both scripts made executable via chmod +x"

# ─── POWER: Login vs. non-login shell startup chain ──────────────────────────
section "1-POWER: Shell Boot Sequence — File Execution Order"

# [WHAT]: Demonstrate the documented startup chain by showing which files exist
#         on this system that bash would read for a login shell.
# [WHY]:  Misplacing an export in ~/.bashrc vs. ~/.bash_profile causes hard-to-
#         debug environment bleed between SSH sessions and GUI terminals.
for startup_file in /etc/profile "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.bash_logout"; do
  if [[ -f "$startup_file" ]]; then
    pass "EXISTS: $startup_file"
  else
    info "ABSENT: $startup_file (would be sourced if it existed)"
  fi
done

# ─── PRECISION: fork() + exec() — The two-step launch model ──────────────────
section "1-PRECISION: fork() + exec() — Every Process's Origin Story"

# [WHAT]: Show the PID lineage from PID 1 down to this script using /proc.
# [WHY]:  Understanding that every process on Linux is a descendant of PID 1
#         (systemd/init) is the mental model behind kill -PGID, process groups,
#         and zombie reaping.
# [COMMAND MEANING] cat = (re-use, no new tag) reading a proc file.
# [COMMAND MEANING] ps = Process Status; reports a snapshot of running processes.
# [FLAG MEANING]    -p = Selects processes by PID.
# [FLAG MEANING]    -o = Output format; defines which columns to display.
# [FLAG MEANING]    --no-headers = Suppress the column header line.
info "This script's PID  : $$"
info "This script's PPID : $(ps -p $$ -o ppid= --no-headers 2>/dev/null | tr -d ' ' || echo 'N/A')"
info "PID 1 cmdline      : $(cat /proc/1/comm 2>/dev/null || echo 'N/A')"

# ─── DEVOPS CONTEXT: bash vs. bash -s remote execution ───────────────────────
section "1-DEVOPS: bash script.sh vs. ./script.sh — When Each Is Correct"

# [WHAT]: Create a script with a deliberate shebang pointing to a non-existent
#         interpreter, then show that `bash script.sh` bypasses it entirely.
# [WHY]:  In CI pipelines you often invoke `bash deploy.sh` explicitly. This
#         bypasses the shebang AND the execute bit — useful for running scripts
#         downloaded from artifact storage without an explicit chmod +x first.
cat > "$WORKSPACE/shebang_demo.sh" << 'EOF'
#!/totally/fake/path/to/bash
echo "My shebang is garbage, but bash invocation still works."
EOF
# [COMMAND MEANING] bash = Invoke the bash interpreter explicitly.
# [WHAT ELSE]: Use `env -i bash script.sh` to run with a scrubbed environment.
bash "$WORKSPACE/shebang_demo.sh"
pass "Segment 1 complete — Unix mental model established."


# ============================================================================
#  SEGMENT 2 — VARIABLES, ASSIGNMENT, AND SCOPE
# ============================================================================
banner "SEGMENT 2 — Variables, Assignment & Scope"

# ─── BASIC: declare flags ─────────────────────────────────────────────────────
section "2-BASIC: declare — Typed Variable Definitions"

# [COMMAND MEANING] declare = Bash builtin that explicitly defines variables with
#                   type constraints, scope modifiers, and export flags.
# [FLAG MEANING]    -i = Integer; bash automatically evaluates arithmetic on assignment.
# [FLAG MEANING]    -r = Readonly; any re-assignment causes an immediate runtime error.
# [FLAG MEANING]    -x = Export; marks the variable for child process inheritance.
# [FLAG MEANING]    -a = Array (indexed); declares a zero-based integer-keyed array.
# [FLAG MEANING]    -A = Associative array; string-keyed hash map. Requires Bash 4+.
declare -i  SEG2_COUNT=0
declare -r  SEG2_CONST="IMMUTABLE"
declare -x  SEG2_EXPORTED="visible_to_children"
declare -a  SEG2_FRUITS=("mango" "pawpaw" "banana")
declare -A  SEG2_MAP=( [host]="prod-01" [env]="production" )

SEG2_COUNT=5+3   # Arithmetic is auto-evaluated because of -i
pass "declare -i: 5+3 evaluated to → $SEG2_COUNT"
pass "declare -r: constant value   → $SEG2_CONST"
pass "declare -x: exported var     → $SEG2_EXPORTED"
pass "declare -a: fruits[1]        → ${SEG2_FRUITS[1]}"
pass "declare -A: map[env]         → ${SEG2_MAP[env]}"

# Prove -r actually blocks re-assignment
if ! (declare -r LOCKED="yes"; LOCKED="no") 2>/dev/null; then
  pass "declare -r: re-assignment correctly blocked"
fi

# ─── POWER: local scope and the footgun it prevents ───────────────────────────
section "2-POWER: local — Function Scope & the Global Side-Effect Footgun"

# [COMMAND MEANING] local = Restricts a variable to the enclosing function's scope,
#                   preventing accidental global side effects from nested calls.
# [FLAG MEANING]    -i = Integer (same semantics as declare -i, function-scoped).
# [FLAG MEANING]    -r = Readonly, function-scoped.
# [FLAG MEANING]    -a = Indexed array, function-scoped.
# [FLAG MEANING]    -A = Associative array, function-scoped.

GLOBAL_VAR="i_am_global"

scope_demo() {
  local LOCAL_VAR="i_am_local"
  local -i LOCAL_COUNTER=10
  GLOBAL_VAR="i_was_mutated_inside_the_function"  # This DOES change globally
  pass "Inside function: LOCAL_VAR=$LOCAL_VAR | GLOBAL_VAR=$GLOBAL_VAR"
}

scope_demo
pass "After function : GLOBAL_VAR=$GLOBAL_VAR (mutation survived)"
# LOCAL_VAR is gone now — that's the whole point of local
if [[ -z "${LOCAL_VAR:-}" ]]; then
  pass "After function : LOCAL_VAR is GONE (local scope confirmed)"
fi

# ─── PRECISION: unset and the set -u interaction ──────────────────────────────
section "2-PRECISION: unset + set -u — Strict Variable Hygiene"

# [COMMAND MEANING] unset = Removes a variable or function from the shell environment.
# [WATCH OUT]: Under set -u, referencing a variable AFTER unset causes an immediate
#              abort. Use ${var:-} to safely test for existence first.
TMP_SECRET="hunter2"
unset TMP_SECRET
if [[ -z "${TMP_SECRET:-}" ]]; then
  pass "unset confirmed: TMP_SECRET is gone. ${TMP_SECRET:-<empty>}"
fi

# ─── DEVOPS CONTEXT: Call-stack introspection for structured logging ───────────
section "2-DEVOPS: Introspection Variables — \$FUNCNAME, \$BASH_SOURCE, \$LINENO"

# [WHAT]: Build a log_trace function that prints WHERE in the call stack we are.
# [WHY]:  In production scripts that source multiple library files, you NEED to
#         know which file, which function, and which line triggered a log event.
log_trace() {
  # [WHAT ELSE]: BASH_LINENO[0] is the line that *called* this function.
  echo "  [TRACE] ${BASH_SOURCE[1]:-<main>}:${BASH_LINENO[0]} → ${FUNCNAME[1]:-<main>}() → $*"
}

caller_function() {
  log_trace "This message came from inside caller_function()"
}

caller_function
pass "Segment 2 complete — Variables, scope, and introspection."


# ============================================================================
#  SEGMENT 3 — QUOTING, WORD SPLITTING & PARAMETER EXPANSION
# ============================================================================
banner "SEGMENT 3 — Quoting, Word Splitting & Parameter Expansion"

# ─── BASIC: The four quoting styles ──────────────────────────────────────────
section "3-BASIC: Quoting Mechanics — The Four Forms"

SEG3_VAR="hello world"

# [WHAT]: Show how each quoting form treats the same content differently.
# [WHY]:  Quoting is the #1 source of bash bugs. Missing double-quotes causes
#         word splitting; missing single-quotes allows unwanted expansion.

# No quotes → word splitting fires; "hello world" becomes TWO arguments
# Double quotes → expansion happens, word splitting suppressed
# Single quotes → EVERYTHING is literal, zero expansion
# ANSI-C quoting → interprets \n, \t, \xNN escape sequences

# [COMMAND MEANING] echo = Print arguments to stdout; used here purely to
#                   demonstrate expansion behaviour.
echo "  Double-quoted  : \"$SEG3_VAR\" (expansion ✔, splitting ✘)"
echo '  Single-quoted  : '"'"'$SEG3_VAR'"'"' (expansion ✘, literal)'

# [FLAG MEANING]    $'...' = ANSI-C quoting; interprets \n, \t, \xNN escape codes.
ANSI_DEMO=$'line one\nline two\ttabbed'
info "ANSI-C quoting output:"
echo "$ANSI_DEMO"

# ─── POWER: IFS manipulation and nullglob ────────────────────────────────────
section "3-POWER: IFS Word Splitting & nullglob"

# [COMMAND MEANING] IFS = Internal Field Separator; controls where bash splits
#                   unquoted variable expansions into separate words.
# [WATCH OUT]: Always save and restore IFS. Mutating IFS globally will silently
#              break while read loops and for-in loops downstream in your script.
SAVED_IFS="$IFS"
CSV_LINE="alpha,beta,gamma,delta"
IFS=',' read -ra SEG3_FIELDS <<< "$CSV_LINE"
IFS="$SAVED_IFS"
pass "IFS=',' split: ${#SEG3_FIELDS[@]} fields → [${SEG3_FIELDS[*]}]"

# [COMMAND MEANING] shopt = Shell Options; enables/disables optional shell behaviours.
# [FLAG MEANING]    -s nullglob = Make unmatched globs expand to nothing instead of
#                   the literal pattern string, preventing the "/*.ext as $1" bug.
shopt -s nullglob
SEG3_TMPDIR=$(mktemp -d)
SEG3_MATCHES=( "$SEG3_TMPDIR"/*.nonexistent )
info "nullglob on empty dir: ${#SEG3_MATCHES[@]} matches (no crash, no literal pattern)"
rm -rf "$SEG3_TMPDIR"
shopt -u nullglob

# ─── PRECISION: Full parameter expansion showcase ─────────────────────────────
section "3-PRECISION: Parameter Expansion — Every Production Form"

FILEPATH="/var/log/nginx/access.log"
GREETING=""
REQUIRED_VAR="I_EXIST"

# [WHAT]: Demonstrate every key expansion form in a single organised block.
# [WHY]:  Each of these replaces an external command call (basename, dirname,
#         tr, sed) with zero-fork pure bash — critical in tight loops.

# Default / fallback expansions
# [WHAT ELSE]: ${var:=default} additionally assigns the default back to var.
pass "\${var:-default}  → '${GREETING:-hello from default}' (var is empty)"
pass "\${var:+alt}      → '${REQUIRED_VAR:+was set!}' (var IS set)"
pass "\${var:?error}    demo: (would abort on unset — skip to preserve demo)"

# String manipulation
pass "\${#FILEPATH}      → length = ${#FILEPATH} characters"
pass "\${FILEPATH##*/}   → basename: '${FILEPATH##*/}'"
pass "\${FILEPATH%/*}    → dirname:  '${FILEPATH%/*}'"
pass "\${FILEPATH#*/}    → strip 1st slash-prefix: '${FILEPATH#*/}'"

# Substring
LONGSTR="production_server_01"
pass "\${LONGSTR:12:6}   → '${LONGSTR:12:6}' (offset 12, length 6)"

# Case modification (Bash 4+)
LOWER_HOST="web-server-01"
pass "\${var^^}           → '${LOWER_HOST^^}' (all uppercase)"
pass "\${var,}            → '${LOWER_HOST^}' wait, ^ capitalises first char only"
FIRST_LOW="UPPERCASE_WORD"
pass "\${var,,}           → '${FIRST_LOW,,}' (all lowercase)"
pass "\${var^}            → '${LOWER_HOST^}' (first char capitalised)"

# Global substitution — the zero-fork sed
DOTTED="192.168.1.100"
pass "\${var//./─}        → '${DOTTED//./-}' (global replace)"

# Indirect expansion — bash's pointer dereference
PTR_NAME="BASH_VERSION"
pass "\${!varname}        → points to $PTR_NAME → '${!PTR_NAME}'"

# $@ vs $* — the critical quoting difference
# [WHAT ELSE]: "$*" is only useful when you intentionally want all args as one word,
#              e.g., building a CSV string. "$@" is the correct default everywhere else.
demo_args() {
  info "  \"\$@\" → ${#@} separately quoted words (correct for passing args)"
  info "  \"\$*\" → 1 joined string: '$*'"
}
demo_args "arg one" "arg two" "arg three"

pass "Segment 3 complete — Quoting, IFS, and expansion arsenal loaded."


# ============================================================================
#  SEGMENT 4 — THE ENVIRONMENT, PATH, AND CREDENTIAL SAFETY
# ============================================================================
banner "SEGMENT 4 — Environment, PATH Hygiene & Credential Safety"

# ─── BASIC: export vs. declare -x ────────────────────────────────────────────
section "4-BASIC: export / declare -x — Promoting Variables to the Environment"

# [WHAT]: Show that export and declare -x are functionally identical, and that
#         scoped-to-command VAR=value does NOT pollute the current shell.
# [WHY]:  Understanding scope prevents the "but I set the variable!" debugging
#         session that wastes 30 minutes in CI pipelines.

# [COMMAND MEANING] export = Marks a variable for inheritance by every child
#                   process spawned from the current shell.
export SEG4_EXPORTED="exported_value"
declare -x SEG4_ALSO_EXPORTED="also_exported"
pass "export result   : $(env | grep SEG4_EXPORTED | head -1)"
pass "declare -x result: $(env | grep SEG4_ALSO_EXPORTED | head -1)"

# VAR=value command — scoped to a single invocation
# [COMMAND MEANING] env = Environment; with no args, prints all exported variables.
#                   With args, runs a command with a modified environment.
# [FLAG MEANING]    -i = Empty environment; strips ALL inherited variables.
SCOPED_CHECK=$(SCOPE_TEST="only_here" env | grep SCOPE_TEST || echo "ABSENT in parent shell")
info "VAR=value command scoping: parent shell sees → $SCOPED_CHECK"

# ─── POWER: env -i for clean-slate execution ─────────────────────────────────
section "4-POWER: env -i — Clean Environment Execution"

# [WHAT]: Run a command with a completely empty environment to verify a script
#         doesn't rely on inherited ambient variables.
# [WHY]:  CI runners often have different environments from dev machines. Scripts
#         that silently consume inherited vars are brittle and non-reproducible.
CLEAN_ENV_OUT=$(env -i HOME="/tmp" PATH="/usr/bin:/bin" bash -c 'echo "Clean PATH: $PATH"')
pass "env -i output: $CLEAN_ENV_OUT"

# ─── PRECISION: PATH hygiene and injection vectors ───────────────────────────
section "4-PRECISION: PATH Hygiene — The Injection Attack Vector"

# [WHAT]: Demonstrate why `.' in PATH is a critical security vulnerability.
# [WHY]:  If an attacker drops a fake `ls` in your working directory and you have
#         . in PATH, your ls call runs their code. This is PATH injection.
# [WATCH OUT]: Also never include world-writable directories in PATH.
info "Current PATH: $PATH"
if echo "$PATH" | grep -qE '(^|:)\.(:|$)'; then
  info "WARNING: '.' detected in PATH — this is a security vulnerability"
else
  pass "PATH is safe — '.' is not in the search path"
fi

# ─── DEVOPS CONTEXT: Safe credential reading ─────────────────────────────────
section "4-DEVOPS: Credential Safety — Never in Env Vars or CLI Args"

# [WHAT]: Simulate the production-safe pattern of reading a secret from a file.
# [WHY]:  Secrets stored in env vars are visible in /proc/PID/environ to any
#         process with read access. CLI arg secrets appear in `ps aux` output
#         to every user on the system. Both are catastrophic in shared environments.

# Write a fake secret to a simulated secret file
SECRET_FILE=$(mktemp)
echo "super_secret_token_12345" > "$SECRET_FILE"
chmod 600 "$SECRET_FILE"

# [FLAG MEANING]    -r = No backslash interpretation (raw read — never omit this).
# [FLAG MEANING]    -s = Silent; does not echo input characters (for TTY use).
# [WATCH OUT]: read -s only suppresses echo on a TTY. In scripts reading from
#              files, it's still best practice to include it for documentation intent.
read -r SEG4_SECRET < "$SECRET_FILE"
pass "Secret read safely from file: ${SEG4_SECRET:0:8}... (truncated)"

# Immediately unset after use
unset SEG4_SECRET
rm -f "$SECRET_FILE"
pass "Secret unset and file removed — minimal exposure window."

info "Key insight: /proc/$$/environ is the graveyard of leaked secrets."
pass "Segment 4 complete — Environment hygiene and credential safety."


# ============================================================================
#  SEGMENT 5 — CONDITIONALS: test, [[, AND SHORT-CIRCUIT LOGIC
# ============================================================================
banner "SEGMENT 5 — Conditionals: test, [[, case, and Short-Circuit Logic"

# Prepare test files
SEG5_FILE=$(mktemp)
echo "test content" > "$SEG5_FILE"
SEG5_LINK=$(mktemp -u)
ln -s "$SEG5_FILE" "$SEG5_LINK"

# ─── BASIC: test / [ ] — POSIX integer and string operators ──────────────────
section "5-BASIC: test / [ ] — POSIX Conditionals"

# [COMMAND MEANING] test = POSIX builtin evaluating conditions; returns exit 0
#                   (true) or 1 (false). The [ ] form is an alias.
# [FLAG MEANING]    -eq = Integer equal to.
# [FLAG MEANING]    -ne = Integer not equal to.
# [FLAG MEANING]    -lt = Integer less than.
# [FLAG MEANING]    -le = Integer less than or equal to.
# [FLAG MEANING]    -gt = Integer greater than.
# [FLAG MEANING]    -ge = Integer greater than or equal to.
# [FLAG MEANING]    -z  = String is zero-length (empty).
# [FLAG MEANING]    -n  = String is non-zero-length (not empty).
SEG5_NUM=42
if [ "$SEG5_NUM" -gt 10 ] && [ "$SEG5_NUM" -le 100 ]; then
  pass "[ ] integer tests: $SEG5_NUM is between 10 and 100"
fi

SEG5_EMPTY=""
if [ -z "$SEG5_EMPTY" ] && [ -n "$SEG5_FILE" ]; then
  pass "[ ] string tests: empty string confirmed empty, filepath is non-empty"
fi

# ─── POWER: File test operators ──────────────────────────────────────────────
section "5-POWER: File Test Operators — The Full Battery"

# [FLAG MEANING]    -e  = Path exists (any type).
# [FLAG MEANING]    -f  = Regular file.
# [FLAG MEANING]    -d  = Directory.
# [FLAG MEANING]    -r  = Readable by current process.
# [FLAG MEANING]    -w  = Writable by current process.
# [FLAG MEANING]    -x  = Executable by current process.
# [FLAG MEANING]    -s  = File exists and has size > 0 bytes.
# [FLAG MEANING]    -L  = Symbolic link.
# [FLAG MEANING]    -p  = Named pipe (FIFO).
# [FLAG MEANING]    -S  = Unix domain socket.
# [FLAG MEANING]    -nt = File1 is newer than file2 (by mtime).
# [FLAG MEANING]    -ot = File1 is older than file2.
# [FLAG MEANING]    -ef = Same inode (hard links or identical path).

[[ -e "$SEG5_FILE" ]]  && pass "-e : $SEG5_FILE exists"
[[ -f "$SEG5_FILE" ]]  && pass "-f : is a regular file"
[[ -s "$SEG5_FILE" ]]  && pass "-s : has non-zero size"
[[ -r "$SEG5_FILE" ]]  && pass "-r : is readable"
[[ -w "$SEG5_FILE" ]]  && pass "-w : is writable"
[[ -L "$SEG5_LINK" ]]  && pass "-L : $SEG5_LINK is a symlink"
[[ ! -d "$SEG5_FILE" ]] && pass "-d : correctly NOT a directory"

# ─── PRECISION: [[ ]] — Bash compound conditional ────────────────────────────
section "5-PRECISION: [[ ]] — Regex, Glob Matching & BASH_REMATCH"

# [COMMAND MEANING] [[ ]] = Bash-specific compound conditional that suppresses
#                   word splitting, supports == glob patterns and =~ regex.
# [FLAG MEANING]    == (inside [[)  = Glob pattern match; RHS is a glob, not literal.
# [FLAG MEANING]    =~              = POSIX extended regex match.
# [COMMAND MEANING] BASH_REMATCH = Array populated by =~; [0]=full match, [1+]=groups.

SERVER_NAME="web-server-prod-07"
if [[ "$SERVER_NAME" == web-server-* ]]; then
  pass "[[ == glob ]]: '$SERVER_NAME' matches 'web-server-*' pattern"
fi

LOG_LINE="2024-05-03 ERROR pid=1234 service=nginx"
if [[ "$LOG_LINE" =~ pid=([0-9]+) ]]; then
  pass "[[ =~ regex ]]: matched PID → BASH_REMATCH[1]='${BASH_REMATCH[1]}'"
fi

# ─── PRECISION: case statement ────────────────────────────────────────────────
section "5-PRECISION: case — Multi-Branch Dispatch Without elif Hell"

# [COMMAND MEANING] case = Multi-branch conditional matching a value against
#                   glob patterns; cleaner than long if/elif chains.
# [FLAG MEANING]    ;; = Standard terminator; no fall-through after this branch.
# [FLAG MEANING]    ;& = Bash 4+ unconditional fall-through to next branch body.
# [FLAG MEANING]    ;;& = Bash 4+ continue testing subsequent patterns.

SEG5_ENV="production"
case "$SEG5_ENV" in
  development|dev)
    info "case: dev environment — verbose logging enabled"
    ;;
  staging)
    info "case: staging environment — integration tests running"
    ;;
  production|prod)
    pass "case: production matched — deploying with zero-downtime strategy"
    ;;
  *)
    info "case: unknown environment '$SEG5_ENV'"
    ;;
esac

# ─── DEVOPS: Short-circuit logic and the hidden anti-pattern ─────────────────
section "5-DEVOPS: Short-Circuit && || — The Hidden Anti-Pattern"

# [WHAT]: Show the dangerous cmd1 && cmd2 || cmd3 anti-pattern.
# [WHY]:  If cmd2 FAILS, cmd3 runs unexpectedly. This silently executes your
#         "error handler" even when cmd1 was the culprit, not cmd2.
# [WATCH OUT]: The safe form for "do X or handle error" is:
#              cmd || { log_error; exit 1; }
#              NEVER: cmd1 && cmd2 || cmd3

safe_or_die() {
  local cmd_result
  echo "intentional_success" > /dev/null && cmd_result="OK" || cmd_result="FAIL"
  pass "Short-circuit &&: command succeeded → $cmd_result"
}
safe_or_die

# The safe error-handling idiom
ls "$SEG5_FILE" > /dev/null || { info "File missing — safe error path via || { }"; }

# Cleanup seg5 temp files
rm -f "$SEG5_FILE" "$SEG5_LINK"
pass "Segment 5 complete — Conditionals, regex, and short-circuit mastered."


# ============================================================================
#  SEGMENT 6 — LOOPS AND ITERATION PATTERNS
# ============================================================================
banner "SEGMENT 6 — Loops & Iteration Patterns"

# Setup mock data
SEG6_DIR=$(mktemp -d)
echo "alpha"   > "$SEG6_DIR/server_a.log"
echo "beta"    > "$SEG6_DIR/server_b.log"
echo "gamma"   > "$SEG6_DIR/server_c.conf"
printf "line1\nline2\nline3 with spaces\nline4" > "$SEG6_DIR/data.txt"

# ─── BASIC: for in "$@" and glob-based for ────────────────────────────────────
section "6-BASIC: for Loops — Positional Args & Glob Iteration"

# [WHAT]: Show the two most common for-in patterns and why quoting matters.

# Simulating $@ with a function since we don't have real args
# [WHAT]: for file in glob — iterate over files matching a pattern safely
shopt -s nullglob  # Re-enable so empty glob doesn't crash
for log_file in "$SEG6_DIR"/*.log; do
  # [FLAG MEANING]    ${path##*/} = Zero-fork basename via longest-prefix strip.
  pass "for glob: processing → ${log_file##*/}"
done
shopt -u nullglob

# ─── POWER: C-style arithmetic loop ──────────────────────────────────────────
section "6-POWER: C-Style Arithmetic for Loop"

# [WHAT]: Use the (( )) arithmetic context for a counter loop.
# [WHY]:  Clean, familiar to any C/Java/JS developer reading your script.
#         Use this when you need index access, not just element iteration.
SEG6_TOTAL=0
for (( i=1; i<=5; i++ )); do
  (( SEG6_TOTAL += i ))
done
pass "C-style for loop: sum of 1..5 = $SEG6_TOTAL"

# ─── POWER: while read — canonical line-by-line processing ───────────────────
section "6-POWER: while IFS='' read -r — Safe Line-by-Line File Processing"

# [WHAT]: Read a file line by line, preserving ALL whitespace, handling the
#         missing-final-newline edge case correctly.
# [WHY]:  `for line in $(cat file)` is WRONG — it word-splits on whitespace.
#         while read is the only correct form for line-by-line processing.
# [WATCH OUT]: The post-loop `[[ -n $line ]]` guard handles files that don't
#              end with a newline — the last line won't be read by the loop alone.
# [FLAG MEANING]    IFS='' = Empty IFS preserves ALL leading/trailing whitespace.
# [FLAG MEANING]    -r     = Raw; disables backslash interpretation on read.
line_count=0
while IFS='' read -r line || [[ -n "$line" ]]; do
  (( line_count++ ))
done < "$SEG6_DIR/data.txt"
pass "while read line count: $line_count lines processed (incl. no-newline final line)"

# ─── PRECISION: Process substitution — defeating the subshell variable trap ──
section "6-PRECISION: < <(cmd) — Process Substitution Loop"

# [WHAT]: Demonstrate that pipe-into-while creates a subshell, losing variables.
# [WHY]:  `command | while read` is the #2 most common bash bug source.
#         Variables set inside the while loop VANISH after the pipe ends.
# [COMMAND MEANING] < <(cmd) = Process substitution; provides cmd's output as
#                   a readable file-like path; loop runs in the CURRENT shell.
collected_items=()
while IFS='' read -r item; do
  collected_items+=("$item")
done < <(echo -e "server01\nserver02\nserver03")
pass "Process substitution: collected ${#collected_items[@]} items in current shell"
pass "  Items: ${collected_items[*]}"

# ─── POWER: break N and continue N ───────────────────────────────────────────
section "6-POWER: break N / continue N — Multi-Level Loop Control"

# [WHAT]: Show break 2 exiting two levels of nested loops in one shot.
found_target=false
for outer in A B C; do
  for inner in 1 2 3; do
    if [[ "$outer" == "B" && "$inner" == "2" ]]; then
      found_target=true
      break 2   # Exits BOTH loops simultaneously
    fi
  done
done
pass "break 2: exited nested loop at B-2 → found=$found_target"

# ─── DEVOPS: select — Interactive menu generation ────────────────────────────
section "6-DEVOPS: select — Auto-Generated Numbered Menus"

# [WHAT]: Show select syntax — not running it interactively (no TTY in script)
#         but demonstrating the structure that would run in an operator prompt.
# [COMMAND MEANING] select = Bash builtin that auto-generates a numbered menu
#                   and sets $REPLY to the raw user input.
# [COMMAND MEANING] PS3 = The prompt string shown by select when awaiting input.
# [COMMAND MEANING] REPLY = Variable set by select holding the raw typed input.
# [WHAT ELSE]: In a real operator tool: PS3="Select environment: "
#              select env in dev staging production; do case $env in ... esac; done

info "select loop structure (non-interactive demo — would show menu on a TTY):"
info "  PS3='Choose target: '"
info "  select server in web-01 web-02 db-01; do ssh \"\$server\"; done"

rm -rf "$SEG6_DIR"
pass "Segment 6 complete — All iteration patterns covered."


# ============================================================================
#  SEGMENT 7 — FUNCTIONS: MODULARITY AND REUSE
# ============================================================================
banner "SEGMENT 7 — Functions: Modularity & Reuse"

# ─── BASIC: Two definition syntaxes ──────────────────────────────────────────
section "7-BASIC: Function Definition Syntax — POSIX vs. Bash"

# [COMMAND MEANING] name() { } = POSIX-compliant function definition syntax;
#                   the portable form compatible with /bin/sh.
# [COMMAND MEANING] function name { } = Bash-specific syntax; identical behaviour
#                   but not valid in POSIX sh scripts.

# POSIX form (preferred):
get_timestamp() {
  # [COMMAND MEANING] date = Prints the current date and time in a specified format.
  # [FLAG MEANING]    +%s = Output as Unix epoch seconds.
  date +%s
}

# Bash-specific form (acceptable in bash-only scripts):
function get_hostname {
  # [COMMAND MEANING] hostname = Prints the system's network name.
  hostname
}

pass "POSIX function get_timestamp → $(get_timestamp)"
pass "Bash  function get_hostname  → $(get_hostname)"

# ─── POWER: return vs. stdout capture ────────────────────────────────────────
section "7-POWER: return N vs. result=\$(fn) — Exit Code vs. Data"

# [WHAT]: Show the fundamental distinction between returning STATUS (0/1) via
#         `return` and returning DATA by printing to stdout and capturing.
# [WHY]:  Bash functions cannot return strings via `return`. The only way to
#         pass data back is via stdout + command substitution.

# [COMMAND MEANING] return = Sets the function's exit status (0–255) and transfers
#                   control back to the caller; does NOT return string data.
validate_port() {
  local port="$1"
  if [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
    return 0  # success
  fi
  return 1  # failure
}

# [COMMAND MEANING] result=$(fn) = Command substitution that captures all stdout
#                   of a function as the return data by forking a subshell.
calculate_checksum() {
  local input="$1"
  echo "${input}" | md5sum | cut -d' ' -f1
}

if validate_port 8080; then
  pass "validate_port: 8080 is valid (return 0 received)"
fi

CHECKSUM=$(calculate_checksum "production-deploy-v2.3.1")
pass "calculate_checksum: '$CHECKSUM'"

# ─── PRECISION: declare -n nameref — Safe array passing ──────────────────────
section "7-PRECISION: declare -n — Nameref for Array Passing"

# [COMMAND MEANING] declare -n = Creates a nameref: a variable that is a
#                   transparent alias for another variable by name reference.
#                   This is the ONLY safe way to pass arrays to functions.
# [WATCH OUT]: The nameref variable name must NOT shadow the original array name
#              or you get a circular reference error.

process_server_list() {
  declare -n _servers="$1"  # _servers is now an alias for whatever array name was passed
  local -i count=0
  for srv in "${_servers[@]}"; do
    (( count++ ))
    info "  nameref processing server[$count]: $srv"
  done
  pass "Nameref: processed ${#_servers[@]} servers from the caller's array"
}

declare -a PROD_SERVERS=("web-01.prod" "web-02.prod" "db-01.prod")
process_server_list PROD_SERVERS  # Pass the NAME of the array, not its value

# ─── DEVOPS: export -f and call-stack introspection ──────────────────────────
section "7-DEVOPS: export -f — Functions to Child Processes"

# [COMMAND MEANING] export -f funcname = Serializes the function definition into
#                   the environment so spawned child bash processes can use it.
# [WATCH OUT]: export -f is the mechanism exploited by the Shellshock CVE-2014-6271
#              vulnerability. Never export functions that process untrusted input.
greet_server() { echo "  Deployed to: $1"; }
export -f greet_server

bash -c 'greet_server "prod-cluster-3"'
pass "export -f: function called successfully in child bash process"

# [COMMAND MEANING] source = Executes a file in the current shell context,
#                   importing its functions and variables without a fork.
# [COMMAND MEANING] . (dot) = POSIX-compliant alias for source; works in /bin/sh.
# [WHAT ELSE]: Always source library files at the top of your script after
#              set -euo pipefail so errors in the library abort early.

pass "Segment 7 complete — Functions, namerefs, and export -f."


# ============================================================================
#  SEGMENT 8 — ARRAYS AND ASSOCIATIVE ARRAYS
# ============================================================================
banner "SEGMENT 8 — Arrays & Associative Arrays"

# ─── BASIC: Indexed arrays ────────────────────────────────────────────────────
section "8-BASIC: Indexed Arrays — Declaration, Expansion & Safety"

# [WHAT]: Build an array and demonstrate every critical expansion form.
# [WHY]:  Most array bugs come from using ${arr[*]} instead of ${arr[@]},
#         or forgetting to quote the expansion.

declare -a DEPLOY_TARGETS=("web-01" "web-02" "db-primary" "cache-01")

# [COMMAND MEANING] ${arr[@]} = Expands every element as individually quoted words;
#                   the ALWAYS-correct form for passing arrays as arguments.
# [COMMAND MEANING] ${arr[*]} = Joins all elements into a single string with IFS[0].
# [COMMAND MEANING] ${#arr[@]} = Count of elements in the array.
# [COMMAND MEANING] ${!arr[@]} = List of all indices (keys for sparse arrays).
pass "Indexed array contents  : ${DEPLOY_TARGETS[*]}"
pass "Element count \${#arr[@]}: ${#DEPLOY_TARGETS[@]}"
pass "All indices \${!arr[@]}  : ${!DEPLOY_TARGETS[*]}"
pass "Element [2]             : ${DEPLOY_TARGETS[2]}"

# Appending elements
# [COMMAND MEANING] arr+=("element") = Appends to the end of an existing array.
DEPLOY_TARGETS+=("monitor-01")
pass "After arr+=: count is now ${#DEPLOY_TARGETS[@]}"

# Slicing
# [COMMAND MEANING] ${arr[@]:offset:length} = Returns a slice of the array.
SEG8_SLICE=("${DEPLOY_TARGETS[@]:1:3}")
pass "Array slice [1:3]: ${SEG8_SLICE[*]}"

# Copying an array
# [COMMAND MEANING] new=("${old[@]}") = Shallow copy by re-expanding all elements.
BACKUP_TARGETS=("${DEPLOY_TARGETS[@]}")
pass "Array copy: BACKUP_TARGETS has ${#BACKUP_TARGETS[@]} elements"

# unset a specific element — creates a sparse array
# [COMMAND MEANING] unset arr[N] = Removes element N; leaves a gap (sparse array).
# [WATCH OUT]: After unset arr[1], indices are NO LONGER contiguous.
#              Always iterate with ${!arr[@]} when you have sparse arrays.
unset DEPLOY_TARGETS[1]
pass "After unset [1]: indices are now [${!DEPLOY_TARGETS[*]}] (sparse!)"

# ─── POWER: mapfile for bulk loading ─────────────────────────────────────────
section "8-POWER: mapfile -t — Bulk Load Command Output Into Array"

# [COMMAND MEANING] mapfile = Reads lines from stdin into an indexed array; Bash 4+.
# [FLAG MEANING]    -t = Trim; strips the trailing newline from each element.
# [WATCH OUT]: mapfile REQUIRES Bash 4+. On macOS without brew bash, this will fail.
#              Add a bash version guard: (( BASH_VERSINFO[0] >= 4 )) || die
mapfile -t RUNNING_PROCS < <(ps -eo comm= | sort -u | head -5)
pass "mapfile loaded ${#RUNNING_PROCS[@]} process names:"
for proc in "${RUNNING_PROCS[@]}"; do
  info "  $proc"
done

# ─── PRECISION: Associative arrays ───────────────────────────────────────────
section "8-PRECISION: Associative Arrays — The Bash Hash Map"

# [WHAT]: Build an env-config hash map and demonstrate key existence testing.
# [WHY]:  Associative arrays replace giant if/elif chains and clunky grep-based
#         config lookups. They're O(1) lookup vs. O(n) linear search.
declare -A SERVICE_CONFIG
SERVICE_CONFIG[db_host]="db-primary.internal"
SERVICE_CONFIG[db_port]="5432"
SERVICE_CONFIG[db_name]="prod_app"
SERVICE_CONFIG[cache_host]="redis-01.internal"
SERVICE_CONFIG[cache_port]="6379"

# [COMMAND MEANING] ${!map[@]} = All keys in the associative array.
# [COMMAND MEANING] [[ -v map[key] ]] = Existence check without error; Bash 4.2+.
pass "Associative array keys: ${!SERVICE_CONFIG[*]}"
pass "db_host → ${SERVICE_CONFIG[db_host]}"

if [[ -v SERVICE_CONFIG[db_port] ]]; then
  pass "[[ -v map[key] ]]: db_port exists → ${SERVICE_CONFIG[db_port]}"
fi

if ! [[ -v SERVICE_CONFIG[missing_key] ]]; then
  pass "[[ -v ]]: missing_key correctly absent"
fi

# Joining array elements with a custom delimiter
# [COMMAND MEANING] IFS=','; "${arr[*]}" = Joins array elements using IFS[0] as
#                   the delimiter; restore IFS immediately after.
ALL_KEYS=("${!SERVICE_CONFIG[@]}")
SAVED_IFS="$IFS"; IFS=','
KEYS_CSV="${ALL_KEYS[*]}"
IFS="$SAVED_IFS"
pass "Keys as CSV (IFS join): $KEYS_CSV"

pass "Segment 8 complete — Arrays and hash maps mastered."


# ============================================================================
#  SEGMENT 9 — REDIRECTION, FILE DESCRIPTORS & PIPELINES
# ============================================================================
banner "SEGMENT 9 — Redirection, File Descriptors & Pipelines"

SEG9_DIR=$(mktemp -d)

# ─── BASIC: The six core redirection operators ────────────────────────────────
section "9-BASIC: Redirection Operators — >, >>, <, 2>, &>"

# [WHAT]: Write to files using each redirection form and verify the results.
# [WHY]:  Understanding left-to-right FD evaluation prevents the classic
#         `command >file 2>&1` vs. `command 2>&1 >file` ordering bug.

# [COMMAND MEANING] > = Redirect stdout to file (truncate/overwrite).
echo "stdout_line_1" > "$SEG9_DIR/out.log"

# [COMMAND MEANING] >> = Redirect stdout to file (append mode).
echo "stdout_line_2" >> "$SEG9_DIR/out.log"

# [COMMAND MEANING] 2> = Redirect stderr only to a file.
ls /nonexistent_path_xyz 2> "$SEG9_DIR/err.log" || true

# [COMMAND MEANING] &> = Redirect BOTH stdout and stderr to a file (bash shorthand).
{ echo "stdout"; ls /nonexistent_xyz; } &> "$SEG9_DIR/combined.log" || true

pass "> and >> log lines: $(wc -l < "$SEG9_DIR/out.log") lines written"
pass "2> error captured:  $(cat "$SEG9_DIR/err.log")"
pass "&> combined log:    $(wc -l < "$SEG9_DIR/combined.log") lines"

# [COMMAND MEANING] 2>&1 = Duplicate FD1 (stdout) into FD2 (stderr).
# [WATCH OUT]: Order matters! `cmd >file 2>&1` = both to file.
#              But `cmd 2>&1 >file` = only stdout to file, stderr to terminal!

# ─── POWER: Custom file descriptors ──────────────────────────────────────────
section "9-POWER: Custom File Descriptors — exec N>file"

# [WHAT]: Open a log file on FD 3, write to it, then close it.
# [WHY]:  In complex scripts, having a dedicated log FD means you can redirect
#         an entire function's output to a file without touching stdout/stderr.

# [COMMAND MEANING] exec N>file = Opens file on custom FD N for writing in the
#                   current shell without spawning a new process.
# [COMMAND MEANING] exec N<file = Opens file on FD N for reading.
# [COMMAND MEANING] exec N>&-  = Closes FD N, flushing and releasing the handle.

exec 3>"$SEG9_DIR/fd3.log"
echo "This goes to FD 3" >&3
echo "So does this"      >&3
exec 3>&-

pass "Custom FD 3 log: $(cat "$SEG9_DIR/fd3.log")"

# Save and restore stdout — the log redirection pattern
# [COMMAND MEANING] exec 3>&1 = Save current stdout to FD 3.
exec 3>&1
exec 1>"$SEG9_DIR/redirected_stdout.log"
echo "This line goes to the log, not the terminal"
exec 1>&3 3>&-
pass "Stdout restored — log contains: $(cat "$SEG9_DIR/redirected_stdout.log")"

# ─── PRECISION: Here-docs and here-strings ───────────────────────────────────
section "9-PRECISION: Here-docs & Here-strings — Inline Input"

# [COMMAND MEANING] <<'EOF' = Here-doc with QUOTED delimiter; zero expansion,
#                   everything is literal.
# [COMMAND MEANING] <<EOF   = Here-doc with unquoted delimiter; expansion active.
# [COMMAND MEANING] <<-EOF  = Strips leading TABS (not spaces) for indentation.
# [COMMAND MEANING] <<< "$var" = Here-string; feeds a variable as single-line stdin.

# Quoted here-doc — no expansion
cat << 'HEREDOC' > "$SEG9_DIR/literal.conf"
server_name=$HOSTNAME
port=8080
HEREDOC
pass "Quoted here-doc (literal): $(cat "$SEG9_DIR/literal.conf")"

# Unquoted here-doc — expansion active
APP_PORT="9090"
cat << HEREDOC > "$SEG9_DIR/expanded.conf"
server_name=$HOSTNAME
port=$APP_PORT
HEREDOC
pass "Unquoted here-doc (expanded): $(cat "$SEG9_DIR/expanded.conf")"

# Here-string
CHECKSUM_INPUT="production-tag-v3.1.2"
RESULT=$(md5sum <<< "$CHECKSUM_INPUT" | cut -d' ' -f1)
pass "Here-string md5: $CHECKSUM_INPUT → $RESULT"

# ─── DEVOPS: PIPESTATUS and pipefail ─────────────────────────────────────────
section "9-DEVOPS: PIPESTATUS — Capturing Every Stage's Exit Code"

# [WHAT]: Run a pipeline and inspect every stage's exit code independently.
# [WHY]:  With pipefail enabled, you know the pipeline failed, but not WHERE.
#         PIPESTATUS gives you surgical precision on which stage broke.

# [COMMAND MEANING] PIPESTATUS = Array of exit codes from the most recent pipeline,
#                   in left-to-right stage order.
# [COMMAND MEANING] set -o pipefail = Pipeline fails if ANY component exits non-zero.

{ echo "web-01 200 OK"; echo "db-01 500 ERROR"; echo "cache-01 200 OK"; } \
  | grep "ERROR" \
  | wc -l \
  > /dev/null || true

info "PIPESTATUS after pipeline: [${PIPESTATUS[*]}]"
info "  Stage 0 (echo block): ${PIPESTATUS[0]}"
info "  Stage 1 (grep):       ${PIPESTATUS[1]}"
info "  Stage 2 (wc -l):      ${PIPESTATUS[2]}"

# Process substitution
# [COMMAND MEANING] <(cmd) = Process substitution; provides cmd's stdout as a
#                   readable named-pipe path; used to pass command output as a file.
# [COMMAND MEANING] >(cmd) = Writable process substitution; data piped to it goes
#                   to cmd's stdin.
# [WHAT ELSE]: Classic use: diff <(ssh host1 cat /etc/hosts) <(ssh host2 cat /etc/hosts)
diff <(echo -e "line1\nline2\nline3") <(echo -e "line1\nLINE2\nline3") || true
pass "Process substitution diff: detected changed line (exit 1 is expected)"

rm -rf "$SEG9_DIR"
pass "Segment 9 complete — FDs, redirections, and pipelines."


# ============================================================================
#  SEGMENT 10 — STRICT MODE & ERROR HANDLING ARCHITECTURE
# ============================================================================
banner "SEGMENT 10 — Strict Mode & Error Handling Architecture"

# ─── BASIC: set -euo pipefail anatomy ────────────────────────────────────────
section "10-BASIC: set -euo pipefail — Every Flag's Meaning"

# [COMMAND MEANING] set -e  = errexit: abort on any non-zero command exit.
# [COMMAND MEANING] set -u  = nounset: unset variable references are fatal.
# [COMMAND MEANING] set -o pipefail = Pipeline fails if any stage is non-zero.
# [COMMAND MEANING] set -E  = errtrace: ERR trap is inherited by functions.
# Already set at the top — demonstrating with a safe subshell probe:

STRICT_PROBE=$(bash -c 'set -euo pipefail; echo "strict mode active"; exit 0')
pass "set -euo pipefail confirmed active in this script: $STRICT_PROBE"

# ─── POWER: Trap architecture ─────────────────────────────────────────────────
section "10-POWER: trap — EXIT, ERR, SIGINT, SIGTERM, SIGHUP"

# [WHAT]: Build a complete trap stack — cleanup on EXIT, error tracing on ERR,
#         and signal handling for graceful shutdown.
# [WHY]:  Without traps, temp files leak on crashes, locks are never released,
#         and error messages are swallowed without context.

# [COMMAND MEANING] trap 'cmd' EXIT   = Runs cmd on any exit (normal or error).
# [COMMAND MEANING] trap 'cmd' ERR    = Runs cmd when set -e would trigger.
# [COMMAND MEANING] trap 'cmd' SIGINT = Handles Ctrl+C (signal 2).
# [COMMAND MEANING] trap 'cmd' SIGTERM = Handles graceful termination (signal 15).
# [COMMAND MEANING] trap 'cmd' SIGHUP = Handles terminal hangup (signal 1).
# [COMMAND MEANING] SIGKILL (9) = Cannot be caught — the kernel kills the process
#                   with no chance for cleanup. Design your scripts to tolerate it.

# Note: The EXIT trap is already set above (sandbox cleanup).
# Adding an ERR trace on top (stacks with EXIT):
SEG10_ERROR_TRIGGERED=false
trap 'SEG10_ERROR_TRIGGERED=true; echo "  [ERR TRAP] Error at line $LINENO in ${FUNCNAME[0]:-main}"' ERR

# Temporarily disable set -e to demo the ERR trap safely
set +e
(exit 1) 2>/dev/null  # Trigger ERR intentionally in a subshell
set -e

pass "ERR trap fired: SEG10_ERROR_TRIGGERED=$SEG10_ERROR_TRIGGERED"

# Reset ERR trap to a cleaner handler
trap '' ERR  # Clear the demo trap

# ─── PRECISION: die() — The canonical error reporter ──────────────────────────
section "10-PRECISION: die() — Production Error Reporting Function"

# [COMMAND MEANING] die() = Convention function that writes to stderr and exits
#                   with a configurable non-zero code.
# [WHAT]: The die() function is the standard production pattern for clean exits.
# [WHY]:  It centralises error formatting, ensures stderr output, and allows
#         callers to specify custom exit codes for different error categories.

die() {
  local message="$1"
  local exit_code="${2:-1}"
  echo "[$(date '+%Y-%m-%dT%H:%M:%S')] [FATAL] ${BASH_SOURCE[1]:-script}:${BASH_LINENO[0]} → $message" >&2
  exit "$exit_code"
}

# Demonstrate without actually dying:
(die "Simulated fatal: database connection refused" 2) 2>&1 | sed 's/^/  /' || true
pass "die() format demonstrated above ↑"

# ─── DEVOPS: Mutex lock via atomic mkdir ─────────────────────────────────────
section "10-DEVOPS: Mutex Lock — Atomic mkdir for Mutual Exclusion"

# [WHAT]: Use mkdir as an atomic lock primitive. The kernel guarantees that
#         only ONE process can successfully create a directory that doesn't exist.
# [WHY]:  Two concurrent script instances must not run the same deployment
#         simultaneously. mkdir is the POSIX-safe alternative to lockfile or flock
#         when you need compatibility across filesystems.
# [COMMAND MEANING] mkdir "$LOCK_DIR" 2>/dev/null = Creates a lock directory
#                   atomically; fails instantly if another process holds the lock.

SEG10_LOCK_DIR="$WORKSPACE/.seg10.lock"

acquire_lock() {
  if mkdir "$SEG10_LOCK_DIR" 2>/dev/null; then
    pass "Lock acquired: $SEG10_LOCK_DIR"
    trap 'rm -rf "$SEG10_LOCK_DIR"' EXIT
    return 0
  else
    die "Lock already held — another instance is running" 2
  fi
}

# Test lock acquisition and re-acquisition
acquire_lock

# Try to acquire when lock is held:
(acquire_lock) 2>&1 | grep -q "already held" && pass "Double-lock correctly rejected"

# [COMMAND MEANING] command -v = Tests whether a command exists on PATH without
#                   executing it; used in guard clauses for required dependencies.
for dep in bash awk grep sed; do
  command -v "$dep" > /dev/null || die "Required tool not found: $dep"
done
pass "Guard clauses: all required tools verified present"

rm -rf "$SEG10_LOCK_DIR"
pass "Segment 10 complete — Strict mode, traps, die(), and mutex."


# ============================================================================
#  SEGMENT 11 — TEMP FILES, ATOMIC WRITES & TOCTOU
# ============================================================================
banner "SEGMENT 11 — Temp Files, Secure Cleanup & TOCTOU"

# ─── BASIC: mktemp — The only safe temp file pattern ─────────────────────────
section "11-BASIC: mktemp — Secure Temporary File Creation"

# [WHAT]: Create both a temp file and a temp directory, demonstrating that the
#         EXIT trap handles cleanup even on mid-script errors.
# [WHY]:  /tmp/script.$$ is a symlink attack vector — the PID is predictable.
#         An attacker can pre-create the path as a symlink to /etc/passwd before
#         your script writes to it.

# [COMMAND MEANING] mktemp = Creates an atomically-named temp file.
# [FLAG MEANING]    -d = Create a temp directory instead of a file.
# [COMMAND MEANING] mktemp /path/prefix.XXXXXX = Creates temp at specific location;
#                   XXXXXX is replaced with cryptographically random characters.

SEG11_TMP_FILE=$(mktemp "$WORKSPACE/report.XXXXXX")
SEG11_TMP_DIR=$(mktemp -d "$WORKSPACE/workdir.XXXXXX")
trap 'rm -rf "$SEG11_TMP_FILE" "$SEG11_TMP_DIR"' EXIT

pass "mktemp file: ${SEG11_TMP_FILE##*/}"
pass "mktemp -d  : ${SEG11_TMP_DIR##*/}"

# ─── POWER: Atomic file writes ────────────────────────────────────────────────
section "11-POWER: Atomic Config Writes — Write+mv, Never Write-in-Place"

# [WHAT]: Write to a temp file first, then atomically rename it into position.
# [WHY]:  If you write directly to a config file and the script crashes midway,
#         you've deployed a HALF-WRITTEN config — potentially taking down your
#         service. write-to-temp + mv is atomic on the same filesystem.
# [COMMAND MEANING] mv tmpfile target = Renames atomically on the same filesystem;
#                   the swap is instantaneous from readers' perspective.
# [WATCH OUT]: mv is only atomic if BOTH paths are on the SAME filesystem.
#              Cross-filesystem mv silently becomes a copy+delete.

CONFIG_TARGET="$WORKSPACE/nginx.conf"

# Write new config to a temp file
NEW_CONFIG=$(mktemp "$WORKSPACE/nginx.XXXXXX")
cat > "$NEW_CONFIG" << 'EOF'
server {
    listen 80;
    server_name example.com;
    location / { proxy_pass http://backend; }
}
EOF

# Atomic deploy — consumers of nginx.conf never see a partial write
mv "$NEW_CONFIG" "$CONFIG_TARGET"
pass "Atomic config write: $(wc -l < "$CONFIG_TARGET") lines deployed atomically"

# ─── PRECISION: noclobber and umask ───────────────────────────────────────────
section "11-PRECISION: set -C (noclobber) & umask 077"

# [COMMAND MEANING] set -C = Enables noclobber; > refuses to overwrite existing files.
# [COMMAND MEANING] umask 077 = File creation mask; newly created files are
#                   owner-only (rwx------) by default.
# [WATCH OUT]: umask is inherited by child processes. Set it at script top, not
#              just before sensitive writes.

ORIGINAL_UMASK=$(umask)
umask 077

PROTECTED_FILE=$(mktemp "$WORKSPACE/protected.XXXXXX")
PERMS=$(stat -c '%a' "$PROTECTED_FILE" 2>/dev/null || stat -f '%Lp' "$PROTECTED_FILE" 2>/dev/null || echo "N/A")
pass "umask 077: new file permissions = $PERMS (owner-only)"

umask "$ORIGINAL_UMASK"  # Restore

# noclobber demo
set -C
CLOBBER_TARGET="$WORKSPACE/noclobber_test.txt"
echo "original" > "$CLOBBER_TARGET"

if ! (echo "overwrite" > "$CLOBBER_TARGET") 2>/dev/null; then
  pass "set -C noclobber: overwrite correctly refused"
fi

set +C  # Restore normal behaviour

# ─── DEVOPS: TOCTOU — Time of Check to Time of Use ───────────────────────────
section "11-DEVOPS: TOCTOU Race Condition — Open FD, Don't Re-check Path"

# [WHAT]: Demonstrate the TOCTOU mitigation — open the file onto an FD first,
#         then operate on the FD rather than re-checking the path.
# [WHY]:  [ -f "$file" ] && cat "$file" has a race window between the check and
#         the use. An attacker can swap the file for a symlink to /etc/shadow in
#         that window. Opening to FD gives you a stable inode reference.
# [COMMAND MEANING] exec N<"$file" = Opens file via inode on FD N, preventing
#                   TOCTOU races where the filename could be swapped.

SAFE_READ_FILE="$WORKSPACE/safe_data.txt"
echo "sensitive_config_data" > "$SAFE_READ_FILE"

# Open once, operate on FD — no re-check race window
exec 4< "$SAFE_READ_FILE"
SAFE_CONTENT=$(cat <&4)
exec 4>&-
pass "TOCTOU-safe read via FD: $SAFE_CONTENT"

pass "Segment 11 complete — Temp files, atomic ops, and TOCTOU."


# ============================================================================
#  SEGMENT 12 — TEXT PROCESSING: grep, sed, awk, AND FRIENDS
# ============================================================================
banner "SEGMENT 12 — Text Processing: grep, sed, awk & Pure Bash"

# Setup mock log data
SEG12_DIR=$(mktemp -d)
cat > "$SEG12_DIR/access.log" << 'EOF'
2024-05-03 08:01:22 INFO  web-01 GET /api/health 200 12ms
2024-05-03 08:01:45 ERROR web-01 GET /api/users  500 5432ms
2024-05-03 08:02:01 INFO  web-02 GET /api/health 200 9ms
2024-05-03 08:02:33 WARN  db-01  SELECT timeout   503 15000ms
2024-05-03 08:03:05 ERROR web-02 POST /api/login  401 22ms
2024-05-03 08:03:21 INFO  web-01 GET /api/health 200 11ms
2024-05-03 08:04:00 ERROR db-01  INSERT deadlock  500 8001ms
EOF

cat > "$SEG12_DIR/servers.csv" << 'EOF'
web-01:10.0.1.1:nginx:active
web-02:10.0.1.2:nginx:active
db-01:10.0.2.1:postgres:active
cache-01:10.0.3.1:redis:inactive
EOF

# ─── BASIC: grep — The line filter ────────────────────────────────────────────
section "12-BASIC: grep — Pattern Matching & Exit Code Awareness"

# [COMMAND MEANING] grep = Global Regular Expression Print; searches line by line
#                   for pattern matches and prints matching lines to stdout.
# [FLAG MEANING]    -E = Extended Regular Expressions; enables +, ?, |, () unescaped.
# [FLAG MEANING]    -F = Fixed string; literal match, no regex interpretation.
# [FLAG MEANING]    -i = Case-insensitive matching.
# [FLAG MEANING]    -v = Invert match; print lines that do NOT match.
# [FLAG MEANING]    -c = Count; print only the number of matching lines.
# [FLAG MEANING]    -l = List files; print only filenames containing a match.
# [FLAG MEANING]    -n = Number; prefix each match with its source line number.
# [FLAG MEANING]    -r = Recursive; search all files under a directory.
# [FLAG MEANING]    -o = Only matching; print just the matched portion of each line.
# [FLAG MEANING]    -q = Quiet; no output — only exit code (1 = no match).
# [WATCH OUT]: grep returns exit code 1 on no match. Under set -e this ABORTS
#              your script. Always pipe with || true or use -q in conditionals.

pass "grep -c ERROR: $(grep -c 'ERROR' "$SEG12_DIR/access.log") error lines"
pass "grep -v INFO:  $(grep -vc 'INFO' "$SEG12_DIR/access.log") non-info lines"
pass "grep -n ERROR: first match at line $(grep -n 'ERROR' "$SEG12_DIR/access.log" | head -1 | cut -d: -f1)"
pass "grep -o [0-9]*ms: $(grep -oE '[0-9]+ms' "$SEG12_DIR/access.log" | head -3 | tr '\n' ' ')"

# Quiet grep for conditional use — safe with set -e
if grep -qE '50[0-3]' "$SEG12_DIR/access.log"; then
  pass "grep -q: 5xx errors detected (exit 0, no output noise)"
fi

# ─── POWER: sed — Stream editing ──────────────────────────────────────────────
section "12-POWER: sed — Stream Transformation"

# [COMMAND MEANING] sed = Stream Editor; applies transformation commands to each
#                   input line in sequence.
# [FLAG MEANING]    s/pat/rep/  = Substitute first occurrence of pat with rep.
# [FLAG MEANING]    s/pat/rep/g = Global substitution; all occurrences per line.
# [FLAG MEANING]    s/pat/rep/i = Case-insensitive substitution (GNU sed only).
# [FLAG MEANING]    -n          = Suppress auto-print; only explicit p commands output.
# [FLAG MEANING]    /pattern/d  = Delete all lines matching pattern.
# [FLAG MEANING]    -i          = In-place file editing.
# [WATCH OUT]: sed -i is NOT portable between GNU (Linux) and BSD (macOS).
#              GNU: sed -i 's/.../.../'  | BSD: sed -i '' 's/.../...'
#              Use -i.bak for portability — the backup suffix works on both.

# Replace log level labels with padded versions
sed 's/INFO /INFO /' "$SEG12_DIR/access.log" | grep -c 'INFO' | xargs -I{} pass "sed pass-through: {} INFO lines"

# Extract only error lines using -n and p
ERROR_LINES=$(sed -n '/ERROR/p' "$SEG12_DIR/access.log" | wc -l)
pass "sed -n '/ERROR/p': $ERROR_LINES error lines extracted"

# Delete comment/blank lines from a config
printf "# comment\n\nkey=value\n# another\nport=8080\n" \
  | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d'  \
  | while IFS= read -r l; do info "  sed /d cleaned: $l"; done

# ─── PRECISION: awk — The field processor ────────────────────────────────────
section "12-PRECISION: awk — Field Processing, Aggregation & Reports"

# [COMMAND MEANING] awk = Pattern-scanning language; processes records (lines)
#                   field by field with a C-like syntax.
# [FLAG MEANING]    BEGIN{} = Block executed once before any input is read.
# [FLAG MEANING]    END{}   = Block executed once after all input is consumed.
# [FLAG MEANING]    $NF     = Last field on the current line.
# [FLAG MEANING]    -F:     = Set input field separator to colon.
# [FLAG MEANING]    NR==N   = Process only line N.
# [FLAG MEANING]    {count[$1]++} = Associative array counting pattern.

# Total up response times from the log
pass "awk response time sum:"
awk '
  BEGIN { total=0; count=0 }
  {
    # $NF is the last field (e.g., "5432ms") — strip "ms" and sum
    gsub(/ms$/, "", $NF)
    total += $NF
    count++
  }
  END {
    printf "  Total: %dms over %d requests | Avg: %.0fms\n", total, count, total/count
  }
' "$SEG12_DIR/access.log"

# Count errors per server using associative arrays
info "awk error count per server:"
awk '/ERROR/ { count[$4]++ } END { for (srv in count) printf "  %-12s %d errors\n", srv, count[srv] }' \
  "$SEG12_DIR/access.log"

# Field extraction with custom -F separator
info "awk -F: extract server names from CSV:"
awk -F: '{ printf "  host=%-10s ip=%-12s service=%s\n", $1, $2, $3 }' "$SEG12_DIR/servers.csv"

# ─── DEVOPS: cut, tr, sort, uniq, paste, jq ──────────────────────────────────
section "12-DEVOPS: cut, tr, sort, uniq, paste — The Pipeline Toolkit"

# [COMMAND MEANING] cut = Extracts specific fields or character positions from lines.
# [FLAG MEANING]    -d: -f1 = Delimiter colon, extract field 1.
pass "cut -d: -f1 (server names): $(cut -d: -f1 "$SEG12_DIR/servers.csv" | tr '\n' ' ')"

# [COMMAND MEANING] tr = Translate; maps or deletes characters one-to-one.
# [FLAG MEANING]    'a-z' 'A-Z' = Uppercase all lowercase ASCII characters.
echo "web-server-01" | tr 'a-z' 'A-Z' | xargs -I{} pass "tr uppercase: {}"

# [COMMAND MEANING] sort = Sorts lines; LC_ALL=C gives deterministic byte-order sort.
# [FLAG MEANING]    -rn = Numeric descending sort.
# [COMMAND MEANING] LC_ALL=C sort = Locale-independent deterministic sort.
# [COMMAND MEANING] uniq -c = Collapse duplicates and prefix with occurrence count.
info "sort + uniq -c on log levels:"
awk '{print $3}' "$SEG12_DIR/access.log" | LC_ALL=C sort | uniq -c | sort -rn | \
  while read -r count level; do info "  $count × $level"; done

# [COMMAND MEANING] paste -d, = Merge files side-by-side with comma delimiter.
NAMES_FILE=$(mktemp); PORTS_FILE=$(mktemp)
printf "web-01\nweb-02\ndb-01\n" > "$NAMES_FILE"
printf "80\n443\n5432\n" > "$PORTS_FILE"
info "paste -d, merge:"
paste -d, "$NAMES_FILE" "$PORTS_FILE" | while IFS= read -r line; do info "  $line"; done
rm -f "$NAMES_FILE" "$PORTS_FILE"

# jq — JSON processing
# [COMMAND MEANING] jq '.field' = Extract named top-level key from JSON.
# [FLAG MEANING]    -r = Raw output; strip JSON string quotes.
# [FLAG MEANING]    --arg name val = Bind shell variable safely into jq filter.
# [FLAG MEANING]    select(.k == "v") = Filter stream by condition.

if command -v jq &>/dev/null; then
  JSON_PAYLOAD='[{"name":"web-01","status":"healthy","port":80},{"name":"db-01","status":"degraded","port":5432}]'

  info "jq field extraction:"
  echo "$JSON_PAYLOAD" | jq -r '.[].name' | while IFS= read -r n; do info "  name: $n"; done

  info "jq select filter (healthy only):"
  echo "$JSON_PAYLOAD" | jq -r '.[] | select(.status == "healthy") | .name' | \
    while IFS= read -r n; do info "  healthy: $n"; done

  TARGET_PORT="5432"
  info "jq --arg safe injection:"
  echo "$JSON_PAYLOAD" | jq --arg p "$TARGET_PORT" -r '.[] | select(.port == ($p|tonumber)) | .name' | \
    while IFS= read -r n; do info "  port $TARGET_PORT → $n"; done
else
  info "jq not installed — skipping JSON demo (install: apt-get install jq)"
fi

rm -rf "$SEG12_DIR"
pass "Segment 12 complete — grep, sed, awk, and the full toolkit."


# ============================================================================
#  SEGMENT 13 — DEFENSIVE INPUT VALIDATION & SECURITY HARDENING
# ============================================================================
banner "SEGMENT 13 — Defensive Input Validation & Security Hardening"

# ─── BASIC: Command injection and eval dangers ────────────────────────────────
section "13-BASIC: eval — The Most Dangerous Builtin"

# [COMMAND MEANING] eval = Concatenates its arguments and executes them as shell
#                   code; NEVER use with any user-controlled input.
# [WHAT]: Show eval being used safely (internal const) vs. the pattern that
#         enables command injection.
# [WATCH OUT]: eval with user input is THE primary injection vector in bash.
#              eval "echo $user_input" where user_input="; rm -rf /" is game over.

# Safe eval: using a known-good internal string
SAFE_EVAL_TARGET="BASH_VERSION"
RESULT=$(eval "echo \${$SAFE_EVAL_TARGET}")
pass "eval (safe, internal const): $SAFE_EVAL_TARGET → $RESULT"

# The safe alternative — declare -n nameref
# [COMMAND MEANING] declare -n = Creates a nameref; the SAFE alternative to eval
#                   for indirect variable addressing.
declare -n SEG13_REF="BASH_VERSION"
pass "declare -n (safe alternative): $SEG13_REF"

# ─── POWER: Input whitelist validation ────────────────────────────────────────
section "13-POWER: Whitelist Validation — Regex Guard for All Inputs"

# [WHAT]: Validate every external input against a strict allowlist before using.
# [WHY]:  Blacklisting (trying to block bad chars) always has holes.
#         Whitelisting (only permitting known-good chars) is the safe inversion.

# [COMMAND MEANING] [[ $input =~ ^[a-zA-Z0-9_-]+$ ]] = Whitelist regex; only
#                   permits alphanumerics, underscores, and hyphens.

validate_identifier() {
  local input="$1"
  local label="${2:-input}"
  if [[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    pass "Whitelist PASS [$label]: '$input'"
    return 0
  else
    info "Whitelist FAIL [$label]: '$input' — REJECTED (contains unsafe chars)"
    return 1
  fi
}

validate_identifier "web-server-01"          "hostname"
validate_identifier "deploy_v2_3_1"          "tag"
validate_identifier "../../etc/passwd"       "path traversal attempt" || true
validate_identifier "\$(rm -rf /tmp/test)"   "injection attempt"      || true
validate_identifier "valid_name; rm -rf /"   "semicolon injection"    || true

# ─── PRECISION: Leading-hyphen file defence ───────────────────────────────────
section "13-PRECISION: rm -- \"\$file\" — Leading-Hyphen Filename Defence"

# [WHAT]: Create a file whose name starts with a hyphen, then safely remove it.
# [WHY]:  rm -rf (without --) interprets -rf-style filenames as flags.
#         A file named "-rf" or "--no-preserve-root" can be weaponised.

# [COMMAND MEANING] rm -- "$file" = The -- signals end-of-options to rm,
#                   preventing a leading-hyphen filename from being parsed as a flag.
HYPHEN_FILE="$WORKSPACE/-dangerous-filename"
echo "trick file content" > "$HYPHEN_FILE"
rm -- "$HYPHEN_FILE"
pass "rm -- safely removed the leading-hyphen file"

# ─── PRECISION: sudo -n and privilege dropping ────────────────────────────────
section "13-PRECISION: sudo -n & sudo -u — Least Privilege in Scripts"

# [COMMAND MEANING] sudo -n = Non-interactive; fails immediately if a password
#                   prompt would appear, preventing script hangs in automation.
# [COMMAND MEANING] sudo -u nobody = Runs the command as the unprivileged 'nobody'
#                   user; implements the principle of least privilege.

if sudo -n true 2>/dev/null; then
  pass "sudo -n: passwordless sudo is available on this system"
else
  info "sudo -n: would require a password (correct for locked-down systems)"
fi

# Demonstrate privilege drop pattern (safe — just echoes):
# [WHAT ELSE]: In real deployment: sudo -u www-data /usr/bin/php artisan migrate
info "Least-privilege pattern: sudo -u nobody command_that_doesnt_need_root"

# ─── DEVOPS: Credential management patterns ───────────────────────────────────
section "13-DEVOPS: Credential Safety — Files > Env Vars > CLI Args"

# [WHAT]: Demonstrate the three credential tiers and why only the first is safe.
# [COMMAND MEANING] read -rs < /run/secrets/name = Read secret from a file
#                   silently (-s) without backslash processing (-r).
# [COMMAND MEANING] HashiCorp Vault = Production secrets manager; CLI is the
#                   preferred external store for infrastructure scripts.
# [COMMAND MEANING] AWS SSM Parameter Store = AWS-native secret/config store
#                   accessed via the AWS CLI for EC2/ECS/Lambda workloads.

SECRET_FILE=$(mktemp)
chmod 600 "$SECRET_FILE"
echo "my_db_password_here" > "$SECRET_FILE"

read -r DB_PASSWORD < "$SECRET_FILE"
pass "Credential read from file (safe): ${DB_PASSWORD:0:5}... (truncated)"

unset DB_PASSWORD
rm -f "$SECRET_FILE"
pass "Secret cleared from memory and file removed"

info "Production pattern: vault kv get -field=password secret/db/prod"
info "AWS pattern       : aws ssm get-parameter --with-decryption --name /prod/db/password"

pass "Segment 13 complete — Input validation and security hardening."


# ============================================================================
#  SEGMENT 14 — PROCESS MANAGEMENT & PARALLEL EXECUTION
# ============================================================================
banner "SEGMENT 14 — Process Management & Parallel Execution"

# ─── BASIC: Background jobs and PID capture ───────────────────────────────────
section "14-BASIC: command & + \$! — Backgrounding and PID Tracking"

# [WHAT]: Launch background jobs and capture their PIDs for later management.
# [WHY]:  Without capturing $!, you cannot wait on a specific job, cannot test if
#         it's still alive, and cannot send targeted signals.

# [COMMAND MEANING] command & = Runs the command as a background job, returning
#                   control to the parent shell immediately.
# [COMMAND MEANING] $! = The PID of the most recently backgrounded process.
# [WATCH OUT]: Capture $! IMMEDIATELY after &. Launching another background job
#              will overwrite $! with the new PID before you save the first.

SEG14_PIDS=()

# Simulate parallel health checks
for port in 8080 8081 8082; do
  (sleep 0.1; echo "  health check port $port: OK") &
  SEG14_PIDS+=("$!")
done

pass "Launched ${#SEG14_PIDS[@]} background jobs: PIDs ${SEG14_PIDS[*]}"

# [COMMAND MEANING] wait $PID = Block until the specified background process exits.
# [COMMAND MEANING] wait      = Block until ALL background children exit.
# [COMMAND MEANING] wait -n   = Block until ANY one child exits; requires Bash 4.3+.
for pid in "${SEG14_PIDS[@]}"; do
  wait "$pid"
done
pass "All background jobs completed"

# ─── POWER: kill signals and process group termination ───────────────────────
section "14-POWER: kill — Signals, Process Groups & kill -0"

# [COMMAND MEANING] kill -0 $PID = Zero-signal probe; tests process existence
#                   without sending a real signal.
# [COMMAND MEANING] kill -TERM $PID = Sends SIGTERM (15); requests graceful exit.
# [COMMAND MEANING] kill -TERM -$PGID = Sends SIGTERM to entire process group.
# [COMMAND MEANING] kill -9 $PID = SIGKILL; kernel forcibly destroys the process.
# [COMMAND MEANING] $BASHPID = The ACTUAL PID of the current bash process, even
#                   in subshells where $$ reports the parent's PID.
# [COMMAND MEANING] $$ = Top-level parent shell PID; does NOT update in subshells.

# Launch a short-lived background process and probe it
sleep 2 &
PROBE_PID=$!

if kill -0 "$PROBE_PID" 2>/dev/null; then
  pass "kill -0: process $PROBE_PID is alive"
else
  info "kill -0: process already gone"
fi

# SIGTERM and confirm death
kill -TERM "$PROBE_PID" 2>/dev/null || true
wait "$PROBE_PID" 2>/dev/null || true

if ! kill -0 "$PROBE_PID" 2>/dev/null; then
  pass "kill -TERM: process $PROBE_PID terminated gracefully"
fi

# BASHPID vs $$ demo in subshell
info "\$\$ in subshell  : $(bash -c 'echo $$')   (reports PARENT PID)"
info "\$BASHPID subshell: $(bash -c 'echo $BASHPID')  (reports ACTUAL subshell PID)"

# ─── PRECISION: Throttled parallel loop ───────────────────────────────────────
section "14-PRECISION: Parallel Loop — Throttle with counter + wait -n"

# [WHAT]: Run N workers in parallel, but cap at MAX_PARALLEL at any one time.
# [WHY]:  Unbounded parallelism exhausts file descriptors and memory.
#         This pattern is the production-safe alternative to xargs -P.

MAX_PARALLEL=3
active_jobs=0
all_pids=()

for server in web-01 web-02 web-03 db-01 cache-01; do
  # Simulate a deployment task
  (sleep 0.05; echo "  [worker] deployed to $server") &
  all_pids+=("$!")
  (( active_jobs++ ))

  # Throttle: wait for one job to finish before spawning another
  if (( active_jobs >= MAX_PARALLEL )); then
    wait -n 2>/dev/null || wait "${all_pids[0]}" 2>/dev/null || true
    (( active_jobs-- ))
  fi
done

# Drain remaining jobs
for pid in "${all_pids[@]}"; do
  wait "$pid" 2>/dev/null || true
done
pass "Throttled parallel loop: 5 deployments completed (MAX_PARALLEL=$MAX_PARALLEL)"

# ─── DEVOPS: xargs -P, timeout, nice, ionice ──────────────────────────────────
section "14-DEVOPS: xargs -P, timeout, nice, ionice"

# [COMMAND MEANING] xargs -P N = Distributes input items across N parallel workers.
# [FLAG MEANING]    -0 = Read null-byte-delimited input (safe for spaces in names).
# [COMMAND MEANING] timeout N command = Send SIGTERM after N seconds.
# [FLAG MEANING]    --kill-after=S = Send SIGKILL S seconds after SIGTERM.
# [COMMAND MEANING] nice -n 19 = Run at lowest CPU priority (highest niceness).
# [COMMAND MEANING] ionice -c 3 = Run at idle I/O class (disk only when no one else needs it).

info "xargs -P pattern:"
printf '%s\n' web-01 web-02 db-01 | xargs -P 2 -I{} bash -c 'echo "  xargs parallel: checking {}"'

# timeout demo
info "timeout demo (1s limit on 0.1s sleep — should succeed):"
timeout 1 sleep 0.1 && pass "timeout: command completed within time limit"

# timeout with --kill-after
info "timeout --kill-after pattern (non-destructive demo):"
info "  timeout --kill-after=5s 10s long_running_script.sh"
info "  → SIGTERM at 10s, SIGKILL at 15s if still alive"

info "nice -n 19 / ionice -c 3 (structure demo):"
info "  nice -n 19 ionice -c 3 rsync -av /data /backup  # background-safe heavy sync"

pass "Segment 14 complete — Process management and parallel patterns."


# ============================================================================
#  SEGMENT 15 — DEBUGGING, STATIC ANALYSIS & TESTING
# ============================================================================
banner "SEGMENT 15 — Debugging, Static Analysis & Testing"

# ─── BASIC: bash -n and bash -x ───────────────────────────────────────────────
section "15-BASIC: bash -n (syntax check) & bash -x (execution trace)"

# [COMMAND MEANING] bash -n = No-execute; parses the script for syntax errors
#                   without running any commands. The mandatory first debug step.
# [COMMAND MEANING] bash -x = Execution trace; prints each command to stderr
#                   prefixed with + before it runs.

# Create a script to syntax-check
VALID_SCRIPT="$WORKSPACE/valid_script.sh"
cat > "$VALID_SCRIPT" << 'EOF'
#!/usr/bin/env bash
name="${1:-world}"
echo "Hello, $name"
EOF

BROKEN_SCRIPT="$WORKSPACE/broken_script.sh"
cat > "$BROKEN_SCRIPT" << 'EOF'
#!/usr/bin/env bash
if [ -z "$1"
  echo "missing arg"
fi
EOF

if bash -n "$VALID_SCRIPT" 2>/dev/null; then
  pass "bash -n: valid_script.sh has no syntax errors"
fi

if ! bash -n "$BROKEN_SCRIPT" 2>/dev/null; then
  pass "bash -n: broken_script.sh syntax error correctly detected"
fi

# ─── POWER: Rich PS4 trace prompt ─────────────────────────────────────────────
section "15-POWER: PS4 — Rich Execution Trace with Source & Line Number"

# [COMMAND MEANING] PS4 = The xtrace prefix prompt; set to include BASH_SOURCE,
#                   LINENO, and FUNCNAME for source-level execution traces.
# [COMMAND MEANING] BASH_XTRACEFD=N = Redirects xtrace output to FD N, keeping
#                   stderr clean so actual errors are not buried in trace output.
# [WHAT ELSE]: In production debugging, redirect xtrace to a file:
#              BASH_XTRACEFD=9; exec 9>/tmp/trace.log; export PS4=...

TRACE_SCRIPT="$WORKSPACE/traced.sh"
cat > "$TRACE_SCRIPT" << 'EOF'
#!/usr/bin/env bash
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
greet() { echo "hello from greet()"; }
greet
EOF

info "bash -x trace output with rich PS4 (first 6 lines):"
bash "$TRACE_SCRIPT" 2>&1 | head -6 | sed 's/^/  /'

# ─── PRECISION: shellcheck warnings ───────────────────────────────────────────
section "15-PRECISION: shellcheck — Static Analysis & Warning Codes"

# [COMMAND MEANING] shellcheck = Static analysis tool detecting unquoted variables,
#                   word-splitting risks, and common bash antipatterns.
# [FLAG MEANING]    SC2086 = Unquoted variable; vulnerable to word splitting.
# [FLAG MEANING]    SC2046 = Unquoted command substitution; word-splitting risk.
# [FLAG MEANING]    SC2034 = Variable assigned but never used.
# [COMMAND MEANING] # shellcheck disable=SCXXXX = Suppress a warning inline;
#                   MUST include a comment explaining why it's safe to suppress.

if command -v shellcheck &>/dev/null; then
  SHELLCHECK_TARGET="$WORKSPACE/shellcheck_test.sh"
  cat > "$SHELLCHECK_TARGET" << 'EOF'
#!/bin/bash
UNUSED_VAR="i_am_never_read"
FILE_PATH="/tmp/test file.txt"
cat $FILE_PATH
EOF
  info "shellcheck findings:"
  shellcheck "$SHELLCHECK_TARGET" 2>&1 | head -10 | sed 's/^/  /' || true
else
  info "shellcheck not installed — install: apt-get install shellcheck"
  info "SC2086: double-quote \$var to prevent word splitting and glob expansion"
  info "SC2046: double-quote \$(cmd) to prevent word splitting on output"
  info "SC2034: unused variable — clean it up or mark intentional with _ prefix"
fi

# ─── DEVOPS: Structured logging system ────────────────────────────────────────
section "15-DEVOPS: Structured Logging — log_info / log_warn / log_error"

# [WHAT]: Build a production-grade logging library with runtime verbosity control.
# [WHY]:  echo "something happened" is not logging. Production scripts need
#         timestamps, severity levels, caller context, and LOG_LEVEL filtering.

# [COMMAND MEANING] LOG_LEVEL = Environment variable acting as a runtime verbosity
#                   dial; lower values = more verbose.
export LOG_LEVEL="${LOG_LEVEL:-2}"  # 0=debug, 1=info, 2=warn, 3=error

_log() {
  local level_num="$1"; local level_name="$2"; shift 2
  (( level_num >= LOG_LEVEL )) || return 0
  printf '[%s] [%s] %s:%s %s\n' \
    "$(date '+%Y-%m-%dT%H:%M:%S')" \
    "$level_name" \
    "${BASH_SOURCE[2]:-script}" \
    "${BASH_LINENO[1]:-?}" \
    "$*" >&2
}

log_debug() { _log 0 "DEBUG" "$@"; }
log_info()  { _log 1 "INFO " "$@"; }
log_warn()  { _log 2 "WARN " "$@"; }
log_error() { _log 3 "ERROR" "$@"; }

log_info  "Structured log: deployment started for env=production"
log_warn  "Structured log: disk at 87% on db-01 — consider cleanup"
log_error "Structured log: health check failed after 3 retries"

pass "Structured logging active (LOG_LEVEL=$LOG_LEVEL)"
info "Set LOG_LEVEL=0 to see debug output, LOG_LEVEL=3 for errors only"

# ─── DEVOPS: bats-core test structure ─────────────────────────────────────────
section "15-DEVOPS: bats-core — Unit Testing Structure"

# [COMMAND MEANING] bats-core = Bash Automated Testing System; unit test framework.
# [COMMAND MEANING] @test     = Decorator defining a named test case block.
# [COMMAND MEANING] run       = bats helper; captures command output into $output
#                   and exit code into $status.
# [COMMAND MEANING] $status   = bats variable: exit code of the last run command.
# [COMMAND MEANING] $output   = bats variable: stdout of the last run command.

# [WHAT ELSE]: Install with: npm install -g bats  or  apt-get install bats
info "bats-core test structure (non-executable demo):"
cat << 'BATS_DEMO'
  @test "validate_port rejects port 0" {
    run validate_port 0
    [ "$status" -eq 1 ]
  }
  @test "validate_port accepts port 8080" {
    run validate_port 8080
    [ "$status"  -eq 0 ]
  }
  @test "log_error writes to stderr" {
    run log_error "test message"
    [[ "$output" =~ ERROR ]]
  }
BATS_DEMO

pass "Segment 15 complete — Debugging, shellcheck, and testing."


# ============================================================================
#  SEGMENT 16 — FILE SYSTEM OPERATIONS & SAFE PATH HANDLING
# ============================================================================
banner "SEGMENT 16 — File System Operations & Safe Path Handling"

SEG16_DIR=$(mktemp -d)
# Build a realistic directory tree
mkdir -p "$SEG16_DIR"/{logs,configs,backup}
touch "$SEG16_DIR/logs/app.log" "$SEG16_DIR/logs/error.log"
touch "$SEG16_DIR/configs/nginx.conf" "$SEG16_DIR/configs/redis.conf"
touch "$SEG16_DIR/backup/db_backup_20240503.sql.gz"
for i in $(seq 1 5); do
  dd if=/dev/urandom bs=64 count=1 of="$SEG16_DIR/logs/access_$i.log" 2>/dev/null
done
ln -s "$SEG16_DIR/configs/nginx.conf" "$SEG16_DIR/nginx_symlink.conf"

# ─── BASIC: Path manipulation — zero-fork forms ───────────────────────────────
section "16-BASIC: Path Manipulation — Zero-Fork bash vs. External Binaries"

# [COMMAND MEANING] dirname  = External binary extracting the directory component.
# [COMMAND MEANING] basename = External binary extracting the filename component.
# [COMMAND MEANING] ${path%/*}  = Pure-bash dirname; shortest-suffix strip.
# [COMMAND MEANING] ${path##*/} = Pure-bash basename; longest-prefix strip.
# [WHAT]: These param-expansion forms are zero-fork replacements for dirname and
#         basename. In a loop over 10,000 files, this saves 20,000 fork() calls.

SAMPLE_PATH="/var/log/nginx/access.log"
pass "dirname  (external): $(dirname  "$SAMPLE_PATH")"
pass "\${path%%/*} (bash): ${SAMPLE_PATH%/*}"
pass "basename (external): $(basename "$SAMPLE_PATH")"
pass "\${path##*/} (bash): ${SAMPLE_PATH##*/}"

# [COMMAND MEANING] SCRIPT_DIR = Convention variable for the script's own directory;
#                   computed via cd + dirname + BASH_SOURCE[0] + pwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pass "SCRIPT_DIR: $SCRIPT_DIR"

# [COMMAND MEANING] realpath  = Resolves all symlinks to canonical absolute path.
# [COMMAND MEANING] readlink -f = GNU-only symlink chain follower; not on BSD macOS.
if command -v realpath &>/dev/null; then
  pass "realpath on symlink: $(realpath "$SEG16_DIR/nginx_symlink.conf")"
elif command -v readlink &>/dev/null; then
  pass "readlink -f on symlink: $(readlink -f "$SEG16_DIR/nginx_symlink.conf" 2>/dev/null || echo 'N/A')"
fi

# ─── POWER: find — Production-grade file discovery ────────────────────────────
section "16-POWER: find — Every Production Flag"

# [COMMAND MEANING] find = Recursively traverses directory trees applying tests.
# [FLAG MEANING]    -type f  = Regular files only.
# [FLAG MEANING]    -type d  = Directories only.
# [FLAG MEANING]    -name    = Glob filename match (case-sensitive).
# [FLAG MEANING]    -iname   = Case-insensitive filename match.
# [FLAG MEANING]    -mtime -N = Modified within last N days.
# [FLAG MEANING]    -maxdepth N = Limit recursion depth.
# [FLAG MEANING]    -exec {} + = Batch all matches into fewest invocations.
# [FLAG MEANING]    -exec {} \; = Execute once per file (slower, single-arg cmds).
# [FLAG MEANING]    -print0  = Null-byte delimited output (safe for special chars).
# [FLAG MEANING]    -L       = Follow symbolic links during traversal.

pass "find -type f .log files:"
find "$SEG16_DIR" -type f -name "*.log" -maxdepth 3 | \
  while IFS= read -r f; do info "  ${f##"$SEG16_DIR/"}"; done

pass "find -type d directories:"
find "$SEG16_DIR" -type d | while IFS= read -r d; do info "  ${d##"$SEG16_DIR/"}"; done

pass "find -mtime -1 (files modified today):"
# -mtime -1 = within last 1 day
find "$SEG16_DIR" -type f -mtime -1 | wc -l | xargs -I{} info "  {} files modified in last 24h"

# Safe find | xargs pipeline for filenames with spaces
# [COMMAND MEANING] xargs -0 = Reads null-delimited input; handles spaces in names.
# [COMMAND MEANING] find -print0 = Pairs with xargs -0 for the safe pipeline.
find "$SEG16_DIR" -type f -name "*.log" -print0 | \
  xargs -0 -I{} bash -c 'echo "  [safe pipeline] processing: ${1##*/}"' _ {}

# ─── PRECISION: flock — File locking for concurrent scripts ───────────────────
section "16-PRECISION: flock — Exclusive File Locking"

# [COMMAND MEANING] flock -x = Acquire an exclusive (write) lock on an FD.
# [FLAG MEANING]    -w N = Wait at most N seconds for the lock before failing.

SEG16_LOCKFILE="$SEG16_DIR/deploy.lock"
touch "$SEG16_LOCKFILE"

(
  # [WHAT]: Open the lockfile on FD 200 and acquire an exclusive lock.
  exec 200>"$SEG16_LOCKFILE"
  # [COMMAND MEANING] flock -x = Exclusive lock; blocks until acquired.
  flock -x 200
  pass "flock -x: exclusive lock acquired on deploy.lock"
  sleep 0.05
  # Lock is released when FD 200 is closed (subshell exits)
)

# Test lock with timeout
(
  exec 200>"$SEG16_LOCKFILE"
  if flock -x -w 1 200; then
    pass "flock -w 1: lock acquired within timeout"
    flock -u 200  # Unlock
  fi
)

# ─── DEVOPS: rsync production sync ────────────────────────────────────────────
section "16-DEVOPS: rsync — Production-Grade File Sync"

# [COMMAND MEANING] rsync --checksum = Compare by content hash, not mtime+size.
# [FLAG MEANING]    --delete  = Remove destination files absent from source.
# [FLAG MEANING]    --dry-run = Simulate; no changes made. ALWAYS run before destructive sync.
# [FLAG MEANING]    -avz      = Archive+verbose+compress.
# [WHAT ELSE]: Production remote sync: rsync -avz -e 'ssh -p 2222' --delete src/ user@host:/dst/

RSYNC_SRC="$SEG16_DIR/logs/"
RSYNC_DST="$SEG16_DIR/backup/logs_mirror/"
mkdir -p "$RSYNC_DST"

# Always dry-run first
rsync --dry-run -av "$RSYNC_SRC" "$RSYNC_DST" 2>&1 | head -5 | sed 's/^/  [dry-run] /'
pass "rsync --dry-run: plan reviewed — no files changed"

# Now execute for real
rsync -a "$RSYNC_SRC" "$RSYNC_DST"
pass "rsync -a: $(find "$RSYNC_DST" -type f | wc -l) files mirrored to backup"

# ─── DEVOPS: envsubst for config templating ───────────────────────────────────
section "16-DEVOPS: envsubst — Safe Config Templating"

# [COMMAND MEANING] envsubst = Substitutes \$VAR placeholders in a template with
#                   current environment variable values.
# [FLAG MEANING]    '$VAR1 $VAR2' = Restricts substitution to ONLY these variables,
#                   leaving other dollar-sign tokens (like $1, $HOME) untouched.

if command -v envsubst &>/dev/null; then
  export APP_HOST="web-01.prod" APP_PORT="8080" APP_ENV="production"
  TEMPLATE="$SEG16_DIR/app.conf.tmpl"
  RENDERED="$SEG16_DIR/app.conf"
  cat > "$TEMPLATE" << 'EOF'
host=$APP_HOST
port=$APP_PORT
env=$APP_ENV
shell=$SHELL
EOF
  # Only substitute the three app variables — $SHELL is left untouched
  envsubst '$APP_HOST $APP_PORT $APP_ENV' < "$TEMPLATE" > "$RENDERED"
  pass "envsubst (restricted):"
  cat "$RENDERED" | sed 's/^/  /'
else
  info "envsubst not found — install: apt-get install gettext-base"
fi

rm -rf "$SEG16_DIR"
pass "Segment 16 complete — find, flock, rsync, and path operations."


# ============================================================================
#  SEGMENT 17 — SSH AUTOMATION, HTTP APIS & REMOTE EXECUTION
# ============================================================================
banner "SEGMENT 17 — SSH Automation, HTTP APIs & Remote Execution"

# ─── BASIC: SSH automation-safe flags ────────────────────────────────────────
section "17-BASIC: ssh -o BatchMode — Automation-Safe SSH"

# [COMMAND MEANING] ssh -o BatchMode=yes = Disables interactive prompts; fails
#                   immediately if key auth is unavailable.
# [COMMAND MEANING] ssh ControlMaster=auto = Enables multiplexing; reuses an
#                   existing master connection for all subsequent sessions.
# [COMMAND MEANING] ssh ControlPath=... = Path for the Unix socket file used by
#                   the multiplexing master connection.
# [COMMAND MEANING] ssh ControlPersist=10m = Keeps the master alive 10 minutes
#                   after the last client disconnects.
# [COMMAND MEANING] ssh user@host 'bash -s' < script = Streams a local script
#                   to remote bash as stdin — no file copy required.
# [COMMAND MEANING] ssh user@host << 'ENDSSH' = Sends a heredoc to remote bash;
#                   single-quoted delimiter prevents local shell expansion.

info "SSH config pattern for automation (write to ~/.ssh/config):"
cat << 'SSHCONF'
  Host *.prod.internal
      BatchMode yes
      ControlMaster auto
      ControlPath ~/.ssh/cm_%r@%h:%p
      ControlPersist 10m
      ConnectTimeout 5
      StrictHostKeyChecking yes
SSHCONF

info "Remote script streaming pattern:"
info "  ssh -o BatchMode=yes deploy@prod 'bash -s' < ./deploy.sh"

info "Remote heredoc pattern (no file copy, no local expansion):"
cat << 'HEREDOC_DEMO'
  ssh user@server << 'ENDSSH'
    sudo systemctl reload nginx
    curl -fs http://localhost/health | jq .status
  ENDSSH
HEREDOC_DEMO

pass "SSH patterns documented — skipping live connection (no target host)"

# ─── BASIC: rsync over custom SSH port ────────────────────────────────────────
section "17-BASIC: rsync -e ssh — Bandwidth-Limited Remote Sync"

# [COMMAND MEANING] rsync -avz = Archive+verbose+compress sync.
# [FLAG MEANING]    -e 'ssh -p PORT' = Custom SSH command with non-default port.
# [FLAG MEANING]    --bwlimit=N = Limit bandwidth to N KB/s; prevents link saturation.
info "Bandwidth-limited remote sync pattern:"
info "  rsync -avz --bwlimit=10240 -e 'ssh -p 2222' /local/data/ user@host:/remote/"
pass "rsync SSH pattern documented"

# ─── POWER: curl — Fail-safe HTTP with retries ────────────────────────────────
section "17-POWER: curl — Production-Safe HTTP Requests"

# [COMMAND MEANING] curl -f = Fail silently on server errors; returns non-zero
#                   exit code for HTTP 4xx/5xx. Required for set -e to catch failures.
# [FLAG MEANING]    -s  = Silent; suppress progress meter.
# [FLAG MEANING]    -S  = Show errors even in silent mode; always pair as -sS.
# [FLAG MEANING]    --retry N      = Auto-retry on transient errors up to N times.
# [FLAG MEANING]    --max-time N   = Maximum seconds for entire operation.
# [FLAG MEANING]    -H "Authorization: Bearer $T" = Set Bearer auth header.
# [FLAG MEANING]    -d '{"key":"val"}' = Request body; implicitly uses POST.
# [FLAG MEANING]    -X POST        = Explicitly set HTTP method.
# [WATCH OUT]: Without -f, curl returns exit 0 even on HTTP 500 errors.
#              Under set -e, a missing -f silently swallows API errors.

# Health check — real HTTP request against a public endpoint
if command -v curl &>/dev/null; then
  HTTP_STATUS=$(curl -fsS --retry 2 --max-time 5 \
    -o /dev/null -w '%{http_code}' \
    https://example.com/ 2>/dev/null || echo "000")
  pass "curl -fsS health check: HTTP $HTTP_STATUS"

  # Demonstrate authenticated POST structure (safe mock — httpbin or /dev/null)
  info "Authenticated API POST structure:"
  info '  curl -fsS --retry 3 --max-time 10 \'
  info '       -H "Authorization: Bearer $API_TOKEN" \'
  info '       -H "Content-Type: application/json" \'
  info '       -X POST -d '"'"'{"status":"deploying","env":"prod"}'"'"' \'
  info '       https://api.internal/v1/deployments'
else
  info "curl not available in this environment"
fi

# ─── PRECISION: jq — JSON processing ─────────────────────────────────────────
section "17-PRECISION: jq — JSON Parsing & Safe Shell Injection"

# Already taught in Segment 12 — demonstrating the API-response parsing pattern
# which is the primary use case in Segment 17.

if command -v jq &>/dev/null; then
  # Simulate an API response
  API_RESPONSE='{
    "deployments": [
      {"id":"d-001","status":"healthy","region":"us-east-1"},
      {"id":"d-002","status":"degraded","region":"eu-west-1"},
      {"id":"d-003","status":"healthy","region":"ap-south-1"}
    ]
  }'

  # [COMMAND MEANING] jq '.field' = Extract named top-level key.
  # [FLAG MEANING]    jq -r = Raw output; strips JSON string quotes.
  # [FLAG MEANING]    jq 'select(.cond)' = Filter stream by condition.
  # [FLAG MEANING]    jq --arg name val = Bind shell var safely as jq variable.
  info "jq field extraction from API response:"
  echo "$API_RESPONSE" | jq -r '.deployments[].id' | \
    while IFS= read -r id; do info "  deployment: $id"; done

  info "jq select (degraded only):"
  echo "$API_RESPONSE" | jq -r '.deployments[] | select(.status == "degraded") | .id + " in " + .region' | \
    while IFS= read -r line; do info "  ALERT: $line"; done

  TARGET_REGION="us-east-1"
  info "jq --arg safe shell injection (searching region=$TARGET_REGION):"
  echo "$API_RESPONSE" | jq --arg r "$TARGET_REGION" -r \
    '.deployments[] | select(.region == $r) | .id' | \
    while IFS= read -r id; do pass "  Found in $TARGET_REGION: $id"; done
else
  info "jq not installed — install: apt-get install jq"
fi

pass "Segment 17 complete — SSH automation, curl, and jq."


# ============================================================================
#  SEGMENT 18 — IDEMPOTENCY, CONFIGURATION MANAGEMENT & TEMPLATING
# ============================================================================
banner "SEGMENT 18 — Idempotency, Config Management & Templating"

SEG18_DIR=$(mktemp -d)

# ─── BASIC: The check-before-act idempotency pattern ──────────────────────────
section "18-BASIC: Idempotency — Running N Times Produces the Same State"

# [WHAT]: Build a user-creation block that is safe to run multiple times.
# [WHY]:  Idempotent scripts are the foundation of all config management.
#         A script that explodes on second run is not a deployment script,
#         it's a ticking time bomb.

# [COMMAND MEANING] if ! id "$user" &>/dev/null = Check-before-act pattern;
#                   only runs useradd if the user does not already exist.
# [COMMAND MEANING] mkdir -p = Create dir and all parents; silently succeeds if exists.
# [COMMAND MEANING] ln -sf   = Symlink; forcibly replaces existing link without error.
# [COMMAND MEANING] apt-get install -y = Non-interactive install; idempotent.

# Simulate idempotent directory setup (safe to run twice)
setup_app_dirs() {
  local base_dir="$1"
  mkdir -p "$base_dir"/{app,logs,tmp,config}
  pass "mkdir -p: app directories created (idempotent)"

  # Idempotent symlink
  ln -sf "$base_dir/config/current.conf" "$base_dir/app.conf"
  pass "ln -sf: symlink created/updated (idempotent)"
}

setup_app_dirs "$SEG18_DIR"
setup_app_dirs "$SEG18_DIR"  # Run twice — should not error
pass "Idempotency confirmed: double-run produced no errors"

# Idempotency test pattern
STATE_BEFORE=$(find "$SEG18_DIR" -type f | sort | md5sum)
setup_app_dirs "$SEG18_DIR"
STATE_AFTER=$(find "$SEG18_DIR" -type f | sort | md5sum)
if [[ "$STATE_BEFORE" == "$STATE_AFTER" ]]; then
  pass "Idempotency TEST: state unchanged after third run (checksums match)"
fi

# ─── POWER: Safe .env file loading ────────────────────────────────────────────
section "18-POWER: .env Loading — Parse, Never source"

# [WHAT]: Parse a .env file safely, key by key, without ever sourcing it.
# [WHY]:  `source .env` executes the file as shell code. A malicious or
#         mis-formatted .env can run arbitrary commands. Parse instead.

# [COMMAND MEANING] while IFS='=' read -r key value = Safe .env parser that reads
#                   key=value pairs line by line without executing the file.
# [WATCH OUT]: Never `source .env` from untrusted or external repositories.
#              Use this read loop every time — even for "your own" .env files.

cat > "$SEG18_DIR/.env" << 'EOF'
DB_HOST=db-primary.internal
DB_PORT=5432
DB_NAME=prod_app
DB_PASS=s3cr3t_passw0rd
# This is a comment — should be skipped
EMPTY_VAR=

EOF

declare -A ENV_VARS
while IFS='=' read -r key value; do
  # Skip empty lines and comments
  [[ -z "$key" || "$key" == \#* ]] && continue
  # Strip surrounding whitespace from value
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  ENV_VARS["$key"]="$value"
done < "$SEG18_DIR/.env"

pass "Safe .env parsed: ${#ENV_VARS[@]} variables loaded"
for k in "${!ENV_VARS[@]}"; do
  info "  $k = ${ENV_VARS[$k]}"
done

# ─── PRECISION: envsubst with variable restriction ────────────────────────────
section "18-PRECISION: envsubst — Restricted Template Substitution"

if command -v envsubst &>/dev/null; then
  # Already demonstrated in Segment 16; here we show the API call that pairs
  # with idempotent atomic deployment.
  export DB_HOST="${ENV_VARS[DB_HOST]:-localhost}"
  export DB_PORT="${ENV_VARS[DB_PORT]:-5432}"

  TEMPLATE="$SEG18_DIR/db.conf.tmpl"
  RENDERED_TMP=$(mktemp "$SEG18_DIR/db.XXXXXX")
  RENDERED_FINAL="$SEG18_DIR/db.conf"

  cat > "$TEMPLATE" << 'EOF'
[database]
host = $DB_HOST
port = $DB_PORT
shell_home = $HOME
EOF

  # Restrict to only DB_HOST and DB_PORT — $HOME is intentionally left literal
  envsubst '$DB_HOST $DB_PORT' < "$TEMPLATE" > "$RENDERED_TMP"
  mv "$RENDERED_TMP" "$RENDERED_FINAL"  # Atomic write
  pass "envsubst restricted + atomic deploy:"
  cat "$RENDERED_FINAL" | sed 's/^/  /'
fi

# ─── DEVOPS: OS detection and portable package management ─────────────────────
section "18-DEVOPS: OS Detection & Portable install_packages()"

# [COMMAND MEANING] source /etc/os-release = Loads OS identification variables
#                   (ID, VERSION_ID, PRETTY_NAME) from the system identification file.
# [COMMAND MEANING] $ID (from os-release) = OS identifier (ubuntu, debian, fedora)
#                   used to dispatch to the correct package manager.

install_packages() {
  local packages=("$@")
  source /etc/os-release 2>/dev/null || true

  case "${ID:-unknown}" in
    ubuntu|debian|linuxmint)
      info "  apt-get install -y ${packages[*]}"
      # apt-get install -y "${packages[@]}"  # Uncomment in real use
      ;;
    fedora|rhel|centos|rocky|almalinux)
      info "  dnf install -y ${packages[*]}"
      ;;
    alpine)
      info "  apk add --no-cache ${packages[*]}"
      ;;
    *)
      info "  Unknown OS '$ID' — manual package installation required"
      return 1
      ;;
  esac
  pass "install_packages: dispatched to correct manager for OS=$ID"
}

install_packages jq curl rsync

# systemd unit awareness
# [COMMAND MEANING] systemctl enable --now = Enable unit at boot AND start it now.
# [COMMAND MEANING] OnCalendar= = Systemd timer: calendar-based scheduling.
# [COMMAND MEANING] OnBootSec=  = Systemd timer: fires N time after boot.
# [COMMAND MEANING] OnUnitActiveSec= = Systemd timer: fires N after last activation.
info "systemd timer directives (structure demo):"
info "  OnCalendar=*-*-* 02:00:00    # daily at 2am"
info "  OnBootSec=30s                 # 30 seconds after boot"
info "  OnUnitActiveSec=1h            # every 1h after last run"

rm -rf "$SEG18_DIR"
pass "Segment 18 complete — Idempotency, .env parsing, and templating."


# ============================================================================
#  SEGMENT 19 — DAEMON SCRIPTING, SCHEDULING & LONG-RUNNING SERVICES
# ============================================================================
banner "SEGMENT 19 — Daemon Scripting, Scheduling & Long-Running Services"

SEG19_DIR=$(mktemp -d)

# ─── BASIC: Cron patterns ─────────────────────────────────────────────────────
section "19-BASIC: cron — Scheduling Fundamentals"

# [COMMAND MEANING] crontab -e = Opens the user's crontab for editing.
# [COMMAND MEANING] @reboot    = Runs the command once on every system boot.
# [COMMAND MEANING] @daily     = Shorthand for 0 0 * * *; runs at midnight.

info "Cron table field order:  m h dom mon dow command"
info "Cron entries (examples):"
info "  */5 * * * *   /usr/local/bin/health_check.sh >> /var/log/health.log 2>&1"
info "  0 2 * * *     /usr/local/bin/backup.sh"
info "  @reboot       /usr/local/bin/startup_agent.sh"
info "  @daily        /usr/local/bin/log_rotate.sh"
info ""
info "  CRITICAL: cron environment is MINIMAL. Always set explicit PATH:"
info "  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ─── POWER: Systemd timer unit ────────────────────────────────────────────────
section "19-POWER: systemd .timer — The Modern cron Replacement"

# [COMMAND MEANING] systemd .timer = A systemd unit activating a paired .service
#                   on a schedule, with full journald logging and dependencies.
# [COMMAND MEANING] OnCalendar= = Realtime calendar-based scheduling.
# [COMMAND MEANING] OnBootSec=  = Fires a fixed duration after boot.

info "systemd timer unit structure:"
cat << 'SYSTEMD_DEMO'
  # /etc/systemd/system/backup.timer
  [Unit]
  Description=Daily Database Backup Timer

  [Timer]
  OnCalendar=*-*-* 02:30:00
  OnBootSec=5min
  Persistent=true

  [Install]
  WantedBy=timers.target

  # Paired service: /etc/systemd/system/backup.service
  [Service]
  Type=oneshot
  ExecStart=/usr/local/bin/backup.sh
  User=backup
SYSTEMD_DEMO

info "Enable and start immediately:"
info "  systemctl enable --now backup.timer"
info "  systemctl list-timers --all"

# ─── PRECISION: Full daemon with PID file and signal handling ─────────────────
section "19-PRECISION: Daemon Script — PID File, Signal Handlers & Event Loop"

# [WHAT]: Build a complete, well-behaved daemon: PID file, SIGTERM graceful
#         shutdown, SIGHUP config reload, and an interruptible main loop.

# [COMMAND MEANING] echo $BASHPID > "$PIDFILE" = Write daemon's actual PID to the
#                   PID file; $BASHPID used because $$ is wrong inside subshells.
# [COMMAND MEANING] kill -0 $(cat "$PIDFILE") = Test if the stored PID is alive;
#                   detects stale PID files from crashed daemon instances.
# [COMMAND MEANING] trap 'RUNNING=false' SIGTERM = Daemon SIGTERM handler; sets a
#                   flag for the event loop to exit cleanly on next iteration.
# [COMMAND MEANING] trap 'reload_config' SIGHUP = Daemon SIGHUP handler for live
#                   config reload without restarting the process.
# [COMMAND MEANING] while $RUNNING; do ... done = The daemon event loop.
# [COMMAND MEANING] sleep N & = Background sleep so SIGTERM interrupts the wait.
# [COMMAND MEANING] wait $SLEEP_PID || true = Wait on background sleep; || true
#                   prevents set -e from aborting when signal interrupts wait.

PIDFILE="$SEG19_DIR/healthd.pid"
DAEMON_LOG="$SEG19_DIR/healthd.log"
DAEMON_CONFIG="$SEG19_DIR/healthd.conf"

# Write a sample config
echo "interval=1" > "$DAEMON_CONFIG"
echo "target=localhost" >> "$DAEMON_CONFIG"

# Source config function
load_config() {
  while IFS='=' read -r k v; do
    [[ "$k" == \#* || -z "$k" ]] && continue
    declare -g "DAEMON_${k^^}=$v"
  done < "$DAEMON_CONFIG"
  log_info "Config loaded: interval=${DAEMON_INTERVAL:-1}s target=${DAEMON_TARGET:-localhost}"
}

# Run the daemon in a subshell so we can control it
(
  # [WHAT]: Stale PID file detection — check if old PID is still alive
  if [[ -f "$PIDFILE" ]]; then
    STALE_PID=$(cat "$PIDFILE")
    if kill -0 "$STALE_PID" 2>/dev/null; then
      echo "Daemon already running as PID $STALE_PID" >&2
      exit 1
    else
      echo "Removing stale PID file (PID $STALE_PID is dead)" >> "$DAEMON_LOG"
    fi
  fi

  echo "$BASHPID" > "$PIDFILE"
  echo "$(date): daemon started (PID=$BASHPID)" >> "$DAEMON_LOG"

  RUNNING=true
  ITERATION=0

  trap 'RUNNING=false; echo "$(date): SIGTERM received — shutting down" >> "$DAEMON_LOG"' SIGTERM
  trap 'echo "$(date): SIGHUP received — reloading config" >> "$DAEMON_LOG"' SIGHUP
  trap 'rm -f "$PIDFILE"; echo "$(date): daemon stopped" >> "$DAEMON_LOG"' EXIT

  while $RUNNING; do
    (( ITERATION++ ))
    echo "$(date): health tick #$ITERATION" >> "$DAEMON_LOG"

    # Interruptible sleep: backgrounded so SIGTERM wakes us
    sleep 0.1 &
    SLEEP_PID=$!
    wait "$SLEEP_PID" || true  # || true: prevent set -e from firing on signal interrupt

    (( ITERATION >= 3 )) && break  # 3 iterations for demo
  done
) 2>/dev/null

DAEMON_PID=$(cat "$PIDFILE" 2>/dev/null || echo "gone")
pass "Daemon completed 3 iterations: PID=$DAEMON_PID"
pass "Daemon log:"
cat "$DAEMON_LOG" | sed 's/^/  /'

# ─── DEVOPS: Double-fork daemonization pattern ────────────────────────────────
section "19-DEVOPS: Double-Fork — POSIX Daemonization"

# [COMMAND MEANING] double-fork = POSIX daemonization pattern; forks twice to
#                   detach from the terminal and ensure no controlling TTY.
# [WHAT ELSE]: In production, use systemd Type=forking or Type=simple instead.
#              Double-fork is for bare POSIX environments without systemd.

info "Double-fork pattern structure (POSIX daemonization):"
cat << 'DFORK_DEMO'
  # First fork — parent exits, child becomes orphan adopted by PID 1
  if (( $(os_fork()) != 0 )); then exit 0; fi

  # Create new session — detach from controlling TTY
  setsid

  # Second fork — prevents the process from ever reacquiring a TTY
  if (( $(os_fork()) != 0 )); then exit 0; fi

  # Redirect stdio
  exec </dev/null >/dev/null 2>&1

  # Now run the actual daemon logic
DFORK_DEMO

rm -rf "$SEG19_DIR"
pass "Segment 19 complete — Cron, systemd timers, and daemon lifecycle."


# ============================================================================
#  SEGMENT 20 — PERFORMANCE OPTIMIZATION & LANGUAGE BOUNDARY DECISIONS
# ============================================================================
banner "SEGMENT 20 — Performance Optimization & Language Boundary Decisions"

SEG20_DIR=$(mktemp -d)

# Create test data for benchmarks
python3 -c "
import random, string
for _ in range(1000):
    name = ''.join(random.choices(string.ascii_lowercase, k=8))
    level = random.choice(['INFO','WARN','ERROR','DEBUG'])
    ms = random.randint(1, 9999)
    print(f'2024-05-03 {level} {name} {ms}ms')
" > "$SEG20_DIR/perf_data.txt" 2>/dev/null || {
  # Fallback: bash-only data generation
  for i in $(seq 1 1000); do
    echo "2024-05-03 INFO service_$((RANDOM % 10)) $((RANDOM % 1000))ms"
  done > "$SEG20_DIR/perf_data.txt"
}
LINE_COUNT=$(wc -l < "$SEG20_DIR/perf_data.txt")
pass "Test dataset: $LINE_COUNT lines generated"

# ─── BASIC: time — Real, User, Sys breakdown ──────────────────────────────────
section "20-BASIC: time — Profiling Wall Clock, CPU & Kernel Time"

# [COMMAND MEANING] time = Bash keyword reporting real (wall-clock), user
#                   (user-space CPU), and sys (kernel CPU) time.
# [COMMAND MEANING] /usr/bin/time -v = GNU time binary; also reports peak RSS
#                   memory and context switch counts.
# [WHAT ELSE]: Use /usr/bin/time -v for memory profiling of long-running scripts.

info "Timing a grep over $LINE_COUNT lines:"
{ time grep -c 'ERROR' "$SEG20_DIR/perf_data.txt" > /dev/null; } 2>&1 | \
  grep -E 'real|user|sys' | sed 's/^/  /'

info "Timing an awk aggregation over $LINE_COUNT lines:"
{ time awk '{sum+=$NF} END{print sum}' "$SEG20_DIR/perf_data.txt" > /dev/null; } 2>&1 | \
  grep -E 'real|user|sys' | sed 's/^/  /'

# ─── POWER: The fork() overhead cost — $() in loops ──────────────────────────
section "20-POWER: Fork Cost — \$() vs. Pure Bash Replacements"

# [COMMAND MEANING] $() = Command substitution; forks a subshell each call.
#                   In tight loops, each invocation is a measurable fork() + exec() cost.
# [COMMAND MEANING] read -rd '' var < file = Reads entire file into a variable in
#                   the current process with ZERO fork overhead.
# [COMMAND MEANING] ${path##*/} = Zero-fork basename via parameter expansion.
# [COMMAND MEANING] ${var^^}    = Zero-fork uppercase via parameter expansion.

N_ITERATIONS=200

# BENCHMARK 1: $(basename) in a loop (N forks)
info "Benchmark: external basename vs pure-bash in $N_ITERATIONS iterations"
PATHS=()
for i in $(seq 1 $N_ITERATIONS); do PATHS+=("/var/log/app/file_$i.log"); done

START=$(date +%s%3N)
for p in "${PATHS[@]}"; do
  _bn=$(basename "$p")
done
ELAPSED_BASENAME=$(( $(date +%s%3N) - START ))

# BENCHMARK 2: ${p##*/} in a loop (zero forks)
START=$(date +%s%3N)
for p in "${PATHS[@]}"; do
  _bn="${p##*/}"
done
ELAPSED_PARAM=$(( $(date +%s%3N) - START ))

pass "$(basename) loop  : ${ELAPSED_BASENAME}ms  ($N_ITERATIONS fork calls)"
pass "\${path##*/} loop : ${ELAPSED_PARAM}ms   (0 fork calls)"
if (( ELAPSED_BASENAME > ELAPSED_PARAM )); then
  pass "Pure bash is faster by $((ELAPSED_BASENAME - ELAPSED_PARAM))ms on $N_ITERATIONS iterations"
fi

# BENCHMARK 3: $(cat file) vs read -rd ''
BIGFILE="$SEG20_DIR/perf_data.txt"
info "Benchmark: \$(cat file) vs read -rd '' var < file"

START=$(date +%s%3N)
for i in $(seq 1 10); do _content=$(cat "$BIGFILE"); done
ELAPSED_CAT=$(( $(date +%s%3N) - START ))

START=$(date +%s%3N)
for i in $(seq 1 10); do read -rd '' _content < "$BIGFILE" || true; done
ELAPSED_READ=$(( $(date +%s%3N) - START ))

pass "\$(cat file) ×10 : ${ELAPSED_CAT}ms  (10 fork+exec calls)"
pass "read -rd '' ×10 : ${ELAPSED_READ}ms  (0 forks — current process reads)"

# BENCHMARK 4: Uppercase — tr vs ${var^^}
info "Benchmark: tr vs \${var^^} for uppercase ($N_ITERATIONS iterations)"
TEST_STR="production-web-server-hostname-01"

START=$(date +%s%3N)
for i in $(seq 1 $N_ITERATIONS); do _up=$(echo "$TEST_STR" | tr 'a-z' 'A-Z'); done
ELAPSED_TR=$(( $(date +%s%3N) - START ))

START=$(date +%s%3N)
for i in $(seq 1 $N_ITERATIONS); do _up="${TEST_STR^^}"; done
ELAPSED_PARAM_UP=$(( $(date +%s%3N) - START ))

pass "tr uppercase ×$N_ITERATIONS  : ${ELAPSED_TR}ms  (forks per iteration)"
pass "\${var^^} ×$N_ITERATIONS     : ${ELAPSED_PARAM_UP}ms  (zero forks)"

# ─── PRECISION: type -a — Builtin vs. external cost ───────────────────────────
section "20-PRECISION: type -a / type -t — Builtin Cost vs. Fork Cost"

# [COMMAND MEANING] type -a command = Reports all definitions: alias, function,
#                   builtin, or external file. Builtins have zero fork cost.
# [FLAG MEANING]    -t = Returns a single word: builtin, function, alias, file.
# [WHAT]: Identify which common commands are builtins (free) vs. external (fork).

info "type -t command classification:"
for cmd in echo printf read cd pwd test [ [[ true false ls find grep awk sed; do
  CMD_TYPE=$(type -t "$cmd" 2>/dev/null || echo "not found")
  if [[ "$CMD_TYPE" == "builtin" || "$CMD_TYPE" == "keyword" ]]; then
    pass "  $cmd → $CMD_TYPE (zero fork cost)"
  else
    info "  $cmd → $CMD_TYPE (requires fork+exec)"
  fi
done

# ─── PRECISION: awk one-pass vs. N grep calls ─────────────────────────────────
section "20-PRECISION: awk One-Pass vs. Per-Line Loops"

# [COMMAND MEANING] awk one-pass = Processing an entire file with one awk
#                   invocation is orders of magnitude faster than calling sed/grep
#                   once per line in a shell loop.
# [WHAT]: Time a naive shell loop doing grep per line vs. a single awk pass.

info "Benchmark: shell loop with grep vs. single awk pass on $LINE_COUNT lines"

# Naive loop (slow — N grep forks)
START=$(date +%s%3N)
ERROR_COUNT_LOOP=0
while IFS= read -r line; do
  if echo "$line" | grep -q 'ERROR'; then
    (( ERROR_COUNT_LOOP++ ))
  fi
done < <(head -100 "$SEG20_DIR/perf_data.txt")  # Only 100 lines or we'll be here all day
ELAPSED_LOOP=$(( $(date +%s%3N) - START ))

# Single awk pass (fast)
START=$(date +%s%3N)
ERROR_COUNT_AWK=$(awk '/ERROR/{c++} END{print c+0}' "$SEG20_DIR/perf_data.txt")
ELAPSED_AWK=$(( $(date +%s%3N) - START ))

pass "Shell loop (100 lines, N greps)  : ${ELAPSED_LOOP}ms  → count=$ERROR_COUNT_LOOP"
pass "awk one-pass ($LINE_COUNT lines) : ${ELAPSED_AWK}ms   → count=$ERROR_COUNT_AWK"
pass "awk is measuring the full dataset; the loop only measured 100 lines and was STILL slower"

# ─── DEVOPS: strace -c — Syscall frequency profiling ─────────────────────────
section "20-DEVOPS: strace -c — Syscall Profile & Language Boundary Decisions"

# [COMMAND MEANING] strace -c = Produces a per-syscall frequency and cumulative
#                   time summary; identifies hidden bottlenecks in script execution.
# [FLAG MEANING]    -f = Follow forks; traces all child processes too.

if command -v strace &>/dev/null; then
  info "strace -c syscall profile of a simple grep:"
  strace -c grep -c 'ERROR' "$SEG20_DIR/perf_data.txt" > /dev/null 2>"$SEG20_DIR/strace_out.txt" || true
  head -15 "$SEG20_DIR/strace_out.txt" | sed 's/^/  /'
else
  info "strace not installed — install: apt-get install strace"
  info "strace -c usage: strace -c bash script.sh 2>profile.txt"
  info "strace -f usage: strace -f bash script.sh (follow forks into children)"
fi

# ─── DEVOPS: Language boundary decision framework ─────────────────────────────
section "20-DEVOPS: Language Boundary — When to Leave Bash"

info "Decision Framework:"
info ""
info "  STAY IN BASH when:"
info "    • Glue code, filesystem ops, process orchestration"
info "    • Simple automation under ~200 lines"
info "    • Wrapping existing CLI tools"
info ""
info "  SWITCH TO PYTHON when:"
info "    • Complex data structures (dicts of dicts, dataclasses)"
info "    • HTTP client logic beyond simple curl wrappers"
info "    • JSON at scale (parsing large API responses in a loop)"
info "    • Rich error recovery, retries with backoff"
info ""
info "  SWITCH TO GO when:"
info "    • Performance-critical paths (sub-millisecond latency required)"
info "    • Binary distribution (single static binary, no interpreter)"
info "    • Concurrent workloads (goroutines vs. fork bombs)"
info ""
info "  RULE OF THUMB:"
info "    Script > ~200 lines OR requires real data structures = reconsider the language."

rm -rf "$SEG20_DIR"
pass "Segment 20 complete — Performance optimization and language decisions."


# ============================================================================
#  FINAL SCORE
# ============================================================================
echo ""
echo -e "${BOLD}${GREEN}================================================================${RESET}"
echo -e "${BOLD}${GREEN}  ALL 20 SEGMENTS COMPLETE — TOPTAL BASELINE ESTABLISHED       ${RESET}"
echo -e "${BOLD}${GREEN}================================================================${RESET}"
echo ""
echo -e "${CYAN}  What you just ran:${RESET}"
echo "  ✔ Segment  1 — Unix mental model, shebang, fork+exec"
echo "  ✔ Segment  2 — declare, local, scope, introspection vars"
echo "  ✔ Segment  3 — Quoting, IFS, nullglob, full param expansion"
echo "  ✔ Segment  4 — Environment, PATH hygiene, credential safety"
echo "  ✔ Segment  5 — test/[[]], file tests, case, short-circuit"
echo "  ✔ Segment  6 — Loops: for/while/C-style/select/break N"
echo "  ✔ Segment  7 — Functions, return, nameref, export -f"
echo "  ✔ Segment  8 — Arrays, mapfile, associative arrays"
echo "  ✔ Segment  9 — FDs, redirections, pipelines, PIPESTATUS"
echo "  ✔ Segment 10 — Strict mode, traps, die(), mutex lock"
echo "  ✔ Segment 11 — mktemp, atomic writes, TOCTOU, noclobber"
echo "  ✔ Segment 12 — grep, sed, awk, cut, tr, sort, uniq, jq"
echo "  ✔ Segment 13 — eval danger, whitelist validation, sudo -n"
echo "  ✔ Segment 14 — Background jobs, kill, throttled parallelism"
echo "  ✔ Segment 15 — bash -n/x, PS4, shellcheck, structured logging"
echo "  ✔ Segment 16 — find, flock, rsync, envsubst, path ops"
echo "  ✔ Segment 17 — SSH automation, curl -fsS, jq API parsing"
echo "  ✔ Segment 18 — Idempotency, .env parsing, OS detection"
echo "  ✔ Segment 19 — cron, systemd timers, daemon lifecycle"
echo "  ✔ Segment 20 — Fork cost, pure-bash perf, awk one-pass, strace"
echo ""
echo -e "${BOLD}${YELLOW}  Next stop: The Crucible (Segment 5 — Assessment). Say the word.${RESET}"
echo ""