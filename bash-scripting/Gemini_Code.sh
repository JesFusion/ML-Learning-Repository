#!/usr/bin/env bash
# [FLAG MEANING] #!/usr/bin/env bash = Portable shebang — uses PATH to find bash, not hardcoded /bin/bash

# ==============================================================================
#  BASH ZERO-TO-HERO | MODULES 1–5 MASTERCLASS EXECUTION SCRIPT
#  Segments: 1.1 → 5.2 | Toptal Elite Standard
#  Author  : Mike (Principal DevOps Architect)
#  Student : Jesse
#  Version : 1.0
#
#  EXIT CODES USED:
#    0   = success
#    1   = generic failure
#    2   = missing dependency
# ==============================================================================

set -euo pipefail
# [FLAG MEANING] -e  = errexit   — exit immediately on any non-zero command return
# [FLAG MEANING] -u  = nounset   — treat any unset variable reference as a fatal error
# [FLAG MEANING] -o pipefail     — the pipeline's exit code = the first failing command (not just the last)

# ── Sandbox Setup ─────────────────────────────────────────────────────────────
# [WHAT]: Create an isolated temp workspace for the entire session and register
#         an EXIT trap to auto-delete it no matter how the script terminates.
# [WHY]:  mktemp -d is atomic and unpredictable — no race-condition symlink attacks.
#         Using $$ for temp names (e.g. /tmp/script.$$) is a known security hole.
WORKSPACE=$(mktemp -d)
# [COMMAND MEANING] mktemp = Make Temporary (file or directory)
# [FLAG MEANING] -d = directory — create a temp DIRECTORY instead of a file

trap 'rm -rf "$WORKSPACE"' EXIT
# [COMMAND MEANING] trap = Trap a signal or shell event and run a handler
# [WHAT ELSE]: trap also catches ERR (on non-zero), DEBUG (before every command),
#              RETURN (on function return), and real signals like SIGTERM, SIGINT

cd "$WORKSPACE"

# Helper: pretty section printer
_section() {
  echo ""
  echo "================================================================================"
  echo "  $*"
  echo "================================================================================"
  echo ""
}

_pillar() {
  echo ""
  echo "  ──────────────────────────────────────────────────────"
  echo "  $*"
  echo "  ──────────────────────────────────────────────────────"
}

# ==============================================================================
# MODULE 1 — THE UNIX PHILOSOPHY & SHELL FUNDAMENTALS
# ==============================================================================

_section "SEGMENT 1.1 — THE UNIX MENTAL MODEL"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# Most /proc reads are live — they need no mock data. We just read the kernel.

_pillar "BASIC: Snapshot your process table"

# [COMMAND MEANING] ps = Process Status
# [WHAT]: Print a snapshot of running processes. This is the first tool you reach
#         for when asking "what is alive on this system right now?"
# [WHY]:  ps reads from /proc — it does NOT need root for basic usage.
ps

echo ""

_pillar "POWER: Full system process inventory"

# [FLAG MEANING] a = all users' processes (not just yours)
# [FLAG MEANING] u = user-oriented format (shows %CPU, %MEM, VSZ, RSS)
# [FLAG MEANING] x = include processes without a controlling TTY (daemons)
# [WATCH OUT]: ps aux output order is NOT guaranteed — don't pipe this into
#              positional parsing. Use --format or awk field names.
ps aux | head -8
echo "  [truncated for brevity — full system shown in production]"
echo ""

# [FLAG MEANING] -e = every process on the system (POSIX form of 'ax')
# [FLAG MEANING] -o = output format — select exactly which columns you want
# [WHAT]: Print only PID, parent PID, and command for every process
# [WHY]:  This is the POSIX-portable form used in #!/bin/sh scripts where
#         BSD-style 'aux' flags may not exist
ps -eo pid,ppid,cmd | head -8
echo ""

_pillar "PRECISION: Visualise the process TREE"

# [FLAG MEANING] --forest = render parent→child relationships as an ASCII tree
# [WHAT]: Shows which processes spawned which — identifies orphaned/zombie chains
# [WHY]:  In a Docker container crash investigation, --forest reveals whether
#         a zombie was created by a signal-unaware parent
ps --forest -eo pid,ppid,cmd | head -15
echo ""

# [COMMAND MEANING] pstree = Process-Status Tree
# [WHAT]: Compact tree rooted at PID 1 (init/systemd)
# [WHY]:  Faster visual than ps --forest for understanding the full hierarchy
# [FLAG MEANING] -p = include PIDs alongside each process name
pstree -p | head -20
echo ""

_pillar "DEVOPS CONTEXT: Inspecting a process via /proc"

# [COMMAND MEANING] /proc = Process filesystem — a virtual FS the kernel exposes
# [WHAT]: Read the kernel-maintained status file for the CURRENT shell ($$)
# [WHY]:  No external tool needed. /proc/$$/status gives you UID, GID, memory,
#         and thread info — critical for debugging privilege issues in automation
# [WATCH OUT]: $$ is the PID of the PARENT shell, not a subshell. Use $BASHPID
#              inside subshells if you need the actual PID of that child.
echo "--- /proc/\$\$/status (live kernel data for THIS shell) ---"
cat /proc/$$/status | head -20
echo ""

# [FLAG MEANING] -la = long listing with hidden files, all attributes shown
# [WHAT]: List ALL virtual files under the current process's /proc directory
echo "--- /proc/\$\$ directory listing ---"
ls -la /proc/$$ | head -20
echo ""

# [WHAT]: Show every memory region mapped into this process — .text, .data,
#         heap, stack, and shared libraries with their permissions
echo "--- /proc/\$\$/maps (virtual memory map) ---"
cat /proc/$$/maps | head -15
echo ""

# [WHAT]: List every open file descriptor this shell currently holds
# [WHY]:  FD 0/1/2 are stdin/stdout/stderr. Any extra FDs reveal open sockets,
#         log files, or pipe handles — the source of "too many open files" bugs
echo "--- /proc/\$\$/fd (open file descriptors) ---"
ls -la /proc/$$/fd
echo ""

# [COMMAND MEANING] lsof = List Open Files
# [WHAT]: Kernel-level view of ALL open files by process, including sockets & pipes
# [FLAG MEANING] -p = filter by PID
# [WHY]:  Tells you exactly what a process is touching at this moment —
#         indispensable when a log file grows unexpectedly or a port is "in use"
lsof -p $$ 2>/dev/null | head -20 || true
echo ""

_pillar "WHAT ELSE (strace — not run live to avoid permission noise)"

# [COMMAND MEANING] strace = System Call Trace
# [WHAT]: Intercepts and logs every syscall between a process and the kernel
# [WHY]:  When a script hangs on a blocked read() or fails with EACCES, strace
#         shows EXACTLY which syscall is the culprit — no guessing
# [FLAG MEANING] -e trace=execve = filter to only show program launch events
# [FLAG MEANING] -p PID          = attach to an already-running process
# [FLAG MEANING] -f              = follow (trace) all child processes forked
echo "  strace -e trace=execve bash -c 'ls'   # traces every exec() call made"
echo "  strace -p \$SOME_PID                   # attach to live process"
echo "  strace -f bash script.sh               # follow all forks in a script"

# [COMMAND MEANING] file = Identify file type via magic bytes
# [WHAT]: Confirms that /dev/sda is a block device — not a regular file
# [WHY]:  Reinforces "everything is a file" — devices appear as files in /dev
echo ""
file /dev/null   # safe stand-in for block devices in any sandbox
echo ""

# [FLAG MEANING] -la /dev/ = long listing of device files
# [WHAT]: Shows 'b' (block), 'c' (character), 'p' (pipe) in the first column
echo "--- Sample /dev device files ---"
ls -la /dev/ | head -15
echo ""

# ==============================================================================

_section "SEGMENT 1.2 — TERMINAL EMULATORS, TTYs & THE SHELL"

_pillar "BASIC: Identify your TTY and session context"

# [COMMAND MEANING] tty = TeleTYpewriter — prints the terminal device path
# [WHAT]: Shows which PTY (pseudo-terminal) stdin is connected to
# [WHY]:  In scripts, if tty returns "not a tty", you know stdin is a pipe/file
#         not an interactive terminal — use this to gate interactive prompts
tty || echo "  [no TTY — stdin is redirected (pipe or file)]"
echo ""

# [COMMAND MEANING] who = Show who is logged in
# [WHAT]: Lists each login session, the TTY assigned, and login time
# [WHY]:  In a multi-user server audit script, who tells you which TTYs are live
who || true
echo ""

# [COMMAND MEANING] w = Who + What they are doing
# [WHAT]: Extends 'who' with the command each user is currently running and idle time
# [WHY]:  Useful in SRE runbooks for confirming no other engineer is running
#         a conflicting maintenance script on the same server
w || true
echo ""

_pillar "POWER: Shell nesting and startup file diagnostics"

# [WHAT]: Print the shell nesting depth — starts at 1, increments each subshell
# [WHY]:  If $SHLVL is unexpectedly high (e.g. 4+) inside a CI job, it means
#         your CI wrapper is spawning redundant shell layers. Useful debug signal.
echo "SHLVL (nesting depth): $SHLVL"
echo ""

# [WHAT]: Print active shell option flags — 'i' = interactive, 's' = stdin
# [WHY]:  Scripts should NOT behave differently based on interactivity unless
#         explicitly designed to. $- exposes which options are active.
echo "Active shell flags (\$-): $-"
echo ""

# [WHAT]: Check if this is a login shell
# [COMMAND MEANING] shopt = Shell Options — get or set Bash option flags
# [FLAG MEANING] login_shell = reports on/off whether this is a login shell
shopt login_shell || true  # returns non-zero if off — guard against set -e
echo ""

# [WHAT]: Print all valid login shells registered in /etc/shells
# [WHY]:  chsh will reject any shell not listed here. Automation that calls chsh
#         must verify the target shell is pre-registered.
echo "--- Valid login shells (/etc/shells) ---"
cat /etc/shells 2>/dev/null || echo "  [/etc/shells not found on this system]"
echo ""

_pillar "PRECISION: Resolve stdin's actual device"

# [WHAT]: Show what device is connected to FD 0 (stdin) for this process
# [WHY]:  Distinguishes TTY from pipe from file redirect — the three execution contexts
#         that change how a script must behave (prompts, passwords, colour output)
echo "--- stdin device (FD 0) ---"
ls -la /proc/$$/fd/0
echo ""

_pillar "WHAT ELSE (SSH & multiplexers — shown as syntax, not executed live)"

# [COMMAND MEANING] ssh = Secure Shell
# [FLAG MEANING] -t = force PTY allocation — required for interactive remote commands
# [FLAG MEANING] -T = suppress PTY — used for batch/non-interactive SSH automation
echo "  ssh user@host                    # login shell, login startup files run"
echo "  ssh -t user@host 'htop'          # force PTY for interactive TUI programs"
echo "  ssh -T user@host 'bash -s' < local.sh  # run local script on remote host"
echo ""
# [COMMAND MEANING] tmux = Terminal Multiplexer
# [COMMAND MEANING] screen = Screen multiplexer (legacy alternative to tmux)
echo "  tmux new -s mysession            # new named tmux session (PTY inside)"
echo "  tmux attach -t mysession         # re-attach to surviving session"
echo "  screen                           # classic detachable session"
echo ""

# ==============================================================================

_section "SEGMENT 1.3 — ENVIRONMENT SETUP & TOOLCHAIN"

_pillar "BASIC: Version and binary identification"

# [WHAT]: Print the full Bash version string — essential before using Bash 4+ features
# [WHY]:  macOS ships with Bash 3.2 (GPL2). Bash 4+ features like associative arrays,
#         ${var^^}, and mapfile will silently fail or throw syntax errors on 3.2
bash --version
echo ""

# [COMMAND MEANING] which = Locate a binary in PATH
# [WHAT]: Find the first 'bash' binary found by searching PATH left-to-right
# [WHY]:  On macOS with Homebrew, /usr/local/bin/bash (5.x) may shadow /bin/bash (3.2)
#         Use this to confirm which bash the shebang will actually invoke
which bash
echo ""

# [COMMAND MEANING] command = Shell builtin for command lookup
# [FLAG MEANING] -v = verbose — print the path or alias/function definition
# [WHAT]: POSIX-compliant alternative to 'which' — preferred in scripts
# [WHY]:  'which' is an external binary that may not exist on all systems.
#         'command -v' is a shell builtin — it always works in #!/bin/sh scripts.
command -v bash
echo ""

# [COMMAND MEANING] type = Identify the nature of a command name
# [WHAT]: Reports whether a name resolves to a builtin, function, alias, or external binary
# [WHY]:  After sourcing a library, 'type funcname' confirms the function loaded correctly
type bash
type ls
echo ""

_pillar "POWER: Static analysis with shellcheck"

# [COMMAND MEANING] shellcheck = Shell Check — static analysis for sh/bash scripts
# [WHAT]: Write a deliberately flawed script, then run shellcheck to catch the bugs
# [WHY]:  shellcheck catches unquoted variables (SC2086), word-splitting traps,
#         and portability issues that cause production failures — BEFORE they run

# Create a flawed script for analysis
cat > "$WORKSPACE/flawed.sh" << 'FLAWED'
#!/bin/bash
name=World
echo Hello $name
files=$(ls /tmp)
for f in $files; do
  echo $f
done
FLAWED

echo "--- Flawed script content ---"
cat "$WORKSPACE/flawed.sh"
echo ""

# [FLAG MEANING] -s bash = set dialect to bash (not sh or ksh)
echo "--- shellcheck output (SC numbers = warning codes) ---"
shellcheck -s bash "$WORKSPACE/flawed.sh" || true
echo ""

# [FLAG MEANING] -s sh = check for POSIX sh compliance — Bashisms become errors
echo "--- shellcheck POSIX compliance check ---"
shellcheck -s sh "$WORKSPACE/flawed.sh" || true
echo ""

# [FLAG MEANING] -e SC2086 = suppress a specific warning globally
echo "--- shellcheck with SC2086 suppressed ---"
shellcheck -s bash -e SC2086 "$WORKSPACE/flawed.sh" || true
echo ""

_pillar "PRECISION: source and dot-operator"

# [COMMAND MEANING] source = Execute a file IN the current shell (not a subshell)
# [WHAT]: Create a library file, source it, confirm its contents are in scope
# [WHY]:  'source' vs './script.sh': sourcing shares the current shell's env;
#         executing in a subshell isolates it. Get this wrong and your env vars
#         disappear after the script completes.
cat > "$WORKSPACE/lib.sh" << 'LIB'
MY_LIB_VERSION="1.0"
greet() { echo "Hello from lib, arg=$1"; }
LIB

source "$WORKSPACE/lib.sh"
echo "MY_LIB_VERSION after source: $MY_LIB_VERSION"
greet "Jesse"
echo ""

# [WHAT]: POSIX dot-operator — identical to source but works in #!/bin/sh
# [WHY]:  In scripts that must run under /bin/sh, use . instead of source
. "$WORKSPACE/lib.sh"
echo "Re-sourced with dot operator — greet still available:"
greet "dot-operator"
echo ""

_pillar "WHAT ELSE (apt-get installs — shown as syntax)"

# [COMMAND MEANING] apt-get = Advanced Package Tool (Debian/Ubuntu)
echo "  sudo apt-get install -y coreutils  # GNU ls, cp, mv, cat (~100 tools)"
echo "  sudo apt-get install -y util-linux # mount, lsblk, flock, kill"
echo "  sudo apt-get install -y procps     # ps, top, kill, free, vmstat"
echo "  sudo apt-get install -y lsof       # open-file lister"
echo "  sudo apt-get install -y strace     # syscall tracer"
echo "  sudo apt-get install -y shellcheck # static analysis"
echo ""

# ==============================================================================

_section "SEGMENT 1.4 — ANATOMY OF A BASH SCRIPT"

_pillar "BASIC: Shebang variants and what they mean"

# [WHAT]: Create three identical scripts with different shebangs to compare

# Shebang 1: hardcoded path
cat > "$WORKSPACE/hard_shebang.sh" << 'EOF'
#!/bin/bash
echo "I use the hardcoded /bin/bash shebang"
EOF

# Shebang 2: env-based portable shebang
cat > "$WORKSPACE/env_shebang.sh" << 'EOF'
#!/usr/bin/env bash
echo "I use the portable /usr/bin/env bash shebang"
EOF

# Shebang 3: POSIX sh — restricted subset
cat > "$WORKSPACE/posix_shebang.sh" << 'EOF'
#!/bin/sh
echo "I use the POSIX sh shebang — no Bash features"
EOF

echo "--- Shebang 1: hard-coded ---"
cat "$WORKSPACE/hard_shebang.sh"
echo ""
echo "--- Shebang 2: env-portable (PREFERRED) ---"
cat "$WORKSPACE/env_shebang.sh"
echo ""
echo "--- Shebang 3: POSIX sh ---"
cat "$WORKSPACE/posix_shebang.sh"
echo ""

_pillar "POWER: chmod permission modes"

# [COMMAND MEANING] chmod = Change Mode (file permission bits)
# [FLAG MEANING] +x = add eXecute permission for owner, group, and others
chmod +x "$WORKSPACE/env_shebang.sh"
ls -la "$WORKSPACE/env_shebang.sh"
echo ""

# [FLAG MEANING] 755 = rwxr-xr-x — owner: full, group+others: read+execute only
# [WHY]: 755 is the standard for scripts in system paths (/usr/local/bin)
chmod 755 "$WORKSPACE/hard_shebang.sh"
ls -la "$WORKSPACE/hard_shebang.sh"
echo ""

# [FLAG MEANING] 700 = rwx------ — ONLY the owner can access this script
# [WHY]: Use 700 for scripts containing credential logic or sensitive operations
chmod 700 "$WORKSPACE/posix_shebang.sh"
ls -la "$WORKSPACE/posix_shebang.sh"
echo ""

_pillar "PRECISION: bash flags as execution modifiers"

# [COMMAND MEANING] bash -n = No-execute (dry run / syntax check only)
# [WHAT]: Parse the script for syntax errors WITHOUT running any of it
# [WHY]:  Run this in a pre-commit hook or CI gate — catches parse errors
#         before they detonate in production
echo "--- bash -n syntax check (should pass) ---"
bash -n "$WORKSPACE/env_shebang.sh" && echo "Syntax OK"
echo ""

# [WHAT]: Introduce a syntax error and show bash -n catching it
cat > "$WORKSPACE/broken.sh" << 'EOF'
#!/usr/bin/env bash
if true
  echo "missing 'then'"
fi
EOF
echo "--- bash -n syntax check (should FAIL) ---"
bash -n "$WORKSPACE/broken.sh" 2>&1 || echo "Syntax error detected — script NOT run"
echo ""

# [FLAG MEANING] -x = xtrace — print each expanded command before executing it
# [WHAT]: The most powerful live-debugging tool in Bash
# [WHY]:  When a script behaves unexpectedly in CI, -x shows you the EXACT
#         commands and variable values at every step — no print-debugging needed
echo "--- bash -x xtrace output ---"
bash -x "$WORKSPACE/env_shebang.sh" 2>&1
echo ""

# [FLAG MEANING] -v = verbose — print each INPUT LINE as it is READ (before expansion)
# [WHAT]: Reveals macro/source expansion — shows the raw text before substitution
echo "--- bash -v verbose output ---"
bash -v "$WORKSPACE/env_shebang.sh" 2>&1
echo ""

# [FLAG MEANING] -e = errexit — exit on first non-zero command
echo "--- bash -e: exit on first failure ---"
bash -e -c 'echo start; false; echo "NEVER REACHED"' 2>&1 || echo "Exited due to -e"
echo ""

_pillar "DEVOPS CONTEXT: Exit codes — the API contract"

# [WHAT]: Demonstrate each reserved exit code and what it means
# [WHY]:  Exit codes are the ONLY communication channel between your script and
#         the calling process (CI runner, orchestrator, cron, systemd). Get this
#         wrong and silent failures become invisible corruptions.
echo "--- Exit code 0 (success) ---"
bash -c 'exit 0'; echo "Exit code: $?"

echo "--- Exit code 1 (generic failure) ---"
bash -c 'exit 1' || echo "Exit code: $?"

echo "--- Exit code 127 (command not found) ---"
bash -c 'nonexistent_command_xyz' 2>/dev/null || echo "Exit code: $?"

echo "--- Exit code 126 (not executable) ---"
# Create a non-executable file to trigger 126
cat > "$WORKSPACE/noexec.sh" << 'EOF'
echo "I am not executable"
EOF
chmod 644 "$WORKSPACE/noexec.sh"
"$WORKSPACE/noexec.sh" 2>/dev/null || echo "Exit code: $?"
echo ""

# ==============================================================================
# MODULE 2 — VARIABLES, DATA TYPES & THE ENVIRONMENT
# ==============================================================================

_section "SEGMENT 2.1 — VARIABLE DECLARATION & ASSIGNMENT"

_pillar "BASIC: declare flags and type enforcement"

# [COMMAND MEANING] declare = Declare a variable with optional type attributes
# [WHAT]: The Swiss Army knife of variable declaration in Bash

# [FLAG MEANING] -i = integer — non-numeric assignments coerce to 0
declare -i counter=0
counter=42
echo "Integer var: $counter"
# [WATCH OUT]: Assigning a non-integer string to a declare -i var coerces it to 0.
#              In arithmetic context, bare words are treated as variable names.
#              With set -u, this fires "unbound variable". Disable -u momentarily.
(
  set +u
  declare -i _ct=0
  _ct="not_a_number"
  echo "After non-integer assignment: $_ct  (coerced to 0)"
)
echo ""

# [FLAG MEANING] -r = readonly — any reassignment is a fatal error
declare -r APP_VERSION="3.14.1"
echo "Readonly var: $APP_VERSION"
# Attempting to reassign would trigger: bash: APP_VERSION: readonly variable
# We don't run it to preserve set -e
echo "  [readonly reassignment would abort script under set -e]"
echo ""

# [FLAG MEANING] -x = export — equivalent to 'export varname'
declare -x EXPORTED_DB_HOST="db.prod.example.com"
printenv EXPORTED_DB_HOST
echo ""

# [FLAG MEANING] -a = array — explicitly declare an indexed array
declare -a my_servers
my_servers=("web01" "web02" "db01")
echo "Array: ${my_servers[*]}"
echo ""

# [FLAG MEANING] -A = associative array (hash map) — MUST be declared before use
declare -A service_ports
service_ports[http]=80
service_ports[https]=443
service_ports[postgres]=5432
echo "Associative array keys: ${!service_ports[*]}"
echo "Associative array values: ${service_ports[*]}"
echo ""

# [FLAG MEANING] -n = nameref — the variable becomes an alias for another variable
declare -n alias_for_counter=counter
alias_for_counter=99
echo "counter via nameref: $counter"
echo ""

# [FLAG MEANING] -p = print — show the full declaration including type flags
echo "--- declare -p output ---"
declare -p APP_VERSION
declare -p service_ports
echo ""

# [FLAG MEANING] -l = lowercase — values auto-lowercased on assignment
declare -l lower_var
lower_var="HeLLo WoRLD"
echo "lower_var: $lower_var"
echo ""

# [FLAG MEANING] -u = uppercase — values auto-uppercased on assignment
declare -u upper_var
upper_var="hello world"
echo "upper_var: $upper_var"
echo ""

_pillar "POWER: readonly and unset"

# [COMMAND MEANING] readonly = Mark variable immutable (POSIX form of declare -r)
readonly MAX_RETRIES=3
echo "MAX_RETRIES: $MAX_RETRIES"

# [FLAG MEANING] -p (readonly) = print all readonly variables
echo "--- All readonly variables ---"
readonly -p | grep -E "MAX_RETRIES|APP_VERSION" || true
echo ""

# [COMMAND MEANING] unset = Remove a variable or function from the shell
# [FLAG MEANING] -v = variable — unset a variable (not a function)
# [WATCH OUT]: Unsetting a variable in a set -u script will cause the NEXT
#              reference to it to throw a fatal "unbound variable" error
counter_temp=100
unset -v counter_temp
echo "counter_temp after unset: ${counter_temp:-[unset — default shown]}"
echo ""

# [FLAG MEANING] -f (unset) = function — unset a function definition
_temp_func() { echo "I am temporary"; }
_temp_func
unset -f _temp_func
echo "  [_temp_func removed — calling it now would error]"
echo ""

_pillar "DEVOPS CONTEXT: local in functions"

# [COMMAND MEANING] local = Scope a variable to the current function only
# [WHAT]: Prevent function variables from leaking into the global namespace
deploy_service() {
  # [FLAG MEANING] local -i = function-scoped integer
  local -i attempt=0
  # [FLAG MEANING] local -r = function-scoped readonly
  local -r SERVICE_NAME="$1"
  local status="unknown"

  echo "  Deploying: $SERVICE_NAME (local vars: attempt=$attempt, status=$status)"
  status="success"
  echo "  After deploy: status=$status"
}

deploy_service "payment-api"
echo "status outside function: ${status:-[not set — local worked!]}"
echo ""

# ==============================================================================

_section "SEGMENT 2.2 — VARIABLE EXPANSION & QUOTING RULES"

_pillar "BASIC: The four quoting modes"

# [WHAT]: Demonstrate each quoting mode side-by-side
demo_var="hello world"
special_chars='$HOME and `date`'

# [WHAT]: Double quotes — allow $ and `` expansion, suppress word-splitting
echo "Double-quoted: \"$demo_var\""

# [WHAT]: Single quotes — 100% literal, nothing expanded
echo 'Single-quoted: $demo_var is NOT expanded'

# [WHAT]: ANSI-C quoting — interpret escape sequences
echo $'ANSI-C: tab\there, newline\nhere'

# [WHAT]: No quotes — subject to word-splitting and glob expansion
# [WATCH OUT]: NEVER use unquoted variables on filesystem operations
echo ""

_pillar "POWER: IFS — the word-splitting engine"

# [WHAT]: Demonstrate IFS controlling how unquoted expansions are tokenized
csv_line="alice,bob,charlie,dave"

# Split on comma by setting IFS
IFS=',' read -ra names <<< "$csv_line"
# [COMMAND MEANING] IFS = Internal Field Separator
# [WHAT]: Temporarily changed IFS to comma — read splits the input accordingly
echo "CSV split via IFS=',': ${names[*]}"
echo "Element 0: ${names[0]}, Element 2: ${names[2]}"
echo ""

# [WHAT]: IFS=$'\n\t' — common setting to prevent space-splitting in loops
# [WHY]:  Default IFS includes space. If a filename has spaces, an unquoted
#         $file in a loop expands to TWO words and breaks the command.
OLD_IFS="$IFS"
IFS=$'\n\t'
echo "IFS set to newline+tab — spaces no longer split words"
IFS="$OLD_IFS"  # always restore
echo ""

# [WHAT]: IFS='' — disables ALL word-splitting
IFS='' read -r full_line <<< "  leading spaces preserved  "
echo "With IFS='': '$full_line'"
IFS="$OLD_IFS"
echo ""

_pillar "PRECISION: shopt glob options"

# [COMMAND MEANING] shopt = Shell Options — configure Bash behavior flags
# [FLAG MEANING] -s nullglob = unmatched globs expand to empty string (not literal)
shopt -s nullglob
shopt -s globstar

# Test nullglob: *.nonexistent would normally be the literal string
matches=( "$WORKSPACE"/*.nonexistent )
echo "nullglob: matched ${#matches[@]} files (would be 1 literal without nullglob)"

# Create some test files for glob demos
touch "$WORKSPACE/file1.log" "$WORKSPACE/file2.log" "$WORKSPACE/data.csv"
matches=( "$WORKSPACE"/*.log )
echo "*.log matched ${#matches[@]} files: ${matches[*]##*/}"
echo ""

# [FLAG MEANING] -s globstar = ** matches any depth recursively
mkdir -p "$WORKSPACE/deep/nested/dir"
touch "$WORKSPACE/deep/nested/dir/found.log"
all_logs=( "$WORKSPACE"/**/*.log )
echo "globstar **/*.log found ${#all_logs[@]} files"
echo ""

# [FLAG MEANING] -s nocaseglob = case-insensitive glob matching
shopt -s nocaseglob
touch "$WORKSPACE/README.TXT" "$WORKSPACE/readme.txt"
nocase=( "$WORKSPACE"/readme* )
echo "nocaseglob: readme* matched ${#nocase[@]} files"
shopt -u nocaseglob nullglob globstar   # restore defaults
echo ""

_pillar "DEVOPS CONTEXT: The -- separator and rm safety"

# [WHAT]: Demonstrate how a filename beginning with '-' can be mistaken as a flag
# [WHY]:  rm $file when $file="-rf /" is the classic foot-gun that nukes your server
touch -- "$WORKSPACE/-dangerous-name"
ls -la "$WORKSPACE/" | grep dangerous
echo ""

# [FLAG MEANING] -- = end-of-options marker — everything after is treated as a filename
rm -- "$WORKSPACE/-dangerous-name"
echo "Safely removed file with leading hyphen using -- separator"
echo ""

# ==============================================================================

_section "SEGMENT 2.3 — ENVIRONMENT VARIABLES & export"

_pillar "BASIC: export and the child process environment"

# [COMMAND MEANING] export = Mark a variable for inclusion in child process environments
local_only="I am NOT exported"
export EXPORTED_VAR="I AM in child envs"

# Prove the difference: local_only is invisible to the subshell
echo "--- Child process env check ---"
bash -c 'echo "EXPORTED_VAR in child: ${EXPORTED_VAR:-[NOT SET]}"; echo "local_only in child: ${local_only:-[NOT SET]}"'
echo ""

# [COMMAND MEANING] export -p = Print all exported variables (re-usable declare -x form)
echo "--- Subset of exported vars ---"
export -p | grep -E "EXPORTED_VAR|EXPORTED_DB_HOST" || true
echo ""

_pillar "POWER: env command variants"

# [COMMAND MEANING] env = Print or modify environment for command execution
# [WHAT]: Print all exported environment variables as KEY=value pairs
echo "--- env (first 10 lines) ---"
env | sort | head -10
echo ""

# [FLAG MEANING] VAR=val command = inject a variable for ONE command only
echo "--- Injecting COLOUR for a single command ---"
COLOUR=blue bash -c 'echo "COLOUR is: $COLOUR"'
echo "COLOUR outside that command: ${COLOUR:-[not set in THIS shell]}"
echo ""

# [FLAG MEANING] -i = ignore-environment — run with a completely clean env
echo "--- env -i: completely clean environment ---"
env -i PATH="/bin:/usr/bin" bash -c 'env'
echo ""

# [FLAG MEANING] env -i PATH=/bin sh = gold standard for isolation testing
echo "  [env -i PATH=/bin sh is used in CI to catch scripts that rely on]"
echo "  [inherited variables they haven't explicitly declared]"
echo ""

_pillar "PRECISION: printenv and PATH safety"

# [COMMAND MEANING] printenv = Print specific environment variable values
printenv HOME
printenv SHELL 2>/dev/null || echo "SHELL not set"
echo ""

# [COMMAND MEANING] LC_ALL=C = Force the C/POSIX locale for one command
# [WHAT]: Ensures sort, grep, and tr use byte-order — critical for deterministic scripts
# [WHY]:  Without LC_ALL=C, 'sort' may produce different output on different locales
echo "--- LC_ALL=C sort vs default sort ---"
LC_ALL=C echo "byte-order locale active for this echo"
echo ""

# [WHAT]: Safely prepend to PATH — the correct idiom
# [WATCH OUT]: NEVER add '.' to PATH — it allows current-directory command injection
echo "PATH before: $PATH" | head -c 100
PATH="/tmp/safe_scripts:$PATH"
echo ""
echo "PATH after prepend (first entry): ${PATH%%:*}"
echo ""

_pillar "DEVOPS CONTEXT: TMPDIR awareness"

echo "TMPDIR: ${TMPDIR:-/tmp (default)}"
echo "LANG: ${LANG:-[not set]}"
echo "LC_ALL: ${LC_ALL:-[not set]}"
echo ""

# ==============================================================================

_section "SEGMENT 2.4 — PARAMETER EXPANSION (THE FULL REFERENCE)"

_pillar "BASIC: Default values and null-guards"

# [WHAT]: Demonstrate every default-value expansion form
unset MAYBE_SET || true

# [WHAT]: Use default if unset OR empty
echo "${MAYBE_SET:-fallback_value}"

# [WHAT]: Use default only if unset (NOT on empty string)
EMPTY_VAR=""
echo "${EMPTY_VAR-not_triggered}"   # prints empty — var IS set
echo "${MAYBE_SET-triggered}"       # prints triggered — var is unset
echo ""

# [WHAT]: Assign default as a side effect
echo "Before := : ${MAYBE_SET:-[unset]}"
: "${MAYBE_SET:=now_assigned}"
echo "After := : $MAYBE_SET"
echo ""

# [WHAT]: Error and exit if unset or empty (used for required parameters)
# [WATCH OUT]: Under set -e, this will EXIT the script if REQUIRED_VAR is unset
REQUIRED_VAR="I am required"
echo "${REQUIRED_VAR:?This variable is mandatory}"
echo ""

# [WHAT]: Use alternate value when var IS set
FEATURE_FLAG="enabled"
echo "Flag alternate: ${FEATURE_FLAG:+--enable-feature}"
echo ""

_pillar "POWER: String manipulation without subshells"

TARGET_STRING="  Hello, World! This is a test string.  "

# [WHAT]: Get string length
echo "Length: ${#TARGET_STRING}"

# [WHAT]: Substring extraction
echo "Substring [2:5]: '${TARGET_STRING:2:5}'"

# [WHAT]: Last N characters using negative offset
echo "Last 8 chars: '${TARGET_STRING: -8}'"
echo ""

# [WHAT]: Prefix removal — mimics dirname/basename without a subprocess
filepath="/var/log/nginx/access.log"
echo "Original path:        $filepath"

# [FLAG MEANING] # = shortest prefix match (non-greedy)
echo "Strip shortest /*/:   ${filepath#*/}"

# [FLAG MEANING] ## = longest prefix match (greedy) — equivalent to basename
echo "basename equivalent:  ${filepath##*/}"

# [FLAG MEANING] % = shortest suffix match (non-greedy)
echo "Strip shortest .*:    ${filepath%.*}"

# [FLAG MEANING] %% = longest suffix match (greedy) — equivalent to dirname
echo "dirname equivalent:   ${filepath%/*}"
echo ""

# [WHAT]: Pattern substitution — global replace without spawning sed
log_entry="2024-01-15 ERROR: disk full. 2024-01-15 ERROR: retrying."
echo "Original:  $log_entry"
echo "First sub: ${log_entry/2024-01-15/[DATE]}"
echo "All sub:   ${log_entry//2024-01-15/[DATE]}"
echo ""

# [WHAT]: Anchor substitution to prefix or suffix
filename="backup_production_2024.tar.gz"
echo "Prefix sub: ${filename/#backup/archive}"
echo "Suffix sub: ${filename/%.tar.gz/.zip}"
echo ""

_pillar "PRECISION: Case modification and indirect expansion"

raw_input="hElLo WoRlD"

# [FLAG MEANING] ^ = uppercase first character (Bash 4+)
echo "First upper:  ${raw_input^}"

# [FLAG MEANING] ^^ = uppercase ALL characters (Bash 4+)
echo "All upper:    ${raw_input^^}"

# [FLAG MEANING] , = lowercase first character (Bash 4+)
echo "First lower:  ${raw_input,}"

# [FLAG MEANING] ,, = lowercase ALL characters (Bash 4+)
echo "All lower:    ${raw_input,,}"
echo ""

# [WHAT]: Indirect expansion — use a variable's VALUE as a variable NAME
# [WHY]:  Implements dynamic variable lookup — a poor-man's hash map for Bash 3
pointer="APP_VERSION"
echo "Indirect \${!pointer}: ${!pointer}"
echo ""

# [WHAT]: Prefix expansion — list all variable names starting with 'BASH_'
echo "Variables starting with BASH_:"
echo "${!BASH_*}"
echo ""

_pillar "DEVOPS CONTEXT: Safe config file path construction"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [WHAT]: The canonical pattern for getting the absolute directory of the
#         running script — works whether called directly or sourced
# [WHY]:  "$0" breaks when a script is sourced. BASH_SOURCE[0] always holds
#         the file path of the currently executing or sourced script.
echo "Script directory (BASH_SOURCE): $SCRIPT_DIR"
CONFIG_FILE="${SCRIPT_DIR}/config.env"
echo "Config file path: $CONFIG_FILE"
echo ""

# ==============================================================================

_section "SEGMENT 2.5 — SPECIAL VARIABLES"

_pillar "BASIC: Positional parameters"

demonstrate_positionals() {
  echo "  \$0 (script/function name): $0"
  echo "  \$# (arg count):            $#"
  echo "  \$1 (first arg):            ${1:-[none]}"
  echo "  \$2 (second arg):           ${2:-[none]}"
  echo ""

  echo "  Iterating \"\$@\" (safe — preserves spaces in args):"
  for arg in "$@"; do
    echo "    arg: [$arg]"
  done
  echo ""

  echo "  \"\$*\" merges to: [$*]"
  echo "  (notice all args become ONE string when quoted with \$*)"
}

demonstrate_positionals "first" "second arg with spaces" "third"

_pillar "POWER: Process and status variables"

echo "\$\$  (current PID):         $$"
echo "\$BASHPID (actual PID):     $BASHPID"
echo "\$?  (last exit code):      $?"
echo "\$-  (option flags):        $-"
echo "\$BASH_VERSION:             $BASH_VERSION"
echo ""

# [WHAT]: Demonstrate $$ vs $BASHPID divergence in a subshell
echo "--- \$\$ vs \$BASHPID inside subshell ---"
echo "Parent \$\$: $$, Parent \$BASHPID: $BASHPID"
( echo "Subshell \$\$: $$  (SAME as parent!), \$BASHPID: $BASHPID  (DIFFERENT!)" )
echo ""

# [WHAT]: Background job tracking with $!
sleep 0.1 &
BG_PID=$!
echo "\$! (last background PID): $BG_PID"
wait $BG_PID
echo "wait exit code: $?"
echo ""

_pillar "PRECISION: RANDOM, SECONDS, and LINENO"

echo "RANDOM (0–32767):  $RANDOM"
echo "RANDOM again:      $RANDOM"
RANDOM=42  # seed the PRNG
echo "RANDOM after seed: $RANDOM"
echo ""

echo "SECONDS since shell start: $SECONDS"
sleep 1
echo "SECONDS after 1s sleep:    $SECONDS"
echo ""

echo "Current LINENO: $LINENO"
echo "FUNCNAME (if in function): ${FUNCNAME[0]:-[global scope]}"
echo "BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
echo ""

_pillar "PRECISION: shift and positional parameter manipulation"

shift_demo() {
  echo "  Before shift: \$# = $#, \$1 = ${1:-}, \$2 = ${2:-}, \$3 = ${3:-}"
  shift
  # [COMMAND MEANING] shift = Shift positional parameters left by N (default 1)
  echo "  After shift 1: \$# = $#, \$1 = ${1:-}, \$2 = ${2:-}"
  shift 2 2>/dev/null || true
  echo "  After shift 2: \$# = $#, \$1 = ${1:-[gone]}"
}
shift_demo alpha beta gamma delta
echo ""

# [WHAT]: set -- clears all positional parameters
set -- "new_first" "new_second"
echo "After set --: \$1=$1, \$2=$2, \$#=$#"
set --  # clear all
echo "After set -- (empty): \$#=$#"
echo ""

# ==============================================================================
# MODULE 3 — CONTROL FLOW: CONDITIONALS
# ==============================================================================

_section "SEGMENT 3.1 — THE test COMMAND AND [ BUILTIN"

_pillar "BASIC: Integer and string comparisons"

a=10; b=20; name="Jesse"; empty=""

# [COMMAND MEANING] test = Evaluate a conditional expression (POSIX)
# [WHAT]: Integer comparisons
test "$a" -eq 10 && echo "-eq: a equals 10"
[ "$a" -ne "$b" ] && echo "-ne: a != b"
[ "$a" -lt "$b" ] && echo "-lt: a < b"
[ "$b" -gt "$a" ] && echo "-gt: b > a"
[ "$a" -le 10 ]   && echo "-le: a <= 10"
[ "$b" -ge 20 ]   && echo "-ge: b >= 20"
echo ""

# [WHAT]: String comparisons
[ "$name" = "Jesse" ] && echo "= : string equal"
[ "$name" != "Bob"  ] && echo "!=: string not equal"

# [FLAG MEANING] -z = zero-length — true if string is empty
[ -z "$empty" ] && echo "-z: empty string is zero-length"

# [FLAG MEANING] -n = non-zero-length — true if string has content
[ -n "$name" ]  && echo "-n: name has content"
echo ""

_pillar "POWER: File test operators"

# Create test subjects
touch "$WORKSPACE/readable.txt"
chmod 444 "$WORKSPACE/readable.txt"
mkdir -p "$WORKSPACE/testdir"
mkfifo "$WORKSPACE/testpipe"
ln -sf "$WORKSPACE/readable.txt" "$WORKSPACE/symlink.txt"

# [FLAG MEANING] -e = exists — any file type
[ -e "$WORKSPACE/readable.txt" ] && echo "-e: file exists"

# [FLAG MEANING] -f = regular file
[ -f "$WORKSPACE/readable.txt" ] && echo "-f: is a regular file"

# [FLAG MEANING] -d = directory
[ -d "$WORKSPACE/testdir" ] && echo "-d: is a directory"

# [FLAG MEANING] -r = readable
[ -r "$WORKSPACE/readable.txt" ] && echo "-r: file is readable"

# [FLAG MEANING] -w = writable
[ -w "$WORKSPACE/readable.txt" ] || echo "-w: file is NOT writable (chmod 444)"

# [FLAG MEANING] -x = executable
[ -x "$WORKSPACE/env_shebang.sh" ] && echo "-x: script is executable"

# [FLAG MEANING] -s = size > 0
echo "content" > "$WORKSPACE/nonempty.txt"
[ -s "$WORKSPACE/nonempty.txt" ] && echo "-s: file has content (size > 0)"

# [FLAG MEANING] -L = symbolic link
[ -L "$WORKSPACE/symlink.txt" ] && echo "-L: is a symlink"

# [FLAG MEANING] -p = named pipe (FIFO)
[ -p "$WORKSPACE/testpipe" ] && echo "-p: is a named pipe"

# [FLAG MEANING] -b = block special device
[ -b /dev/sda ] 2>/dev/null && echo "-b: is a block device" || echo "-b: /dev/sda not accessible (OK in container)"

# [FLAG MEANING] -c = character special device
[ -c /dev/tty ] 2>/dev/null && echo "-c: /dev/tty is a char device" || echo "-c: /dev/tty not available"

# [FLAG MEANING] -S = Unix socket
[ -S /run/docker.sock ] 2>/dev/null && echo "-S: docker.sock is a Unix socket" || echo "-S: no docker socket here"
echo ""

_pillar "DEVOPS CONTEXT: The empty variable trap"

# [WATCH OUT]: Unquoted variable in [ ] when var is empty = syntax error!
var_could_be_empty=""
echo "--- Safe (quoted) ---"
if [ "$var_could_be_empty" = "yes" ]; then
  echo "matches yes"
else
  echo "does not match yes (safe — no crash)"
fi

echo "--- The -a/-o compound operators (fragile — prefer && ||) ---"
[ "$a" -gt 5 -a "$b" -gt 5 ] && echo "-a compound: both true" || true
[ "$a" -gt 50 -o "$b" -gt 5 ] && echo "-o compound: at least one true" || true
echo ""

# ==============================================================================

_section "SEGMENT 3.2 — THE [[ EXTENDED TEST BUILTIN"

_pillar "BASIC: Pattern and regex matching"

filename="error_2024-01-15.log"
version="v2.14.3"
ip_addr="192.168.1.100"

# [WHAT]: Glob pattern match inside [[
[[ "$filename" == *.log ]] && echo "Pattern: filename ends in .log"
[[ "$filename" != *.txt ]] && echo "Pattern: filename is NOT a .txt"
echo ""

# [WHAT]: Regex match with =~
# [FLAG MEANING] =~ = Extended Regular Expression match operator
# [WHAT]: BASH_REMATCH[0] = full match, [1]+ = capture groups
if [[ "$version" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  echo "Regex match!"
  echo "  Full match:  ${BASH_REMATCH[0]}"
  echo "  Major:       ${BASH_REMATCH[1]}"
  echo "  Minor:       ${BASH_REMATCH[2]}"
  echo "  Patch:       ${BASH_REMATCH[3]}"
fi
echo ""

# [WHAT]: IP address validation via regex
if [[ "$ip_addr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Looks like an IP address: $ip_addr"
fi
echo ""

_pillar "POWER: Safe comparisons without quoting anxiety"

empty_safe=""
# [WHY]: Inside [[, no word splitting occurs — unquoted empty variable is safe
[[ $empty_safe == "" ]] && echo "[[ handles empty var without quoting error ]]"
echo ""

# [WHAT]: Logical operators inside [[
num=7
[[ $num -gt 5 && $num -lt 10 ]] && echo "&& inside [[: 5 < num < 10"
[[ $num -gt 10 || $num -lt 8 ]] && echo "|| inside [[: num > 10 OR num < 8"
[[ ! $num -eq 99 ]]             && echo "! inside [[: num is NOT 99"
echo ""

# [WHAT]: Lexicographic string comparison inside [[
[[ "apple" < "banana" ]] && echo "< : apple is lexicographically before banana"
[[ "zebra"  > "alpha"  ]] && echo "> : zebra is lexicographically after alpha"
echo ""

# [WHAT]: Arithmetic evaluation with (( ))
# [FLAG MEANING] (( expr )) = arithmetic compound command — returns 0 if result != 0
x=15
(( x > 10 )) && echo "(( )): x > 10 is arithmetically true"
(( x % 3 == 0 )) && echo "(( )): x is divisible by 3"
echo ""

# [FLAG MEANING] -v = variable is set (Bash 4.2+)
declared_var="present"
[[ -v declared_var ]] && echo "-v: declared_var is set"
unset maybe_missing || true
[[ -v maybe_missing ]] || echo "-v: maybe_missing is NOT set"
echo ""

# ==============================================================================

_section "SEGMENT 3.3 — if / elif / else / fi"

_pillar "BASIC: Full conditional structure"

check_service_status() {
  local -r service="$1"
  local -r port="${2:-80}"

  # [WHAT]: Minimal if/elif/else/fi demonstrating command-as-condition
  if [[ "$service" == "nginx" ]]; then
    echo "  Service: nginx (port $port) — web tier"
  elif [[ "$service" == "postgres" ]]; then
    echo "  Service: postgres (port $port) — data tier"
  elif [[ "$service" == "redis" ]]; then
    echo "  Service: redis (port $port) — cache tier"
  else
    echo "  Service: $service — unknown tier"
  fi
}

check_service_status "nginx" "80"
check_service_status "postgres" "5432"
check_service_status "redis" "6379"
check_service_status "kafka" "9092"
echo ""

_pillar "POWER: Command exit code as condition"

# [WHAT]: Use grep's exit code directly as an if condition — no [ ] needed
echo "DevOps Engineer" > "$WORKSPACE/roles.txt"
echo "SRE" >> "$WORKSPACE/roles.txt"
echo "Platform Engineer" >> "$WORKSPACE/roles.txt"

# [FLAG MEANING] -q = quiet — grep suppresses output; only exit code matters
if grep -q "DevOps" "$WORKSPACE/roles.txt"; then
  echo "grep: DevOps role found in roles.txt"
fi

# [FLAG MEANING] ! = negate a command's exit code
if ! grep -q "Manager" "$WORKSPACE/roles.txt"; then
  echo "grep: Manager role NOT found — safe to proceed"
fi
echo ""

# [WHAT]: Compound command as if condition using { }
if { echo "checking..." && [[ -f "$WORKSPACE/roles.txt" ]]; }; then
  echo "Compound condition: both echo and file test passed"
fi
echo ""

# [WHAT]: Arithmetic if condition
deployments=5
if (( deployments > 3 )); then
  echo "Arithmetic condition: $deployments deployments exceeds threshold of 3"
fi
echo ""

# ==============================================================================

_section "SEGMENT 3.4 — case STATEMENTS"

_pillar "BASIC: Pattern matching with case"

# [WHAT]: Route script behaviour based on a CLI argument
handle_action() {
  local action="$1"

  # [COMMAND MEANING] case = multi-pattern conditional branching
  case "$action" in
    start)
      echo "  case: Starting service..."
      ;;
    stop|shutdown)
      # [WHAT]: Multiple patterns per arm — pipe-separated
      echo "  case: Stopping service (matched 'stop' or 'shutdown')..."
      ;;
    restart|reload)
      echo "  case: Restarting service..."
      ;;
    status)
      echo "  case: Checking status..."
      ;;
    *.sh)
      # [WHAT]: Glob pattern arm — matches any .sh file path
      echo "  case: Executing script: $action"
      ;;
    [0-9]*)
      # [WHAT]: Character class glob — matches anything starting with a digit
      echo "  case: Numeric argument received: $action"
      ;;
    *)
      # [WHAT]: Wildcard default arm — catches everything else
      echo "  case: Unknown action: $action"
      ;;
  esac
}

handle_action "start"
handle_action "shutdown"
handle_action "deploy.sh"
handle_action "42"
handle_action "unknown_command"
echo ""

_pillar "POWER: Fall-through with ;& and ;;&"

# [WHAT]: Bash 4+ fall-through — execute NEXT arm unconditionally after match
echo "--- ;& fall-through ---"
stage="build"
case "$stage" in
  build)
    echo "  Running build..."
    ;&   # FALLS THROUGH to test
  test)
    echo "  Running tests..."
    ;&   # FALLS THROUGH to deploy
  deploy)
    echo "  Deploying..."
    ;;
esac
echo ""

# [WHAT]: Bash 4+ ;;&  — continue testing patterns even after a match
echo "--- ;;& continue-test ---"
log_level="WARNING"
case "$log_level" in
  ERROR|WARNING)
    echo "  Alerting on-call team..."
    ;;&  # CONTINUES testing — does NOT stop at first match
  WARNING|INFO)
    echo "  Writing to dashboard..."
    ;;&
  *)
    echo "  Writing to log file..."
    ;;
esac
echo ""

# ==============================================================================

_section "SEGMENT 3.5 — SHORT-CIRCUIT EVALUATION"

_pillar "BASIC: && and || chaining"

# [WHAT]: && — cmd2 runs ONLY if cmd1 succeeds (exit 0)
echo "test" > "$WORKSPACE/guard.txt"
[ -f "$WORKSPACE/guard.txt" ] && echo "&& : guard.txt exists, proceeding"

# [WHAT]: || — cmd2 runs ONLY if cmd1 fails
[ -f "$WORKSPACE/missing.txt" ] || echo "|| : missing.txt absent, using fallback"
echo ""

_pillar "POWER: Error handling idioms"

# [WHAT]: Canonical error-exit idiom using curly-brace grouping
# [WHY]:  Without { }, only the first command after || runs; exit won't chain
safe_operation() {
  local -r file="$1"
  [[ -f "$file" ]] || { echo "  ERROR: $file not found"; return 1; }
  echo "  File $file is valid"
  return 0
}
safe_operation "$WORKSPACE/guard.txt"
safe_operation "$WORKSPACE/does_not_exist.txt" || true
echo ""

# [WATCH OUT]: cmd1 && cmd2 || cmd3 is NOT a ternary — cmd3 fires if cmd2 fails too
echo "--- The fake ternary danger ---"
result=""
true && result="success" || result="failure"    # OK here because assignment never fails
echo "  true  path: $result"
false && result="success" || result="failure"
echo "  false path: $result"
echo ""

_pillar "PRECISION: set -e interaction with short-circuit"

# [WHAT]: false || true does NOT trigger set -e
# [WHY]:  When a command is the left side of ||, its failure is EXPECTED —
#         the shell sees the overall || expression, not the individual false
echo "--- false || true does not trigger set -e ---"
(
  set -e
  false || true
  echo "  Still running — set -e not triggered by false || true"
)
echo ""

# [WHAT]: set +e — locally disabling errexit for a command that's allowed to fail
echo "--- set +e: allow a specific command to fail ---"
(
  set -e
  set +e
  failing_cmd_that_is_ok() { return 1; }
  failing_cmd_that_is_ok
  RESULT=$?
  set -e
  echo "  Command failed with code $RESULT — handled gracefully"
)
echo ""

# ==============================================================================
# MODULE 4 — CONTROL FLOW: LOOPS
# ==============================================================================

_section "SEGMENT 4.1 — for LOOPS"

_pillar "BASIC: List and glob iteration"

echo "--- List-based for ---"
for env in dev staging production; do
  echo "  Deploying to: $env"
done
echo ""

echo "--- Positional parameter iteration ---"
process_args() {
  for arg in "$@"; do
    echo "  Processing arg: [$arg]"
  done
}
process_args "file one.txt" "file-two.txt" "file three.txt"
echo ""

echo "--- Glob iteration over .log files ---"
touch "$WORKSPACE/app.log" "$WORKSPACE/error.log" "$WORKSPACE/access.log"
for logfile in "$WORKSPACE"/*.log; do
  echo "  Log: ${logfile##*/}"
done
echo ""

_pillar "POWER: Brace expansion and C-style loop"

echo "--- Brace expansion sequence ---"
for i in {1..5}; do
  printf "  Server%02d\n" "$i"
done
echo ""

echo "--- Brace expansion with step ---"
for port in {8080..8090..2}; do
  echo "  Port: $port"
done
echo ""

echo "--- C-style arithmetic for loop ---"
for (( i=0; i<5; i++ )); do
  printf "  index %d\n" "$i"
done
echo ""

echo "--- C-style countdown ---"
for (( i=5; i>=0; i-- )); do
  printf "  T-%d\n" "$i"
done
echo ""

_pillar "DEVOPS CONTEXT: nullglob prevents ghost iterations"

echo "--- Without nullglob (default) ---"
shopt -u nullglob
for f in "$WORKSPACE"/*.nonexistent; do
  echo "  Iterating over literal: $f  ← THIS IS A BUG (file doesn't exist)"
done

echo ""
echo "--- With nullglob ---"
shopt -s nullglob
for f in "$WORKSPACE"/*.nonexistent; do
  echo "  This never prints — loop body skipped"
done
echo "  Loop completed safely (0 iterations)"
shopt -u nullglob
echo ""

# ==============================================================================

_section "SEGMENT 4.2 — while AND until LOOPS"

_pillar "BASIC: while read — the canonical file-processing pattern"

# [WHAT]: Create a mock log file with varied content
cat > "$WORKSPACE/server.log" << 'LOGFILE'
2024-01-15 INFO  Server started on port 8080
2024-01-15 WARN  Memory at 78%
2024-01-15 ERROR Disk write failed: /var/data
  leading whitespace line
line without trailing newline
LOGFILE

# [WHAT]: while read — reads file line-by-line in the CURRENT shell (no subshell)
# [WATCH OUT]: pipe | while read runs in a SUBSHELL — variable changes are LOST
echo "--- IFS='' read -r (preserves whitespace and backslashes) ---"
line_count=0
while IFS='' read -r line; do
  (( line_count += 1 ))
  echo "  Line $line_count: [$line]"
done < "$WORKSPACE/server.log"
echo "  Total lines processed: $line_count"
echo ""

_pillar "POWER: Process substitution fixes the subshell variable-loss problem"

# [WHAT]: < <(cmd) runs cmd in a subshell BUT the while loop stays in current shell
# [WHY]:  With cmd | while, the loop body's variable assignments vanish after done
echo "--- Process substitution: variable survives the loop ---"
error_count=0
while IFS='' read -r line; do
  if [[ "$line" == *"ERROR"* ]]; then
    (( error_count += 1 ))
  fi
done < <(cat "$WORKSPACE/server.log")
echo "  Errors found (via process substitution): $error_count"
echo ""

# [WHAT]: Demonstrate the SUBSHELL TRAP (variables lost after pipe | while)
echo "--- Pipe trap: variables lost after done ---"
lost_count=0
cat "$WORKSPACE/server.log" | while IFS='' read -r line; do
  if [[ "$line" == *"ERROR"* ]]; then
    (( lost_count += 1 ))
  fi
done
echo "  Errors after pipe|while: $lost_count  ← 0 because subshell lost it!"
echo ""

_pillar "PRECISION: read flag variants"

echo "--- read -t (timeout) ---"
# [FLAG MEANING] -t N = timeout after N seconds — returns non-zero on timeout
if read -t 0 < /dev/null; then
  echo "  stdin has data"
else
  echo "  stdin empty (or timed out)"
fi
echo ""

echo "--- read -n (character limit) ---"
# [FLAG MEANING] -n N = read exactly N characters
printf "ABCDEF" | (read -n 3 chunk; echo "  First 3 chars: $chunk")
echo ""

echo "--- read -a (split into array) ---"
# [FLAG MEANING] -a arr = read words into an indexed array
IFS=',' read -ra csv_fields <<< "alice,42,engineer"
echo "  Field 0: ${csv_fields[0]}, Field 1: ${csv_fields[1]}, Field 2: ${csv_fields[2]}"
echo ""

echo "--- read -d '' (read entire file into var) ---"
# [FLAG MEANING] -d '' = null delimiter — reads until EOF
read -r -d '' entire_file < "$WORKSPACE/server.log" || true
echo "  File read into var. Length: ${#entire_file}"
echo ""

_pillar "POWER: until and infinite loop patterns"

# [WHAT]: until — inverse of while; loops UNTIL condition becomes TRUE
echo "--- until loop (countdown) ---"
countdown=3
until (( countdown == 0 )); do
  echo "  T-$countdown..."
  countdown=$(( countdown - 1 ))
done
echo "  Launch!"
echo ""

# [WHAT]: while true — the daemon/poller pattern
echo "--- while true with break (simulates a retry loop) ---"
attempts=0
max_attempts=3
while true; do
  (( attempts += 1 ))
  echo "  Attempt $attempts of $max_attempts..."
  if (( attempts >= max_attempts )); then
    echo "  Max attempts reached — breaking"
    break
  fi
done
echo ""

# [WHAT]: Last-line without trailing newline guard
echo "--- Last-line-without-newline guard ---"
printf "line1\nline2\nlast line no newline" > "$WORKSPACE/no_newline.txt"
while IFS='' read -r line || [[ -n "$line" ]]; do
  echo "  Got: [$line]"
done < "$WORKSPACE/no_newline.txt"
echo ""

# ==============================================================================

_section "SEGMENT 4.3 — LOOP CONTROL"

_pillar "BASIC: break and continue"

echo "--- break: exit innermost loop ---"
for i in {1..10}; do
  if (( i == 5 )); then
    echo "  Breaking at i=$i"
    break
  fi
  echo "  i=$i"
done
echo ""

echo "--- continue: skip current iteration ---"
for i in {1..6}; do
  if (( i % 2 == 0 )); then
    continue  # skip even numbers
  fi
  echo "  Odd: $i"
done
echo ""

_pillar "POWER: Nested loop control with N"

echo "--- break 2: exit BOTH inner and outer loop ---"
for outer in A B C; do
  for inner in 1 2 3; do
    if [[ "$outer" == "B" && "$inner" == "2" ]]; then
      echo "  Breaking 2 levels at outer=$outer inner=$inner"
      break 2
    fi
    echo "  outer=$outer inner=$inner"
  done
done
echo ""

echo "--- continue 2: skip to next outer iteration ---"
for server in web01 web02 web03; do
  for check in cpu mem disk; do
    if [[ "$server" == "web02" && "$check" == "disk" ]]; then
      echo "  Skipping disk check on $server — continue 2"
      continue 2
    fi
    echo "  Checking $check on $server"
  done
done
echo ""

_pillar "DEVOPS CONTEXT: Flag variable for post-loop signaling"

echo "--- Flag variable pattern (alternative to break) ---"
# [WHAT]: Use a flag to communicate loop result to code AFTER the loop
_found=0
servers=("web01" "db01" "cache01" "web02")

for server in "${servers[@]}"; do
  if [[ "$server" == "db01" ]]; then
    _found=1
    echo "  Found db01!"
    break
  fi
done

if (( _found )); then
  echo "  Post-loop: database server located — proceeding with migration"
else
  echo "  Post-loop: no database server — aborting"
fi
echo ""

# ==============================================================================

_section "SEGMENT 4.4 — select LOOP (MENU GENERATION)"

_pillar "BASIC: Interactive menu (non-interactive demo)"

# [WHAT]: select generates a numbered menu and reads user choice
# [WHY]:  Perfect for interactive deployment scripts that need human confirmation
# [WATCH OUT]: select blocks waiting for input — NOT suitable for fully automated pipelines

echo "--- select menu (simulated via stdin) ---"

# [COMMAND MEANING] PS3 = Prompt String 3 — the prompt shown by select
PS3="Choose deployment target: "

# Feed simulated input to avoid blocking in non-interactive context
{
  echo "2"  # simulated user input: choose item 2
} | (
  select env in "development" "staging" "production" "abort"; do
    # [COMMAND MEANING] REPLY = the raw string the user typed in a select loop
    echo "  REPLY (raw input): $REPLY"
    case "$env" in
      development|staging|production)
        echo "  Deploying to: $env"
        break
        ;;
      abort)
        echo "  Deployment cancelled"
        break
        ;;
      *)
        echo "  Invalid choice — try again"
        ;;
    esac
  done
)
echo ""

_pillar "DEVOPS CONTEXT: Guard against empty list"

echo "--- Empty list guard ---"
available_envs=()  # simulate no environments configured

if [[ ${#available_envs[@]} -eq 0 ]]; then
  echo "  Guard triggered: no environments configured — skipping select menu"
else
  # Only reach select if list is non-empty
  PS3="Choose: "
  select env in "${available_envs[@]}"; do
    echo "Selected: $env"; break
  done
fi
echo ""

# ==============================================================================
# MODULE 5 — FUNCTIONS
# ==============================================================================

_section "SEGMENT 5.1 — DEFINING AND CALLING FUNCTIONS"

_pillar "BASIC: Three function definition syntaxes"

# [WHAT]: POSIX form — the only form valid in both bash and sh
posix_style_func() {
  echo "  posix_style_func: called with $# args"
}

# [WHAT]: Bash keyword form — not POSIX, but explicit
function bash_keyword_func {
  echo "  bash_keyword_func: called"
}

# [WHAT]: Combined form — valid Bash, most common in real-world scripts
function combined_form_func() {
  echo "  combined_form_func: called"
}

posix_style_func "arg1" "arg2"
bash_keyword_func
combined_form_func
echo ""

_pillar "POWER: Introspection — discovering functions"

# [COMMAND MEANING] type = Identify what a name resolves to
type posix_style_func
echo ""

# [FLAG MEANING] -f (declare) = print function definition
echo "--- declare -f: full function body ---"
declare -f posix_style_func
echo ""

# [FLAG MEANING] -F (declare) = list function names only
echo "--- declare -F: function inventory (all loaded functions) ---"
declare -F | grep -E "func|greet|deploy|safe|check|handle|shift|process|demonstrate" || true
echo ""

_pillar "PRECISION: source, export -f, and unset -f"

# [WHAT]: Source a file to make its functions available in this shell
cat > "$WORKSPACE/network_lib.sh" << 'NETLIB'
check_connectivity() {
  local host="${1:-8.8.8.8}"
  echo "  [check_connectivity] Testing: $host"
  return 0
}
NETLIB

. "$WORKSPACE/network_lib.sh"
check_connectivity "db.internal"
echo ""

# [FLAG MEANING] export -f = export a function to child process environments
# [WATCH OUT]: This is the ShellShock (CVE-2014-6271) vector. NEVER export
#              functions whose names or bodies contain user-controlled input.
export -f check_connectivity
bash -c 'check_connectivity "exported-to-child"'
echo ""

# [FLAG MEANING] unset -f = remove a function definition
unset -f check_connectivity
type check_connectivity 2>&1 || echo "check_connectivity successfully removed"
echo ""

# ==============================================================================

_section "SEGMENT 5.2 — ARGUMENTS & RETURN VALUES"

_pillar "BASIC: Positional params inside functions"

# [WHAT]: Demonstrate that $1/$2/$@ inside a function are LOCAL to that function
script_level_arg="I belong to the script"

inspect_function_scope() {
  echo "  Inside function:"
  echo "    \$# (arg count): $#"
  echo "    \$1 (first arg): ${1:-[none]}"
  echo "    \$2 (second arg): ${2:-[none]}"
  echo "    \"\$@\" expansion:"
  for arg in "$@"; do
    echo "      [$arg]"
  done
  echo "    script_level_arg (global): $script_level_arg"
}

inspect_function_scope "function_arg_1" "arg with spaces" "third"
echo ""

_pillar "POWER: Return values — exit codes vs stdout capture"

# [WHAT]: Return by EXIT CODE — signals success/failure
is_valid_port() {
  local -i port="${1:-0}"
  if (( port >= 1 && port <= 65535 )); then
    return 0  # success
  else
    return 1  # failure
  fi
}

# [WHAT]: Use function exit code in an if condition — the idiomatic pattern
if is_valid_port 8080; then
  echo "Port 8080 is valid"
fi
if ! is_valid_port 99999; then
  echo "Port 99999 is invalid"
fi

# [WHAT]: Capture exit code into $? immediately after the call
is_valid_port 443
echo "Port 443 check exit code: $?"
echo ""

# [WHAT]: Return by STDOUT — the mechanism for returning string data
generate_deploy_id() {
  local -r env="$1"
  local -r ts="$(date +%Y%m%d_%H%M%S)"
  # [COMMAND MEANING] printf = Print Formatted — portable alternative to echo
  # [WHY]: printf handles values starting with '-' safely; echo does not
  printf "%s_deploy_%s" "$env" "$ts"
}

# [WHAT]: Capture stdout into a variable via $()
deploy_id=$(generate_deploy_id "production")
echo "Generated deploy ID: $deploy_id"
echo ""

_pillar "PRECISION: local scoping and preventing namespace pollution"

# [WHAT]: Without local, the inner function would clobber the outer variable
GLOBAL_STATUS="OK"

outer_function() {
  # [WHAT]: local prevents status from overwriting GLOBAL_STATUS
  local status="processing"
  echo "  outer: status=$status, GLOBAL_STATUS=$GLOBAL_STATUS"
  inner_function
  echo "  outer after inner: status=$status"  # unchanged — local protected it
}

inner_function() {
  local status="inner_done"
  GLOBAL_STATUS="modified_by_inner"  # deliberate global mutation
  echo "  inner: status=$status"
}

outer_function
echo "After outer_function: GLOBAL_STATUS=$GLOBAL_STATUS"
echo ""

# [WHAT]: return in a sourced file — exits the file, returns to calling script
cat > "$WORKSPACE/guarded_lib.sh" << 'GUARDLIB'
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  : # being sourced — continue loading
else
  echo "This library must be sourced, not executed directly"
  exit 1
fi

validated_lib_function() {
  local -r input="$1"
  local -r result="${input^^}"
  printf "%s\n" "$result"
}
GUARDLIB

source "$WORKSPACE/guarded_lib.sh"
output=$(validated_lib_function "hello from library")
echo "Library function output: $output"
echo ""

_pillar "DEVOPS CONTEXT: FUNCNAME call stack for error tracing"

# [WHAT]: FUNCNAME[] is an array forming the current call stack
# [WHY]:  In production error handlers, FUNCNAME tells you the exact call chain
#         that led to the failure — no stack trace tool needed

error_aware_function() {
  local msg="$1"
  echo "  ERROR at function: ${FUNCNAME[0]} (called from: ${FUNCNAME[1]:-main})"
  echo "  Line: $LINENO | Script: ${BASH_SOURCE[0]##*/}"
  echo "  Message: $msg"
}

wrapper_function() {
  error_aware_function "simulated failure"
}

wrapper_function
echo ""




# ==============================================================================
# MODULE 5 (CONTINUED) — FUNCTIONS
# ==============================================================================

# ── Named Exit Code Constants (Bash-9.3.J) ────────────────────────────────────
# [COMMAND MEANING] readonly = Declare a variable that cannot be reassigned
# [WHAT]: Define meaningful exit codes as named constants — no magic numbers
# [WHY]:  Callers (CI runners, orchestrators, other scripts) can branch on
#         specific codes; integers alone are unreadable in a postmortem.
readonly E_VALIDATION_FAIL=3

_section "SEGMENT 5.3 — VARIABLE SCOPING WITH local"

# ── Mock Data ─────────────────────────────────────────────────────────────────
GLOBAL_COUNTER=0       # will be used to show the global footgun

_pillar "BASIC: local vs global — the footgun demo (Bash-5.3.H)"

# [COMMAND MEANING] local = Scope a variable to the current function frame only
# [WHAT]: Show what happens when you OMIT local — the function silently
#         clobbers the caller's variable. The most common hidden bug in
#         intermediate Bash scripts.
# [WHY]:  Without local, every function shares the global namespace —
#         identical to having no function scope at all.
footgun_function() {
  GLOBAL_COUNTER=999          # no local — this OVERWRITES the global
  echo "  Inside footgun_function: GLOBAL_COUNTER=$GLOBAL_COUNTER"
}

echo "Before footgun_function: GLOBAL_COUNTER=$GLOBAL_COUNTER"
footgun_function
echo "After footgun_function:  GLOBAL_COUNTER=$GLOBAL_COUNTER  <-- clobbered!"
echo ""

_pillar "POWER: local -i, -r, -a, -A (Bash-5.3.C/D/E/F)"

# [WHAT]: Reset the global so later demos are clean
GLOBAL_COUNTER=0

demonstrate_local_flags() {
  # [FLAG MEANING] -i = integer — non-numeric assignment coerces to 0
  local -i int_only=42
  int_only="not_a_number"
  echo "  local -i after bad assign: $int_only"   # prints 0 — coerced

  # [FLAG MEANING] -r = readonly — cannot be reassigned within the function
  local -r IMMUTABLE="locked"
  # Attempting: IMMUTABLE="changed"  <-- would throw: readonly variable
  echo "  local -r value: $IMMUTABLE"

  # [FLAG MEANING] -a = indexed array scoped to this function
  local -a scoped_arr=("alpha" "beta" "gamma")
  echo "  local -a element 0: ${scoped_arr[0]}"

  # [FLAG MEANING] -A = associative array scoped to this function
  local -A scoped_map
  scoped_map[env]="production"
  scoped_map[region]="us-east-1"
  echo "  local -A env: ${scoped_map[env]}"
}

demonstrate_local_flags
echo ""

_pillar "PRECISION: Subshell copy — mutations don't propagate (Bash-5.3.G)"

# [WHAT]: A local variable inside a subshell ( ) is a COPY of the parent's
#         frame — changes inside the subshell evaporate on exit.
# [WHY]:  This is the #1 cause of "why doesn't my variable update inside
#         a pipe or while loop?" — subshells are forks, not references.
# [WATCH OUT]: Any variable assigned inside ( ) or |  is lost after the
#              closing ) or done. Use process substitution < <(cmd) instead.
shared_val="original"
(
  shared_val="mutated_inside_subshell"
  echo "  Inside subshell:  shared_val=$shared_val"
)
echo "  Outside subshell: shared_val=$shared_val  <-- unchanged"
echo ""

# ==============================================================================

_section "SEGMENT 5.4 — ADVANCED FUNCTION PATTERNS"

_pillar "BASIC: Recursive function — factorial (Bash-5.4.A/B)"

# [WHAT]: Classic recursion demonstrating base-case + self-call pattern
# [WHY]:  Bash supports recursion up to ~1000 frames (stack depth limit).
#         Know the limit — never recurse over a large file tree in pure Bash.
factorial() {
  # [FLAG MEANING] -i (local) = integer-typed local variable
  local -i n="${1:-0}"
  if (( n <= 1 )); then
    echo 1
    return 0
  fi
  local -i sub
  sub=$(factorial $(( n - 1 )))
  echo $(( n * sub ))
}

echo "  5! = $(factorial 5)"
echo "  7! = $(factorial 7)"
echo ""

_pillar "POWER: Callbacks — functions as first-class arguments (Bash-5.4.C)"

# [WHAT]: Pass a function NAME as a string argument; invoke it inside the
#         receiving function using "$callback" — enables map/filter patterns.
# [WHY]:  Allows building generic utility functions (apply_to_each, retry,
#         with_lock) that accept behaviour as a parameter.
apply_to_each() {
  local callback="$1"
  shift                              # remove callback from $@
  for item in "$@"; do
    "$callback" "$item"              # invoke the passed function name
  done
}

announce_item() {
  echo "  → item: $1"
}

apply_to_each announce_item "server-01" "server-02" "server-03"
echo ""

_pillar "PRECISION: Namerefs — pass-by-reference for arrays (Bash-5.4.D/E/F)"

# [WHAT]: declare -n creates a transparent alias (nameref) to whatever
#         variable name was passed as the argument — the correct way to
#         pass and mutate arrays across function boundaries.
# [WHY]:  Passing "${arr[@]}" flattens the array into positional params —
#         the array structure is GONE. Namerefs preserve it entirely.

# [COMMAND MEANING] declare = Declare variables and their attributes
# [FLAG MEANING] -n = nameref — this variable is an alias for another variable
populate_service_list() {
  declare -n _target_array="$1"     # _target_array is now an alias for caller's var
  _target_array=("nginx" "postgres" "redis" "prometheus")
}

declare -a services
populate_service_list services       # pass the NAME, not the value
echo "  Services populated via nameref:"
for svc in "${services[@]}"; do
  echo "    - $svc"
done
echo ""

_pillar "DEVOPS CONTEXT: FUNCNAME call stack + export -f / ShellShock (Bash-5.4.G/H/I/J/K/L)"

# [WHAT]: FUNCNAME is an array forming the call stack — [0]=current, [1]=caller
# [WHY]:  In ERR trap handlers, iterating ${FUNCNAME[@]} prints a full stack
#         trace to stderr — a crucial diagnostic in production failures.
stack_trace_demo() {
  echo "  FUNCNAME call stack:"
  local i
  for (( i=0; i<${#FUNCNAME[@]}; i++ )); do
    echo "    [$i] ${FUNCNAME[$i]:-main}"
  done
}

middle_function() { stack_trace_demo; }
outer_caller()    { middle_function;  }
outer_caller
echo ""

# [WHAT]: export -f serialises a function into the environment for children
# [WATCH OUT]: ShellShock (CVE-2014-6271) exploited trailing code after
#              exported function bodies. NEVER export functions that were
#              constructed from or named after user-controlled input.
__internal_health_check() {
  echo "  [__internal_health_check] private API — not for external callers"
}
# [FLAG MEANING] export -f = export a function definition to child bash processes
export -f __internal_health_check
bash -c '__internal_health_check'   # child process can now call it
# Immediately unexport to limit the exposure window
export -fn __internal_health_check 2>/dev/null || unset -f __internal_health_check
echo ""

# ==============================================================================
# MODULE 6 — ARRAYS AND ASSOCIATIVE ARRAYS
# ==============================================================================

_section "SEGMENT 6.1 — INDEXED ARRAYS"

_pillar "BASIC: Declaration, access, length, indices (Bash-6.1.A–G)"

# [COMMAND MEANING] declare = Declare variables and set attributes
# [FLAG MEANING] -a = indexed array
declare -a services_arr=("nginx" "postgres" "redis" "vault" "prometheus")

echo "  Full array ([@]):       ${services_arr[@]}"
echo "  Element [0]:            ${services_arr[0]}"
echo "  Element [2]:            ${services_arr[2]}"
echo "  Array length (#[@]):    ${#services_arr[@]}"
echo "  All indices (![@]):     ${!services_arr[@]}"
echo ""

_pillar "POWER: Append, unset, sparse arrays, slicing (Bash-6.1.H–M)"

# [WHAT]: Append an element — does NOT overwrite existing elements
services_arr+=("grafana")
echo "  After append: ${services_arr[@]}"
echo "  New length:   ${#services_arr[@]}"

# [WHAT]: unset a middle element — creates a SPARSE array; indices don't shift
# [WATCH OUT]: After unset, iterating with a C-style for((i=0;i<N;i++)) loop
#              is BROKEN because index 2 no longer exists. Always use ${!arr[@]}.
unset 'services_arr[2]'
echo ""
echo "  After unset [2] — indices: ${!services_arr[@]}"
echo "  Iterating SPARSE array safely (via \${!arr[@]}):"
for idx in "${!services_arr[@]}"; do
  echo "    [$idx] = ${services_arr[$idx]}"
done
echo ""

# [WHAT]: Array slice — return a range of elements
echo "  Slice [1..3] (\${arr[@]:1:3}): ${services_arr[@]:1:3}"
echo "  Slice from [3] onward:         ${services_arr[@]:3}"
echo ""

_pillar "PRECISION: Safe iteration, copy, broken vs correct pass (Bash-6.2.A–E)"

# [WHAT]: Canonical safe array iteration — each element is a separate quoted word
declare -a replica_arr
replica_arr=("${services_arr[@]}")   # shallow copy — independent clone
echo "  Copied array: ${replica_arr[@]}"
echo ""

# [WHAT]: In-place element substitution without a loop (Bash-6.2.H)
declare -a tags=("env:dev" "env:staging" "env:prod")
tags=("${tags[@]/env:/tier:}")      # replace prefix in ALL elements
echo "  After in-place substitution: ${tags[@]}"
echo ""

_pillar "DEVOPS CONTEXT: IFS join — CSV from array (Bash-6.2.F/G)"

# [WHAT]: Join array elements with a custom delimiter by temporarily setting IFS
# [WHY]:  Useful for building comma-separated lists for API calls, Slack messages,
#         or CSV generation without spawning a subprocess.
# [WATCH OUT]: Always restore IFS immediately — a polluted IFS breaks subsequent
#              word-splitting everywhere in the script.
declare -a healthy_nodes=("node-01" "node-02" "node-03")
old_IFS="$IFS"
IFS=','
csv_output="${healthy_nodes[*]}"
IFS="$old_IFS"                       # restore immediately
echo "  CSV join output: $csv_output"
echo ""

# ==============================================================================

_section "SEGMENT 6.2 — mapfile / readarray"

# ── Mock Data ─────────────────────────────────────────────────────────────────
printf '%s\n' "10.0.0.1" "10.0.0.2" "10.0.0.3" "10.0.0.4" \
  > "$WORKSPACE/ip_list.txt"

printf '%s\n' "hostname,ip,status" \
              "web-01,10.0.0.1,healthy" \
              "web-02,10.0.0.2,degraded" \
              "db-01,10.0.0.3,healthy" \
  > "$WORKSPACE/inventory.csv"

_pillar "BASIC: mapfile -t — canonical file-to-array load (Bash-6.3.A/C/D)"

# [COMMAND MEANING] mapfile = Map File lines into an array variable
# [FLAG MEANING] -t = strip trailing newlines from each element — ALWAYS use this
# [WHAT]: Read every line of a file into an indexed array; one line per element
# [WHY]:  mapfile is VASTLY faster than a while-read loop for large files and
#         avoids the subshell variable-loss trap of command | while read.
declare -a ip_list
mapfile -t ip_list < "$WORKSPACE/ip_list.txt"
echo "  Loaded ${#ip_list[@]} IPs from file:"
for ip in "${ip_list[@]}"; do
  echo "    $ip"
done
echo ""

_pillar "POWER: mapfile -s (skip), -n (limit), -O (offset) (Bash-6.3.G/H/I)"

# [FLAG MEANING] -s N = skip first N lines (skip CSV header row)
# [FLAG MEANING] -n N = read at most N lines (memory-safe for huge files)
declare -a csv_data
mapfile -t -s 1 -n 2 csv_data < "$WORKSPACE/inventory.csv"
echo "  CSV rows (header skipped, max 2):"
for row in "${csv_data[@]}"; do
  echo "    $row"
done
echo ""

# [FLAG MEANING] -O N = start populating at index N (append to existing array)
declare -a combined_arr=("existing-entry")
mapfile -t -O 1 combined_arr < "$WORKSPACE/ip_list.txt"
echo "  Array with -O append: ${combined_arr[@]}"
echo ""

_pillar "PRECISION: mapfile without -t — the silent newline bug (Bash-6.3.J)"

# [WHAT]: Demonstrate why omitting -t is a bug — each element contains a
#         trailing \n, so string comparisons silently fail.
declare -a buggy_arr
mapfile buggy_arr < "$WORKSPACE/ip_list.txt"    # no -t
echo "  Without -t — does element == '10.0.0.1'?"
[[ "${buggy_arr[0]}" == "10.0.0.1" ]] \
  && echo "    MATCH" \
  || echo "    NO MATCH — trailing newline contamination!"
echo ""

_pillar "DEVOPS CONTEXT: mapfile from process substitution (Bash-6.3.E)"

# [WHAT]: Load filtered command output into an array WITHOUT a subshell
# [WHY]:  cmd | while read — runs the loop in a subshell; variables set inside
#         are lost. < <(cmd) runs the loop in the CURRENT shell — variables survive.
declare -a healthy_ips
mapfile -t healthy_ips < <(grep -v "degraded" "$WORKSPACE/inventory.csv" | cut -d, -f2)
echo "  Healthy IPs loaded via process substitution: ${healthy_ips[@]}"
echo ""

# ==============================================================================

_section "SEGMENT 6.3 — ASSOCIATIVE ARRAYS (HASH MAPS)"

_pillar "BASIC: declare -A, assign, access, keys, values (Bash-6.4.A–F)"

# [FLAG MEANING] -A = associative (string-keyed) array — MANDATORY declaration
# [WATCH OUT]: Omitting declare -A causes Bash to treat it as an indexed array —
#              string keys get silently coerced to 0, corrupting all your data.
declare -A service_ports
service_ports[nginx]=80
service_ports[postgres]=5432
service_ports[redis]=6379
service_ports[vault]=8200

echo "  All keys:   ${!service_ports[@]}"
echo "  All values: ${service_ports[@]}"
echo "  nginx port: ${service_ports[nginx]}"
echo ""

_pillar "POWER: Key existence test, delete, bulk init (Bash-6.4.B/C/G/H)"

# [WHAT]: Bulk initialise an associative array in a single compound assignment
declare -A env_config=([APP_ENV]="production" [LOG_LEVEL]="warn" [REPLICAS]="3")

# [FLAG MEANING] -v (inside [[ ]]) = test if a variable (or key) is set
# [WHAT]: Test key existence — the CORRECT form; do NOT use -n because an
#         empty-string value is a valid entry that -n would incorrectly reject.
if [[ -v env_config[APP_ENV] ]]; then
  echo "  APP_ENV is set: ${env_config[APP_ENV]}"
fi

if [[ ! -v env_config[MISSING_KEY] ]]; then
  echo "  MISSING_KEY is not set — correctly detected"
fi

# [WHAT]: Delete a specific key
unset 'env_config[REPLICAS]'
echo "  After unset REPLICAS — keys: ${!env_config[@]}"
echo ""

_pillar "PRECISION: Canonical iteration + export/subshell limitations (Bash-6.4.I/J/K)"

declare -A region_map=([us-east-1]="Virginia" [eu-west-1]="Ireland" [ap-southeast-1]="Singapore")

echo "  Iterating associative array:"
for key in "${!region_map[@]}"; do
  printf "    %-15s → %s\n" "$key" "${region_map[$key]}"
done
echo ""

# [WATCH OUT]: Associative arrays CANNOT be exported. Trying to export them
#              silently does nothing — the child process sees an empty env.
# [WHAT ELSE]: The workaround is to serialise to JSON (via jq) or write to a
#              temp file and source it in the child.
echo "  Demonstrating export limitation:"
export -A region_map 2>/dev/null || true   # silently fails — not an error
bash -c 'echo "  Child sees region_map: ${region_map[us-east-1]:-[EMPTY — not exported]}"'
echo ""

# ==============================================================================
# MODULE 7 — INPUT / OUTPUT AND REDIRECTION
# ==============================================================================

_section "SEGMENT 7.1 — STANDARD FILE DESCRIPTORS"

_pillar "BASIC: FD 0/1/2 — inspect open descriptors (Bash-7.1.A–E)"

# [WHAT]: List all open file descriptors for THIS shell process
# [WHY]:  FD leaks (unclosed file handles) exhaust ulimit -n in long-running
#         scripts. Always verify your FD count in scripts that open custom FDs.
echo "  Open FDs for PID $$:"
ls -la /proc/$$/fd 2>/dev/null | head -10
echo ""

# ==============================================================================

_section "SEGMENT 7.2 — REDIRECTION OPERATORS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
echo "initial log entry" > "$WORKSPACE/app.log"

_pillar "BASIC: >, >>, <, 2>, &> (Bash-7.2.A–F)"

# [WHAT]: Truncate-write to file (Bash-7.2.A)
echo "new content" > "$WORKSPACE/truncate_demo.txt"
cat "$WORKSPACE/truncate_demo.txt"

# [WHAT]: Append to file (Bash-7.2.B)
echo "appended line" >> "$WORKSPACE/app.log"
echo "  app.log after append:"
cat "$WORKSPACE/app.log"
echo ""

# [WHAT]: Read from file via stdin redirect (Bash-7.2.C)
echo "  Line count from file via stdin redirect:"
wc -l < "$WORKSPACE/app.log"
echo ""

# [WHAT]: Redirect stderr to a separate file (Bash-7.2.D)
ls /nonexistent_path 2> "$WORKSPACE/errors.log" || true
echo "  Captured stderr:"
cat "$WORKSPACE/errors.log"
echo ""

_pillar "POWER: 2>&1 ordering trap — the most misunderstood redirect (Bash-7.2.G–J)"

# [WHAT]: Demonstrate WHY ordering of 2>&1 relative to > matters
# [HOW]:  >file 2>&1  — (1) point FD1 at file  (2) point FD2 at FD1 (= file)  ✓
#         2>&1 >file  — (1) point FD2 at FD1 (= terminal)  (2) point FD1 at file  ✗

# CORRECT: both streams go to file
ls /nonexistent /dev/null > "$WORKSPACE/both_correct.log" 2>&1 || true
echo "  CORRECT (>file 2>&1) — both streams in file:"
cat "$WORKSPACE/both_correct.log"
echo ""

# Demonstrate discarding all output — the canonical "run quietly" idiom (Bash-7.2.L)
ls /nonexistent /dev/null > /dev/null 2>&1 || true
echo "  Silent run completed (no output — both FDs → /dev/null)"
echo ""

_pillar "PRECISION: 1>&2 — writing errors from functions (Bash-7.2.H)"

# [WHAT]: Send a message to stderr from inside a function without contaminating
#         stdout — critical when the function's stdout is captured via $()
# [WHY]:  If you echo errors to stdout inside a function that a caller captures
#         via result=$(my_func), the error message gets assigned to the variable.
log_error() {
  echo "[ERROR] $*" 1>&2
}

captured=$(log_error "this goes to stderr, not the variable" || true; echo "clean_data")
echo "  Captured stdout: '$captured'"
echo "  (Error message went to stderr — not captured)"
echo ""

_pillar "DEVOPS CONTEXT: /dev/stdin, /dev/stdout, /dev/stderr explicit paths (Bash-7.2.M–O)"

# [WHAT]: tee to /dev/stderr — write pipeline data to stderr for live
#         monitoring while keeping stdout clean for downstream processing
echo "pipeline data" | tee /dev/stderr > "$WORKSPACE/tee_out.txt" 2>/dev/null || true
echo ""

# ==============================================================================

_section "SEGMENT 7.3 — FILE DESCRIPTOR MANAGEMENT WITH exec"

_pillar "BASIC: exec N>file, exec N<file, exec N>&- (Bash-7.3.A–D)"

# [WHAT]: Open a persistent write FD for a log file — no re-opening on each write
exec 3> "$WORKSPACE/persistent.log"
echo "  first log entry"  >&3
echo "  second log entry" >&3
echo "  third log entry"  >&3
# [FLAG MEANING] N>&- = close file descriptor N
exec 3>&-
echo "  Persistent log contents (written via FD 3):"
cat "$WORKSPACE/persistent.log"
echo ""

_pillar "POWER: Save/restore stdout — exec 3>&1 pattern (Bash-7.3.E/F)"

# [WHAT]: Temporarily redirect all script output to a log file, then restore
# [WHY]:  Production scripts often need to log ALL output (including nested
#         function output) to a file for a block of work, then restore terminal.
exec 3>&1                              # save current stdout to FD 3
exec 1> "$WORKSPACE/redirected.log"   # redirect stdout to log file
  echo "  This goes to the log file"
  echo "  So does this"
exec 1>&3                             # restore stdout from FD 3
exec 3>&-                             # close FD 3 — prevent FD leak
echo "  Stdout restored — reading log:"
cat "$WORKSPACE/redirected.log"
echo ""

_pillar "PRECISION: read -u N — reading from a persistent FD (Bash-7.3.I)"

# [WHAT]: Open a file on FD 4 for reading; use read -u to consume it line-by-line
# [WHY]:  More efficient than re-opening the file on each loop iteration in
#         high-frequency polling scripts.
exec 4< "$WORKSPACE/ip_list.txt"
echo "  Reading IPs via FD 4 with read -u:"
while read -r -u 4 line; do
  echo "    → $line"
done
exec 4>&-    # close the FD — prevent the leak (Bash-7.3.H)
echo ""

# ==============================================================================

_section "SEGMENT 7.4 — HERE-DOCUMENTS AND HERE-STRINGS"

_pillar "BASIC: Quoted vs unquoted delimiter (Bash-7.4.A/B)"

APP_VERSION="2.4.1"
DEPLOY_ENV="production"

# [WHAT]: QUOTED delimiter ('EOF') — zero expansion; literal content only
# [WHY]:  Use when generating scripts or code that contains $ signs — prevents
#         accidental interpolation of variable names in the output.
cat << 'EOF'
  QUOTED heredoc: $APP_VERSION and $DEPLOY_ENV are NOT expanded here.
  This is safe for generating raw scripts or config with $ in them.
EOF
echo ""

# [WHAT]: UNQUOTED delimiter (EOF) — full variable and command expansion
cat << EOF
  UNQUOTED heredoc: APP_VERSION=$APP_VERSION, ENV=$DEPLOY_ENV
  Timestamp: $(date +%Y-%m-%d)
EOF
echo ""

_pillar "POWER: Indented heredoc (<<-) and here-string (<<<) (Bash-7.4.C/D)"

# [FLAG MEANING] <<- = strip leading TAB characters (not spaces) from each line
# [WHAT]: Write readable indented heredocs without injecting whitespace
# [WATCH OUT]: Only TABs are stripped — indent with actual tab characters,
#              not spaces, or the closing delimiter won't be recognised.
generate_nginx_stub() {
	cat <<- NGINX_CONF
	server {
	    listen 80;
	    server_name example.com;
	    location / { proxy_pass http://127.0.0.1:3000; }
	}
	NGINX_CONF
}
echo "  Nginx stub (tabs stripped by <<-):"
generate_nginx_stub
echo ""

# [WHAT]: Here-string — feed a single variable as stdin without echo | cmd subshell
# [WHY]:  echo "$var" | read spawns a subshell — the read's result is lost.
#         <<< "$var" feeds stdin in the CURRENT shell with zero forking.
version_string="v2.4.1-release"
read -r major_part _ <<< "${version_string//-/ }"    # split on hyphen
echo "  Here-string extracted major: $major_part"
echo ""

_pillar "PRECISION: heredoc for config generation (Bash-7.4.F/G)"

# [WHAT]: Generate a config file from variables using a heredoc
cat > "$WORKSPACE/app.conf" << EOF
# Generated $(date +%Y-%m-%d) — DO NOT EDIT MANUALLY
app_version=$APP_VERSION
environment=$DEPLOY_ENV
log_level=warn
workers=4
EOF
echo "  Generated config:"
cat "$WORKSPACE/app.conf"
echo ""

# [WHAT]: Feed a heredoc to a function's stdin (Bash-7.4.G)
count_config_lines() {
  local count=0
  while IFS= read -r _line; do
    (( count++ )) || true
  done
  echo "  Line count received on stdin: $count"
}

count_config_lines << 'CONFIGBLOCK'
line one
line two
line three
CONFIGBLOCK
echo ""

# ==============================================================================

_section "SEGMENT 7.5 — PIPES AND PROCESS SUBSTITUTION"

_pillar "BASIC: Pipeline exit status — the hidden failure (Bash-7.5.A/B)"

# [WHAT]: Without pipefail, the pipeline's exit code = the LAST command only.
#         A failing first command is invisible.
# [WATCH OUT]: This is already handled by set -o pipefail at the top of the
#              parent script — this demo intentionally turns it off temporarily
#              to show the unsafe behaviour before restoring it.
set +o pipefail   # temporarily disable to demo the bug
false | true      # false fails, but pipeline "succeeds"
echo "  Pipeline exit (no pipefail): $?   <-- 0 even though false failed"
set -o pipefail   # restore immediately
echo ""

_pillar "POWER: \$PIPESTATUS — inspect every exit code in a pipeline (Bash-7.5.C)"

# [WHAT]: PIPESTATUS is an array populated after any pipeline — one code per stage
# [WHY]:  Even with pipefail, PIPESTATUS lets you know WHICH stage failed and
#         report it precisely in your error handler.
# [WATCH OUT]: PIPESTATUS is overwritten by the VERY NEXT command — capture it immediately.
set +e    # allow the failing grep to not kill the script for this demo
grep "NOTPRESENT" "$WORKSPACE/app.log" | sort | uniq
pipe_statuses=("${PIPESTATUS[@]}")     # capture immediately
set -e
echo "  PIPESTATUS: grep=${pipe_statuses[0]}  sort=${pipe_statuses[1]}  uniq=${pipe_statuses[2]}"
echo "  (grep=1 means no match — sort and uniq still ran and succeeded)"
echo ""

_pillar "PRECISION: Process substitution — diff two commands (Bash-7.5.E/F/G)"

# [WHAT]: <(cmd) runs cmd in a subshell and presents output as a readable
#         virtual file (e.g. /dev/fd/63) — no temp files needed.
# [WHY]:  diff requires file paths, not stdin. Without process substitution
#         you'd need two mktemp files, two writes, one diff, and two rm calls.
printf '%s\n' "nginx" "postgres" "redis" > "$WORKSPACE/expected_services.txt"
printf '%s\n' "nginx" "mysql"    "redis" > "$WORKSPACE/actual_services.txt"

echo "  diff: expected vs actual services:"
diff <(sort "$WORKSPACE/expected_services.txt") \
     <(sort "$WORKSPACE/actual_services.txt") || true
echo ""

_pillar "DEVOPS CONTEXT: while read < <(cmd) — current-shell loop (Bash-7.5.H)"

# [WHAT]: The correct pattern that keeps variables AFTER the loop
# [WHY]:  cmd | while read — the loop runs in a subshell (right side of |).
#         Variables set inside are GONE when done is reached.
#         < <(cmd) runs the loop body in the CURRENT shell — variables persist.
declare -a degraded_hosts=()
while IFS=',' read -r hostname ip status; do
  if [[ "$status" == "degraded" ]]; then
    degraded_hosts+=("$hostname")
  fi
done < <(grep -v "^hostname" "$WORKSPACE/inventory.csv")

echo "  Degraded hosts (variable survived loop): ${degraded_hosts[@]}"
echo ""

# ==============================================================================

_section "SEGMENT 7.6 — tee, xargs, AND PIPELINE TOOLS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/logs"
for i in {1..5}; do
  printf "timestamp=%s level=INFO msg=request_%d\n" "$(date +%s)" "$i" \
    >> "$WORKSPACE/logs/app-$(printf '%02d' $i).log"
done

touch "$WORKSPACE/logs/app space name.log"  # deliberate filename with spaces

_pillar "BASIC: tee — T-junction logging (Bash-7.6.A/B/C)"

# [COMMAND MEANING] tee = T-shape pipe junction — write to BOTH stdout and file
# [WHAT]: Pipe data downstream AND capture it to a file simultaneously
# [WHY]:  Without tee, you must choose: pipe to next command OR redirect to file.
#         tee lets you do both — critical for audit logging in CI pipelines.
echo "deployment_started host=web-01 ts=$(date +%s)" \
  | tee "$WORKSPACE/deploy_audit.log" \
  | grep --color=never "deployment"

# [FLAG MEANING] -a = append mode — don't truncate the file
echo "deployment_step=2 status=ok" | tee -a "$WORKSPACE/deploy_audit.log" > /dev/null
echo "  Audit log:"
cat "$WORKSPACE/deploy_audit.log"
echo ""

# [WHAT]: tee to /dev/stderr for live monitoring (Bash-7.6.D)
echo "health_check host=db-01 result=pass" \
  | tee /dev/stderr 2>/dev/null \
  > "$WORKSPACE/health.log" || true
echo ""

_pillar "POWER: xargs — bridge output to arguments (Bash-7.6.E–K)"

# [COMMAND MEANING] xargs = Execute Arguments — build and run commands from stdin
# [WHAT]: Pass each log filename as an argument to wc -l
# [WHY]:  find outputs filenames to stdout, but wc -l takes arguments, not stdin.
#         xargs bridges the gap without a while read loop.
echo "  Line counts for all log files:"
find "$WORKSPACE/logs" -name "*.log" -print0 \
  | xargs -0 wc -l

echo ""

# [FLAG MEANING] -I{} = replacement string — put the input item at a specific position
# [WHAT]: Rename each log file by appending .bak — {} is substituted with each filename
find "$WORKSPACE/logs" -name "*.log" -print0 \
  | xargs -0 -I{} cp {} {}.bak
echo "  Backup files created:"
ls "$WORKSPACE/logs/"*.bak 2>/dev/null | head -4
echo ""

# [FLAG MEANING] -n N = at most N args per invocation
echo "  xargs -n 2 (pairs):"
printf '%s\n' "a" "b" "c" "d" | xargs -n 2 echo "pair:"
echo ""

# [FLAG MEANING] -P N = run N instances in parallel
echo "  xargs -P 3 parallel echo:"
printf '%s\n' "svc-1" "svc-2" "svc-3" "svc-4" | xargs -P 3 -I{} echo "  checking: {}"
echo ""

_pillar "PRECISION: find -print0 | xargs -0 — NUL-safe pipeline (Bash-7.6.I/L)"

# [WHAT]: The canonical safe file-processing pipeline — handles filenames with
#         spaces, newlines, and glob metacharacters correctly
# [WHY]:  Plain find | xargs splits on whitespace — "app space name.log" would
#         be treated as TWO files ("app" and "space" and "name.log").
echo "  Safe NUL-delimited processing (handles 'app space name.log'):"
find "$WORKSPACE/logs" -name "*.log" -not -name "*.bak" -print0 \
  | xargs -0 -I{} bash -c 'echo "  processing: {}"'
echo ""

# ==============================================================================
# MODULE 8 — STRING PROCESSING AND TEXT MANIPULATION
# ==============================================================================

_section "SEGMENT 8.1 — grep — PATTERN SEARCH"

# ── Mock Data ─────────────────────────────────────────────────────────────────
cat > "$WORKSPACE/access.log" << 'ACCESSLOG'
2024-01-15 10:00:01 GET /api/users 200 45ms 10.0.0.1
2024-01-15 10:00:02 POST /api/login 200 12ms 10.0.0.2
2024-01-15 10:00:03 GET /api/orders 500 230ms 10.0.0.1
2024-01-15 10:00:04 DELETE /api/session 404 8ms 10.0.0.3
2024-01-15 10:00:05 GET /api/users 200 41ms 10.0.0.1
2024-01-15 10:00:06 GET /health 200 2ms 10.0.0.4
2024-01-15 10:00:07 POST /api/orders 500 310ms 10.0.0.2
ACCESSLOG

_pillar "BASIC: BRE, ERE, -i, -v, -c (Bash-8.1.A–G)"

# [COMMAND MEANING] grep = Global Regular Expression Print
# [WHAT]: Find all 500 errors — basic BRE match (Bash-8.1.B)
echo "  5xx errors:"
grep " 500 " "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -E = Extended Regular Expression — no backslash-escaping for + ? | ()
echo "  POST or DELETE methods (ERE):"
grep -E "POST|DELETE" "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -i = case-insensitive match
echo "  Case-insensitive 'health':"
grep -i "HEALTH" "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -v = invert — lines that do NOT match
echo "  Non-health, non-login requests:"
grep -v -E "/health|/login" "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -c = count matching lines (not the lines themselves)
echo "  Count of 200 responses:"
grep -c " 200 " "$WORKSPACE/access.log"
echo ""

_pillar "POWER: -n, -o, -r, -l, -A, -B (Bash-8.1.H–P)"

# [FLAG MEANING] -n = prefix matching lines with line numbers
echo "  Error lines with line numbers:"
grep -n " 500 " "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -o = print ONLY the matched portion (not the full line)
echo "  Extracted IPs only (-o with ERE):"
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$WORKSPACE/access.log" | sort -u
echo ""

# [FLAG MEANING] -A N = print N lines of context AFTER the match
echo "  500 errors with 1 line of context after (-A 1):"
grep -A 1 " 500 " "$WORKSPACE/access.log"
echo ""

# [FLAG MEANING] -q = quiet — only set exit code; no output
# [WHAT]: Use grep as a boolean condition — the fastest check
# [WHY]:  In set -e scripts, bare grep returns 1 on no-match and KILLS the script.
#         Always use -q inside if, or append || true for "absence is ok" cases.
if grep -q " 500 " "$WORKSPACE/access.log"; then
  echo "  ALERT: 500 errors detected in access log"
fi
echo ""

# [FLAG MEANING] -P = Perl-Compatible Regex (PCRE) — lookahead/lookbehind, \d, \s
echo "  PCRE: extract slow requests >200ms:"
grep -oP "\d+(?=ms)" "$WORKSPACE/access.log" \
  | awk '$1 > 200 {print "  slow: "$1"ms"}' || true
echo ""

_pillar "PRECISION: -F (fixed string) and set -e interaction (Bash-8.1.M/Q)"

# [FLAG MEANING] -F = fixed string — NO regex interpretation; faster, avoids metachar surprises
echo "  Fixed string search for IP (no regex metachar risk):"
grep -F "10.0.0.1" "$WORKSPACE/access.log" | wc -l | tr -d ' '
echo " requests from 10.0.0.1"
echo ""

# [WATCH OUT]: grep returns exit code 1 when NO lines match — this KILLS the
#              script under set -e. Always guard with || true or wrap in if.
set +e
grep "NOTPRESENT" "$WORKSPACE/access.log"
grep_exit=$?
set -e
echo "  grep exit code for no match: $grep_exit  (1 = not found, not an error)"
echo ""

# ==============================================================================

_section "SEGMENT 8.2 — sed — STREAM EDITOR"

# ── Mock Data ─────────────────────────────────────────────────────────────────
cat > "$WORKSPACE/config_template.conf" << 'CONF'
# Application Config
app_name=myapp
app_env=__ENV__
app_port=__PORT__
database_url=postgres://user:password@__DB_HOST__:5432/mydb
log_level=debug
# End of config
CONF

_pillar "BASIC: s/pattern/replacement/ and delete (Bash-8.2.A–H)"

# [COMMAND MEANING] sed = Stream EDitor
# [WHAT]: Perform variable substitution in a config template (first occurrence)
sed 's/__ENV__/production/' "$WORKSPACE/config_template.conf"
echo ""

# [FLAG MEANING] g = global — replace ALL occurrences on each line
echo "  Replace ALL occurrences of 'app' with 'svc' globally:"
sed 's/app/svc/g' "$WORKSPACE/config_template.conf" | grep "svc"
echo ""

# [FLAG MEANING] /regex/d = delete lines matching the regex
echo "  Config with comment lines removed:"
sed '/^#/d' "$WORKSPACE/config_template.conf"
echo ""

_pillar "POWER: -n with /p, in-place editing, alternate delimiter (Bash-8.2.B/I/J/N)"

# [FLAG MEANING] -n = silent mode; only print lines that match the p command
echo "  Print only lines containing '__' (template tokens):"
sed -n '/__/p' "$WORKSPACE/config_template.conf"
echo ""

# [WHAT]: Chain multiple substitutions to fully render a template
echo "  Fully rendered config (multiple -e substitutions):"
sed \
  -e 's/__ENV__/staging/' \
  -e 's/__PORT__/3000/' \
  -e 's/__DB_HOST__/db.internal/' \
  "$WORKSPACE/config_template.conf"
echo ""

# [WHAT]: In-place edit — GNU sed -i modifies the file directly
# [WATCH OUT]: Always test without -i first. macOS requires sed -i '' (BSD form).
cp "$WORKSPACE/config_template.conf" "$WORKSPACE/config_inplace.conf"
sed -i 's/log_level=debug/log_level=warn/' "$WORKSPACE/config_inplace.conf"
echo "  In-place result (log_level changed):"
grep "log_level" "$WORKSPACE/config_inplace.conf"
echo ""

# [WHAT]: Alternate delimiter — use | when pattern contains forward slashes
echo "  URL substitution using | delimiter (avoids escaping /):"
sed 's|postgres://user:password@|postgres://svc:secret@|' \
  "$WORKSPACE/config_template.conf" | grep database_url
echo ""

_pillar "PRECISION: Range addresses and last-line $ (Bash-8.2.O/P)"

# [WHAT]: Delete a specific range of lines (lines 1-2, i.e. the comment block)
echo "  Lines 1-2 deleted (range address 1,2d):"
sed '1,2d' "$WORKSPACE/config_template.conf"
echo ""

# [WHAT]: $ = the LAST line in sed — add a footer to the config
echo "  Adding generated_at footer to last line:"
sed "\$ a generated_at=$(date +%Y-%m-%d)" "$WORKSPACE/config_template.conf" | tail -3
echo ""

_pillar "DEVOPS CONTEXT: hold space swap for block reordering (Bash-8.2.M)"

# [WHAT]: Use hold space to swap two lines (a classic sed pattern)
# [WHY]:  Hold space persists across lines — the only way to do multi-line
#         transformations in POSIX sed without writing to temp files.
printf 'FOOTER_LINE\nHEADER_LINE\n' | sed -n '1{h;d}; 2{p;g;p}'
echo "  (FOOTER and HEADER lines swapped using hold space)"
echo ""

# ==============================================================================

_section "SEGMENT 8.3 — awk — PATTERN SCANNING AND PROCESSING"

# ── Mock Data ─────────────────────────────────────────────────────────────────
cat > "$WORKSPACE/metrics.csv" << 'METRICS'
service,requests,errors,latency_ms
nginx,14520,12,45
postgres,8831,0,12
redis,31200,3,2
vault,420,0,88
prometheus,1100,0,55
METRICS

_pillar "BASIC: BEGIN, /pattern/, END, field access (Bash-8.3.A–D/M)"

# [COMMAND MEANING] awk = Aho, Weinberger, Kernighan (the authors' initials)
# [WHAT]: Print the service name and latency for all rows where latency > 40ms
# [HOW]:  BEGIN sets the FS; /pattern/ selects rows; $1=service, $4=latency
awk -F',' '
  NR > 1 && $4 > 40 {
    printf "  %-12s latency: %sms\n", $1, $4
  }
' "$WORKSPACE/metrics.csv"
echo ""

# [WHAT]: Full BEGIN/END report with aggregation
awk -F',' '
  BEGIN {
    print "  === Request Summary ==="
    total_req = 0
    total_err = 0
  }
  NR > 1 {
    total_req += $2
    total_err += $3
  }
  END {
    printf "  Total requests: %d\n", total_req
    printf "  Total errors:   %d\n", total_err
    printf "  Error rate:     %.2f%%\n", (total_err / total_req) * 100
  }
' "$WORKSPACE/metrics.csv"
echo ""

_pillar "POWER: FS, OFS, NR, NF, FNR, awk arrays, printf (Bash-8.3.E–Q)"

# [FLAG MEANING] -F = set Field Separator on the command line
# [FLAG MEANING] -v = pass a shell variable into awk's namespace safely
threshold=30
awk -F',' -v thresh="$threshold" '
  NR > 1 && $4 < thresh {
    printf "  FAST: %-12s %sms (under %sms threshold)\n", $1, $4, thresh
  }
' "$WORKSPACE/metrics.csv"
echo ""

# [WHAT]: awk associative array — count requests per first octet of service name
awk -F',' '
  NR > 1 {
    first_char = substr($1, 1, 1)
    counts[first_char] += $2
  }
  END {
    print "  Request totals grouped by first char:"
    for (c in counts) printf "  [%s]: %d\n", c, counts[c]
  }
' "$WORKSPACE/metrics.csv"
echo ""

# [WHAT]: $NF = last field; $(NF-1) = second-to-last — column-count agnostic
echo "  Last field of each data row (latency_ms):"
awk -F',' 'NR > 1 { print "  " $1 ": last field=" $NF }' "$WORKSPACE/metrics.csv"
echo ""

# [WHAT]: FNR==1 — detect first line of each file in multi-file processing
echo "  FNR/NR multi-file header detection:"
awk -F',' 'FNR==1 { print "  File header: " FILENAME " → " $0 }' \
  "$WORKSPACE/metrics.csv" "$WORKSPACE/inventory.csv"
echo ""

_pillar "PRECISION: delete arr[key], RS paragraph mode (Bash-8.3.G/P)"

# [WHAT]: delete arr[key] — remove a stale entry from awk array in END block
awk -F',' '
  NR > 1 { svc[$1] = $2 }
  END {
    delete svc["vault"]   # decommissioned service — remove from summary
    print "  Active services (vault excluded):"
    for (s in svc) printf "  %-12s %d req\n", s, svc[s]
  }
' "$WORKSPACE/metrics.csv"
echo ""

# ==============================================================================

_section "SEGMENT 8.4 — cut, tr, sort, uniq, paste, join"

# ── Mock Data ─────────────────────────────────────────────────────────────────
cat > "$WORKSPACE/passwd_sample.txt" << 'PASSWD'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
jesse:x:1001:1001:Jesse,,,:/home/jesse:/bin/bash
PASSWD

cat > "$WORKSPACE/versions.txt" << 'VERS'
app-2.10.0
app-2.9.1
app-2.1.0
app-10.0.0
VERS

_pillar "BASIC: cut -d -f, cut -c, tr (Bash-8.4.A–H)"

# [COMMAND MEANING] cut = Cut out selected portions of each line
# [FLAG MEANING] -d: = field delimiter is colon
# [FLAG MEANING] -f1 = extract field 1
echo "  Usernames from /etc/passwd (cut -d: -f1):"
cut -d: -f1 "$WORKSPACE/passwd_sample.txt"
echo ""

# [FLAG MEANING] -f1,3 = extract fields 1 AND 3
echo "  Username and UID (fields 1 and 3):"
cut -d: -f1,3 "$WORKSPACE/passwd_sample.txt"
echo ""

# [FLAG MEANING] -c = character positions
echo "  First 6 characters of each line:"
cut -c1-6 "$WORKSPACE/passwd_sample.txt"
echo ""

# [COMMAND MEANING] tr = TRanslate characters
# [FLAG MEANING] 'a-z' 'A-Z' = translate lowercase to uppercase
echo "  Uppercase translation:"
echo "hello world" | tr 'a-z' 'A-Z'

# [FLAG MEANING] -d = delete matching characters
# [WHAT]: Strip carriage returns from Windows files — the universal CRLF fix
printf "windows\r\nline\r\n" | tr -d '\r' | cat -A | head -2

# [FLAG MEANING] -s = squeeze repeated characters
echo "  Squeeze spaces (tr -s):"
echo "too   many    spaces" | tr -s ' '
echo ""

_pillar "POWER: sort flags, LC_ALL=C, uniq -c -d -u (Bash-8.4.I–U)"

# [COMMAND MEANING] sort = Sort lines of text input
# [FLAG MEANING] -n = numeric sort (10 after 9, not before)
# [FLAG MEANING] -r = reverse (descending)
echo "  Numeric descending sort:"
printf '%s\n' 5 12 3 100 7 | sort -n -r
echo ""

# [FLAG MEANING] -V = version sort (natural number ordering in strings)
echo "  Version sort (-V) vs lexicographic:"
echo "  Lex order:"
sort "$WORKSPACE/versions.txt"
echo "  Version order:"
sort -V "$WORKSPACE/versions.txt"
echo ""

# [FLAG MEANING] LC_ALL=C = force byte-order sort — deterministic, locale-independent
echo "  Deterministic LC_ALL=C sort:"
LC_ALL=C sort "$WORKSPACE/passwd_sample.txt" | cut -d: -f1
echo ""

# [FLAG MEANING] -k2,2 = sort by key field 2 only (colon-delimited)
echo "  Sort passwd by UID (field 3):"
sort -t: -k3,3 -n "$WORKSPACE/passwd_sample.txt" | cut -d: -f1,3
echo ""

# [COMMAND MEANING] uniq = Report or filter adjacent duplicate lines
# [FLAG MEANING] -c = count occurrences
# [FLAG MEANING] -d = print only lines that appear MORE than once
# [FLAG MEANING] -u = print only lines that appear EXACTLY once
echo "  Top IPs by request frequency (uniq -c + sort):"
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$WORKSPACE/access.log" \
  | LC_ALL=C sort | uniq -c | sort -rn
echo ""

_pillar "PRECISION: paste -d, paste -s, join (Bash-8.4.V–Y)"

# [COMMAND MEANING] paste = Paste lines from files side by side
printf '%s\n' "web-01" "web-02" "web-03" > "$WORKSPACE/hostnames.txt"
printf '%s\n' "10.0.0.1" "10.0.0.2" "10.0.0.3" > "$WORKSPACE/ips_only.txt"

# [FLAG MEANING] -d, = use comma as the output delimiter
echo "  paste -d, (CSV from two column files):"
paste -d, "$WORKSPACE/hostnames.txt" "$WORKSPACE/ips_only.txt"
echo ""

# [FLAG MEANING] -s = serial mode — all lines onto ONE line
echo "  paste -s (column → row):"
paste -s -d, "$WORKSPACE/hostnames.txt"
echo ""

# [COMMAND MEANING] join = Join lines from two sorted files on a common field
printf '%s\n' "nginx 80" "postgres 5432" "redis 6379" \
  | LC_ALL=C sort > "$WORKSPACE/svc_ports.txt"
printf '%s\n' "nginx healthy" "postgres healthy" "redis degraded" \
  | LC_ALL=C sort > "$WORKSPACE/svc_status.txt"

echo "  join: services with port AND status:"
join "$WORKSPACE/svc_ports.txt" "$WORKSPACE/svc_status.txt"
echo ""

# ==============================================================================

_section "SEGMENT 8.5 — PURE BASH STRING OPERATIONS (NO SUBSHELLS)"

_pillar "BASIC: Global/first replace, case change, length (Bash-8.5.A–E)"

# [WHAT]: All pure Bash parameter expansions — ZERO subprocess cost
deployment_tag="env:dev-env:dev-env:dev"

# [FLAG MEANING] // = global replace all occurrences
echo "  Global replace (//): ${deployment_tag//env:/tier:}"

# [FLAG MEANING] / = replace first occurrence only
echo "  First replace (/):   ${deployment_tag/env:/tier:}"

# [FLAG MEANING] ^^ = uppercase all
hostname_var="web-server-01"
echo "  Uppercase (^^):      ${hostname_var^^}"

# [FLAG MEANING] ,, = lowercase all
SERVICE_LABEL="NGINX-PROXY"
echo "  Lowercase (,,):      ${SERVICE_LABEL,,}"

# [FLAG MEANING] # (with ${#}) = string length
log_entry="2024-01-15 connection refused"
echo "  String length (#):   ${#log_entry} characters"
echo ""

_pillar "POWER: Prefix/suffix stripping for path and extension ops (Bash-8.5.F–I)"

filepath="/var/log/nginx/access.log.2024"

# [FLAG MEANING] ## = strip LONGEST prefix (greedy) — basename equivalent
echo "  Basename (##*/):         ${filepath##*/}"

# [FLAG MEANING] # = strip SHORTEST prefix
echo "  Strip /var/ prefix (#*/): ${filepath#/*/}"

# [FLAG MEANING] % = strip SHORTEST suffix — remove one extension
echo "  Strip .2024 (%.*):       ${filepath%.*}"

# [FLAG MEANING] %% = strip LONGEST suffix (greedy) — everything after first dot
echo "  Strip all extensions (%%.*): ${filepath%%.*}"
echo ""

_pillar "PRECISION: [[ =~ ]] + BASH_REMATCH + subshell cost (Bash-8.5.J–N)"

# [WHAT]: In-shell ERE regex match — no grep subprocess required
# [WHY]:  In a tight loop, calling grep 10,000 times = 10,000 fork/exec pairs.
#         [[ =~ ]] has ZERO subprocess cost — a 50-100x speedup for bulk validation.
validate_sem_ver() {
  local version="$1"
  local semver_pattern='^v([0-9]+)\.([0-9]+)\.([0-9]+)(-[a-z]+)?$'
  if [[ "$version" =~ $semver_pattern ]]; then
    echo "  VALID:   major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]} pre=${BASH_REMATCH[4]:-none}"
  else
    echo "  INVALID: $version"
  fi
}

validate_sem_ver "v2.4.1"
validate_sem_ver "v2.4.1-beta"
validate_sem_ver "2.4.1"       # missing leading v
validate_sem_ver "v2.4"        # missing patch component
echo ""

# [WHAT]: Performance demo — pure Bash vs external command in loop
# [WHY]:  Show that parameter expansion can replace tr/sed for simple transforms
echo "  Performance: pure Bash vs subshell for case conversion (100 iterations):"

time_bash() {
  local i result
  for (( i=0; i<100; i++ )); do
    result="${hostname_var^^}"    # pure Bash — zero forks
  done
  echo "  Pure Bash (100 iter): done"
}

time_subshell() {
  local i result
  for (( i=0; i<100; i++ )); do
    result=$(echo "$hostname_var" | tr 'a-z' 'A-Z')   # 100 subshells!
  done
  echo "  Subshell tr (100 iter): done"
}

time time_bash
time time_subshell
echo ""

# ==============================================================================
# MODULE 9 — ERROR HANDLING AND DEFENSIVE SCRIPTING
# ==============================================================================

_section "SEGMENT 9.1 — set — STRICT MODE FLAGS"

_pillar "BASIC: set -x / set +x surgical tracing (Bash-9.1.D/E)"

# [WHAT]: set -x enables xtrace — every command is printed to stderr before
#         running, prefixed by PS4. Use it surgically around suspect code.
# [WHY]:  Full script xtrace is noisy. Wrapping just the failing block reveals
#         the exact expansion and execution order without drowning in output.

double_trouble() {
  local x="${1:-}" y="${2:-}"
  echo $(( x * 2 )) $(( y * 2 ))   # safe math — both params should be integers
}

set -x    # turn on xtrace
result=$(double_trouble 7 9)
set +x    # turn off immediately — suppress noise from the echo
echo "  xtrace result: $result"
echo ""

_pillar "POWER: set -v, set -E, set -C (Bash-9.1.F/G/H)"

# [FLAG MEANING] set -C = noclobber — prevent > from overwriting existing files
set -C
echo "noclobber test" > "$WORKSPACE/noclobber_demo.txt"
set +e
echo "OVERWRITE ATTEMPT" > "$WORKSPACE/noclobber_demo.txt" 2>&1 || \
  echo "  Noclobber blocked the overwrite — use >| to force"
set -e

# Use >| to force-overwrite when noclobber is active
echo "INTENTIONAL OVERWRITE" >| "$WORKSPACE/noclobber_demo.txt"
echo "  Force-overwrite with >| succeeded: $(cat "$WORKSPACE/noclobber_demo.txt")"
set +C    # restore — noclobber would break our script's temp file writes
echo ""

_pillar "PRECISION: set -e exceptions + empty array guard (Bash-9.1.K/L/M/N)"

# [WHAT]: Commands in if / while / && / || do NOT trigger set -e on failure
# [WHY]:  The shell treats them as INTENTIONAL conditional tests — the programmer
#         is expected to handle the failure via the conditional structure.
if ls /nonexistent_path_xyz &>/dev/null; then
  echo "  path exists"
else
  echo "  set -e did NOT fire here — if condition failure is intentional"
fi
echo ""

# [WHAT]: Empty array guard — the "${arr[@]+"${arr[@]}"}" pattern
# [WHY]:  Under set -u, "${arr[@]}" on an EMPTY array triggers "unbound variable"
#         because an array with no elements is technically unset.
declare -a empty_arr=()
echo "  Empty array guard: ${empty_arr[@]+"${empty_arr[@]}"}"
echo "  (No output above — array was empty, no error raised)"

declare -a populated_arr=("x" "y")
echo "  Populated array guard: ${populated_arr[@]+"${populated_arr[@]}"}"
echo ""

# ==============================================================================

_section "SEGMENT 9.2 — trap — SIGNAL AND EVENT HANDLING"

# ── Setup: build a full production trap framework ─────────────────────────────

_pillar "BASIC: EXIT + ERR traps — the production preamble (Bash-9.2.G/H/K/L)"

# [WHAT]: A production-grade ERR trap that logs the failed line and call stack
# [WHY]:  Without an ERR trap, set -e just kills the script silently. With one,
#         you get: which line failed, which function, the exit code — full context.
__err_handler() {
  local exit_code="$?"
  local line_no="${1:-?}"
  echo "" >&2
  echo "  [ERR TRAP] ════════════════════════════════" >&2
  echo "  Exit code : $exit_code"                       >&2
  echo "  Line      : $line_no"                         >&2
  echo "  Script    : ${BASH_SOURCE[1]:-unknown}"        >&2
  echo "  Call stack:" >&2
  local i
  for (( i=1; i<${#FUNCNAME[@]}; i++ )); do
    echo "    [$i] ${FUNCNAME[$i]:-main} (${BASH_SOURCE[$i]:-?}:${BASH_LINENO[$i-1]:-?})" >&2
  done
  echo "  ════════════════════════════════════════════" >&2
}

# [WHAT]: Register the ERR trap — $LINENO is evaluated AT TRAP TIME (correct)
# [FLAG MEANING] ERR = pseudo-signal fired when any command returns non-zero
trap '__err_handler $LINENO' ERR

# [WHAT]: Override the EXIT trap to also print a completion banner
# [WATCH OUT]: This REPLACES the existing EXIT trap from the parent script.
#              In a real append scenario, we'd chain them. Here we extend it.
trap 'echo ""; echo "  [EXIT TRAP] Script exiting — workspace cleaned by trap."; rm -rf "$WORKSPACE"' EXIT

echo "  ERR + EXIT traps registered."
echo ""

_pillar "POWER: SIGINT, SIGTERM, SIGHUP, SIGQUIT (Bash-9.2.B–E)"

# [WHAT]: Show signal trap registration — these are not triggered in this script
#         (no Ctrl+C or kill is sent), but the pattern is the standard one.
# [WHY]:  In a daemon or long-running script, SIGTERM must be trapped to release
#         locks, flush buffers, and remove PID files before exiting.

graceful_shutdown() {
  echo "" >&2
  echo "  [SIGTERM] Graceful shutdown initiated — flushing state..." >&2
  # In a real daemon: stop accepting work, drain the queue, remove PID file
  exit 0
}

reload_config() {
  echo "  [SIGHUP] Config reload triggered" >&2
  # In a real daemon: re-read .env, update thresholds, don't restart the process
}

trap 'graceful_shutdown'  SIGTERM
trap 'reload_config'      SIGHUP
# [FLAG MEANING] SIGQUIT = Ctrl+\ — trap it to prevent accidental core dumps
trap 'echo "  [SIGQUIT] Ignored — use SIGTERM for graceful stop" >&2' SIGQUIT

echo "  Signal traps registered: SIGTERM, SIGHUP, SIGQUIT"
echo ""

_pillar "PRECISION: trap '' SIG (ignore), trap - SIG (restore), subshell inheritance (Bash-9.2.M/N/O)"

# [WHAT]: Temporarily ignore SIGINT during a critical section
# [WHY]:  In a database write or file rename sequence, Ctrl+C must not interrupt
#         mid-operation or you'll leave the system in a partial state.
trap '' SIGINT    # ignore Ctrl+C
echo "  SIGINT temporarily ignored (critical section start)"
sleep 0.1         # simulate critical work
trap - SIGINT     # restore default disposition
echo "  SIGINT restored to default"
echo ""

# [WHAT]: Demonstrate subshell trap inheritance rules
# [WATCH OUT]: Custom handlers (trap 'fn' SIG) are NOT inherited by subshells.
#              Ignored signals (trap '' SIG) ARE inherited by subshells.
trap '' SIGUSR1   # ignore in parent — child inherits this
(
  # Inside subshell: SIGUSR1 is still ignored (inherited)
  # But our SIGTERM/SIGHUP custom traps are NOT active here
  echo "  Subshell: custom SIGTERM trap NOT active; ignored SIGUSR1 IS inherited"
) &
wait $!
trap - SIGUSR1    # restore
echo ""

_pillar "DEVOPS CONTEXT: two-step termination — SIGTERM then SIGKILL (Bash-9.2.P)"

# [WHAT]: The industry-standard process termination pattern for automation
# [WHY]:  kill -9 (SIGKILL) is uncatchable — the process has NO chance to clean up.
#         Always give SIGTERM first, then escalate to SIGKILL after a timeout.
two_step_terminate() {
  local pid="$1"
  local timeout="${2:-5}"   # seconds to wait for graceful exit

  echo "  Sending SIGTERM to PID $pid..."
  kill -TERM "$pid" 2>/dev/null || { echo "  PID $pid already gone"; return 0; }

  local elapsed=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 1
    (( elapsed++ )) || true
    if (( elapsed >= timeout )); then
      echo "  SIGTERM ignored after ${timeout}s — escalating to SIGKILL"
      kill -KILL "$pid" 2>/dev/null || true
      return 0
    fi
  done
  echo "  Process $pid exited cleanly after ${elapsed}s"
}

# Demo: spawn a sleep process, then terminate it gracefully
sleep 60 &
demo_pid=$!
two_step_terminate "$demo_pid" 2
echo ""

# ==============================================================================

_section "SEGMENT 9.3 — EXIT CODES — THE API OF YOUR SCRIPT"

_pillar "BASIC: exit 0/1/N, return N, reserved codes (Bash-9.3.A–H)"

# [WHAT]: Named exit code constants — the contract this script exports
# (E_VALIDATION_FAIL=3 is already declared at the top of this patch)
echo "  Exit code contract:"
echo "    0  = success"
echo "    1  = generic failure"
echo "    2  = missing dependency"
echo "    3  = validation failure (E_VALIDATION_FAIL)"
echo "    126 = command found but not executable"
echo "    127 = command not found"
echo "    130 = SIGINT (Ctrl+C) — 128+2"
echo "    137 = SIGKILL        — 128+9"
echo "    143 = SIGTERM        — 128+15"
echo ""

_pillar "POWER: \$? capture, exit without arg, return N in functions (Bash-9.3.D/E/L)"

# [WHAT]: $? is overwritten by EVERY subsequent command — capture it immediately
validate_input() {
  local input="$1"
  if [[ -z "$input" ]]; then
    return "$E_VALIDATION_FAIL"   # 3 — validation failure
  fi
  if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    return "$E_VALIDATION_FAIL"
  fi
  return 0
}

test_inputs=("valid-input_123" "" "invalid input!" "another-good-one")
for inp in "${test_inputs[@]}"; do
  set +e
  validate_input "$inp"
  rc=$?    # capture IMMEDIATELY — next command would overwrite $?
  set -e
  case "$rc" in
    0) echo "  PASS [$rc]: '$inp'" ;;
    "$E_VALIDATION_FAIL") echo "  FAIL [$rc — validation]: '${inp:-[empty]}'" ;;
    *) echo "  UNKNOWN [$rc]: '$inp'" ;;
  esac
done
echo ""

_pillar "PRECISION: exit code documentation header (Bash-9.3.K)"

# [WHAT]: Generate a self-documenting exit code summary — as it would appear
#         in the script header comment block of a production script.
cat << 'EXITDOC'
  # EXIT CODE CONTRACT (from script header comment):
  #
  # Code | Constant          | Meaning
  # -----+-------------------+------------------------------------------
  #  0   | —                 | Success — all operations completed
  #  1   | —                 | Generic failure (unexpected error)
  #  2   | E_MISSING_DEP     | Required binary not found in PATH
  #  3   | E_VALIDATION_FAIL | Input failed whitelist validation
  # 126   | —                | Command found but not executable
  # 127   | —                | Command not found in PATH
  # 130   | —                | Interrupted by SIGINT (Ctrl+C)
  # 143   | —                | Terminated by SIGTERM (systemd/k8s)
EXITDOC
echo ""

_pillar "DEVOPS CONTEXT: die() pattern — structured fatal error exit (Bash-9.3 + 9.4 preview)"

# [WHAT]: The 'die' function — the enterprise-standard fatal error handler.
#         Writes to stderr, logs context, exits with a specific code.
# [WHY]:  Scattering 'echo "error" >&2; exit 1' everywhere is unmaintainable.
#         A single die() call gives consistent format, line numbers, and codes.
die() {
  local msg="$1"
  local code="${2:-1}"
  echo "" >&2
  echo "  [FATAL] ${FUNCNAME[1]:-main}(): $msg" >&2
  echo "  [FATAL] Exit code: $code | Line: ${BASH_LINENO[0]}" >&2
  exit "$code"
}

# [WHAT]: Guard clause — validate a precondition at script entry
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    die "Required command '$cmd' not found in PATH" 2
  fi
  echo "  ✓ $cmd found: $(command -v "$cmd")"
}

require_command bash
require_command awk
require_command sed
set +e
require_command nonexistent_tool_xyz 2>/dev/null \
  || echo "  [Expected] die() would have been called for missing tool"
set -e
echo ""



# ==============================================================================
# MODULE 9 (CONTINUED) — ERROR HANDLING AND DEFENSIVE SCRIPTING
# ==============================================================================

# [COMMAND MEANING] readonly = Declare a variable that cannot be reassigned
readonly E_LOCK_HELD=4      # another instance is running
readonly E_DISK_FULL=5      # disk threshold exceeded

_section "SEGMENT 9.4 — STRUCTURED ERROR HANDLING PATTERNS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/app"
echo "v1.0.0" > "$WORKSPACE/app/VERSION"
echo "config_key=original_value" > "$WORKSPACE/app/app.conf"

_pillar "BASIC: err() — canonical timestamped stderr reporter (Bash-9.4.A/B)"

# [COMMAND MEANING] err = Error reporter (user-defined function)
# [WHAT]: Write a timestamped [ERROR] message to stderr — NEVER stdout.
# [WHY]:  Keeping errors on stderr means callers who capture stdout via $()
#         get only clean data; the error message goes to the terminal/log separately.
err() {
  # [FLAG MEANING] $* = all arguments joined as a single string (correct for a message)
  echo "[ERROR] $(date '+%Y-%m-%dT%H:%M:%S'): $*" >&2
}

err "This is a demonstration error — not a real failure"
echo "  (error went to stderr — stdout is clean)"
echo ""

_pillar "POWER: err+exit — fragile && vs correct {} grouping (Bash-9.4.C/D)"

# [WHAT]: Demonstrate WHY err "msg" && exit 1 is a footgun
# [WHY]:  && chains on SUCCESS of the left side. If err() ever returns non-zero
#         (e.g. the write to stderr fails on a full disk), exit 1 is SKIPPED.
#         The {} grouped form guarantees exit always runs.
# [WATCH OUT]: This is a real production bug — always use the grouped form.

safe_exit_demo() {
  local should_fail="${1:-false}"
  if [[ "$should_fail" == "true" ]]; then
    # CORRECT grouped form — exit fires unconditionally
    { err "Grouped form: exit is guaranteed"; return 1; }
  fi
  echo "  safe_exit_demo: completed normally"
}

safe_exit_demo "false"
set +e
safe_exit_demo "true" 2>/dev/null
set -e
echo "  Grouped error form demonstrated (see stderr above)"
echo ""

_pillar "PRECISION: Guard clauses — fail fast at script top (Bash-9.4.G)"

# [WHAT]: Guard clauses validate all preconditions BEFORE any destructive work
# [WHY]:  A script that discovers a missing file halfway through a deployment
#         is infinitely worse than one that fails in the first 5 lines.
#         Guard early; work late.

# [COMMAND MEANING] command = Shell builtin that locates or invokes a command
# [FLAG MEANING] -v = verify — print the path of a command; exit non-zero if absent
guard_required_file() {
  local filepath="$1"
  local label="${2:-file}"
  if [[ ! -f "$filepath" ]]; then
    die "Required $label not found: $filepath" 2
  fi
  echo "  ✓ Guard passed: $label exists at $filepath"
}

guard_required_file "$WORKSPACE/app/VERSION"  "VERSION file"
guard_required_file "$WORKSPACE/app/app.conf" "app config"
echo ""

_pillar "POWER: Rollback pattern — compensation array in EXIT trap (Bash-9.4.H)"

# [WHAT]: Track completed operations in an array; the EXIT trap walks it in
#         REVERSE and undoes each one — the compensation transaction pattern.
# [WHY]:  A half-applied deployment is worse than no deployment at all.
#         This pattern guarantees you always leave the system in a known state.

declare -a ROLLBACK_STACK=()

push_rollback() {
  # [FLAG MEANING] += (array) = append to the array without overwriting
  ROLLBACK_STACK+=("$1")
  echo "  [rollback] registered: $1"
}

execute_rollback() {
  if (( ${#ROLLBACK_STACK[@]} == 0 )); then
    echo "  [rollback] nothing to undo"
    return 0
  fi
  echo "  [rollback] executing ${#ROLLBACK_STACK[@]} compensation steps (LIFO)..."
  local i
  for (( i=${#ROLLBACK_STACK[@]}-1; i>=0; i-- )); do
    echo "  [rollback] undoing: ${ROLLBACK_STACK[$i]}"
    eval "${ROLLBACK_STACK[$i]}" 2>/dev/null || true
  done
  ROLLBACK_STACK=()
}

# Simulate a two-step deployment with rollback
cp "$WORKSPACE/app/app.conf" "$WORKSPACE/app/app.conf.bak"
push_rollback "mv '$WORKSPACE/app/app.conf.bak' '$WORKSPACE/app/app.conf'"

echo "new_config=deployed_value" >> "$WORKSPACE/app/app.conf"
push_rollback "sed -i '/new_config/d' '$WORKSPACE/app/app.conf'"

echo "  Deployed config:"
cat "$WORKSPACE/app/app.conf"
echo ""

# Simulate a failure mid-deployment — trigger rollback
echo "  Simulating deployment failure — initiating rollback..."
execute_rollback

echo "  Config after rollback:"
cat "$WORKSPACE/app/app.conf"
echo ""

_pillar "DEVOPS CONTEXT: Mutex lock — mkdir atomic vs flock kernel (Bash-9.4.I/J/K/L)"

# ── mkdir-based lock — atomic on most Linux filesystems ──────────────────────
LOCK_DIR="$WORKSPACE/myscript.lock"

# [COMMAND MEANING] mkdir = Make Directory
# [WHAT]: mkdir is atomic — it either creates the directory or fails if it exists.
#         This makes it a race-condition-safe mutex primitive.
# [WHY]:  Two processes running simultaneously will race to mkdir; only ONE wins.
#         The loser sees exit code 1 and can abort or wait.

# Register cleanup so a crash doesn't leave a stale lock
# [WATCH OUT]: This trap REPLACES any earlier EXIT trap — in production you'd
#              chain them. Here we extend the existing cleanup to also remove the lock.
trap 'rm -rf "$WORKSPACE" "$LOCK_DIR" 2>/dev/null || true' EXIT

acquire_mkdir_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "  [lock] acquired: $LOCK_DIR"
    return 0
  else
    echo "  [lock] HELD — another instance is running (exit $E_LOCK_HELD)"
    return "$E_LOCK_HELD"
  fi
}

release_mkdir_lock() {
  rm -rf "$LOCK_DIR"
  echo "  [lock] released"
}

acquire_mkdir_lock
echo "  Critical section: doing exclusive work..."
sleep 0.1

# Attempt a second acquisition while first is held — must fail
set +e
acquire_mkdir_lock
second_rc=$?
set -e
echo "  Second acquire exit code: $second_rc (expected: $E_LOCK_HELD)"

release_mkdir_lock
echo ""

# ── flock-based lock — kernel-managed, survives crashes ──────────────────────
FLOCK_FILE="$WORKSPACE/script.flock"
touch "$FLOCK_FILE"

# [COMMAND MEANING] flock = File Lock — advisory kernel-level locking
# [FLAG MEANING] -x = exclusive lock — only one holder at a time
# [FLAG MEANING] -n = non-blocking — return immediately if lock is held
# [FLAG MEANING] -s = shared lock — multiple readers allowed simultaneously

echo "  flock -x (exclusive) — run command under lock:"
# [HOW]: flock opens FLOCK_FILE, acquires exclusive lock, runs echo, then releases
flock -x "$FLOCK_FILE" echo "  [flock] exclusive section executed safely"

echo "  flock -n (non-blocking) — detect held lock:"
# Hold the lock in a background subshell for 1 second
(flock -x "$FLOCK_FILE"; sleep 1) &
LOCK_BG=$!
sleep 0.1   # give the subshell time to acquire

set +e
flock -n "$FLOCK_FILE" echo "  [flock] this should NOT print"
flock_rc=$?
set -e
echo "  flock -n exit code while lock held: $flock_rc  (expected: 1)"
wait "$LOCK_BG" 2>/dev/null || true

echo "  flock -s (shared) — two readers simultaneously:"
flock -s "$FLOCK_FILE" echo "  [flock] reader 1 acquired shared lock" &
flock -s "$FLOCK_FILE" echo "  [flock] reader 2 acquired shared lock" &
wait
echo ""

# ==============================================================================

_section "SEGMENT 9.5 — TEMPORARY FILES AND SECURE CLEANUP"

_pillar "BASIC: mktemp file and directory (Bash-9.5.A/B/C)"

# [WHAT]: Create a secure temp file — kernel randomness, not predictable $$
# [WHY]:  /tmp/script.$$ is guessable; an attacker can pre-create a symlink
#         pointing at /etc/passwd — your script then overwrites it.

# [COMMAND MEANING] mktemp = Make Temporary (file or directory using kernel randomness)
SECURE_TMPFILE=$(mktemp)
echo "  Secure temp file: $SECURE_TMPFILE"

# [FLAG MEANING] -d = directory — create a temp directory, not a file
SECURE_TMPDIR=$(mktemp -d)
echo "  Secure temp dir:  $SECURE_TMPDIR"
echo ""

_pillar "POWER: EXIT trap cleanup + TMPDIR respect (Bash-9.5.D/E)"

# [WHAT]: Register cleanup of ALL temp resources in a single EXIT trap
# [WHY]:  The EXIT trap fires on normal exit, set -e kills, AND signal kills —
#         it is the ONLY reliable cleanup mechanism.
# [WATCH OUT]: In this script the trap was already set above; in a real fresh
#              script you would consolidate all cleanup into one EXIT trap at the top.
trap 'rm -rf "$WORKSPACE" "$LOCK_DIR" "$SECURE_TMPFILE" "$SECURE_TMPDIR" 2>/dev/null || true' EXIT

echo "  TMPDIR env variable: ${TMPDIR:-/tmp  (default — not set in environment)}"
echo "  mktemp respects TMPDIR so scripts work correctly inside containers"
echo "  that mount a restricted /tmp substitute (e.g. Docker tmpfs volumes)"
echo ""

_pillar "PRECISION: GNU vs BSD mktemp templates (Bash-9.5.F/G)"

# [WHAT]: GNU mktemp template — Xs at the END, passed as the path argument
GNU_STYLE=$(mktemp "$WORKSPACE/myapp.XXXXXX")
echo "  GNU template result: $GNU_STYLE"

# [WHAT]: BSD/macOS uses -t prefix + auto-appended random suffix — different API
# [WATCH OUT]: Running the BSD form on GNU coreutils fails; running GNU form on
#              macOS also fails. The portable wrapper below handles both.
portable_mktemp() {
  local prefix="${1:-tmp}"
  # Detect GNU vs BSD by trying the GNU form first
  mktemp "${TMPDIR:-/tmp}/${prefix}.XXXXXX" 2>/dev/null \
    || mktemp -t "$prefix"
}

PORTABLE_TMP=$(portable_mktemp "deploy")
echo "  Portable mktemp result: $PORTABLE_TMP"
echo ""

_pillar "DEVOPS CONTEXT: Insecure $$ pattern vs mktemp (Bash-9.5.H/I)"

# [WHAT]: Demonstrate WHY the $$ pattern is a security hole
# [HOW]:  $$ is the process PID — visible in 'ps', predictable, reused after reboot.
#         A malicious process can pre-create /tmp/script.<known-PID> as a symlink
#         to /etc/crontab BEFORE your script runs, then your script writes to it.

INSECURE_NAME="/tmp/demo_insecure.$$"
SECURE_NAME=$(mktemp)

echo "  INSECURE name: $INSECURE_NAME"
echo "    → PID $$ is visible in 'ps aux' — an attacker who sees it can win the race"
echo ""
echo "  SECURE name:   $SECURE_NAME"
echo "    → $(wc -c <<< "$SECURE_NAME" | tr -d ' ') chars of kernel randomness — race is computationally infeasible"
echo ""

# Atomic write demo: write to temp, then rename into place
echo "deployment_id=$(date +%s)" > "$SECURE_NAME"
# [COMMAND MEANING] mv = Move — also performs atomic rename on same filesystem
mv "$SECURE_NAME" "$WORKSPACE/app/deployment.state"
echo "  Atomic write complete: $(cat "$WORKSPACE/app/deployment.state")"
echo ""

# ==============================================================================
# MODULE 10 — FILE SYSTEM OPERATIONS AND PATH HANDLING
# ==============================================================================

_section "SEGMENT 10.1 — PATH CONSTRUCTION AND MANIPULATION"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/project/src/lib"
touch    "$WORKSPACE/project/src/lib/utils.sh"
ln -sf   "$WORKSPACE/project/src" "$WORKSPACE/project/src_link"

_pillar "BASIC: dirname, basename, pure Bash equivalents (Bash-10.1.A/B/C/D)"

sample_path="$WORKSPACE/project/src/lib/utils.sh"

# [COMMAND MEANING] dirname = Directory Name — extract directory component of a path
echo "  dirname result:          $(dirname "$sample_path")"

# [COMMAND MEANING] basename = Base Name — extract filename component of a path
echo "  basename result:         $(basename "$sample_path")"

# [WHAT]: Pure Bash equivalents — identical output, ZERO subshell forks
# [WHY]:  In a loop processing 10,000 paths, dirname/basename spawn 10,000
#         subprocesses each. The parameter expansion form costs nothing.
echo "  Pure Bash dirname (%/*): ${sample_path%/*}"
echo "  Pure Bash basename (##*/): ${sample_path##*/}"
echo ""

# [WHAT]: Strip just the extension — pure Bash
filename="${sample_path##*/}"
echo "  Extension stripped (%.*): ${filename%.*}"
echo "  Extension only (##*.):    ${filename##*.}"
echo ""

_pillar "POWER: realpath, readlink -f, symlink resolution (Bash-10.1.E/F)"

# [COMMAND MEANING] realpath = Real Path — resolve ALL symlinks to canonical absolute path
echo "  realpath of symlink:"
realpath "$WORKSPACE/project/src_link/lib/utils.sh"

# [COMMAND MEANING] readlink = Read Link — read the target of a symlink
# [FLAG MEANING] -f = follow — resolve the full chain; equivalent to realpath
echo "  readlink -f of symlink:"
readlink -f "$WORKSPACE/project/src_link"
echo ""

_pillar "PRECISION: SCRIPT_DIR — canonical self-location pattern (Bash-10.1.G/H/I/J)"

# [WHAT]: The production-grade way to find the directory the script lives in.
#         Works correctly whether the script is executed directly OR sourced.
# [WHY]:  $0 is unreliable when sourced — it points to the sourcing shell's name.
#         BASH_SOURCE[0] ALWAYS refers to the actual file being parsed.
# [WATCH OUT]: The && pwd is load-bearing — if cd fails, pwd would return the
#              wrong directory and silently continue. The && ensures we exit instead.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "  SCRIPT_DIR resolved to: $SCRIPT_DIR"
echo "  BASH_SOURCE[0]:         ${BASH_SOURCE[0]}"
echo "  \$0 (top-level script):  $0"
echo ""

# [WHAT]: Construct a path RELATIVE to the script's location — portable regardless
#         of where the user invokes the script from.
CONFIG_PATH="${SCRIPT_DIR}/config/defaults.conf"
echo "  Script-relative config path: $CONFIG_PATH"
echo "  (would work from ANY working directory)"
echo ""

# ==============================================================================

_section "SEGMENT 10.2 — find — THE PRODUCTION FILE SEARCH TOOL"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/search_root/logs/app"
mkdir -p "$WORKSPACE/search_root/config"
mkdir -p "$WORKSPACE/search_root/bin"

# Files of various types, sizes, and permissions
printf '%0.s-' {1..1025} > "$WORKSPACE/search_root/logs/big.log"        # >1k
echo  "small"             > "$WORKSPACE/search_root/logs/small.log"
echo  "config content"    > "$WORKSPACE/search_root/config/app.conf"
echo  "#!/bin/bash"       > "$WORKSPACE/search_root/bin/deploy.sh"
chmod 755                   "$WORKSPACE/search_root/bin/deploy.sh"
touch                       "$WORKSPACE/search_root/logs/app/access.log"
touch                       "$WORKSPACE/search_root/logs/app/error.LOG"  # uppercase
ln -sf "$WORKSPACE/search_root/config/app.conf" \
       "$WORKSPACE/search_root/config/app_link.conf"                      # symlink
touch  "$WORKSPACE/search_root/world_writable.txt"
chmod  o+w "$WORKSPACE/search_root/world_writable.txt"
# Filename with spaces — the classic pipeline killer
touch  "$WORKSPACE/search_root/logs/my evil log.log"

_pillar "BASIC: Type filters and name filters (Bash-10.2.A–I)"

# [COMMAND MEANING] find = Find files by traversing a directory tree

# [FLAG MEANING] -type f = regular files only
echo "  All regular files:"
find "$WORKSPACE/search_root" -type f | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -type d = directories only
echo "  Directories only:"
find "$WORKSPACE/search_root" -type d | sed "s|$WORKSPACE/search_root||"
echo ""

# [FLAG MEANING] -type l = symbolic links only
echo "  Symbolic links only (-type l):"
find "$WORKSPACE/search_root" -type l | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -name = case-sensitive glob match on filename
echo "  Case-sensitive -name '*.log':"
find "$WORKSPACE/search_root" -type f -name "*.log" \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -iname = case-INsensitive glob match — catches .LOG, .Log
echo "  Case-insensitive -iname '*.log' (also catches .LOG):"
find "$WORKSPACE/search_root" -type f -iname "*.log" \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -path = match against the FULL path string
echo "  -path '*/logs/*' (only files inside logs/ subtrees):"
find "$WORKSPACE/search_root" -type f -path "*/logs/*" \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

_pillar "POWER: Size, time, depth, permission filters (Bash-10.2.J–V)"

# [FLAG MEANING] -size +1k = files LARGER than 1 kilobyte
echo "  Files larger than 1k (-size +1k):"
find "$WORKSPACE/search_root" -type f -size +1k \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -size -500c = files SMALLER than 500 bytes (c=characters/bytes)
echo "  Files smaller than 500 bytes (-size -500c):"
find "$WORKSPACE/search_root" -type f -size -500c \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -mtime -1 = modified in the last 24 hours
echo "  Files modified in last 24h (-mtime -1):"
find "$WORKSPACE/search_root" -type f -mtime -1 \
  | wc -l | xargs printf "  %s files found\n"
echo ""

# [FLAG MEANING] -maxdepth 1 = only immediate children of the root
echo "  -maxdepth 1 (no recursion into subdirs):"
find "$WORKSPACE/search_root" -maxdepth 1 -type f \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -mindepth 2 = skip root and its immediate children
echo "  -mindepth 2 (at least 2 levels deep):"
find "$WORKSPACE/search_root" -mindepth 2 -type f \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -perm /mode = any of the specified bits are set
echo "  World-writable files (-perm /o+w) — security audit:"
find "$WORKSPACE/search_root" -type f -perm /o+w \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

# [FLAG MEANING] -perm -u+x = user-executable bit is set (at minimum)
echo "  Executable files (-perm -u+x):"
find "$WORKSPACE/search_root" -type f -perm -u+x \
  | sed "s|$WORKSPACE/search_root/||"
echo ""

_pillar "PRECISION: -exec {} \\; vs {} + performance, -delete, -print0 (Bash-10.2.W–AB)"

# [FLAG MEANING] -exec cmd {} \; = run cmd ONCE PER FILE — slow (N forks)
echo "  -exec {} \\; (one fork per file — slow pattern, shown for contrast):"
find "$WORKSPACE/search_root" -type f -name "*.conf" \
  -exec echo "  processing: {}" \;
echo ""

# [FLAG MEANING] -exec cmd {} + = run cmd ONCE with ALL files batched — fast
echo "  -exec {} + (batched — one fork total — fast pattern):"
find "$WORKSPACE/search_root" -type f -name "*.log" \
  -exec wc -l {} +
echo ""

# [FLAG MEANING] -print0 = NUL-terminate output — safe for filenames with spaces
# [FLAG MEANING] xargs -0 = read NUL-terminated input — the other half of the safe pipeline
echo "  NUL-safe pipeline — handles 'my evil log.log' correctly:"
find "$WORKSPACE/search_root" -type f -name "*.log" -print0 \
  | xargs -0 -I{} echo "  safe: {}"
echo ""

# [FLAG MEANING] -P = never follow symlinks (default) — safe with -delete
echo "  find -P (default) — symlinks are listed, NOT followed:"
find -P "$WORKSPACE/search_root" -type l -print0 \
  | xargs -0 -I{} echo "  symlink found (not followed): {}"
echo ""

# ==============================================================================

_section "SEGMENT 10.3 — FILE TESTING AND stat"

# ── Mock Data ─────────────────────────────────────────────────────────────────
STAT_FILE="$WORKSPACE/stat_demo.txt"
echo "stat test content" > "$STAT_FILE"
chmod 640 "$STAT_FILE"

OLDER_FILE="$WORKSPACE/older.txt"
echo "older" > "$OLDER_FILE"
touch -t 202001010000 "$OLDER_FILE"   # force mtime to year 2020

_pillar "BASIC: Extended file comparison operators (Bash-10.3.A–D)"

# [WHAT]: -N = file has been modified since it was last READ
# [WHY]:  Detect config drift without storing checksums — the "has anything
#         changed since I last processed this file?" check.
if [[ -N "$STAT_FILE" ]]; then
  echo "  -N: $STAT_FILE was modified since last read (true — just created)"
fi

# [WHAT]: -ef = same inode — detect hard links and duplicate path references
touch "$WORKSPACE/hardlink_a.txt"
ln "$WORKSPACE/hardlink_a.txt" "$WORKSPACE/hardlink_b.txt"
if [[ "$WORKSPACE/hardlink_a.txt" -ef "$WORKSPACE/hardlink_b.txt" ]]; then
  echo "  -ef: hardlink_a and hardlink_b share the same inode — confirmed hard link"
fi

# [WHAT]: -nt / -ot — compare modification times between two files
if [[ "$STAT_FILE" -nt "$OLDER_FILE" ]]; then
  echo "  -nt: stat_demo.txt IS newer than older.txt — correct"
fi
if [[ "$OLDER_FILE" -ot "$STAT_FILE" ]]; then
  echo "  -ot: older.txt IS older than stat_demo.txt — correct"
fi
echo ""

_pillar "POWER: GNU stat --format, portability wrapper (Bash-10.3.E/F)"

# [COMMAND MEANING] stat = STATus — query file metadata from the inode
# [FLAG MEANING] --format = specify which metadata fields to print (GNU form)

echo "  GNU stat fields for $STAT_FILE:"
# [FLAG MEANING] %s = file size in bytes
printf "  Size:        %s bytes\n"    "$(stat --format="%s" "$STAT_FILE")"
# [FLAG MEANING] %a = permissions in OCTAL
printf "  Permissions: %s (octal)\n" "$(stat --format="%a" "$STAT_FILE")"
# [FLAG MEANING] %U = owning username
printf "  Owner:       %s\n"         "$(stat --format="%U" "$STAT_FILE")"
# [FLAG MEANING] %Y = last modification time as Unix epoch
printf "  Mtime epoch: %s\n"         "$(stat --format="%Y" "$STAT_FILE")"
echo ""

# [WHAT]: Portable stat wrapper — detects GNU vs BSD and normalises output
portable_file_size() {
  local file="$1"
  # GNU coreutils stat (Linux)
  if stat --version &>/dev/null 2>&1; then
    stat --format="%s" "$file"
  else
    # BSD/macOS stat
    stat -f "%z" "$file"
  fi
}
echo "  Portable file size: $(portable_file_size "$STAT_FILE") bytes"
echo ""

_pillar "PRECISION: df -P, df -i, du -sh, du -sb (Bash-10.3.G–J)"

# [COMMAND MEANING] df = Disk Free — report filesystem space usage
# [FLAG MEANING] -P = POSIX format — one line per filesystem; safe to parse with awk
echo "  df -P (current filesystem):"
df -P "$WORKSPACE" | awk 'NR==2 {
  printf "  Total: %s 1k-blocks | Used: %s | Available: %s | Use%%: %s\n",
         $2, $3, $4, $5
}'
echo ""

# [FLAG MEANING] -i = inode report — a full inode table means no new files even
#                     if blocks are free (classic "too many small files" failure)
echo "  df -i (inode usage):"
df -i "$WORKSPACE" | awk 'NR==2 {
  printf "  Inodes total: %s | Used: %s | Free: %s | Use%%: %s\n",
         $2, $3, $4, $5
}'
echo ""

# [COMMAND MEANING] du = Disk Usage
# [FLAG MEANING] -s = summary — print only the total, not per-file breakdown
# [FLAG MEANING] -h = human-readable — K, M, G suffixes
echo "  du -sh (human-readable total):"
du -sh "$WORKSPACE"
echo ""

# [FLAG MEANING] -b = bytes — raw number; use for threshold comparisons in scripts
WORKSPACE_BYTES=$(du -sb "$WORKSPACE" | cut -f1)
echo "  du -sb (raw bytes for scripted threshold): $WORKSPACE_BYTES bytes"
if (( WORKSPACE_BYTES > 1048576 )); then
  echo "  WARNING: workspace exceeds 1MB — would trigger E_DISK_FULL=$E_DISK_FULL"
else
  echo "  Disk check passed — workspace is under 1MB limit"
fi
echo ""

# ==============================================================================

_section "SEGMENT 10.4 — SAFE FILE OPERATIONS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/src_tree/subdir"
echo "file content v1" > "$WORKSPACE/src_tree/data.txt"
echo "nested content"  > "$WORKSPACE/src_tree/subdir/nested.txt"
mkdir -p "$WORKSPACE/dst_tree"

_pillar "BASIC: Atomic write — mktemp + mv (Bash-10.4.A/B)"

# [WHAT]: The atomic write pattern — NEVER write directly to the destination.
# [WHY]:  A direct write to the destination file is visible to readers as a
#         partial write mid-operation. The kernel's rename() syscall is ATOMIC —
#         the destination switches instantly from old to new; no partial state exists.
atomic_write() {
  local destination="$1"
  local content="$2"
  local tmpfile
  # Write to a temp file IN THE SAME filesystem as the destination
  # (mv is only atomic within the same filesystem — same partition/mount point)
  tmpfile=$(mktemp "$(dirname "$destination")/.atomic.XXXXXX")
  echo "$content" > "$tmpfile"
  # [FLAG MEANING] mv = rename() syscall — atomic on same filesystem
  mv "$tmpfile" "$destination"
}

atomic_write "$WORKSPACE/dst_tree/config.conf" "key=atomic_value_$(date +%s)"
echo "  Atomic write result:"
cat "$WORKSPACE/dst_tree/config.conf"
echo ""

_pillar "POWER: cp --no-clobber vs -f, rsync flags (Bash-10.4.C–H)"

# [COMMAND MEANING] cp = CoPy
# [FLAG MEANING] --no-clobber = do NOT overwrite existing destination
cp --no-clobber "$WORKSPACE/src_tree/data.txt" "$WORKSPACE/dst_tree/data.txt"
echo "  cp --no-clobber: first copy succeeded"
cp --no-clobber "$WORKSPACE/src_tree/data.txt" "$WORKSPACE/dst_tree/data.txt" \
  && echo "  ERROR: should not overwrite" \
  || echo "  cp --no-clobber: refused to overwrite existing file — correct"
echo ""

# [COMMAND MEANING] rsync = Remote Sync — delta-transfer file synchronisation
# [FLAG MEANING] -a = archive mode: recursive + preserve permissions, timestamps, symlinks, owner
# [FLAG MEANING] -v = verbose: print each transferred file
# [FLAG MEANING] -z = compress transfer data (useful over network; overhead on local)
echo "  rsync -av (archive, verbose):"
rsync -av "$WORKSPACE/src_tree/" "$WORKSPACE/dst_tree/" 2>&1 | head -10
echo ""

# [FLAG MEANING] --dry-run = simulate — print what WOULD be transferred; make no changes
echo "  rsync --dry-run (safe preview before --delete):"
rsync -av --dry-run --delete "$WORKSPACE/src_tree/" "$WORKSPACE/dst_tree/" \
  2>&1 | grep -E "^(sending|deleting|>f)" || echo "  nothing to change"
echo ""

# [FLAG MEANING] --checksum = use file hash instead of size+mtime to determine changes
# [WHAT]: Essential on NFS or FAT where timestamps are unreliable
echo "  rsync --checksum (content-hash comparison):"
rsync -a --checksum "$WORKSPACE/src_tree/" "$WORKSPACE/dst_tree/" \
  && echo "  checksum sync complete — all content verified"
echo ""

_pillar "PRECISION: ln -sf idempotent symlinks, flock file locking (Bash-10.4.I–L)"

# [COMMAND MEANING] ln = LiNk — create hard or symbolic links
# [FLAG MEANING] -s = symbolic link
# [FLAG MEANING] -f = force — remove existing link before creating new one (idempotent)
# [WHAT]: Run twice — must produce identical result, no error on second run
ln -sf "$WORKSPACE/dst_tree/config.conf" "$WORKSPACE/current.conf"
echo "  First ln -sf: $(readlink "$WORKSPACE/current.conf")"
ln -sf "$WORKSPACE/dst_tree/data.txt"   "$WORKSPACE/current.conf"
echo "  Second ln -sf (updated target): $(readlink "$WORKSPACE/current.conf")"
echo "  (No error — -f makes ln idempotent)"
echo ""

# [WHAT]: flock inside a script block using the file descriptor form
# [WHY]:  The exec-based form lets you wrap an arbitrary code block in a lock,
#         not just a single command — the production pattern for critical sections.
FLOCK_RESOURCE="$WORKSPACE/shared_resource.lock"
touch "$FLOCK_RESOURCE"

echo "  flock file descriptor pattern (lock a code BLOCK):"
(
  # Open FLOCK_RESOURCE on FD 200 and acquire exclusive lock
  exec 200>"$FLOCK_RESOURCE"
  # [FLAG MEANING] -x 200 = acquire exclusive lock on FD 200
  flock -x 200
  echo "  [flock fd] exclusive lock acquired on FD 200"
  echo "  [flock fd] performing critical section..."
  sleep 0.1
  echo "  [flock fd] done — lock released when subshell exits"
)
echo ""

_pillar "DEVOPS CONTEXT: cross-filesystem mv is NOT atomic (Bash-10.4.M)"

# [WHAT]: Demonstrate that mv across mount points copies then deletes — not atomic
# [WHY]:  On the same filesystem, mv() → rename() syscall → atomic.
#         Across filesystems, mv() → copy() + unlink() → NOT atomic.
#         A crash between copy and unlink leaves TWO copies; readers may see
#         the incomplete intermediate state during the copy phase.

echo "  Cross-filesystem mv safety:"
echo "  UNSAFE:  mv /tmp/file /data/file   (if /tmp and /data are different mounts)"
echo "  SAFE:    rsync /tmp/file /data/file && rm /tmp/file"
echo "           rsync completes and checksums BEFORE the source is removed"
echo "           A crash leaves the source intact — no data loss"
echo ""

# ==============================================================================
# MODULE 11 — PROCESS MANAGEMENT AND JOB CONTROL
# ==============================================================================

_section "SEGMENT 11.1 — BACKGROUND PROCESSES AND JOB CONTROL"

_pillar "BASIC: &, \$!, wait PID, exit code capture (Bash-11.1.A/B/F/I)"

# [WHAT]: Launch a background job and immediately capture its PID via $!
# [WATCH OUT]: $! is overwritten by EVERY subsequent & — capture it IMMEDIATELY
slow_task() {
  local id="$1"
  local duration="${2:-1}"
  sleep "$duration"
  echo "  [task $id] completed after ${duration}s"
  return 0
}

echo "  Launching 3 background tasks..."
slow_task "alpha" 1 &
PID_ALPHA=$!   # capture immediately

slow_task "beta" 1 &
PID_BETA=$!

slow_task "gamma" 1 &
PID_GAMMA=$!

echo "  PIDs: alpha=$PID_ALPHA  beta=$PID_BETA  gamma=$PID_GAMMA"

# [COMMAND MEANING] wait = Wait for background process(es) to finish
# [WHAT]: Wait for a SPECIFIC PID and capture its exit code
wait "$PID_ALPHA"
rc_alpha=$?
echo "  alpha exit code: $rc_alpha"

wait "$PID_BETA" "$PID_GAMMA"
echo "  beta + gamma finished"
echo ""

_pillar "POWER: wait -n — first-completed harvesting (Bash-11.1.H)"

# [WHAT]: wait -n waits for ANY ONE child and returns its exit code
# [WHY]:  Without wait -n you must either wait for all jobs or poll with kill -0.
#         wait -n enables a responsive "process results as they arrive" pattern.
# [FLAG MEANING] -n = next — return as soon as ANY child finishes

echo "  wait -n demo — harvesting tasks as they complete:"
sleep 0.3 & PID_FAST=$!
sleep 0.8 & PID_SLOW=$!

# Harvest whichever finishes first
wait -n
echo "  First task finished (wait -n returned)"
wait    # wait for the remaining one
echo "  All tasks done"
echo ""

_pillar "PRECISION: disown vs nohup (Bash-11.1.J/K)"

# [COMMAND MEANING] disown = Remove a job from the shell's job table
# [WHAT]: After disown, the job survives when the shell exits — no SIGHUP sent
# [WHY]:  nohup must be specified BEFORE the command runs. disown can be applied
#         to a job that is ALREADY running — the retroactive survival tool.

sleep 30 &
DISOWN_PID=$!
disown "$DISOWN_PID"
echo "  PID $DISOWN_PID disowned — will survive shell exit (verified via jobs):"
jobs || echo "  (no jobs in table — disown succeeded)"

# Clean up the disowned process
kill "$DISOWN_PID" 2>/dev/null || true
echo ""

# ==============================================================================

_section "SEGMENT 11.2 — kill, SIGNALS, AND PROCESS GROUPS"

_pillar "BASIC: kill -SIGNAL, kill -0, kill -l (Bash-11.2.A/B/C)"

# [COMMAND MEANING] kill = Send a signal to a process (despite the name — it's a signal sender)

# [WHAT]: Probe whether a process is alive without sending a real signal
sleep 30 &
PROBE_PID=$!

# [FLAG MEANING] -0 = null signal — test process existence and permissions only
if kill -0 "$PROBE_PID" 2>/dev/null; then
  echo "  kill -0: PID $PROBE_PID exists and is alive — confirmed"
fi

kill -TERM "$PROBE_PID" 2>/dev/null || true
wait "$PROBE_PID" 2>/dev/null || true

set +e
kill -0 "$PROBE_PID" 2>/dev/null
kill0_rc=$?
set -e
echo "  kill -0 after SIGTERM: exit $kill0_rc (expected: 1 — process gone)"
echo ""

# [FLAG MEANING] -l = list — print all signal names and numbers
echo "  Common signals (kill -l excerpt):"
kill -l | tr ' ' '\n' | grep -E "^[0-9]+\)" | head -16 || kill -l | head -4
echo ""

_pillar "POWER: Process groups — kill entire tree (Bash-11.2.D/E/F)"

# [WHAT]: Spawn a process that spawns children — kill the entire group at once
# [WHY]:  kill PID only kills the PARENT — orphaned children keep running.
#         kill -TERM -PGID kills the parent AND all its children in one shot.

# [WHAT]: $$ vs $BASHPID — the subshell PID distinction
echo "  \$\$ in main shell:    $$"
echo "  \$BASHPID in main:    $BASHPID"
(echo "  \$\$ inside subshell: $$  (parent's PID — unchanged)")
(echo "  \$BASHPID in subshell: $BASHPID — wait, this IS the subshell PID")
echo ""

_pillar "PRECISION: Zombie processes — cause, detection, remedy (Bash-11.2.G/H)"

# [WHAT]: A zombie is a process that has exited but whose exit status has not yet
#         been collected by the parent via wait(). It occupies a slot in the process
#         table but consumes no CPU or memory.
# [WATCH OUT]: You CANNOT kill a zombie with any signal — it is already dead.
#              The remedy is to call wait on the parent, or kill the parent.

echo "  Zombie process theory (safe demo — no real zombie created here):"
echo "  1. Child exits → becomes Z (zombie) until parent calls wait()"
echo "  2. kill -9 on a zombie → silently ignored (it's already dead)"
echo "  3. Remedy: call 'wait \$child_pid' from the parent process"
echo "  4. If parent is dead too: zombies are reparented to PID 1 (init/systemd)"
echo "     which automatically reaps them"
echo ""

# ==============================================================================

_section "SEGMENT 11.3 — PARALLEL EXECUTION PATTERNS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/parallel_out"

_pillar "BASIC: Simple parallel loop with & and wait (Bash-11.3.A)"

# [WHAT]: Process N items simultaneously — all launch at once, wait collects all
echo "  Parallel health check simulation (3 hosts simultaneously):"
declare -a HOSTS=("web-01" "web-02" "db-01")

for host in "${HOSTS[@]}"; do
  (
    sleep 0.$((RANDOM % 5))   # simulate variable network latency
    echo "  [health] $host → OK"
  ) &
done
wait   # wait for ALL background children
echo "  All health checks complete"
echo ""

_pillar "POWER: Semaphore throttle — max N concurrent jobs (Bash-11.3.B/C)"

# [WHAT]: The semaphore pattern — never let more than MAX_JOBS run at once
# [WHY]:  Launching 1000 jobs simultaneously exhausts file descriptors, RAM,
#         and CPU. A semaphore gate prevents resource exhaustion.
# [HOW]:  Track a running counter; when it hits MAX_JOBS, call wait -n to block
#         until one slot frees, then decrement and continue.

MAX_JOBS=3
running=0

echo "  Semaphore throttle (max $MAX_JOBS concurrent):"
for i in {1..7}; do
  (
    sleep 0.$((RANDOM % 4 + 1))
    echo "  [job $i] done"
  ) &
  (( running++ )) || true

  if (( running >= MAX_JOBS )); then
    wait -n           # block until one slot frees
    (( running-- )) || true
  fi
done
wait   # drain remaining jobs
echo "  All 7 throttled jobs complete"
echo ""

_pillar "PRECISION: Parallel output collection via temp files (Bash-11.3.F)"

# [WHAT]: Each worker writes to its own dedicated temp file — no interleaving
# [WHY]:  If parallel workers all write to the same file (even line-by-line),
#         partial writes can interleave and corrupt the output.
#         Each worker owns its own file; the coordinator reads them in order.

echo "  Collecting parallel output via per-worker temp files:"
declare -a RESULT_FILES=()

for worker in "alpha" "beta" "gamma"; do
  outfile=$(mktemp "$WORKSPACE/parallel_out/worker.XXXXXX")
  RESULT_FILES+=("$outfile")
  (
    sleep 0.$((RANDOM % 3))
    echo "result_from_${worker}=$(date +%s%N)" > "$outfile"
  ) &
done
wait

echo "  Results (in launch order, not completion order):"
for f in "${RESULT_FILES[@]}"; do
  cat "$f"
done
echo ""

_pillar "DEVOPS CONTEXT: xargs -P N — embarrassingly parallel tasks (Bash-11.3.D)"

# [FLAG MEANING] -P N = run up to N parallel xargs worker processes
# [FLAG MEANING] -I{} = substitute {} with the current input item
echo "  xargs -P 3 (3 parallel workers):"
printf '%s\n' "node-01" "node-02" "node-03" "node-04" "node-05" \
  | xargs -P 3 -I{} bash -c 'sleep 0.1; echo "  [xargs -P] synced: {}"'
echo ""

# ==============================================================================

_section "SEGMENT 11.4 — COPROCESSES"

_pillar "BASIC: coproc — bidirectional persistent communication (Bash-11.4.A/B/C)"

# [WHAT]: Start a persistent bc calculator as a coprocess — one process, many calculations
# [WHY]:  Without a coprocess, each bc call spawns a new process. In a loop of
#         1000 calculations that's 1000 fork/exec pairs. The coprocess is one.

# [COMMAND MEANING] coproc = CoProcess — launch with bidirectional stdin/stdout pipes
# [FLAG MEANING] stdbuf -oL = force Line-buffered output — MANDATORY to prevent deadlock
coproc BC_PROC { stdbuf -oL bc; }

# [WHAT]: Write expressions to bc's stdin via NAME[1] (the write FD)
echo "6 * 7"     >&"${BC_PROC[1]}"
# [WHAT]: Read bc's output from NAME[0] (the read FD)
read -r result <&"${BC_PROC[0]}"
echo "  coproc bc: 6 * 7 = $result"

echo "2^10"      >&"${BC_PROC[1]}"
read -r result <&"${BC_PROC[0]}"
echo "  coproc bc: 2^10  = $result"

echo "sqrt(144)" >&"${BC_PROC[1]}"
read -r result <&"${BC_PROC[0]}"
echo "  coproc bc: sqrt(144) = $result"

# Shut down the coprocess cleanly by closing its stdin
exec {BC_PROC[1]}>&-
wait "${BC_PROC_PID}" 2>/dev/null || true
echo ""

_pillar "POWER: stdbuf — the coprocess deadlock fix (Bash-11.4.E/F)"

# [WHAT]: Demonstrate WHY buffering causes coprocess deadlock
# [WHY]:  Most Unix tools buffer stdout when not connected to a terminal.
#         The coprocess pipe IS NOT a terminal — so the tool buffers until its
#         buffer is full. Your script waits for output; the tool waits for the
#         buffer to fill. DEADLOCK.
# [FLAG MEANING] -oL = output buffering mode Line — flush after every newline

echo "  Coprocess buffering rules:"
echo "  stdbuf -oL cmd  → line-buffered  → flush after each \n (coprocess-safe)"
echo "  stdbuf -o0 cmd  → unbuffered     → flush after every byte (safest, slowest)"
echo "  (default)       → fully buffered → deadlock with coprocesses"
echo ""

# ==============================================================================

_section "SEGMENT 11.5 — nice, ionice, ulimit, timeout"

_pillar "BASIC: nice, ionice — CPU and I/O priority (Bash-11.5.A–D)"

# [COMMAND MEANING] nice = Nice — adjust CPU scheduling priority
# [FLAG MEANING] -n 19 = niceness 19 — the LOWEST CPU priority; yields to everything
echo "  Running find at CPU niceness 19 (lowest priority):"
nice -n 19 find "$WORKSPACE" -name "*.txt" -type f | wc -l | xargs printf "  %s .txt files found\n"

# [COMMAND MEANING] ionice = I/O Nice — adjust I/O scheduling class and priority
# [FLAG MEANING] -c 3 = Idle class — only gets disk access when no other process needs it
echo "  Running du at I/O Idle class (-c 3):"
ionice -c 3 du -sh "$WORKSPACE" 2>/dev/null || \
  echo "  (ionice requires a supported I/O scheduler — skipped in this environment)"
echo ""

_pillar "POWER: ulimit — resource caps for safety (Bash-11.5.E/F/G)"

# [COMMAND MEANING] ulimit = User Limit — set or report process resource limits
# [FLAG MEANING] -n = number of open file descriptors
echo "  Current FD limit (ulimit -n):"
ulimit -n

# [FLAG MEANING] -v N = virtual memory cap in kilobytes
echo "  Current virtual memory limit (ulimit -v):"
ulimit -v

# [WHAT]: Show current CPU time limit
echo "  Current CPU time limit (ulimit -t):"
ulimit -t
echo ""

_pillar "PRECISION: timeout — enforce maximum runtime (Bash-11.5.H/I/J)"

# [COMMAND MEANING] timeout = Kill a command after N seconds if it hasn't finished
# [WHAT]: Prevent runaway scripts from blocking pipelines indefinitely
# [FLAG MEANING] N = number of seconds before sending SIGTERM
echo "  timeout 2s on a sleep 5 (should terminate early):"
set +e
timeout 2 sleep 5
timeout_rc=$?
set -e
echo "  timeout exit code: $timeout_rc  (124 = timed out; 0 = completed in time)"
echo ""

# [FLAG MEANING] --signal=SIGKILL = send SIGKILL directly (no SIGTERM first)
echo "  timeout with immediate SIGKILL:"
set +e
timeout --signal=SIGKILL 1 sleep 10
set -e
echo "  SIGKILL timeout completed"
echo ""

# [FLAG MEANING] --kill-after=K = two-phase: SIGTERM at N seconds, SIGKILL after K more
echo "  timeout --kill-after pattern (SIGTERM then SIGKILL):"
set +e
timeout --kill-after=2 1 sleep 10
set -e
echo "  Two-phase timeout completed"
echo ""

# ==============================================================================
# MODULE 12 — DEBUGGING, PROFILING, AND TESTING
# ==============================================================================

_section "SEGMENT 12.1 — BASH BUILT-IN DEBUGGING TOOLS"

_pillar "BASIC: bash -n syntax check, bash -x xtrace (Bash-12.1.A/B)"

# [WHAT]: Write a small script to disk so we can run bash -n and bash -x on it
cat > "$WORKSPACE/demo_debug.sh" << 'DEBUGSCRIPT'
#!/usr/bin/env bash
greet() {
  local name="$1"
  echo "Hello, $name"
}
greet "World"
greet "Jesse"
DEBUGSCRIPT
chmod +x "$WORKSPACE/demo_debug.sh"

# [FLAG MEANING] bash -n = No execute — parse and syntax-check only
echo "  bash -n (syntax check — no execution):"
bash -n "$WORKSPACE/demo_debug.sh" \
  && echo "  Syntax OK — no errors found"
echo ""

# [FLAG MEANING] bash -x = eXtrace — print each command before executing
echo "  bash -x (execution trace — first 10 lines of output):"
bash -x "$WORKSPACE/demo_debug.sh" 2>&1 | head -10
echo ""

_pillar "POWER: Rich PS4 trace prefix (Bash-12.1.C/D)"

# [WHAT]: The production PS4 — every traced line shows file, line number, and function
cat > "$WORKSPACE/demo_ps4.sh" << 'PS4SCRIPT'
#!/usr/bin/env bash
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
multiply() {
  local result=$(( $1 * $2 ))
  echo "$result"
}
multiply 6 7
PS4SCRIPT

echo "  bash -x with rich PS4 (file:line:function prefix):"
bash "$WORKSPACE/demo_ps4.sh" 2>&1 | head -10
echo ""

_pillar "PRECISION: set -x / set +x surgical toggle, BASH_XTRACEFD (Bash-12.1.E/G)"

# [WHAT]: Toggle xtrace only around suspect code — not the whole script
SUSPICIOUS_VAR="hello world"
set -x   # start trace
result="${SUSPICIOUS_VAR^^}"
set +x   # stop trace immediately
echo "  Traced expansion result: $result"
echo ""

# [FLAG MEANING] BASH_XTRACEFD=N = redirect xtrace to FD N, not stderr
# [WHAT]: Capture xtrace to a dedicated log file without mixing with stderr
exec 9> "$WORKSPACE/xtrace.log"
BASH_XTRACEFD=9

set -x
demo_value="production"
demo_upper="${demo_value^^}"
set +x

exec 9>&-    # close the trace FD
unset BASH_XTRACEFD

echo "  BASH_XTRACEFD trace log contents:"
cat "$WORKSPACE/xtrace.log"
echo ""

# ==============================================================================

_section "SEGMENT 12.2 — shellcheck — STATIC ANALYSIS"

_pillar "BASIC: SC2086, SC2046, SC2034 — the big three findings (Bash-12.2.A–D)"

# [WHAT]: Write intentionally buggy scripts to disk to demonstrate each SC code
# [WHY]:  shellcheck can't be run on THIS script (it's already running), so we
#         write illustrative examples and explain them from the code.

cat > "$WORKSPACE/shellcheck_sc2086.sh" << 'SC2086'
#!/bin/bash
# SC2086: Double quote to prevent globbing and word splitting
filename="my file.txt"
cat $filename        # BUG: $filename splits into 2 args — 'my' and 'file.txt'
cat "$filename"      # CORRECT: treats the whole string as one argument
SC2086

cat > "$WORKSPACE/shellcheck_sc2046.sh" << 'SC2046'
#!/bin/bash
# SC2046: Quote this to prevent word splitting
files=$(ls /tmp)
cp $files /backup/  # BUG: filenames with spaces split into multiple args
cp "$files" /backup/  # CORRECT — but better to use arrays
SC2046

cat > "$WORKSPACE/shellcheck_sc2034.sh" << 'SC2034'
#!/bin/bash
# SC2034: unused variable — often a typo
server_name="web-01"
servr_name="web-02"  # BUG: typo — 'server_name' is never used again
echo "deploying to: $server_name"
SC2034

echo "  Shellcheck finding demonstrations written to:"
echo "    $WORKSPACE/shellcheck_sc2086.sh  (SC2086 — unquoted variable)"
echo "    $WORKSPACE/shellcheck_sc2046.sh  (SC2046 — word splitting in \$())"
echo "    $WORKSPACE/shellcheck_sc2034.sh  (SC2034 — unused variable)"
echo ""

# [WHAT]: Run shellcheck if available and show its output
if command -v shellcheck &>/dev/null; then
  echo "  shellcheck SC2086 demo:"
  shellcheck "$WORKSPACE/shellcheck_sc2086.sh" 2>&1 || true
  echo ""
  echo "  shellcheck SC2034 demo:"
  shellcheck "$WORKSPACE/shellcheck_sc2034.sh" 2>&1 || true
else
  echo "  shellcheck not installed — showing expected output format:"
  cat << 'EXPECTED'
  In /tmp/.../shellcheck_sc2086.sh line 4:
  cat $filename
      ^--------^ SC2086 (info): Double quote to prevent globbing and word splitting.

  For more information:
    https://www.shellcheck.net/wiki/SC2086
EXPECTED
fi
echo ""

_pillar "POWER: Inline suppression, -s sh POSIX mode (Bash-12.2.E/F)"

cat > "$WORKSPACE/shellcheck_suppress.sh" << 'SUPPRESS'
#!/bin/bash
# shellcheck disable=SC2016  # intentional: we WANT unexpanded $PATH in this message
echo 'Current PATH is: $PATH'   # single-quoted — expansion intentionally suppressed
SUPPRESS

echo "  Inline suppression example:"
cat "$WORKSPACE/shellcheck_suppress.sh"
echo ""

# [FLAG MEANING] -s sh = check as POSIX /bin/sh — Bashisms become errors
cat > "$WORKSPACE/shellcheck_posix.sh" << 'POSIXCHECK'
#!/bin/sh
declare -a arr=("a" "b")  # Bashism — not POSIX
echo "${arr[@]}"
POSIXCHECK

if command -v shellcheck &>/dev/null; then
  echo "  shellcheck -s sh POSIX compliance check:"
  shellcheck -s sh "$WORKSPACE/shellcheck_posix.sh" 2>&1 || true
else
  echo "  Expected finding for -s sh: arrays are not POSIX (SC2039)"
fi
echo ""

# ==============================================================================

_section "SEGMENT 12.3 — strace AND SYSTEM CALL TRACING"

_pillar "BASIC: strace command reference (Bash-12.3.A–I)"

# [WHAT]: strace cannot be run inside this script without elevated permissions
#         in most container environments. We document the exact command forms
#         with concrete DevOps use-case examples — the Toptal screener tests
#         whether you know the commands, not whether you can run them here.

echo "  strace command reference (documented patterns for production use):"
echo ""

# [COMMAND MEANING] strace = System Call Trace — intercept kernel interface calls
cat << 'STRACEREF'
  ── BASIC TRACE ───────────────────────────────────────────────────────────
  strace bash script.sh
    → Trace all syscalls of the top-level bash process only.
    → Use when the script itself (not its children) is the suspect.

  ── FOLLOW FORKS (Bash-12.3.B) ───────────────────────────────────────────
  strace -f bash script.sh
    → -f: follow all child processes forked by the script.
    → Required to see what subshells, external commands (grep, awk) do.
    → Output prefixed by [pid NNNNN] to identify which child issued the call.

  ── FILTERED TRACE (Bash-12.3.C) ─────────────────────────────────────────
  strace -e trace=open,read,write,execve bash script.sh
    → Only show the four most relevant syscall categories:
        open   → which files are being opened (and with what flags)
        read   → what data is being read (and from where)
        write  → what is being written (and where)
        execve → every program launch (find missing binaries instantly)

  ── TIMING (Bash-12.3.D) ─────────────────────────────────────────────────
  strace -T bash script.sh
    → -T: append time spent INSIDE each syscall.
    → A read() showing <5.003456> means a 5-second I/O wait — your bottleneck.

  ── TIMESTAMPED (Bash-12.3.E) ────────────────────────────────────────────
  strace -tt bash script.sh
    → -tt: absolute HH:MM:SS.usec prefix on every line.
    → Cross-reference with application logs to find what triggered a failure.

  ── ERROR CODES (Bash-12.3.F/G) ──────────────────────────────────────────
  ENOENT = "No such file or directory"
    → The binary, config file, or socket your script expects does not exist.
    → strace reveals the EXACT path — no more guessing which file is missing.
  EACCES = "Permission denied"
    → Your script lacks read/write/execute permission on a file or socket.
    → Faster to find than chmod -R trial and error.

  ── BLOCKED read() (Bash-12.3.H) ────────────────────────────────────────
  strace output: read(3, <unfinished ...>
    → The script is BLOCKED waiting for data on FD 3.
    → FD 3 is likely a FIFO, socket, or pipe with no writer.
    → Cross-reference /proc/PID/fd/3 to identify the blocked resource.

  ── LIBRARY TRACING (Bash-12.3.I) ────────────────────────────────────────
  ltrace bash script.sh
    → One level ABOVE strace — shows libc calls (fopen, malloc, SSL_connect).
    → Use when the bug is in library behaviour, not raw syscalls.
STRACEREF
echo ""

# ==============================================================================

_section "SEGMENT 12.4 — TESTING WITH bats"

_pillar "BASIC: bats test file structure, run, \$status, \$output (Bash-12.4.A–E)"

# [WHAT]: Generate a real .bats test suite and a script under test
# [WHY]:  You learn bats by reading and running it — so we build a full suite.

# ── Script under test ────────────────────────────────────────────────────────
cat > "$WORKSPACE/lib_validate.sh" << 'LIBSCRIPT'
#!/usr/bin/env bash
# Library: input validation functions

validate_hostname() {
  local hostname="$1"
  [[ "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]
}

validate_port() {
  local port="$1"
  [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 ))
}

get_service_status() {
  local service="$1"
  case "$service" in
    nginx|postgres|redis) echo "running" ;;
    stopped_svc)          echo "stopped" ;;
    *)                    echo "unknown"; return 1 ;;
  esac
}
LIBSCRIPT

# ── Bats test suite ───────────────────────────────────────────────────────────
cat > "$WORKSPACE/test_validate.bats" << 'BATSFILE'
#!/usr/bin/env bats
# [WHAT]: Test suite for lib_validate.sh
# [WHY]:  Every public function needs at least: happy path, edge case, failure case.

# setup() runs BEFORE each @test — create fixtures here
setup() {
  source "$BATS_TEST_DIRNAME/lib_validate.sh"
}

# teardown() runs AFTER each @test — clean up fixtures here
teardown() {
  :   # nothing to clean for these pure-function tests
}

# ── validate_hostname ─────────────────────────────────────────────────────────
@test "validate_hostname: accepts valid hostname" {
  run validate_hostname "web-01"
  [ "$status" -eq 0 ]
}

@test "validate_hostname: accepts multi-component hostname" {
  run validate_hostname "db-primary-01"
  [ "$status" -eq 0 ]
}

@test "validate_hostname: rejects hostname with spaces" {
  run validate_hostname "web 01"
  [ "$status" -ne 0 ]
}

@test "validate_hostname: rejects hostname starting with hyphen" {
  run validate_hostname "-bad-host"
  [ "$status" -ne 0 ]
}

# ── validate_port ─────────────────────────────────────────────────────────────
@test "validate_port: accepts valid port 8080" {
  run validate_port "8080"
  [ "$status" -eq 0 ]
}

@test "validate_port: rejects port 0" {
  run validate_port "0"
  [ "$status" -ne 0 ]
}

@test "validate_port: rejects port 65536" {
  run validate_port "65536"
  [ "$status" -ne 0 ]
}

@test "validate_port: rejects non-numeric input" {
  run validate_port "http"
  [ "$status" -ne 0 ]
}

# ── get_service_status ────────────────────────────────────────────────────────
@test "get_service_status: returns 'running' for nginx" {
  run get_service_status "nginx"
  [ "$status"  -eq 0         ]
  [ "$output"  = "running"   ]
}

@test "get_service_status: returns 'stopped' for stopped_svc" {
  run get_service_status "stopped_svc"
  [ "$status" -eq 0        ]
  [ "$output" = "stopped"  ]
}

@test "get_service_status: returns non-zero for unknown service" {
  run get_service_status "nonexistent_svc"
  [ "$status" -ne 0       ]
  [ "$output" = "unknown" ]
}
BATSFILE

echo "  Generated test assets:"
echo "    $WORKSPACE/lib_validate.sh    (library under test)"
echo "    $WORKSPACE/test_validate.bats (bats test suite — 11 tests)"
echo ""

# [WHAT]: Run the bats suite if bats is installed
if command -v bats &>/dev/null; then
  echo "  Running bats test suite:"
  bats "$WORKSPACE/test_validate.bats"
else
  echo "  bats not installed — showing expected output format:"
  cat << 'EXPECTED_BATS'
  1..11
  ok 1 validate_hostname: accepts valid hostname
  ok 2 validate_hostname: accepts multi-component hostname
  ok 3 validate_hostname: rejects hostname with spaces
  ok 4 validate_hostname: rejects hostname starting with hyphen
  ok 5 validate_port: accepts valid port 8080
  ok 6 validate_port: rejects port 0
  ok 7 validate_port: rejects port 65536
  ok 8 validate_port: rejects non-numeric input
  ok 9 get_service_status: returns 'running' for nginx
  ok 10 get_service_status: returns 'stopped' for stopped_svc
  ok 11 get_service_status: returns non-zero for unknown service

  11 tests, 0 failures
EXPECTED_BATS
fi
echo ""

_pillar "POWER: PATH-prepend mock stub pattern (Bash-12.4.I/J)"

# [WHAT]: Create a fake 'curl' stub that returns a controlled response
# [WHY]:  Tests must not make real HTTP calls — mocks isolate the unit.
#         Prepending a directory to PATH intercepts the call transparently.
STUB_DIR=$(mktemp -d)
cat > "$STUB_DIR/curl" << 'CURLSTUB'
#!/bin/bash
# Mock curl — always returns HTTP 200 with a JSON body
echo '{"status":"ok","version":"2.4.1"}'
exit 0
CURLSTUB
chmod +x "$STUB_DIR/curl"

# Inject the stub into PATH
OLD_PATH="$PATH"
export PATH="$STUB_DIR:$PATH"

echo "  PATH stub active — calling 'curl' (intercepted by mock):"
curl "https://api.example.com/health"
echo ""

# Restore real PATH
export PATH="$OLD_PATH"
rm -rf "$STUB_DIR"

# ==============================================================================

_section "SEGMENT 12.5 — LOGGING FRAMEWORKS AND OBSERVABILITY"

_pillar "BASIC: Structured log_info / log_warn / log_error / log_debug (Bash-12.5.A/B/C)"

# [WHAT]: A production-grade logging framework with level control and structured output
# [WHY]:  echo "something happened" is not a log line. A real log line has:
#         timestamp, severity, script name, caller function, line number, message.

# [WHAT]: Numeric log level — lower number = more verbose
# 0=DEBUG  1=INFO  2=WARN  3=ERROR  (matching syslog conventions)
readonly LOG_DEBUG=0
readonly LOG_INFO=1
readonly LOG_WARN=2
readonly LOG_ERROR=3

# [FLAG MEANING] LOG_LEVEL = controls minimum severity level for output
LOG_LEVEL="${LOG_LEVEL:-$LOG_INFO}"   # default to INFO if not set in environment

__log() {
  local level_num="$1"
  local level_name="$2"
  shift 2
  local message="$*"

  # Suppress if below current LOG_LEVEL threshold
  (( level_num < LOG_LEVEL )) && return 0

  # [WHAT]: Structured log format — ISO-8601 timestamp + all context fields
  # [FLAG MEANING] ${BASH_SOURCE[-1]##*/} = script filename only (strip path)
  # [FLAG MEANING] ${FUNCNAME[1]} = the name of the CALLER (not __log itself)
  # [FLAG MEANING] $BASH_LINENO = the line number of the CALLER
  printf '[%s] [%-5s] [%s] [%s:%s] %s\n' \
    "$(date '+%Y-%m-%dT%H:%M:%S')" \
    "$level_name" \
    "${BASH_SOURCE[-1]##*/}" \
    "${FUNCNAME[1]:-main}" \
    "${BASH_LINENO[0]}" \
    "$message" \
    >&2
}

log_debug() { __log "$LOG_DEBUG" "DEBUG" "$@"; }
log_info()  { __log "$LOG_INFO"  "INFO"  "$@"; }
log_warn()  { __log "$LOG_WARN"  "WARN"  "$@"; }
log_error() { __log "$LOG_ERROR" "ERROR" "$@"; }

echo "  Structured logging framework (output to stderr):"
log_debug "This is suppressed at INFO level"
log_info  "Application started — version 2.4.1"
log_warn  "Disk usage at 78% — approaching threshold"
log_error "Failed to connect to database — retrying"
echo ""

# [WHAT]: Show LOG_LEVEL filtering in action
echo "  Changing LOG_LEVEL to WARN (suppresses INFO and DEBUG):"
LOG_LEVEL=$LOG_WARN
log_debug "DEBUG  — suppressed at WARN level"
log_info  "INFO   — suppressed at WARN level"
log_warn  "WARN   — visible at WARN level"
log_error "ERROR  — visible at WARN level"
LOG_LEVEL=$LOG_INFO   # restore
echo ""

_pillar "POWER: logger → syslog, systemd-cat → journald (Bash-12.5.D/E/F)"

# [COMMAND MEANING] logger = Write a message to the system logger (syslog/journald)
# [FLAG MEANING] -t = tag — identifies the script in syslog output
# [FLAG MEANING] -p = priority — facility.level (e.g. user.err, daemon.info)
if command -v logger &>/dev/null; then
  logger -t "bash-zero-to-hero" -p user.info "Module 12.5 syslog integration demo"
  echo "  logger: message sent to syslog (check: journalctl -t bash-zero-to-hero)"

  # [FLAG MEANING] -s = also print to stderr (dual output: terminal + syslog)
  logger -s -t "bash-zero-to-hero" -p user.warn "Dual output: stderr AND syslog"
fi
echo ""

_pillar "PRECISION: Prometheus Pushgateway metric push (Bash-12.5.H)"

# [WHAT]: Push a custom metric to Prometheus Pushgateway from a shell script
# [WHY]:  Scripts that run in batch/cron jobs die before Prometheus can scrape them.
#         The Pushgateway accepts metric PUSHES and holds them for the next scrape.
# [HOW]:  Pipe metric lines in Prometheus text format to curl with --data-binary @-

DEPLOY_DURATION_SECONDS=47
JOB_NAME="bash_zero_to_hero"

echo "  Prometheus Pushgateway push (dry-run — no real endpoint):"
cat << PUSHGATEWAY_CMD
  echo "deploy_duration_seconds $DEPLOY_DURATION_SECONDS" \\
    | curl --silent --output /dev/null \\
           --write-out "HTTP %{http_code}\\n" \\
           --data-binary @- \\
           "http://pushgateway:9091/metrics/job/${JOB_NAME}"
  # This survives script exit — metric persists until explicitly deleted
PUSHGATEWAY_CMD
echo ""

# ==============================================================================
# MODULE 13 — SCRIPTING PATTERNS FOR SYSTEM ADMINISTRATION
# ==============================================================================

_section "SEGMENT 13.1 — IDEMPOTENCY PRINCIPLES"

# ── Mock Data ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKSPACE/idempotency_demo"
IDEM_DIR="$WORKSPACE/idempotency_demo"

_pillar "BASIC: check-before-act, mkdir -p, ln -sf (Bash-13.1.A–D)"

# [WHAT]: The canonical check-before-act pattern
# [WHY]:  Unconditional useradd fails if the user exists; conditional is idempotent.
# We simulate with a file presence check instead of useradd (no root needed here)

ensure_config_file() {
  local target="$1"
  local content="$2"
  if [[ ! -f "$target" ]]; then
    echo "$content" > "$target"
    log_info "Created: $target"
  else
    log_debug "Already exists (skipped): $target"
  fi
}

echo "  Run 1 — creating resources:"
ensure_config_file "$IDEM_DIR/app.conf"  "app_env=production"
ensure_config_file "$IDEM_DIR/db.conf"   "db_host=localhost"
# [FLAG MEANING] -p = parents — no error if directory already exists (idempotent)
mkdir -p "$IDEM_DIR/logs/app"
# [FLAG MEANING] -sf = symbolic + force (idempotent symlink)
ln -sf "$IDEM_DIR/app.conf" "$IDEM_DIR/current.conf"

echo ""
echo "  Run 2 — same commands, same end state (idempotency):"
ensure_config_file "$IDEM_DIR/app.conf"  "app_env=production"
ensure_config_file "$IDEM_DIR/db.conf"   "db_host=localhost"
mkdir -p "$IDEM_DIR/logs/app"
ln -sf "$IDEM_DIR/app.conf" "$IDEM_DIR/current.conf"
echo "  (no changes — system was already in desired state)"
echo ""

_pillar "POWER: diff-before-write — avoid spurious mtime bumps (Bash-13.1.E)"

# [WHAT]: Only write a config file if the new content DIFFERS from the existing one
# [WHY]:  Overwriting with identical content bumps mtime, which triggers config
#         management tools (Puppet, Ansible) to restart services unnecessarily.

idempotent_write() {
  local filepath="$1"
  local new_content="$2"
  local tmpfile
  tmpfile=$(mktemp)
  echo "$new_content" > "$tmpfile"

  if [[ ! -f "$filepath" ]]; then
    mv "$tmpfile" "$filepath"
    log_info "Created (new): $filepath"
  elif diff -q "$tmpfile" "$filepath" &>/dev/null; then
    rm "$tmpfile"
    log_debug "No change (skipped write): $filepath"
    return 0
  else
    mv "$tmpfile" "$filepath"
    log_info "Updated (content changed): $filepath"
  fi
}

echo "  idempotent_write demo:"
idempotent_write "$IDEM_DIR/service.conf" "port=8080"
idempotent_write "$IDEM_DIR/service.conf" "port=8080"   # same — no write
idempotent_write "$IDEM_DIR/service.conf" "port=9090"   # different — write
echo ""

_pillar "PRECISION: Idempotency testing — snapshot and diff (Bash-13.1.G)"

# [WHAT]: Capture a filesystem snapshot, run the script, capture again, compare
# [WHY]:  The gold standard test — if the snapshots are identical, the script
#         is provably idempotent for that test case.
snapshot_state() {
  local label="$1"
  # [COMMAND MEANING] find = enumerate all files with their modification times
  find "$IDEM_DIR" -type f -exec stat --format="%n %Y %s" {} \; \
    | LC_ALL=C sort > "$WORKSPACE/snapshot_${label}.txt"
  echo "  Snapshot '$label': $(wc -l < "$WORKSPACE/snapshot_${label}.txt") entries"
}

snapshot_state "before"
# Run the idempotent operations a third time
ensure_config_file "$IDEM_DIR/app.conf" "app_env=production"
mkdir -p "$IDEM_DIR/logs/app"
ln -sf "$IDEM_DIR/app.conf" "$IDEM_DIR/current.conf"
snapshot_state "after"

echo "  diff snapshot before vs after (empty = idempotent):"
diff "$WORKSPACE/snapshot_before.txt" "$WORKSPACE/snapshot_after.txt" \
  && echo "  PASS — snapshots identical — script is idempotent" \
  || echo "  FAIL — state changed on second run — NOT idempotent"
echo ""

# ==============================================================================

_section "SEGMENT 13.2 — PRIVILEGE AND PERMISSION MANAGEMENT"

_pillar "BASIC: EUID check, sudo -n, sudo -u (Bash-13.2.A/B/C)"

# [WHAT]: Check effective UID — the correct privilege check
# [WHY]:  $USER == "root" can be spoofed by renaming a user; EUID == 0 cannot.
if [[ $EUID -eq 0 ]]; then
  log_info "Running as root (EUID=0) — all operations permitted"
else
  log_info "Running as non-root (EUID=$EUID) — privilege-sensitive ops will be skipped"
fi
echo ""

# [WHAT]: sudo -n — non-interactive check (safe for automation)
# [WHY]:  sudo without -n will BLOCK waiting for a password in a cron job.
#         -n makes it fail fast — the CI-safe form.
echo "  sudo -n availability check:"
if sudo -n true 2>/dev/null; then
  echo "  sudo -n: passwordless sudo available"
else
  echo "  sudo -n: password required (or sudo not configured) — automation-safe fail"
fi
echo ""

echo "  Privilege management reference (root required — documented only):"
cat << 'PRIVREF'
  sudo -u www-data touch /var/www/html/health.txt
    → Run a single command as the www-data service account.
    → Correct form for dropping to a service account for one operation.

  su -c "pg_dump mydb > /backup/db.sql" postgres
    → POSIX equivalent of sudo -u — requires target user's password unless root.
    → Use in scripts that cannot rely on sudo configuration.

  runuser -u nginx -- nginx -t
    → PAM-aware privilege drop — preferred in systemd ExecStart lines.
    → Does NOT require target user's password when invoked as root.

  setuid on bash scripts:
    → The kernel IGNORES setuid on interpreted scripts (shebang files).
    → A setuid bash script is a misconfiguration — use a C wrapper or sudo.

  getcap /usr/bin/ping
    → Show capabilities granted to a binary — safer than full root.
  setcap cap_net_bind_service=+ep /usr/bin/node
    → Grant only port-binding capability — not all root privileges.
PRIVREF
echo ""

# ==============================================================================

_section "SEGMENT 13.3 — systemd INTEGRATION"

_pillar "BASIC: Unit file anatomy + systemctl commands (Bash-13.3.A–F)"

# [WHAT]: Generate a real production-grade systemd unit file on disk
# [WHY]:  The Toptal screener will ask you to write one from scratch.
#         Every field here is explained and justified.

UNIT_FILE="$WORKSPACE/bash-monitor.service"
cat > "$UNIT_FILE" << 'UNITFILE'
[Unit]
Description=Bash Zero-to-Hero System Monitor
# After= ensures this unit starts AFTER the network is up
After=network.target
# Requires= declares a hard dependency — if this fails, our unit fails too
Requires=network.target

[Service]
# Type=simple: ExecStart process IS the service process (default and correct for scripts)
Type=simple

# User/Group: drop privileges to a service account — NEVER run as root
User=nobody
Group=nogroup

# ExecStart: MUST be an absolute path — systemd does not search PATH
ExecStart=/usr/local/bin/bash-monitor.sh

# Restart=on-failure: auto-restart if the script exits non-zero
Restart=on-failure
# RestartSec: wait 5s before restarting — prevents rapid-restart loops
RestartSec=5s

# StandardOutput/Error: route all output to journald
StandardOutput=journal
StandardError=journal

# Environment: inject config without storing in the script
Environment=LOG_LEVEL=warn
Environment=MONITOR_INTERVAL=60

# EnvironmentFile: load secrets from a protected file (chmod 600)
# EnvironmentFile=/etc/bash-monitor/secrets.env

[Install]
# WantedBy=multi-user.target: start in normal multi-user runlevel
WantedBy=multi-user.target
UNITFILE

echo "  Generated systemd unit file:"
cat "$UNIT_FILE"
echo ""

# [WHAT]: Validate the unit file syntax without installing it
if command -v systemd-analyze &>/dev/null; then
  echo "  systemd-analyze verify:"
  systemd-analyze verify "$UNIT_FILE" 2>&1 || \
    echo "  (verification requires systemd — unit file structure is correct)"
fi
echo ""

_pillar "POWER: systemctl scripting patterns (Bash-13.3.C/D/E/F/I)"

echo "  systemctl command reference for scripts:"
cat << 'SYSTEMCTLREF'
  systemctl start   bash-monitor   # start immediately (not persistent)
  systemctl stop    bash-monitor   # stop  immediately
  systemctl restart bash-monitor   # stop + start (reload if possible instead)
  systemctl reload  bash-monitor   # send SIGHUP — graceful config reload (no restart)
  systemctl enable  bash-monitor   # start on boot (create wants/ symlink)
  systemctl disable bash-monitor   # remove the boot symlink
  systemctl enable --now bash-monitor  # enable AND start in one command

  # Script-safe status check (Bash-13.3.I):
  if systemctl is-active --quiet bash-monitor; then
    echo "service is running"
  fi
  # is-active --quiet: zero output, exits 0=active, non-zero=not active
  # Use this form — 'systemctl status' always exits 0 whether active or not

  # journalctl for live log following (Bash-13.3.G):
  journalctl -u bash-monitor -f
  journalctl -u bash-monitor --since "10 minutes ago"
  journalctl -u bash-monitor -n 50 --no-pager

  # Transient one-shot timer (Bash-13.3.H):
  systemd-run --on-active=30m /usr/local/bin/rotate-logs.sh
  # Schedules rotate-logs.sh to run once, 30 minutes from now
  # No .timer file needed — perfect for one-off delayed tasks
SYSTEMCTLREF
echo ""

# ==============================================================================

_section "SEGMENT 13.4 — PACKAGE MANAGEMENT AUTOMATION"

_pillar "BASIC: apt-get vs apt, DEBIAN_FRONTEND, dpkg checks (Bash-13.4.A–G)"

# [WHAT]: Source /etc/os-release to detect the current distro
# [WHY]:  Every portable bootstrap script starts here — no hardcoded distro assumptions
if [[ -f /etc/os-release ]]; then
  # [COMMAND MEANING] source = execute a file in the CURRENT shell context
  # [FLAG MEANING] . = POSIX alias for source
  # shellcheck source=/dev/null
  source /etc/os-release
  echo "  Detected OS: ${PRETTY_NAME:-unknown}"
  echo "  Distro ID:   ${ID:-unknown}"
  echo "  Version:     ${VERSION_ID:-unknown}"
else
  echo "  /etc/os-release not found — non-standard environment"
  ID="unknown"
fi
echo ""

# [WHAT]: Check if a specific package is installed — the correct pattern
is_package_installed() {
  local pkg="$1"
  # [COMMAND MEANING] dpkg = Debian Package manager
  # [FLAG MEANING] -s = status — show installation status; exits 1 if not installed
  dpkg -s "$pkg" &>/dev/null 2>&1 \
    && dpkg -s "$pkg" 2>/dev/null | grep -q "Status: install ok installed"
}

echo "  Package installation checks:"
for pkg in "bash" "coreutils" "definitely-not-installed-pkg-xyz"; do
  if is_package_installed "$pkg" 2>/dev/null; then
    echo "  ✓ $pkg — installed"
  else
    echo "  ✗ $pkg — NOT installed"
  fi
done
echo ""

_pillar "POWER: Portable install_packages() — cross-distro abstraction (Bash-13.4.M)"

# [WHAT]: The cross-distro package installer — detects the package manager
#         from /etc/os-release and calls the correct tool with the right flags.
# [WHY]:  A bootstrap script that only works on Ubuntu is not a production script.
#         This function works on Debian, Ubuntu, RHEL, CentOS, Fedora, and Alpine.

install_packages() {
  local packages=("$@")

  # Reload os-release if ID is not set
  [[ -z "${ID:-}" ]] && source /etc/os-release 2>/dev/null || true

  case "${ID:-unknown}" in
    ubuntu|debian|linuxmint)
      # [FLAG MEANING] DEBIAN_FRONTEND=noninteractive = suppress ALL interactive prompts
      # [FLAG MEANING] -y = auto-confirm all prompts
      # [FLAG MEANING] apt-get update = refresh package index FIRST
      log_info "apt-get: installing ${packages[*]}"
      DEBIAN_FRONTEND=noninteractive apt-get update -qq
      DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}"
      ;;
    rhel|centos|rocky|almalinux)
      # [COMMAND MEANING] yum = Yellowdog Updater Modified
      # [FLAG MEANING] -y = auto-confirm (same convention as apt-get)
      log_info "yum: installing ${packages[*]}"
      yum install -y "${packages[@]}"
      ;;
    fedora)
      # [COMMAND MEANING] dnf = Dandified YUM (yum replacement for Fedora/RHEL8+)
      log_info "dnf: installing ${packages[*]}"
      dnf install -y "${packages[@]}"
      ;;
    alpine)
      # [COMMAND MEANING] apk = Alpine Package Keeper
      # [FLAG MEANING] --no-cache = don't cache the index (smaller containers)
      log_info "apk: installing ${packages[*]}"
      apk add --no-cache "${packages[@]}"
      ;;
    *)
      die "Unsupported OS: ${ID:-unknown} — add it to install_packages()" 2
      ;;
  esac
}

echo "  install_packages() abstraction layer ready"
echo "  Usage: install_packages curl jq rsync"
echo "  Detected package manager for ${ID:-unknown}:"
case "${ID:-unknown}" in
  ubuntu|debian*)  echo "    → apt-get (with DEBIAN_FRONTEND=noninteractive)" ;;
  rhel|centos*)    echo "    → yum -y" ;;
  fedora)          echo "    → dnf -y" ;;
  alpine)          echo "    → apk add --no-cache" ;;
  *)               echo "    → UNSUPPORTED — extend the case statement" ;;
esac
echo ""

_pillar "PRECISION: rpm -q, dpkg -l pattern, dnf vs yum (Bash-13.4.H/I/J)"

echo "  RPM package query reference (Red Hat / CentOS / Fedora):"
cat << 'RPMREF'
  rpm -q bash
    → Query if 'bash' is installed — prints name-version-release or 'not installed'
    → Exit code 0 if installed, 1 if not. The dpkg -s equivalent for RPM systems.

  rpm -qa | grep "^nginx"
    → List ALL installed packages and grep for a pattern.
    → Use when you don't know the exact package name.

  yum install -y package     → RHEL/CentOS 7 and earlier
  dnf install -y package     → Fedora / RHEL 8+ (faster, better deps)
  dnf list installed         → List all installed packages (dnf equivalent of dpkg -l)

  dpkg -l "bash*"            → List all installed packages matching pattern
  dpkg -s bash | grep Status → Show full status — confirm 'install ok installed'
RPMREF
echo ""


# ==============================================================================
#  BASH ZERO-TO-HERO | CONTINUATION PATCH
#  Segments: 13.5 → 18.3 | Modules 13–18 | Toptal Elite Standard
#  PATCH PROTOCOL: Paste at the bottom of the existing code.sh
#  DO NOT add a new shebang, strict mode, or sandbox setup.
#  Reuses: WORKSPACE, _section(), _pillar(), log_info(), die()
# ==============================================================================

# ==============================================================================
# MODULE 13 (cont.) — PARSING /proc AND /sys
# ==============================================================================

_section "SEGMENT 13.5 — PARSING /proc AND /sys"

# ── No Mock Data Needed ───────────────────────────────────────────────────────
# [WHAT]: /proc and /sys are live kernel virtual filesystems — the kernel
#         generates their content on each read. No setup required.
# [WATCH OUT]: The /proc atomicity edge case (Bash-13.5.J) — always capture
#              a /proc file to a variable in ONE read; never read it twice
#              inside a decision block. Two reads may return different values.

_pillar "BASIC: CPU and memory metrics (Bash-13.5.A / 13.5.B)"

# [COMMAND MEANING] /proc/cpuinfo = CPU Information — virtual kernel file per-core
# [WHAT]: Extract the CPU model name without lscpu — no root required
# [WHY]:  Works inside a scratch Docker container where lscpu may be absent
echo "  CPU model (from /proc/cpuinfo):"
grep "model name" /proc/cpuinfo | head -1
echo ""

# [COMMAND MEANING] /proc/meminfo = Memory Information — virtual kernel file
# [WHAT]: Parse the four most operationally relevant memory fields with awk
# [WHY]:  A script that gates actions on memory thresholds (e.g. "only snapshot
#         if MemAvailable > 512 MB") uses this as the single authoritative source
echo "  Memory snapshot (awk-parsed from /proc/meminfo):"
awk '/^MemTotal:|^MemFree:|^MemAvailable:|^Buffers:|^Cached:/ {
  printf "    %-18s %s %s\n", $1, $2, $3
}' /proc/meminfo
echo ""

_pillar "POWER: Load average — atomicity in practice (Bash-13.5.C)"

# [COMMAND MEANING] /proc/loadavg = Load Average — five-field virtual file
# [WHAT]: Capture the entire file in ONE read to a variable, then parse the var
# [WATCH OUT]: This is the correct atomicity pattern. Reading /proc/loadavg
#              twice via two separate cat/read calls may return different values
#              because the kernel regenerates it on every access.
LOADAVG_SNAP=$(< /proc/loadavg)
read -r LOAD1 LOAD5 LOAD15 TASKS LASTPID <<< "$LOADAVG_SNAP"
echo "  Load averages  (1 / 5 / 15 min): $LOAD1  $LOAD5  $LOAD15"
echo "  Running / total tasks:            $TASKS"
echo "  Last PID spawned by kernel:       $LASTPID"
echo ""

_pillar "PRECISION: Per-process /proc entries (Bash-13.5.D / 13.5.E / 13.5.F)"

# [COMMAND MEANING] /proc/\$PID/status = Per-process status inode
# [WHAT]: Read memory and thread info for the current shell via /proc/$$/status
# [WHY]:  The no-tool equivalent of ps -p $$ — indispensable in minimal
#         containers where ps is not installed
echo "  /proc/\$\$/status — key fields for this shell (PID $$):"
awk '/^Name:|^State:|^VmRSS:|^Threads:|^Uid:|^Gid:/ {
  printf "    %-12s %s\n", $1, $2
}' /proc/$$/status
echo ""

# [COMMAND MEANING] /proc/\$PID/fd/ = File Descriptor directory — one symlink per open FD
# [WHAT]: Count open file descriptors by listing the /proc/$$/fd directory
# [WHY]:  An ever-growing count between two snapshots confirms an FD leak
#         without needing lsof
FD_COUNT=$(ls /proc/$$/fd | wc -l)
echo "  Open FD count for PID $$ (via /proc/\$\$/fd/): $FD_COUNT"
echo ""

# [COMMAND MEANING] /proc/\$PID/cmdline = Command line as NUL-separated bytes
# [WHAT]: Read the shell's own command line; convert NUL bytes to spaces with tr
# [WHY]:  More reliable than parsing ps — NUL-separated, no whitespace ambiguity
echo "  Command line (NUL→space conversion via tr):"
tr '\0' ' ' < /proc/$$/cmdline
echo ""
echo ""

_pillar "DEVOPS CONTEXT: Replacing netstat — /proc/net/tcp (Bash-13.5.G)"

# [COMMAND MEANING] /proc/net/tcp = TCP socket table — kernel's hex-encoded socket list
# [WHAT]: List LISTENING ports by parsing the kernel's TCP socket table
# [WHY]:  netstat is absent from hardened containers; /proc/net/tcp is always
#         present — the zero-dependency port enumeration method
# [WATCH OUT]: Addresses and ports are little-endian hex — awk converts port field
echo "  LISTENING TCP ports (from /proc/net/tcp — state 0A = LISTEN):"
awk 'NR>1 && $4=="0A" {
  split($2, addr, ":")
  port = strtonum("0x" addr[2])
  printf "    Port: %d\n", port
}' /proc/net/tcp 2>/dev/null | sort -t: -k2 -n | head -10 \
  || echo "    (no LISTEN entries or /proc/net/tcp not accessible in this sandbox)"
echo ""

_pillar "DEVOPS CONTEXT: /sys/class/net and /sys/block (Bash-13.5.H / 13.5.I)"

# [COMMAND MEANING] /sys/class/net/ = Network class sysfs — one subdir per interface
# [WHAT]: Read each interface's operational state with a single file read per loop
# [WHY]:  Reading one file per interface is faster than calling ip link in a loop
#         for a metrics collector polling 50 interfaces every second
echo "  Network interfaces (/sys/class/net/):"
for iface_dir in /sys/class/net/*/; do
  iface_name="${iface_dir%/}"
  iface_name="${iface_name##*/}"
  state=$(< "${iface_dir}operstate" 2>/dev/null || echo "unknown")
  printf "    %-12s  operstate: %s\n" "$iface_name" "$state"
done
echo ""

# [COMMAND MEANING] /sys/block/ = Block device sysfs — one subdir per block device
# [WHAT]: Read I/O counters from /sys/block/<dev>/stat — the iostat alternative
# [WHY]:  Available even when sysstat/iostat is not installed
echo "  Block device I/O stats (/sys/block/*/stat):"
FOUND_BLOCK=0
for dev_dir in /sys/block/*/; do
  dev_name="${dev_dir%/}"
  dev_name="${dev_name##*/}"
  # Skip loop and ram devices in the demo environment
  [[ "$dev_name" == loop* || "$dev_name" == ram* ]] && continue
  if [[ -r "${dev_dir}stat" ]]; then
    read -r reads _ _ _ writes _ _ _ _ _ _ < "${dev_dir}stat"
    printf "    %-10s  reads: %-8s  writes: %s\n" "$dev_name" "$reads" "$writes"
    FOUND_BLOCK=1
  fi
done
[[ $FOUND_BLOCK -eq 0 ]] && echo "    (no physical block devices visible in sandbox)"
echo ""

# ==============================================================================
# MODULE 14 — ADVANCED I/O: FILE DESCRIPTORS, FIFOs, AND IPC
# ==============================================================================

_section "SEGMENT 14.1 — FILE DESCRIPTOR INTERNALS"

_pillar "BASIC: Inspecting the live FD table (Bash-14.1.J / 14.1.K)"

# [COMMAND MEANING] /proc/self/fd = Self FD directory — symlinks for current process
# [WHAT]: Enumerate every FD this shell currently holds open with its kernel target
# [WHY]:  Confirms exact FD table state before and after exec redirections —
#         the gold standard for debugging "bad fd" or "too many open files" errors
echo "  /proc/self/fd — open descriptors for this shell:"
for fd_path in /proc/self/fd/*; do
  fd_num="${fd_path##*/}"
  # [COMMAND MEANING] readlink = Read Link — print the target of a symbolic link
  target=$(readlink "$fd_path" 2>/dev/null || echo "(unreadable)")
  printf "    FD %-3s → %s\n" "$fd_num" "$target"
done
echo ""

_pillar "POWER: ulimit and system-wide limits (Bash-14.1.L / 14.1.M)"

# [WHAT]: Report the soft FD limit — the per-shell ceiling on open file descriptors
# [WHY]:  Scripts with 100+ background jobs will silently fail with "too many open
#         files" at the default 1024 limit — always inspect and raise before spawning
echo "  Current shell FD soft limit: $(ulimit -n)"
echo "  Raising to 4096 for this session:"
# [FLAG MEANING] -n = number — set the open file descriptor limit
ulimit -n 4096
echo "  New FD soft limit: $(ulimit -n)"
echo ""

# [COMMAND MEANING] /proc/sys/fs/file-max = System-wide kernel FD ceiling
# [WHAT]: The hard upper bound across ALL processes on the entire system
# [WHY]:  Raising ulimit -n above file-max silently fails — always check both
echo "  Kernel-wide FD ceiling (/proc/sys/fs/file-max):"
cat /proc/sys/fs/file-max
echo "  (raise with: sysctl -w fs.file-max=1048576)"
echo ""

_pillar "PRECISION: FD duplication — >&  demystified (Bash-14.1.D / 14.1.E / 14.1.F)"

# [WHAT]: Walk through dup2() semantics hands-on using Bash FD redirects
# [WHY]:  This exercise is the definitive explanation for why
#         >file 2>&1 and 2>&1 >file behave differently

# Step 1: Save stdout to FD 3 — dup2(1, 3) in kernel terms
exec 3>&1
echo "  FD 3 is now a duplicate of stdout (dup2(1,3) via exec 3>&\1)"

# Step 2: Redirect stdout to a file — FD 3 still points at the terminal
FD_CAPTURE="$WORKSPACE/fd_demo_output.txt"
exec 1>"$FD_CAPTURE"
echo "  This line is captured to the FILE (stdout redirected)"
echo "  So is this line — FD 3 is untouched"

# Step 3: Restore stdout from FD 3
exec 1>&3
exec 3>&-   # close FD 3

echo "  Stdout restored from FD 3 — you see this on the terminal."
echo "  Captured file content:"
cat "$FD_CAPTURE"
echo ""

echo "  THE ORDERING LESSON:"
echo "    Correct:  >file 2>&1   → stdout→file, then stderr→(same file entry)   ✓"
echo "    Trap:     2>&1 >file   → stderr→(old stdout=terminal), stdout→file     ✗"
echo ""

_pillar "DEVOPS CONTEXT: FD inheritance, O_CLOEXEC, and leak prevention (Bash-14.1.G/H/I)"

echo "  FD lifecycle across fork() and exec():"
cat << 'FDLEAK'
  fork():   child gets an exact copy of the parent's FD table
            → every open FD is open in both parent AND child
            → both share the same open-file-table entry (same file offset)

  exec():   FDs survive exec() BY DEFAULT — Bash scripts that exec a
            child process hand all their open FDs to it
            → FDs marked O_CLOEXEC are automatically closed on exec()

  In Bash (Bash-14.1.I — O_CLOEXEC):
    exec N>file      → opens FD N WITHOUT O_CLOEXEC
                     → children inherit FD N — potential leak
    {fd}>file        → opens FD with O_CLOEXEC (Bash 4.1+)
                     → children do NOT inherit it — safe

  Production leak pattern:
    exec 5>>"$LOG_FILE"      # opened in parent
    do_heavy_work &          # child inherits FD 5
    exec 5>&-                # MUST close before spawning children
                             # otherwise log rotation can't reclaim the inode
FDLEAK
echo ""

# ==============================================================================

_section "SEGMENT 14.2 — NAMED PIPES (FIFOs)"

_pillar "BASIC: Create and use a FIFO (Bash-14.2.A / 14.2.C / 14.2.D)"

# [WHAT]: Create a named pipe in the workspace
FIFO_BASIC="$WORKSPACE/basic.pipe"
# [FLAG MEANING] mkfifo = Make FIFO — creates a named pipe as a filesystem entry
mkfifo "$FIFO_BASIC"
echo "  Created FIFO: $FIFO_BASIC"
file "$FIFO_BASIC"
echo ""

# [WHAT]: Write to the FIFO from a backgrounded subshell, then read in the foreground
# [WATCH OUT]: The trailing & is MANDATORY. Without it, the writer blocks at open()
#              waiting for a reader that has not been started yet — guaranteed deadlock.
echo "  Sending 'hello from the pipe' through the FIFO:"
echo "  hello from the pipe" > "$FIFO_BASIC" &
FIFO_WRITER=$!
IFS= read -r FIFO_LINE < "$FIFO_BASIC"
wait "$FIFO_WRITER"
echo "  Reader received: '$FIFO_LINE'"
echo ""

_pillar "POWER: Deadlock anatomy (Bash-14.2.B / 14.2.E)"

echo "  FIFO open() blocking semantics:"
cat << 'DEADLOCK'
  The kernel's open() on a FIFO BLOCKS until BOTH sides connect:
    • writer calls open() → blocked if no reader present yet
    • reader calls open() → blocked if no writer present yet

  Safe patterns:
    ① Background the writer:
        echo data > fifo &     ← writer blocked until reader opens
        read line  < fifo      ← reader opens, unblocks the writer

    ② Background the reader:
        read line  < fifo &    ← reader blocked until writer opens
        echo data  > fifo      ← writer opens, unblocks the reader

    ③ Open read-write (skips the blocking rendezvous entirely):
        exec 3<> fifo          ← O_RDWR bypasses blocking semantics
        echo data >&3
        read line  <&3
        exec 3>&-

  DEADLOCK (never do this in a sequential script):
    echo data > fifo           ← line 1: writer opens — blocks (no reader)
    read line  < fifo          ← line 2: never reached — both sides stuck
DEADLOCK
echo ""

_pillar "PRECISION: FIFO lifecycle — EXIT trap cleanup (Bash-14.2.G)"

echo "  Production FIFO cleanup pattern:"
cat << 'FIFOCLEAN'
  # FIFOs inside \$WORKSPACE are cleaned by the existing EXIT trap.
  # FIFOs in /tmp need their OWN explicit trap entry:

  FIFO=/tmp/myscript-ipc.$$
  mkfifo "\$FIFO"
  trap 'rm -f "\$FIFO"' EXIT
  # ↑ Ensures the FIFO is removed even on SIGTERM, SIGINT, or ERR.
  # A stale FIFO blocks the NEXT run of the script at open() indefinitely —
  # the process hangs with no error message, which looks like a hung deploy.
FIFOCLEAN
echo ""

_pillar "DEVOPS CONTEXT: Two-FIFO request/response IPC (Bash-14.2.F / 14.3.B)"

# [WHAT]: Bidirectional IPC without sockets — two FIFOs form a full-duplex channel
# [WHY]:  The canonical shell IPC pattern when socat/nc is unavailable and you
#         need synchronous request/response between two independent processes
REQ_FIFO="$WORKSPACE/req.pipe"
RES_FIFO="$WORKSPACE/res.pipe"
mkfifo "$REQ_FIFO" "$RES_FIFO"

# Server process: reads from REQ_FIFO, writes to RES_FIFO
(
  IFS= read -r request < "$REQ_FIFO"
  echo "  [SERVER PID $$] Received request: '$request'"
  echo "ACK:${request^^}" > "$RES_FIFO"
) &
SERVER_PID=$!

# Client: writes request, awaits response
echo "DEPLOY:v2.4.1" > "$REQ_FIFO"
IFS= read -r server_response < "$RES_FIFO"
echo "  [CLIENT] Got server response: '$server_response'"
wait "$SERVER_PID"
echo ""

# ==============================================================================

_section "SEGMENT 14.3 — IPC PATTERNS & SEGMENT 14.4 — HERE-DOC PIPE IPC"

_pillar "BASIC: Producer/consumer FIFO pipeline (Bash-14.3.A)"

# [WHAT]: Classic producer/consumer — producer fills the pipe with records;
#         consumer reads and processes each one as it arrives
# [WHY]:  Decouples production rate from consumption rate using the kernel's
#         pipe buffer (typically 64 KB) as a natural queue
WORK_FIFO="$WORKSPACE/work.pipe"
mkfifo "$WORK_FIFO"

(
  for job_id in deploy_api deploy_worker deploy_scheduler deploy_gateway deploy_health; do
    echo "$job_id"
  done
) > "$WORK_FIFO" &
PRODUCER_PID=$!

echo "  Producer → Consumer pipeline:"
while IFS= read -r job_name; do
  printf "    [WORKER] Processing: %s\n" "$job_name"
done < "$WORK_FIFO"
wait "$PRODUCER_PID"
echo ""

_pillar "POWER: Coprocess IPC — persistent bidirectional channel (Bash-14.3.C)"

# [COMMAND MEANING] coproc = Coprocess — starts a background process with
#                   two anonymous pipes (stdin and stdout) connected back to the parent
# [WHAT]: Keep a single bc process alive for the entire loop — one fork, many uses
# [WHY]:  Every $(echo "2^10" | bc) forks a new bc process (fork+exec+exit).
#         With coproc, one bc process handles all expressions — 10x less overhead
#         for scripts that need repeated arithmetic via an external tool
coproc BC_COPROC { bc -l 2>/dev/null; }

echo "  Coprocess demo — persistent bc -l (one fork, many queries):"
for math_expr in "2^10" "sqrt(144)" "3.14159 * 6.2832" "e(1)"; do
  # [FLAG MEANING] >&"${BC_COPROC[1]}" = write to coprocess stdin (FD index 1 = write end)
  printf '%s\n' "$math_expr" >&"${BC_COPROC[1]}"
  # [FLAG MEANING] -u "${BC_COPROC[0]}" = read from coprocess stdout (FD index 0 = read end)
  IFS= read -r bc_result -u "${BC_COPROC[0]}"
  printf "    %-25s = %s\n" "$math_expr" "$bc_result"
done
# Gracefully close the coprocess's stdin — bc sees EOF and exits cleanly
exec "${BC_COPROC[1]}">&-
wait "${BC_COPROC_PID}" 2>/dev/null || true
echo ""

_pillar "POWER: Here-doc to stdin — multi-line IPC without temp files (Bash-14.4.A)"

# [WHAT]: Feed multiple lines to a command's stdin inline via a here-doc
# [WHY]:  Cleaner than echo "line1\nline2" (which relies on -e); no temp file;
#         the kernel handles the buffering entirely in memory
echo "  Here-doc → command stdin:"
sort << 'HEREDATA'
  zebra
  apple
  mango
  banana
  cherry
HEREDATA
echo ""

_pillar "POWER: Persistent log tail on FD — read -t -u polling (Bash-14.4.C / 14.4.D)"

# [WHAT]: Open a persistent tail -f on a log file via process substitution into FD 5
# [WHY]:  A monitoring loop that calls tail in every iteration forks a new process
#         each time. Holding tail -f on an FD and using read -t to poll it is
#         orders of magnitude cheaper for high-frequency monitoring scripts.
LOG_DEMO="$WORKSPACE/app.log"
for entry_num in {1..8}; do
  printf '%s [INFO] event_%d fired\n' "$(date +%T)" "$entry_num" >> "$LOG_DEMO"
done

# Open FD 5 as a persistent reader on tail -f (process substitution)
exec 5< <(tail -f "$LOG_DEMO" 2>/dev/null)

echo "  Polling log via FD 5 with read -t 1 -u 5:"
LINES_POLLED=0
while [[ $LINES_POLLED -lt 8 ]]; do
  # [FLAG MEANING] -t 1 = timeout after 1 second — non-blocking poll; exits 1 on timeout
  # [FLAG MEANING] -u 5 = read from FD 5 instead of stdin (FD 0)
  if IFS= read -t 1 -u 5 polled_line; then
    printf "    %s\n" "$polled_line"
    (( LINES_POLLED++ )) || true
  fi
done
exec 5>&-   # close the persistent FD — releases tail -f
echo ""

_pillar "PRECISION: Multi-FD polling loop (Bash-14.4.E)"

echo "  Multi-FD polling pattern (two independent streams):"

cat << 'MULTIFD'
  # Open two independent input streams on FD 3 and FD 4:
  exec 3< <(tail -f /var/log/nginx/access.log)
  exec 4< <(tail -f /var/log/nginx/error.log)

  while true; do
    # Poll access log — 1 second timeout
    if IFS= read -t 1 -u 3 access_line; then
      parse_access "$access_line"
    fi
    # Poll error log — 1 second timeout (neither blocks the other)
    if IFS= read -t 1 -u 4 error_line; then
      alert_on_error "$error_line"
    fi
  done

  # Neither read blocks the other — the loop progresses after 1 s of silence
  # on each channel. Total latency: at most 2 s per cycle.
MULTIFD

echo ""

_pillar "DEVOPS CONTEXT: SIGUSR1/USR2 signal-based daemon notifications (Bash-14.3.G / 14.3.H)"

# [WHAT]: Demonstrate signal-based IPC — the standard way to trigger live
#         actions in a running daemon without restarting it
echo "  Signal-based IPC — SIGUSR1 (log rotate) / SIGUSR2 (dump stats):"

(
  ROTATION_COUNT=0
  # [FLAG MEANING] -USR1 = SIGUSR1 = User-Defined Signal 1 (conventionally: rotate logs)
  trap '(( ROTATION_COUNT++ )) || true
        printf "  [DAEMON %d] SIGUSR1 → log rotation #%d triggered\n" "$$" "$ROTATION_COUNT"' \
    SIGUSR1
  # [FLAG MEANING] -USR2 = SIGUSR2 = User-Defined Signal 2 (conventionally: dump stats)
  trap 'printf "  [DAEMON %d] SIGUSR2 → stats dump (rotations=%d)\n" "$$" "$ROTATION_COUNT"
        exit 0' \
    SIGUSR2
  # Idle loop — a real daemon would service requests here
  for _ in {1..10}; do sleep 0.15; done
) &
DAEMON_PID=$!

sleep 0.1
kill -USR1 "$DAEMON_PID"
sleep 0.1
kill -USR1 "$DAEMON_PID"
sleep 0.1
kill -USR2 "$DAEMON_PID"   # triggers stats dump and exit
wait "$DAEMON_PID" 2>/dev/null || true
echo ""

# ==============================================================================
# MODULE 15 — NETWORKING AND REMOTE EXECUTION
# ==============================================================================

_section "SEGMENT 15.1 — SSH AUTOMATION"

_pillar "BASIC: BatchMode, StrictHostKeyChecking, remote command (Bash-15.1.A/B/C/G)"

echo "  SSH automation flag reference:"
cat << 'SSHBASIC'
  # BatchMode=yes — fail immediately if a password or host-key prompt would appear:
  ssh -o BatchMode=yes user@host 'hostname'
  # Exit code 255 on auth failure — caught cleanly by set -e

  # StrictHostKeyChecking=accept-new — SAFE automation default:
  ssh -o StrictHostKeyChecking=accept-new user@host 'hostname'
  # Accepts NEW host keys silently; REJECTS changed keys (blocks MITM attacks)

  # NEVER use in production (accepts changed keys = silent MITM):
  # ssh -o StrictHostKeyChecking=no user@host 'cmd'

  # Single quoted remote command (single quotes = no LOCAL expansion):
  ssh user@host 'echo "hostname=$(hostname), date=$(date)"'
  # Remote bash evaluates $(hostname) and $(date) — not the local shell

  # Stream a LOCAL script to remote bash — zero file transfer:
  ssh user@host 'bash -s' < ./deploy.sh
  # The script runs in the remote shell's memory — never written to the remote disk

  # Heredoc multi-command block to remote bash (quoted = no local expansion):
  ssh user@host 'bash -s' << 'REMOTE'
    systemctl restart nginx
    nginx -t && echo "Config valid"
    systemctl is-active nginx
  REMOTE
SSHBASIC
echo ""

_pillar "POWER: SSH multiplexing — ControlMaster (Bash-15.1.D / 15.1.E / 15.1.F)"

echo "  SSH multiplexing config (~/.ssh/config):"
cat << 'MUXCONF'
  Host prod-*
    ControlMaster    auto          # 1st conn creates master socket; subsequent reuse it
    ControlPath      ~/.ssh/ctl/%h # One socket file per host (%h = hostname macro)
    ControlPersist   10m           # Keep master alive 10 min after last client exits
    BatchMode        yes           # Mandatory for automation — no interactive prompts

  # Performance impact:
  #   Without mux: each ssh call = ~300ms TLS handshake + key exchange
  #   With mux:    subsequent calls = ~2ms reconnect to existing socket
  #   A deploy loop hitting 20 servers saves ~6 seconds per loop iteration

  # Gotcha: if the master socket crashes, ALL mux clients fail simultaneously
  # Safety net: ssh -o ControlMaster=no user@host 'probe' as a health check
MUXCONF
echo ""

_pillar "PRECISION: Port forwarding cheat-sheet (Bash-15.1.J / 15.1.K / 15.1.L)"

echo "  SSH tunnel patterns:"
cat << 'TUNNELS'
  ┌─ Local Forward (-L) ────────────────────────────────────────────────────────┐
  │  ssh -L 5432:db.internal:5432 bastion-host                                 │
  │  localhost:5432 → [SSH tunnel through bastion] → db.internal:5432          │
  │  USE CASE: reach a private database through a bastion host                  │
  └──────────────────────────────────────────────────────────────────────────────┘

  ┌─ Remote Forward (-R) ───────────────────────────────────────────────────────┐
  │  ssh -R 8080:localhost:3000 public-server                                   │
  │  public-server:8080 → [tunnel back] → localhost:3000                        │
  │  USE CASE: expose a local dev service through a public-facing EC2 instance  │
  └──────────────────────────────────────────────────────────────────────────────┘

  ┌─ Dynamic SOCKS Proxy (-D) ──────────────────────────────────────────────────┐
  │  ssh -D 1080 gateway-host                                                   │
  │  localhost:1080 = SOCKS5 proxy exit node through gateway-host               │
  │  USE CASE: route curl/wget through the remote network segment               │
  │  curl --proxy socks5h://localhost:1080 http://internal-service/health       │
  └──────────────────────────────────────────────────────────────────────────────┘
TUNNELS
echo ""

_pillar "DEVOPS CONTEXT: Key generation and provisioning (Bash-15.1.M / 15.1.N)"

echo "  Automation key provisioning pattern:"
cat << 'KEYSETUP'
  # Generate a dedicated deploy key — Ed25519, no passphrase (automation requires it):
  ssh-keygen -t ed25519 -C "deploy-bot@ci-$(date +%Y%m%d)" \
             -f ~/.ssh/deploy_ed25519 \
             -N ""
  # -t ed25519     : modern curve — faster and smaller than RSA-4096
  # -C "comment"   : embed purpose and date for key rotation tracking
  # -N ""          : empty passphrase — mandatory for unattended scripts

  # Distribute public key to target hosts:
  ssh-copy-id -i ~/.ssh/deploy_ed25519.pub deploy@prod-01
  # Appends to ~/.ssh/authorized_keys on remote — idempotent (safe to re-run)

  # Harden the authorized_keys entry (restrict the key's capabilities):
  # command="/usr/local/bin/deploy.sh",no-pty,no-agent-forwarding,
  # no-port-forwarding,no-X11-forwarding ssh-ed25519 AAAA... deploy-bot@ci
  # → Key can ONLY execute deploy.sh — arbitrary shell access is denied
KEYSETUP
echo ""

# ==============================================================================

_section "SEGMENT 15.2 — scp AND rsync"

_pillar "BASIC: scp vs rsync — the decision matrix (Bash-15.2.A / 15.2.B)"

echo "  scp vs rsync:"
cat << 'SCPVSRSYNC'
  scp src user@host:dst
    ✓ Simple one-off copy; no extra setup
    ✗ Full copy every time — no delta transfer
    ✗ Cannot resume after interruption
    ✗ Slow on many small files (one round-trip per file)
    ✗ Deprecated in OpenSSH 9+ (replaced internally by sftp)

  rsync -avz --progress src/ user@host:/dst/
    ✓ Delta transfer — sends only changed blocks (rsync algorithm)
    ✓ Resumes interrupted transfers automatically
    ✓ Preserves: permissions, symlinks, timestamps, ownership (-a = archive)
    ✓ Compresses in-transit (-z = gzip)
    ✓ Human-readable progress bar (--progress)
    → Use rsync for ALL production file sync operations
SCPVSRSYNC
echo ""

_pillar "POWER: rsync production flags (Bash-15.2.C/D/E/F/G)"

echo "  Production rsync invocations:"
cat << 'RSYNCPROD'
  # ALWAYS dry-run before --delete:
  rsync --dry-run --delete -avz src/ user@host:/dst/
  # --dry-run: simulate only — print what WOULD change without touching anything
  # --delete:  delete files on dst not present in src — MIRROR MODE
  # ↑ NEVER run --delete without --dry-run first to review the deletion list

  # Integrity-based sync (ignore timestamps — compare checksums):
  rsync --checksum -avz src/ user@host:/dst/
  # --checksum: compute MD5 for each file pair; send only truly changed content
  # Use on: NFS mounts, FAT32, exFAT, or any filesystem with unreliable mtime

  # Custom SSH port or key:
  rsync -e 'ssh -p 2222 -i ~/.ssh/deploy_ed25519' -avz src/ user@host:/dst/
  # -e 'ssh ...': override the entire SSH command used for transport

  # Throttle bandwidth during business hours:
  rsync --bwlimit=2048 -avz src/ user@host:/dst/
  # --bwlimit=2048: cap at 2 MB/s — prevents saturating a shared production link
RSYNCPROD
echo ""

# ==============================================================================

_section "SEGMENT 15.3 — curl FOR HTTP APIs"

_pillar "BASIC: Silent health-check and --fail (Bash-15.3.A / 15.3.B / 15.3.L)"

# [COMMAND MEANING] curl = Client URL — multi-protocol data transfer tool
# [WHAT]: The canonical health-check pattern — returns only the HTTP status code
# [WATCH OUT]: Without -f, curl exits 0 on 404 or 500. set -e will NOT catch it.
#              -f is MANDATORY whenever curl is used inside set -e scripts.
echo "  Health-check pattern (reference — network disabled in sandbox):"
cat << 'CURLHC'
  HTTP_CODE=$(curl \
    -s \
    -o /dev/null \
    -w "%{http_code}" \
    -f \
    --connect-timeout 5 \
    --max-time 15 \
    "https://api.example.com/health")
  # -s                  : silent — suppress progress meter and error messages
  # -o /dev/null        : discard the response body entirely
  # -w "%{http_code}"   : write ONLY the HTTP status code to stdout
  # -f (--fail)         : exit non-zero on HTTP 4xx/5xx — REQUIRED for set -e
  # --connect-timeout 5 : abort TCP connection attempt after 5 seconds
  # --max-time 15       : abort the ENTIRE transfer (including download) after 15 s

  [[ "$HTTP_CODE" == "200" ]] || { echo "Unhealthy: HTTP $HTTP_CODE" >&2; exit 1; }
CURLHC
echo ""

_pillar "POWER: Retry, auth, and POST JSON (Bash-15.3.C/D/E/F/G/H/I)"

echo "  Production curl with retry + bearer auth:"
cat << 'CURLPROD'
  # Resilient API call for CI/CD pipelines:
  curl \
    -f \
    -s \
    --retry 3 \
    --retry-delay 2 \
    --connect-timeout 5 \
    --max-time 30 \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    "https://api.example.com/v1/deployments"
  # --retry 3             : retry up to 3 times on transient network failures
  # --retry-delay 2       : wait 2 seconds between retry attempts
  # -H "Authorization..." : API_TOKEN from a variable — NEVER a literal in code
  #   [WATCH OUT]: Do NOT use --header=Authorization:token — it appears in ps aux!
  #                Use -H from a variable; the value stays in curl's memory only.

  # POST JSON payload:
  curl -f -s \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"event":"deploy","version":"2.4.1","env":"prod"}' \
    "https://hooks.example.com/webhook"
  # -X POST: set the HTTP method
  # -d '...': request body — always pair with Content-Type: application/json
CURLPROD
echo ""

_pillar "PRECISION: Save response + curl | jq pipeline (Bash-15.3.J / 15.3.K)"

echo "  Save response to file and pipe into jq:"
cat << 'CURLJQ'
  # Save response body to a file (combine -o with -f!):
  curl -f -s -o /tmp/api_response.json --max-time 15 \
    "https://api.example.com/v1/status"
  # [WATCH OUT]: Without -f, a 404 body is silently written to the file.
  #              The file looks like a valid API response but contains an error page.

  # The canonical API-to-variable pipeline:
  DEPLOY_TAG=$(
    curl -f -s \
      -H "Authorization: Bearer $TOKEN" \
      "https://registry.example.com/api/latest" \
    | jq -r '.release.tag'
  )
  echo "Deploying: $DEPLOY_TAG"
CURLJQ
echo ""

# ==============================================================================

_section "SEGMENT 15.4 — jq FOR JSON PROCESSING"

_pillar "BASIC: Field extraction and array filtering (Bash-15.4.A/B/C/E)"

# [COMMAND MEANING] jq = JSON Query — the standard command-line JSON processor
# [WHAT]: Build mock JSON data for all jq exercises
JSON_DATA="$WORKSPACE/services.json"
cat > "$JSON_DATA" << 'JSONMOCK'
{
  "cluster": "prod-us-east-1",
  "services": [
    {"name": "api-gateway",   "status": "active",  "replicas": 3, "version": "2.1.0"},
    {"name": "auth-service",  "status": "active",  "replicas": 2, "version": "1.9.3"},
    {"name": "worker",        "status": "stopped", "replicas": 0, "version": "1.8.1"},
    {"name": "scheduler",     "status": "active",  "replicas": 1, "version": "2.0.0"},
    {"name": "legacy-notifs", "status": "stopped", "replicas": 0, "version": "0.9.9"}
  ],
  "metadata": {"owner": "platform-team", "env": "production", "region": "us-east-1"}
}
JSONMOCK

echo "  1. Top-level scalar (.cluster):"
# [FLAG MEANING] -r = raw output — strip surrounding JSON quotes from string values
jq -r '.cluster' "$JSON_DATA"
echo ""

echo "  2. Nested field (.metadata.owner):"
jq -r '.metadata.owner' "$JSON_DATA"
echo ""

echo "  3. Array index (.services[0].name):"
jq -r '.services[0].name' "$JSON_DATA"
echo ""

echo "  4. Filter array — active services only (.[] | select()):"
# [WHAT]: .[] iterates ALL elements; select() keeps only those where condition is true
jq -r '.services[] | select(.status == "active") | .name' "$JSON_DATA"
echo ""

_pillar "POWER: Injection-safe construction and shell loop iteration (Bash-15.4.D/F/G/H/I)"

echo "  5. Build JSON from shell variables safely (--arg injection guard):"
SVC="new-canary"
ENV="staging"
# [FLAG MEANING] -n = null input — don't read stdin as JSON; start from null
# [FLAG MEANING] --arg key val = inject shell variable as a typed jq STRING
#                               (it is NOT evaluated as jq code — injection-safe)
jq -n --arg svc_name "$SVC" --arg env_name "$ENV" \
   '{"service": $svc_name, "environment": $env_name, "deployed_at": (now | todate)}'
echo ""

echo "  6. Iterate jq array in the CURRENT shell (no subshell trap):"
# [WHAT]: Process substitution < <(jq ...) keeps while in the CURRENT shell.
#         If you pipe: jq ... | while read — the loop runs in a SUBSHELL and
#         variables set inside the loop are LOST when the loop ends.
# [FLAG MEANING] -c = compact — one JSON object per line (required for safe iteration)
ACTIVE_SVC_COUNT=0
while IFS= read -r svc_json; do
  svc_name=$(jq -r '.name'    <<< "$svc_json")
  svc_ver=$(jq  -r '.version' <<< "$svc_json")
  printf "    %-16s version: %s\n" "$svc_name" "$svc_ver"
  (( ACTIVE_SVC_COUNT++ )) || true
done < <(jq -c '.services[] | select(.status == "active")' "$JSON_DATA")
echo "  Total active (variable survived loop): $ACTIVE_SVC_COUNT"
echo ""

echo "  7. --argjson — inject a shell value as raw JSON (number, not string):"
MIN_REPLICAS=2
# [FLAG MEANING] --argjson key val = inject as raw JSON — number/bool/object
#                (use --arg for strings; --argjson for everything else)
jq -r --argjson min_r "$MIN_REPLICAS" \
   '.services[] | select(.replicas >= $min_r) | "\(.name): \(.replicas) replicas"' \
   "$JSON_DATA"
echo ""

_pillar "PRECISION: to_entries, del, and combined curl | jq (Bash-15.4.K/L/J)"

echo "  8. to_entries — iterate an object with UNKNOWN key names:"
# [WHAT]: Converts {k1:v1, k2:v2} → [{key:k1,value:v1}, {key:k2,value:v2}]
# [WHY]:  When key names are dynamic (e.g. from an API response) — you can't
#         hardcode .field; you need to iterate all key/value pairs
jq -r '.metadata | to_entries[] | "\(.key): \(.value)"' "$JSON_DATA"
echo ""

echo "  9. del — remove a field before forwarding a payload:"
# [WHAT]: Strip the 'metadata' key — sanitise API payloads before logging
jq 'del(.metadata)' "$JSON_DATA"
echo ""

echo "  10. Full pipeline pattern (curl | jq — reference):"
cat << 'PIPELINE'
  # Extract a field from a live API response:
  ACTIVE_COUNT=$(
    curl -f -s \
      -H "Authorization: Bearer $TOKEN" \
      "https://registry.example.com/api/services" \
    | jq '[.services[] | select(.status == "active")] | length'
  )
  echo "Active services: $ACTIVE_COUNT"
PIPELINE
echo ""

# ==============================================================================
# MODULE 16 — SECURITY HARDENING AND SECURE SCRIPTING
# ==============================================================================

_section "SEGMENT 16.1 — COMMAND INJECTION AND INPUT VALIDATION"

_pillar "BASIC: eval is a loaded gun (Bash-16.1.A / 16.1.B / 16.1.C)"

echo "  eval + user input = arbitrary code execution:"
cat << 'EVALWARN'
  # DANGEROUS — if user controls any part of the eval argument:
  user_input="; rm -rf /critical/data #"
  eval "config_${user_input}"   # ← executes: rm -rf /critical/data — data gone

  # SAFE ALTERNATIVE 1: Arrays preserve word boundaries without eval:
  cmd_args=("--output" "file with spaces.txt" "--verbose")
  mytool "${cmd_args[@]}"        # ← word-safe; no shell code execution

  # SAFE ALTERNATIVE 2: declare -n (nameref) for indirect variable access:
  target_var_name="DB_HOST"
  declare -n target_ref="$target_var_name"
  echo "$target_ref"             # ← reads the value of $DB_HOST safely; no eval

  # SAFE ALTERNATIVE 3: ${!varname} indirect expansion (Bash, no nameref needed):
  echo "${!target_var_name}"     # ← equivalent; available since Bash 2.0
EVALWARN
echo ""

_pillar "POWER: Whitelist validation — the only reliable input defence (Bash-16.1.D/E)"

# [WHAT]: A reusable input validation function using whitelist regex
# [WHY]:  Blacklisting (blocking ; | & $ ...) always has undiscovered gaps.
#         Whitelisting (allow ONLY known-safe characters) has ZERO gaps.
validate_identifier() {
  local input="$1"
  # Accept ONLY alphanumeric, underscore, hyphen — nothing else can pass
  [[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]]
}

echo "  Whitelist validation demo:"
PASS_LIST=("valid-name" "api_v2" "service-01" "ok123")
FAIL_LIST=("'; DROP TABLE users--" "../../../etc/shadow" "\$(id)" "name with space" "")

for t in "${PASS_LIST[@]}"; do
  validate_identifier "$t" \
    && printf "    [PASS] %-30s ✓\n" "'$t'" \
    || printf "    [FAIL] %-30s ✗ (unexpected)\n" "'$t'"
done

for t in "${FAIL_LIST[@]}"; do
  validate_identifier "$t" \
    && printf "    [PASS] %-30s ✗ (should have failed!)\n" "'$t'" \
    || printf "    [BLOCK]%-30s ✓ injection blocked\n" "'$t'"
done
echo ""

_pillar "PRECISION: The -- separator and quoted filenames (Bash-16.1.E / 16.1.F)"

# [WHAT]: Demonstrate the -- end-of-options separator for hyphen-prefixed filenames
HYPHEN_DIR="$WORKSPACE/hyphen_test"
mkdir -p "$HYPHEN_DIR"
touch "$HYPHEN_DIR/-evil-filename"
touch "$HYPHEN_DIR/normal.txt"

echo "  Files including the hyphen-prefixed trap:"
ls -la "$HYPHEN_DIR/"
echo ""

echo "  Safe removal with rm -- (end-of-options separator):"
# [FLAG MEANING] -- = end of flags — everything after is treated as a filename
rm -- "$HYPHEN_DIR"/*
ls "$HYPHEN_DIR/" 2>/dev/null \
  && echo "  (files remain)" \
  || echo "  (directory empty — both files removed safely)"
echo ""

echo "  find -exec injection guard:"
cat << 'FINDGUARD'
  # DANGEROUS: eval path is injected into sh -c string
  find /logs -name "*.log" -exec sh -c "grep $PATTERN {}" \;
  # If $PATTERN = '; rm -rf /' — executes the rm

  # SAFE: pass pattern as a separate argument to sh -c; {} is never eval'd
  find /logs -name "*.log" -exec sh -c 'grep "$1" "$2"' _ "$PATTERN" {} \;
  # $1 = $PATTERN (a separate argv slot — not shell code)
  # $2 = the filename from find (also a separate argv slot)
FINDGUARD
echo ""

# ==============================================================================

_section "SEGMENT 16.2 — CREDENTIAL MANAGEMENT"

_pillar "BASIC: Secret exposure vectors (Bash-16.2.A / 16.2.B / 16.2.C)"

echo "  Where secrets leak — never do these:"
cat << 'SECRETLEAK'
  # ❌ Environment variables — visible in /proc/PID/environ (same UID can read):
  export DB_PASS="s3cret"
  # cat /proc/$$/environ | tr '\0' '\n' | grep DB_PASS  ← any same-UID process sees it

  # ❌ Command-line arguments — visible in ps aux and /proc/PID/cmdline (ALL users):
  mysql -u root -ps3cret                        # appears in ps aux output
  curl -H "Authorization: Bearer s3cret" URL    # also in ps aux!
  # Even short-lived processes have a race window where ps captures them

  # ❌ Hardcoded in the script — committed to git → secret lives in history forever:
  API_KEY="hardcoded-secret-9f3b"

  # ✓ CORRECT: Read from a permission-locked file into a shell variable:
  IFS= read -r DB_PASS < /run/secrets/db_password
  # The file path is visible; the file CONTENT never appears in ps, env, or argv
  # The variable DB_PASS lives in shell memory only
SECRETLEAK
echo ""

_pillar "POWER: read -rs and file-based secrets (Bash-16.2.D / 16.2.E / 16.2.I)"

# [WHAT]: Demonstrate the file-based secret pattern in the sandbox
SECRET_FILE="$WORKSPACE/mock_secret"
printf 'super-secret-token-9f3b2a1c\n' > "$SECRET_FILE"
chmod 600 "$SECRET_FILE"

echo "  Secret file permissions:"
ls -la "$SECRET_FILE"
echo ""

echo "  Reading secret from file (no exec args, no environment):"
# [FLAG MEANING] -r = raw — do NOT interpret backslash escape sequences in input
IFS= read -r LOADED_SECRET < "$SECRET_FILE"
echo "  Loaded. Length: ${#LOADED_SECRET} chars | Preview: ${LOADED_SECRET:0:4}****"
echo ""

echo "  [WATCH OUT]: /proc/PID/environ exposure demo:"
# Show that the LOADED_SECRET variable IS readable from /proc/self/environ
# if exported — this is exactly why you should NOT export secret variables
export EXPOSED_FOR_DEMO="visible-secret"
echo "  After export EXPOSED_FOR_DEMO — visible in /proc/self/environ:"
tr '\0' '\n' < /proc/self/environ | grep EXPOSED_FOR_DEMO
unset EXPOSED_FOR_DEMO   # clean up immediately
echo "  → This is why secrets must never be exported to the environment."
echo ""

_pillar "PRECISION: Enterprise secret manager patterns (Bash-16.2.F / 16.2.G / 16.2.H)"

echo "  Enterprise secret retrieval patterns (reference — not executed live):"
cat << 'VAULTPAT'
  # HashiCorp Vault — secrets fetched at runtime via CLI:
  DB_PASS=$(vault kv get -field=password "secret/prod/database")
  # Never stored in script or env; lives in shell memory only during execution

  # AWS SSM Parameter Store — uses IAM role (no credentials in the script):
  DB_PASS=$(aws ssm get-parameter \
    --with-decryption \
    --name "/prod/myapp/db_password" \
    --query "Parameter.Value" \
    --output text)
  # --with-decryption: transparently decrypts SecureString params using KMS
  # IAM role on the EC2/ECS task provides the auth — zero hardcoded credentials

  # GPG-encrypted secrets file — for air-gapped/offline environments:
  DB_PASS=$(gpg --quiet --batch --decrypt /etc/app/secrets.gpg \
            | jq -r '.database.password')
  # Decrypted output goes to a pipe — never written to disk unencrypted
  # gpg reads the private key from the agent or keyring

  # Verify no secret appears in process list:
  ps aux | grep "$DB_PASS"   ← should return nothing if the pattern is correct
VAULTPAT
echo ""

# ==============================================================================

_section "SEGMENT 16.3 — TOCTOU RACES"

_pillar "BASIC: Classic TOCTOU and the fix (Bash-16.3.A / 16.3.B / 16.3.C)"

echo "  TOCTOU — Time-of-Check-Time-of-Use:"
cat << 'TOCTOU'
  VULNERABLE — two separate kernel operations with an exploitable window:

    if [ -f "$config_file" ]; then      ← CHECK: kernel stat() syscall
      cat "$config_file"                ← USE:   kernel open() syscall
    fi
    # Between the stat() and the open(), an attacker can:
    #   ln -sf /etc/shadow "$config_file"
    # Your script then reads /etc/shadow — the symlink replacement took effect

  SAFE — open the inode ONCE; operate on the file descriptor:

    exec 7< "$config_file" 2>/dev/null \
      || { echo "Cannot open config" >&2; exit 1; }
    # open() was called ONCE — the kernel now holds a reference to the INODE
    # Even if an attacker replaces the path with a symlink AFTER this line,
    # FD 7 still points at the original inode — the path swap has no effect
    while IFS= read -r -u 7 cfg_line; do
      process_config_line "$cfg_line"
    done
    exec 7>&-    # close when done
TOCTOU
echo ""

_pillar "POWER: Atomic mkdir lock and noclobber (Bash-16.3.D / 16.3.E / 16.3.F)"

# [WHAT]: mkdir as an atomic lock — fails instantly if directory already exists
# [WHY]:  mkdir is a SINGLE kernel syscall (mkdir() with O_CREAT | O_EXCL semantics).
#         There is NO window between a check and a create — it's intrinsically atomic.
LOCK_DIR="$WORKSPACE/deploy.lock"

echo "  Atomic mkdir locking demo:"
if mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "  Lock ACQUIRED (mkdir returned 0 — no race)"
  echo "  (simulating deployment work...)"
  sleep 0.1
  rmdir "$LOCK_DIR"
  echo "  Lock RELEASED"
else
  echo "  Lock ALREADY HELD — another instance is running; exiting"
fi
echo ""

# [WHAT]: noclobber (set -C) — prevent > from overwriting existing files
echo "  set -C (noclobber) demo:"
ONCE_FILE="$WORKSPACE/run_once.flag"
(
  set -C   # in a subshell to avoid affecting the parent script's stdout
  if printf 'first-run-timestamp=%s\n' "$(date +%s)" > "$ONCE_FILE" 2>/dev/null; then
    echo "  Flag file created (first run)"
  fi
  # Second attempt — noclobber blocks it
  if printf 'second-run\n' > "$ONCE_FILE" 2>/dev/null; then
    echo "  (unexpected: overwrote file)"
  else
    echo "  noclobber prevented overwrite — correct O_EXCL-like behaviour"
  fi
  # To force-overwrite intentionally when noclobber is set: use >| operator
  printf 'forced\n' >| "$ONCE_FILE" 2>/dev/null
  echo "  Force-overwrite with >| succeeded: $(cat "$ONCE_FILE")"
)
echo ""

_pillar "DEVOPS CONTEXT: Symlink attack anatomy (Bash-16.3.G)"

echo "  Why mktemp defeats symlink attacks:"
cat << 'SYMLINK'
  VULNERABLE — predictable temp file name:
    TMPFILE="/tmp/myscript.$$"    # $$ is the PID — trivially predictable
    # Attacker races: ln -sf /etc/cron.d/backdoor /tmp/myscript.$$
    # Your script writes its temp content → attacker's backdoor cron job

  SAFE — mktemp uses kernel-generated randomness:
    TMPFILE=$(mktemp /tmp/myscript.XXXXXX)
    # 6+ X chars → ~56 bits of entropy (62^6 = 56 billion combinations)
    # Computationally infeasible to predict and pre-create a winning symlink

  ADDITIONAL HARDENING:
    trap 'rm -f "$TMPFILE"' EXIT
    # Ensures cleanup on SIGTERM, SIGINT, ERR, and normal exit
    # (SIGKILL cannot be caught — but a 56-bit random name is already safe)

    # Extra: open the temp file immediately after creation to hold the inode:
    exec 9> "$TMPFILE"
    # Now you operate on FD 9 — path-swap after this line has zero effect
SYMLINK
echo ""

# ==============================================================================

_section "SEGMENT 16.4 — umask, PERMISSIONS, AND PRIVILEGE MANAGEMENT"

_pillar "BASIC: umask 077 — secrets get 600 by default (Bash-16.4.A / 16.4.B / 16.4.C)"

# [COMMAND MEANING] umask = User Mask — bitmask subtracted from default permissions
# [WHAT]: umask 077 → new files get 600, new dirs get 700 — safe for secrets
# [WHY]:  Without this, a script running under the default umask 022 creates
#         files world-readable — any process on the box can read your configs
echo "  Current shell umask: $(umask)"
echo ""

(
  # Demonstrate in a subshell to avoid changing parent shell's umask
  umask 077
  echo "  After umask 077:"
  PRIV="$WORKSPACE/private.cfg"
  printf 'api_key=secret\n' > "$PRIV"
  echo "  New file permissions (expect 600):"
  ls -la "$PRIV"
)
echo ""

(
  umask 022
  echo "  After umask 022 (dangerous for secrets):"
  PUB="$WORKSPACE/public.cfg"
  printf 'log_level=info\n' > "$PUB"
  echo "  New file permissions (expect 644 — world-readable!):"
  ls -la "$PUB"
  echo "  [WATCH OUT]: Never use umask 022 for files containing credentials."
)
echo ""

_pillar "POWER: chmod, chown, chgrp, setgid directory (Bash-16.4.C/D/E/F)"

echo "  Permission operations:"
cat << 'PERMOPS'
  # Explicit permission setting — never rely on umask alone for sensitive files:
  chmod 600 /etc/app/db.conf      # owner rw only         (credentials)
  chmod 644 /etc/app/logging.conf # owner rw, others r    (public config)
  chmod 755 /usr/local/bin/deploy # owner rwx, others rx  (executable script)
  chmod 700 /etc/app/secrets/     # owner rwx only        (secrets directory)

  # Ownership:
  chown deploy:www-data /var/www/app/   # set owner AND group atomically
  chgrp www-data        /var/log/app/   # group only — less disruptive than chown

  # Setgid bit on a shared directory:
  chmod g+s /srv/shared/uploads/
  # New files inherit the directory's group (not creator's primary group)
  # The shared-workspace pattern — all team members' files belong to the same group

  # Atomic deployment — install is chown+chmod in one syscall:
  install -m 600 -o root -g root secrets.conf /etc/app/secrets.conf
  # No window between copy and permission-set — safer than cp + chmod
PERMOPS
echo ""

_pillar "PRECISION: Privilege dropping and least-privilege sudo (Bash-16.4.G/H/I/J)"

echo "  Privilege management patterns:"
cat << 'PRIVDROP'
  # Drop to a specific unprivileged user for a single command:
  sudo -u nobody /usr/local/bin/parse-untrusted-data.sh
  # nobody has no home dir, no login shell — maximally unprivileged

  # Drop to a service account (PAM-aware — use inside unit files):
  runuser -u www-data -- /usr/local/bin/render-templates.sh
  # runuser is the systemd-correct alternative to sudo for service accounts

  # Guard against accidental non-root execution:
  [[ $EUID -eq 0 ]] || { echo "This script requires root" >&2; exit 1; }

  # Least-privilege sudoers rule (/etc/sudoers.d/deploy-bot):
  deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart app-service
  deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl start   app-service
  deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop    app-service
  # The deploy user can ONLY perform these three actions — no shell, no other binaries

  # PATH injection prevention — NEVER in a privileged script:
  PATH="$PATH:$USER_INPUT_DIR"  # ← attacker places malicious 'cp' in that dir
  # Safe: use absolute paths for every tool in privileged scripts:
  /bin/cp /bin/mv /usr/bin/install
PRIVDROP
echo ""

# Demonstrate setgid directory
SETGID_DIR="$WORKSPACE/shared_uploads"
mkdir -p "$SETGID_DIR"
chmod g+s "$SETGID_DIR"
echo "  Setgid directory created:"
ls -la "$WORKSPACE/" | grep shared_uploads
echo ""

# ==============================================================================
# MODULE 17 — POSIX COMPLIANCE AND CROSS-PLATFORM PORTABILITY
# ==============================================================================

_section "SEGMENT 17.1 — POSIX SHELL (/bin/sh) CONSTRAINTS"

_pillar "BASIC: The POSIX feature matrix (Bash-17.1.A/B/C/D)"

echo "  POSIX sh feature matrix — what's in, what's out:"
cat << 'POSIXMAT'
  ✓ POSIX — safe in #!/bin/sh scripts:
    if / while / for / case       control flow
    [ ] / test                    conditional tests (always quote variables)
    $()                           command substitution (not backticks)
    $(( ))                        arithmetic expansion
    $1 $@ $#                      positional parameters
    printf                        formatted output (portable; echo is NOT)
    functions:  name() { }        (NOT the 'function' keyword — that's a Bashism)
    .  file                       source a file (NOT the 'source' keyword)
    read                          line input (limited flags in pure POSIX)
    :                             null command — always true (true equivalent)

  ✗ FORBIDDEN in #!/bin/sh — Bashisms that cause silent bugs on dash/ash/ksh:
    declare -a / declare -A       no arrays of any kind
    [[ ]]                         use [ ] only
    (( ))                         use $(( )) for arithmetic
    function keyword              use name() { } form only
    select                        no interactive menu loop
    {a,b,c} brace expansion       not available
    <<< here-strings              not available
    $'...' ANSI-C quoting         not available
    ${var^^} ${var,,}             no case modification operators
    [[ =~ ]] regex matching       not available
    mapfile / readarray           not available
    coproc                        not available
    FUNCNAME / BASH_SOURCE        not available
POSIXMAT
echo ""

_pillar "POWER: printf vs echo portability trap (Bash-17.1.F / 17.1.G)"

# [WHAT]: Demonstrate that echo behaviour differs across shells; printf does not
# [WHY]:  echo -e / echo -n work in bash but not in dash (Alpine's default sh).
#         A script that uses echo for data output will silently produce wrong
#         results on the CI runner if CI uses dash (/bin/sh = dash on Ubuntu)
echo "  echo portability comparison:"
cat << 'ECHOPRINT'
  echo "\n"      # bash: literal "\n"   | dash: a newline   ← DIFFERENT
  echo -n "x"   # bash: "x" no newline | dash: "-n x"      ← DIFFERENT
  echo -e "\t"  # bash: a tab          | dash: "-e \t"      ← DIFFERENT

  printf is portable and behaviour-defined in POSIX:
  printf "%s\n" "hello world"           # always: hello world + newline
  printf "Line 1\nLine 2\n"            # always: two separate lines
  printf "%d active replicas\n" 3      # always: "3 active replicas"

  For data output in POSIX scripts: ALWAYS use printf.
  echo is acceptable ONLY for simple interactive messages where portability
  is not required and the string contains no escape sequences.
ECHOPRINT
echo ""

_pillar "PRECISION: Live shellcheck -s sh audit (Bash-17.1.H)"

# [WHAT]: Write a script containing deliberate Bashisms, then audit it
BASHISM_FILE="$WORKSPACE/bashisms.sh"
cat > "$BASHISM_FILE" << 'BASHSCRIPT'
#!/bin/sh
# Deliberate Bashisms for shellcheck demonstration
items=(one two three)
echo "${items[0]}"

if [[ -z "$1" ]]; then
  echo "no arg"
fi

for i in {1..5}; do
  printf "%d\n" "$i"
done

read -r -a words <<< "hello world"
echo "${words[1]}"

x=5
(( x += 3 ))
echo "$x"
BASHSCRIPT

echo "  shellcheck -s sh on a Bashisms-laden #!/bin/sh script:"
if command -v shellcheck &>/dev/null; then
  shellcheck -s sh "$BASHISM_FILE" || true
else
  echo "  shellcheck not available — expected output:"
  cat << 'SCEXPECT'
    bashisms.sh:3:1:  warning: In POSIX sh, arrays are undefined. [SC2039/SC3054]
    bashisms.sh:6:4:  warning: In POSIX sh, [[ ]] is not supported. [SC2039/SC3010]
    bashisms.sh:10:12: warning: In POSIX sh, brace expansion is undefined. [SC2039/SC3009]
    bashisms.sh:14:8:  warning: In POSIX sh, 'read -a' is not supported. [SC2039/SC3045]
    bashisms.sh:14:21: warning: In POSIX sh, here-strings are not supported. [SC2039/SC3011]
    bashisms.sh:19:1:  warning: In POSIX sh, (( )) is not supported. [SC2039/SC3010]
SCEXPECT
fi
echo ""

# ==============================================================================

_section "SEGMENT 17.2 — GNU VS. BSD COREUTILS DIFFERENCES"

_pillar "BASIC: The sed -i portability trap (Bash-17.2.A / 17.2.B / 17.2.C)"

# [WHAT]: The single most common "works on my Linux, breaks on macOS CI" bug
# [WHY]:  GNU sed: -i takes NO argument. BSD sed: -i REQUIRES an extension argument.
#         The difference is invisible until you have a macOS CI runner.

SED_TARGET="$WORKSPACE/portability_test.cfg"
printf 'host=old-db.internal\nport=5432\nenv=staging\n' > "$SED_TARGET"
echo "  Config before substitution:"
cat "$SED_TARGET"
echo ""

# Portable sed -i wrapper — detects GNU vs BSD at runtime
portable_inplace_sed() {
  local expr="$1" file="$2"
  # [WHAT]: --version succeeds on GNU sed; fails on BSD sed
  if sed --version &>/dev/null 2>&1; then
    sed -i "$expr" "$file"        # GNU form: no argument to -i
  else
    sed -i '' "$expr" "$file"     # BSD form: empty string = no backup suffix
  fi
}

portable_inplace_sed 's/old-db/new-db/g'  "$SED_TARGET"
portable_inplace_sed 's/staging/production/g' "$SED_TARGET"

echo "  After portable_inplace_sed():"
cat "$SED_TARGET"
echo ""

_pillar "POWER: date, grep -P, xargs -r, readlink -f (Bash-17.2.D/E/F/G/H)"

echo "  GNU vs BSD coreutils quick-reference:"
cat << 'GNUBSD'
  ┌──────────────────────┬──────────────────────────────┬───────────────────────┐
  │ Operation            │ GNU (Linux)                  │ BSD / macOS           │
  ├──────────────────────┼──────────────────────────────┼───────────────────────┤
  │ sed in-place         │ sed -i 's/a/b/' file         │ sed -i '' 's/a/b/' f  │
  │ date: yesterday      │ date -d "yesterday"          │ date -v-1d            │
  │ date: 2 hours ago    │ date -d "2 hours ago"        │ date -v-2H            │
  │ Perl regex grep      │ grep -P '\d+\.\d+'           │ NOT AVAILABLE         │
  │ skip empty xargs     │ xargs -r cmd                 │ NOT AVAILABLE         │
  │ resolve symlink      │ readlink -f /path            │ realpath /path        │
  │ stat: file size      │ stat --format="%s" file      │ stat -f "%z" file     │
  │ stat: permissions    │ stat --format="%a" file      │ stat -f "%OLp" file   │
  └──────────────────────┴──────────────────────────────┴───────────────────────┘
GNUBSD
echo ""

_pillar "PRECISION: Feature detection over OS detection (Bash-17.2.I)"

# [WHAT]: Test for CAPABILITIES, not the OS — the robust portability strategy
# [WHY]:  Detecting uname or $OSTYPE fails on: Alpine Linux (reports "Linux" but
#         may have BusyBox tools), WSL (reports "Linux" with Windows FS quirks),
#         and Docker containers built from custom base images

echo "  Capability-based feature detection:"

# Detect: GNU sed (--version) vs BSD sed (--version fails)
if sed --version &>/dev/null 2>&1; then
  INPLACE_SED() { sed -i "$1" "$2"; }
  echo "  sed: GNU form detected (no suffix argument)"
else
  INPLACE_SED() { sed -i '' "$1" "$2"; }
  echo "  sed: BSD form detected (requires '' suffix)"
fi

# Detect: grep -P (PCRE) availability
if printf '' | grep -P '' &>/dev/null 2>&1; then
  REGEX_GREP="grep -P"
  echo "  grep: PCRE (-P) available"
else
  REGEX_GREP="grep -E"
  echo "  grep: -P unavailable — falling back to ERE (-E)"
fi
echo "  REGEX_GREP=$REGEX_GREP"
echo ""

# Portable stat — size of a file
if stat --format="%s" /dev/null &>/dev/null 2>&1; then
  portable_stat_size() { stat --format="%s" "$1"; }
  echo "  stat: GNU --format detected"
else
  portable_stat_size() { stat -f "%z" "$1"; }
  echo "  stat: BSD -f detected"
fi
echo "  /dev/null size via portable_stat_size(): $(portable_stat_size /dev/null) bytes"
echo ""

# ==============================================================================

_section "SEGMENT 17.3 — BusyBox AND ALPINE LINUX"

_pillar "BASIC: BusyBox detection and ash constraints (Bash-17.3.A / 17.3.D / 17.3.E)"

# [COMMAND MEANING] BusyBox = Busy Box — single static binary providing ~300 tools
# [WHAT]: Detect BusyBox at runtime and gate tool-specific code paths
echo "  BusyBox detection:"
if ls --help 2>&1 | grep -q "BusyBox"; then
  IS_BUSYBOX=1
  echo "  ⚠  Running inside a BusyBox environment — POSIX-safe paths only"
else
  IS_BUSYBOX=0
  echo "  ✓  GNU/standard environment (not BusyBox)"
fi
echo "  IS_BUSYBOX=$IS_BUSYBOX"
echo ""

echo "  BusyBox / Alpine ash constraints:"
cat << 'BUSYBOX'
  BusyBox awk (vs gawk):
    ✗ Missing: PROCINFO, gensub(), bitwise ops (and/or/xor/lshift/rshift)
    ✗ Missing: gawk -i inplace flag
    ✓ Safe:    FS OFS RS NR NF $1..$NF arrays if/while/for printf sub gsub

  BusyBox sed:
    ✗ Older Alpine: -E flag not supported → use -r as the ERE flag
    ✓ Alpine ≥ 3.15: -E works correctly
    ✓ Always safe: s/pattern/replacement/flags, d, p with -n, ranges

  Alpine /bin/sh (busybox ash):
    ✗ No:  arrays, [[ ]], (( )), coproc, select, {1..5} brace expansion
    ✗ No:  here-strings <<<, $'...' quoting, BASH_SOURCE, FUNCNAME
    ✓ Yes: POSIX sh — if/while/for/case, [ ], $(), $(( )), functions, .
    FIX:  apk add bash → then use explicit #!/usr/bin/env bash in scripts
BUSYBOX
echo ""

_pillar "POWER: Docker-based portability testing (Bash-17.3.F)"

echo "  Docker portability test matrix:"
cat << 'DOCKERMAT'
  # Test against BusyBox ash (the Alpine default):
  docker run --rm -v "$PWD:/work" busybox sh /work/script.sh

  # Test against Alpine with bash explicitly installed:
  docker run --rm -v "$PWD:/work" alpine \
    sh -c 'apk add -q bash && bash /work/script.sh'

  # Full portability matrix loop:
  declare -a IMAGES=(
    "ubuntu:22.04"
    "debian:12"
    "alpine:3.19"
    "amazonlinux:2023"
  )
  for image in "${IMAGES[@]}"; do
    printf "=== Testing on %-25s ===\n" "$image"
    docker run --rm -v "$PWD:/work" "$image" bash /work/script.sh 2>&1 \
      && echo "PASS" \
      || echo "FAIL — review output above"
  done
DOCKERMAT
echo ""

# ==============================================================================

_section "SEGMENT 17.4 — PORTABILITY TESTING STRATEGIES"

_pillar "BASIC: checkbashisms and shellcheck -s sh (Bash-17.4.B / 17.4.F)"

echo "  Static analysis for portability:"
cat << 'STATIC'
  # checkbashisms (devscripts package) — scans #!/bin/sh scripts:
  checkbashisms script.sh
  # Reports: [[, arrays, (( )), process substitution, $'...' quoting, etc.
  # Exit code 1 if any Bashism found — integrates cleanly into CI
  # Install: apt-get install devscripts

  # shellcheck -s sh — more context + fix suggestions:
  shellcheck -s sh script.sh
  # -s sh: treat as /bin/sh and flag ALL Bashisms as errors
  # Reports code, severity, description, and a Wiki link for each issue
  # Integrate in CI pre-commit or GitHub Actions:
  #   find . -name "*.sh" -exec shellcheck -s sh {} +
STATIC
echo ""

_pillar "POWER: Capability-based feature detection (Bash-17.4.C)"

# [WHAT]: Build a portable date wrapper using capability detection
echo "  Portable date wrapper (GNU -d vs BSD -v):"

if date -d "1 second ago" &>/dev/null 2>&1; then
  # GNU date: human-readable -d flag
  date_relative() {
    local n="$1" unit="$2"
    date -d "$n $unit ago" "+%Y-%m-%d %H:%M:%S"
  }
  echo "  GNU date -d detected"
else
  # BSD/macOS: adjustment flags (-v-NX syntax)
  date_relative() {
    # BSD date only supports -v-1S (seconds) natively for small offsets
    date -v-1S "+%Y-%m-%d %H:%M:%S"
  }
  echo "  BSD date -v detected"
fi

echo "  1 second ago: $(date_relative 1 second)"
echo ""

_pillar "PRECISION: GitHub Actions matrix CI (Bash-17.4.A / 17.4.E)"

echo "  GitHub Actions multi-OS portability workflow:"
cat << 'GHACT'
name: Portability & Lint
on: [push, pull_request]

jobs:
  portability:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      - name: Install shellcheck
        run: |
          if [[ "$RUNNER_OS" == "Linux" ]]; then
            sudo apt-get install -y shellcheck
          else
            brew install shellcheck
          fi

      - name: ShellCheck (Bash scripts)
        run: shellcheck -s bash scripts/**/*.sh

      - name: checkbashisms (POSIX scripts — Linux only)
        if: runner.os == 'Linux'
        run: |
          sudo apt-get install -y devscripts
          find scripts/posix -name "*.sh" -exec checkbashisms {} +

      - name: Run test suite
        run: bash tests/run_all.sh
GHACT
echo ""

# ==============================================================================
# MODULE 18 — CONFIGURATION MANAGEMENT AND TEMPLATING
# ==============================================================================

_section "SEGMENT 18.1 — .env FILE LOADING"

_pillar "BASIC: Why 'source .env' is dangerous (Bash-18.1.B)"

# [WHAT]: Demonstrate that sourcing a .env file executes it as shell code
EVIL_ENV_FILE="$WORKSPACE/.env.malicious"
cat > "$EVIL_ENV_FILE" << 'EVILENV'
DB_HOST=prod-db-01.internal
DB_PORT=5432
# Safe-looking line — but the next one executes code on source:
INJECTED=$(echo "[INJECTION] I executed as shell code!" >&2)
ALSO_DANGEROUS=`echo "[INJECTION] Backtick form also executes!" >&2`
EVILENV

echo "  Malicious .env contents:"
cat "$EVIL_ENV_FILE"
echo ""
echo "  'source .env.malicious' would EXECUTE both \$() expressions."
echo "  The safe parser (below) treats them as literal string values."
echo ""

_pillar "POWER: Production-hardened load_env() (Bash-18.1.C / 18.1.E / 18.1.F / 18.1.G)"

# [WHAT]: A safe .env parser — reads line-by-line; no source; no eval
# [WHY]:  This function:
#         1. Reads with while IFS='=' read -r key val — splits on FIRST = only
#         2. Skips comments and blank lines
#         3. Validates KEY against a whitelist regex
#         4. Strips surrounding single or double quotes from values
#         5. Only exports clean KEY=VALUE pairs — never executes values
load_env() {
  local env_file="$1"

  [[ -f "$env_file" ]] || {
    echo "  load_env: file not found: $env_file" >&2
    return 1
  }

  # Warn if file is world- or group-readable
  local perm
  perm=$(stat -c "%a" "$env_file" 2>/dev/null \
      || stat -f "%OLp" "$env_file" 2>/dev/null \
      || echo "unknown")
  if [[ "$perm" != "600" && "$perm" != "400" && "$perm" != "unknown" ]]; then
    echo "  [WARN] $env_file has permissions $perm — should be 600" >&2
  fi

  while IFS='=' read -r key remainder; do
    # Skip blank lines and comment lines
    [[ -z "$key" || "$key" == \#* ]] && continue

    # Trim leading/trailing whitespace from key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    # Whitelist: KEY must be UPPERCASE letters, digits, and underscores
    # starting with a letter or underscore — reject anything else
    if ! [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      echo "  [WARN] load_env: skipping invalid key: '$key'" >&2
      continue
    fi

    # Strip surrounding single or double quotes from the value
    local val="$remainder"
    if [[ "$val" == \"*\" || "$val" == \'*\' ]]; then
      val="${val:1:${#val}-2}"
    fi

    # Export the sanitised KEY=VALUE pair
    export "$key=$val"
  done < "$env_file"
}

# Create a realistic test .env
TEST_ENV="$WORKSPACE/.env"
cat > "$TEST_ENV" << 'TESTENV'
# Production .env
DB_HOST=prod-db-01.internal
DB_PORT=5432
APP_ENV=production
SECRET_KEY="bearer-token-with-quotes"
SERVICE_NAME='auth-service-v2'
LOG_LEVEL=info
# MALICIOUS=$(rm -rf /)  ← treated as a comment; never reaches the parser
INVALID KEY=space-in-key-name
123STARTS_WITH_DIGIT=rejected
TESTENV
chmod 600 "$TEST_ENV"

echo "  load_env() — safe parsing demo:"
load_env "$TEST_ENV"
echo ""

echo "  Variables loaded:"
for var in DB_HOST DB_PORT APP_ENV SECRET_KEY SERVICE_NAME LOG_LEVEL; do
  printf "    %-16s = %s\n" "$var" "${!var:-<not set>}"
done
echo ""

_pillar "PRECISION: The xargs pattern and its failure modes (Bash-18.1.D)"

echo "  The common-but-fragile xargs pattern:"
cat << 'XARGSFAIL'
  # Seen everywhere — understand exactly when it breaks:
  export $(grep -v '^#' .env | xargs)

  Failure 1 — values with spaces:
    API_URL=https://api.example.com/the path
    xargs splits on spaces → exports: API_URL=https://api.example.com/the
                                        path (EXTRA BROKEN VARIABLE)

  Failure 2 — shell metacharacters in values:
    DB_PASS=pa$$w0rd!secret
    $$ expands to the PID; ! triggers history expansion in interactive shells

  Failure 3 — multi-line values (certificates, PEM keys):
    CERT="-----BEGIN CERT-----
    ..."
    xargs interprets the newline as a word boundary — truncates the value

  Rule of thumb:
    Use load_env() for any .env you do not fully control or have not audited.
    Reserve the xargs form ONLY for trivially simple KEY=simplevalue files
    with no spaces, no metacharacters, and no multi-line values.
XARGSFAIL
echo ""

# ==============================================================================

_section "SEGMENT 18.2 — envsubst AND TEMPLATE GENERATION"

_pillar "BASIC: envsubst — template → rendered config (Bash-18.2.A / 18.2.B)"

# [COMMAND MEANING] envsubst = Environment Substitute — replace \${VAR} tokens
# [WHAT]: Create a realistic nginx config template and render it
TEMPLATE="$WORKSPACE/nginx.conf.tmpl"
RENDERED="$WORKSPACE/nginx.conf"

cat > "$TEMPLATE" << 'NGINXTMPL'
# nginx config — generated by envsubst on ${GENERATION_TIMESTAMP}
# DO NOT EDIT DIRECTLY

server {
    listen       ${NGINX_PORT};
    server_name  ${SERVER_NAME};

    access_log   /var/log/nginx/${SERVICE_NAME}-access.log;
    error_log    /var/log/nginx/${SERVICE_NAME}-error.log;

    location / {
        proxy_pass         http://${UPSTREAM_HOST}:${UPSTREAM_PORT};
        proxy_set_header   X-Environment  ${APP_ENV};
        proxy_set_header   X-Service-Name ${SERVICE_NAME};

        # $host is nginx's own runtime variable — NOT a shell variable
        # It must NOT be substituted by envsubst
        proxy_set_header   Host $host;
    }
}
NGINXTMPL

# Set the substitution variables
export NGINX_PORT="443"
export SERVER_NAME="api.example.com"
export UPSTREAM_HOST="backend-01.internal"
export UPSTREAM_PORT="8080"
export GENERATION_TIMESTAMP
GENERATION_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S UTC")
# APP_ENV and SERVICE_NAME were set by load_env() above

echo "  Template:"
cat "$TEMPLATE"
echo ""

# [WHAT]: Render template with SELECTIVE substitution
# [WHY]:  Passing the variable list to envsubst prevents it from replacing
#         $host (nginx's runtime variable) — only the listed vars are touched
echo "  Rendered config (envsubst with selective variable list):"
envsubst '$NGINX_PORT $SERVER_NAME $UPSTREAM_HOST $UPSTREAM_PORT $APP_ENV $SERVICE_NAME $GENERATION_TIMESTAMP' \
  < "$TEMPLATE" > "$RENDERED"
cat "$RENDERED"
echo ""

_pillar "POWER: Atomic config deployment (Bash-18.2.D)"

# [WHAT]: Render to a temp file first; swap atomically with mv
# [WHY]:  If envsubst writes DIRECTLY to the live config and is interrupted
#         mid-write, the running nginx reloads a PARTIAL config — the process
#         may crash or silently serve broken responses. mv (rename syscall) is
#         atomic within the same filesystem — readers never see a partial file.
LIVE_CONFIG="$WORKSPACE/nginx_live.conf"
echo "  Atomic config deployment pattern:"
TEMP_RENDER=$(mktemp "$WORKSPACE/nginx.conf.XXXXXX")
envsubst '$NGINX_PORT $SERVER_NAME $UPSTREAM_HOST $UPSTREAM_PORT $APP_ENV $SERVICE_NAME $GENERATION_TIMESTAMP' \
  < "$TEMPLATE" > "$TEMP_RENDER"
mv "$TEMP_RENDER" "$LIVE_CONFIG"
echo "  Deployed atomically → $LIVE_CONFIG ($(wc -c < "$LIVE_CONFIG") bytes)"
echo ""

_pillar "PRECISION: sed substitution template with __TOKEN__ convention (Bash-18.2.E / 18.2.F)"

# [WHAT]: Alternative to envsubst — sed with double-underscore tokens
# [WHY]:  __DB_HOST__ has no $ prefix — it cannot be accidentally expanded by
#         the shell during heredoc writing or variable interpolation. The
#         double-underscore namespace is entirely distinct from shell variables.
SED_TMPL="$WORKSPACE/app.ini.tmpl"
SED_OUT="$WORKSPACE/app.ini"

cat > "$SED_TMPL" << 'SEDINITMPL'
[database]
host     = __DB_HOST__
port     = __DB_PORT__
name     = __DB_NAME__
url      = postgres://__DB_HOST__:__DB_PORT__/__DB_NAME__

[application]
environment = __APP_ENV__
log_dir     = /var/log/__SERVICE_NAME__
SEDINITMPL

echo "  sed-based template substitution (using | delimiter — safe for values with /):"
sed \
  -e "s|__DB_HOST__|${DB_HOST:-localhost}|g" \
  -e "s|__DB_PORT__|${DB_PORT:-5432}|g" \
  -e "s|__DB_NAME__|appdb_prod|g" \
  -e "s|__APP_ENV__|${APP_ENV:-development}|g" \
  -e "s|__SERVICE_NAME__|${SERVICE_NAME:-myapp}|g" \
  "$SED_TMPL" > "$SED_OUT"

cat "$SED_OUT"
echo ""

# ==============================================================================

_section "SEGMENT 18.3 — INI AND SIMPLE CONFIG FILE PARSING"

_pillar "BASIC: key=value extraction with grep and sed (Bash-18.3.A / 18.3.B / 18.3.G)"

# [WHAT]: Build a realistic multi-section INI file for all parsing demos
INI="$WORKSPACE/app.conf"
cat > "$INI" << 'INICONTENT'
# Application Configuration — v2.4.1
# Last updated by bootstrap script

[database]
host     = prod-db-01.internal
port     = 5432
name     = appdb
url      = postgres://svcuser:pass@prod-db-01:5432/appdb=main
max_conn = 20

[cache]
host     = redis-01.internal
port     = 6379
ttl      = 3600

[app]
log_level = info
workers   = 4
debug     = false
INICONTENT

echo "  INI file:"
cat "$INI"
echo ""

echo "  Method 1 — grep + cut (handles values containing =):"
# [WHAT]: cut -d= -f2- returns field 2 AND EVERYTHING AFTER — the = in the URL
#         value is preserved intact (cut -f2 would truncate at the second =)
grep '^url' "$INI" | head -1 | cut -d= -f2- | tr -d ' '
echo ""

echo "  Method 2 — sed -n 's/^key=//p' (cleanest for simple values):"
# [FLAG MEANING] -n = suppress automatic print; p = print only matching substitution
sed -n 's/^port[[:space:]]*=[[:space:]]*//p' "$INI" | head -1
echo ""

echo "  [WATCH OUT]: Both methods fail when the same key appears in multiple"
echo "   sections (e.g. 'host' appears in [database] AND [cache])."
echo "   Use the awk section-aware parser below for multi-section configs."
echo ""

_pillar "POWER: Section-aware awk INI parser (Bash-18.3.C / 18.3.E)"

# [WHAT]: The ONLY correct multi-section INI parser in shell — awk tracks the
#         current [section] header and only extracts from the target section
# [WHY]:  grep-based extraction returns the first match regardless of section —
#         a silent bug when the same key name appears in multiple sections

echo "  awk section-aware parser:"

DB_HOST_INI=$(awk -F'[[:space:]]*=[[:space:]]*' '
  /^\[/{section=$0; gsub(/[\[\] \t]/, "", section)}
  section=="database" && /^host[[:space:]]*=/ {print $2; exit}
' "$INI")
echo "  [database].host = $DB_HOST_INI"

CACHE_HOST_INI=$(awk -F'[[:space:]]*=[[:space:]]*' '
  /^\[/{section=$0; gsub(/[\[\] \t]/, "", section)}
  section=="cache" && /^host[[:space:]]*=/ {print $2; exit}
' "$INI")
echo "  [cache].host    = $CACHE_HOST_INI"

DB_URL_INI=$(awk '
  /^\[/{section=$0; gsub(/[\[\] \t]/, "", section)}
  section=="database" && /^url[[:space:]]*=/ {
    sub(/^url[[:space:]]*=[[:space:]]*/, "")
    print; exit
  }
' "$INI")
echo "  [database].url  = $DB_URL_INI"
echo ""

_pillar "PRECISION: get_config() reusable accessor (Bash-18.3.D)"

# [WHAT]: A reusable INI accessor — encapsulates the awk parser in a clean function
# [WHY]:  Makes the rest of the script read like English:
#         get_config database max_conn "$INI"  →  "20"
get_config() {
  local section="$1" key="$2" file="$3"

  awk -F'[[:space:]]*=[[:space:]]*' -v sec="$section" -v k="$key" '
    /^\[/{
      cur=$0
      gsub(/[\[\] \t]/, "", cur)
    }
    cur==sec && $1==k {
      # sub() removes key= prefix including surrounding spaces —
      # everything remaining (including = chars in the value) is the value
      sub(/^[^=]*=[[:space:]]*/, "")
      print
      exit
    }
  ' "$file"
}

echo "  get_config() demo:"
printf "  %-35s → %s\n" \
  "get_config database host"     "$(get_config database host     "$INI")"
printf "  %-35s → %s\n" \
  "get_config database max_conn" "$(get_config database max_conn "$INI")"
printf "  %-35s → %s\n" \
  "get_config database url"      "$(get_config database url      "$INI")"
printf "  %-35s → %s\n" \
  "get_config cache ttl"         "$(get_config cache     ttl     "$INI")"
printf "  %-35s → %s\n" \
  "get_config app workers"       "$(get_config app       workers "$INI")"
echo ""

_pillar "DEVOPS CONTEXT: Generating INI from shell variables (Bash-18.3.F)"

# [WHAT]: Build a config file from shell variables using printf for clean formatting
# [WHY]:  The reverse of parsing — generates configs at deploy time from
#         environment variables without a full templating engine

GENERATED_CFG="$WORKSPACE/generated_app.conf"
GEN_DB_HOST="${DB_HOST:-localhost}"
GEN_DB_PORT="${DB_PORT:-5432}"
GEN_APP_ENV="${APP_ENV:-development}"
GEN_LOG_LEVEL="${LOG_LEVEL:-info}"
GEN_WORKERS=4
GEN_TS
GEN_TS=$(date "+%Y-%m-%d %H:%M:%S")

{
  printf '# Generated by bootstrap script at %s\n\n' "$GEN_TS"
  printf '[database]\n'
  printf 'host     = %s\n' "$GEN_DB_HOST"
  printf 'port     = %d\n' "$GEN_DB_PORT"
  printf '\n'
  printf '[app]\n'
  printf 'env       = %s\n' "$GEN_APP_ENV"
  printf 'log_level = %s\n' "$GEN_LOG_LEVEL"
  printf 'workers   = %d\n' "$GEN_WORKERS"
} > "$GENERATED_CFG"

echo "  Generated INI from shell variables:"
cat "$GENERATED_CFG"
echo ""

# Verify round-trip: write with printf, read back with get_config()
echo "  Round-trip verification (generate → parse with get_config()):"
printf "  %-30s → %s\n" \
  "get_config database host"   "$(get_config database host     "$GENERATED_CFG")"
printf "  %-30s → %s\n" \
  "get_config app log_level"  "$(get_config app     log_level "$GENERATED_CFG")"
echo ""


# ==============================================================================
# MODULE 19 — SCHEDULING, DAEMONS, AND LONG-RUNNING SCRIPTS
# ==============================================================================

_section "SEGMENT 19.1 — CRON AND CRONTAB"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# [WHAT]: Build a realistic crontab file in the workspace and a mock /etc/cron.d
#         entry so every pillar has live data to demonstrate against.
# [WHY]:  We cannot safely write the real system crontab in a sandbox — doing so
#         would persist jobs beyond the script's EXIT trap. Writing to WORKSPACE
#         lets us demonstrate every crontab concept without side-effects.
MOCK_CRONTAB="$WORKSPACE/mock_crontab"
MOCK_CROND_DIR="$WORKSPACE/cron.d"
MOCK_CRON_DAILY="$WORKSPACE/cron.daily"
mkdir -p "$MOCK_CROND_DIR" "$MOCK_CRON_DAILY"

# [WHAT ELSE]: In production this file lives at /var/spool/cron/crontabs/<user>
#              and is managed exclusively through 'crontab -e' — never edit it
#              directly because cron locks the spool and a race-write corrupts it.
cat > "$MOCK_CRONTAB" << 'CRONEOF'
# ── Environment header (Bash-19.1.T / 19.1.U / 19.1.V) ───────────────────────
MAILTO=""
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ── m   h  dom mon dow   command ──────────────────────────────────────────────
# [Bash-19.1.F] Five-field time syntax: minute hour day-of-month month day-of-week

# Every minute (Bash-19.1.G — wildcard in every field)
* * * * *       /usr/local/bin/heartbeat.sh >> /var/log/heartbeat.log 2>&1

# Every 15 minutes (Bash-19.1.H — step syntax */N)
*/15 * * * *    /usr/local/bin/metrics_push.sh >> /var/log/metrics.log 2>&1

# Daily at 02:30 AM (Bash-19.1.F)
30 2 * * *      /usr/local/bin/db_backup.sh >> /var/log/backup.log 2>&1

# Every Monday at 03:00 (day-of-week 1 = Monday)
0 3 * * 1       /usr/local/bin/weekly_report.sh >> /var/log/weekly.log 2>&1

# First day of every month at midnight (Bash-19.1.F)
0 0 1 * *       /usr/local/bin/billing_export.sh >> /var/log/billing.log 2>&1

# Run once on system boot (Bash-19.1.I)
@reboot         /usr/local/bin/startup_checks.sh >> /var/log/startup.log 2>&1

# Aliases for the above:
# @daily   → 0 0 * * *    (Bash-19.1.J)
# @hourly  → 0 * * * *    (Bash-19.1.K)
# @weekly  → 0 0 * * 0    (Bash-19.1.L)
# @monthly → 0 0 1 * *    (Bash-19.1.M)
@daily          /usr/local/bin/log_rotate_custom.sh >> /var/log/rotation.log 2>&1
@hourly         /usr/local/bin/cache_purge.sh >> /var/log/cache.log 2>&1
CRONEOF

# [WHAT]: Build a mock /etc/cron.d/ drop-in file (Bash-19.1.N)
# [WHY]:  /etc/cron.d/ allows packages to ship their own crontab fragments
#         without touching /etc/crontab — each file is a complete crontab with
#         an extra 6th field specifying the username to run the job as.
cat > "$MOCK_CROND_DIR/myapp" << 'CRONDEOF'
# /etc/cron.d/myapp — drop-in for myapp package (Bash-19.1.N)
# Format: m h dom mon dow USER command
MAILTO=""
*/5 * * * *   www-data   /opt/myapp/bin/healthcheck >> /var/log/myapp/health.log 2>&1
0   4 * * *   root       /opt/myapp/bin/vacuum_db    >> /var/log/myapp/vacuum.log 2>&1
CRONDEOF

# [WHAT]: Build a mock /etc/cron.daily/ script (Bash-19.1.O)
# [WHY]:  run-parts executes every executable file in cron.daily — no time fields,
#         no username field. The filename IS the identifier. Must be executable.
cat > "$MOCK_CRON_DAILY/clean_tmp" << 'DAILYEOF'
#!/bin/bash
# /etc/cron.daily/clean_tmp — run by run-parts daily (Bash-19.1.O / 19.1.W)
find /tmp -type f -mtime +7 -delete
DAILYEOF
chmod +x "$MOCK_CRON_DAILY/clean_tmp"

_pillar "BASIC: Crontab management commands (Bash-19.1.A/B/C/D)"

# [COMMAND MEANING] crontab = Cron Table — manage scheduled periodic jobs
# [WHAT]: Show the crontab management command family without executing -e (which
#         opens an editor) or -r (which irreversibly deletes the real crontab).
echo "  Crontab management commands:"
echo "  ┌─────────────────────────────────────────────────────────────────┐"
echo "  │  crontab -e          → Open/create crontab in \$EDITOR            │"
echo "  │  crontab -l          → List current crontab (safe, stdout)       │"
echo "  │  crontab -r          → DELETE entire crontab (no undo, no prompt)│"
echo "  │  crontab -u <user>   → Operate on another user's crontab (root)  │"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""

# [COMMAND MEANING] crontab -l = List — print crontab to stdout for auditing
# [WATCH OUT]: crontab -l exits 1 if no crontab exists for the user — always
#              guard with '|| true' in scripts running under set -e.
echo "  Live crontab for current user (if any):"
crontab -l 2>/dev/null || echo "  [no crontab installed for $(whoami) — this is normal in a container]"
echo ""

_pillar "POWER: The five-field syntax and special strings (Bash-19.1.F/G/H/I-M)"

# [WHAT]: Parse and annotate our mock crontab — proves comprehension of every field
# [WHY]:  Toptal screeners will hand you a crontab and ask "what does this do?"
#         Being able to read it instantly separates junior from senior.
echo "  Annotated mock crontab (from \$WORKSPACE/mock_crontab):"
echo ""
# Filter out comments and blanks, then pretty-print each job line
grep -v '^\s*#' "$MOCK_CRONTAB" | grep -v '^\s*$' | grep -v '^[A-Z]' \
  | while IFS= read -r line; do
      printf "  %s\n" "$line"
    done
echo ""

echo "  ┌─── Five-field reference (Bash-19.1.F) ──────────────────────────┐"
echo "  │  Field 1: minute   0–59       */15 = every 15 minutes           │"
echo "  │  Field 2: hour     0–23       2    = 02:xx AM                   │"
echo "  │  Field 3: dom      1–31       1    = 1st of the month           │"
echo "  │  Field 4: month    1–12       *    = every month                │"
echo "  │  Field 5: dow      0–7 (0=7=Sun)  1 = Monday                   │"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""

echo "  ┌─── Special strings (Bash-19.1.I–M) ────────────────────────────┐"
printf "  │  %-12s %-25s %-20s │\n" "@reboot"  "At system startup"        "→ once per boot"
printf "  │  %-12s %-25s %-20s │\n" "@hourly"  "0 * * * *"                "→ top of each hour"
printf "  │  %-12s %-25s %-20s │\n" "@daily"   "0 0 * * *"                "→ midnight daily"
printf "  │  %-12s %-25s %-20s │\n" "@weekly"  "0 0 * * 0"                "→ midnight Sunday"
printf "  │  %-12s %-25s %-20s │\n" "@monthly" "0 0 1 * *"                "→ midnight 1st"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""

_pillar "PRECISION: Environment header and logging pattern (Bash-19.1.S/T/U/V)"

# [WHAT]: Demonstrate the critical crontab environment header fields
# [WHY]:  Cron inherits NONE of your interactive session environment.
#         PATH=/usr/bin:/bin only — your custom tools are invisible.
#         SHELL defaults to /bin/sh — your Bashisms silently fail.
#         MAILTO defaults to the user account — your spool fills with noise.
echo "  The 3 environment lines every production crontab MUST start with:"
echo ""
echo '  MAILTO=""                                       # suppress email noise'
echo '  SHELL=/bin/bash                                 # use Bash not /bin/sh'
echo '  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
echo ""
echo "  The canonical job logging pattern:"
echo '  */5 * * * * /abs/path/script.sh >> /var/log/script.log 2>&1'
echo "                                    ^^                    ^^^^"
echo "  [HOW]:  >> appends stdout to log file (never truncate cron logs mid-day)"
echo "  [HOW]:  2>&1 merges stderr into the same log — cron errors are silent otherwise"
echo "  [WATCH OUT]: Relative paths in cron commands fail silently — ALWAYS use"
echo "               absolute paths. cron's CWD is / and PATH is minimal."
echo ""

_pillar "DEVOPS CONTEXT: /etc/cron.d/, cron.daily/, and run-parts (Bash-19.1.N/O/W)"

# [COMMAND MEANING] run-parts = Run Parts — execute all executable scripts in a directory
# [WHAT]: Show the /etc/cron.d/ drop-in format and the cron.daily structure
# [WHY]:  Package managers (apt, rpm) install their own cron jobs via /etc/cron.d/
#         so they don't clobber your /etc/crontab. Infrastructure engineers who
#         don't know this structure can't debug "who scheduled that at 4 AM?"
echo "  /etc/cron.d/ drop-in format (6 fields — note extra USERNAME column):"
cat "$MOCK_CROND_DIR/myapp"
echo ""

echo "  /etc/cron.daily/ — run-parts drops the time fields entirely:"
ls -la "$MOCK_CRON_DAILY/"
echo ""
cat "$MOCK_CRON_DAILY/clean_tmp"
echo ""

# [WHAT]: Simulate run-parts executing the daily directory
# [WHY]:  Understanding that run-parts = chmod +x IS the scheduling mechanism
#         explains why 'cron.daily' scripts that lose their +x bit silently stop.
echo "  Simulating run-parts execution:"
# [FLAG MEANING] --report = print name of each script as it runs (verbose mode)
# [FLAG MEANING] --test   = dry-run — list what would run without running it
if command -v run-parts &>/dev/null; then
  run-parts --test "$MOCK_CRON_DAILY" && echo "  ↑ run-parts --test: these scripts WOULD execute"
else
  echo "  run-parts not available — showing equivalent: ls -1 $MOCK_CRON_DAILY/"
  for f in "$MOCK_CRON_DAILY"/*/; do :; done
  ls -1 "$MOCK_CRON_DAILY/"
fi
echo ""

# [COMMAND MEANING] anacron = Anachronistic cron — runs missed jobs after downtime
echo "  [WHAT ELSE]: anacron — the downtime-resilient cron supplement:"
echo "  /etc/anacrontab format:  PERIOD  DELAY  JOB-ID  COMMAND"
echo "  Example: 1  5  daily-backup  /usr/local/bin/backup.sh"
echo "  PERIOD=1 means daily; DELAY=5 means wait 5 min after boot before running"
echo "  anacron is ESSENTIAL on VMs and laptops — pure cron skips missed windows"
echo ""

# ==============================================================================

_section "SEGMENT 19.2 — at AND batch"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# [WHAT]: Build the job script that at would schedule — we can't leave real at
#         jobs pending beyond the script's EXIT trap, so we demonstrate the
#         submission workflow and immediately cancel the job atomically.
AT_JOB_SCRIPT="$WORKSPACE/at_job.sh"
cat > "$AT_JOB_SCRIPT" << 'ATEOF'
#!/bin/bash
# One-time maintenance job submitted via 'at'
echo "[$(date)] Vacuuming database..." >> /var/log/maintenance.log
/usr/local/bin/vacuumdb --all --quiet
echo "[$(date)] Done." >> /var/log/maintenance.log
ATEOF
chmod +x "$AT_JOB_SCRIPT"

_pillar "BASIC: at — one-time job scheduling (Bash-19.2.A/B/E)"

# [COMMAND MEANING] at = At — schedule a one-time command at a specific future time
# [WHAT]: Unlike cron (which repeats), at fires ONCE and is removed from the queue.
# [WHY]:  Use at for one-off maintenance windows, post-deploy cleanup, deferred
#         notifications — anything that should run exactly once at a specific moment.
echo "  at accepts human-readable time expressions:"
echo "  ┌───────────────────────────────────────────────────────────────────┐"
echo "  │  at now + 5 minutes              → 5 minutes from now            │"
echo "  │  at now + 2 hours                → 2 hours from now              │"
echo "  │  at midnight                     → tonight at 00:00:00           │"
echo "  │  at noon tomorrow                → tomorrow at 12:00:00          │"
echo "  │  at 14:30                        → today (or tomorrow) at 14:30  │"
echo "  │  at 02:00 next Monday            → next Monday at 02:00          │"
echo "  └───────────────────────────────────────────────────────────────────┘"
echo ""

_pillar "POWER: at -f, atq, atrm (Bash-19.2.C/D/F/G/H/I/J)"

# [FLAG MEANING] -f = file — read commands from a script file, not interactive stdin
# [WHAT]: Submit a job from a script file — the production-safe at invocation
# [WHY]:  Interactive stdin submission (echo "cmd" | at TIME) is fragile in CI.
#         -f reads the full script without pipe buffering issues.
if command -v at &>/dev/null; then
  AT_JOB_ID=""

  # Submit a job 1 minute from now and capture the job ID
  # [WATCH OUT]: at writes job confirmation to STDERR, not stdout.
  #              Capture via 2>&1 and parse the job number from the output.
  AT_OUTPUT=$(at -f "$AT_JOB_SCRIPT" now + 1 minute 2>&1) || true
  echo "  at submission output:"
  echo "  $AT_OUTPUT"
  echo ""

  # Extract job number from "job N at ..." output
  AT_JOB_ID=$(echo "$AT_OUTPUT" | grep -oP 'job \K[0-9]+') || true

  # [COMMAND MEANING] atq = At Queue — list all pending one-time jobs
  echo "  atq — pending at jobs for $(whoami):"
  atq 2>/dev/null || echo "  [no pending jobs or atq not available]"
  echo ""

  # [FLAG MEANING] -l = list — equivalent to atq; shows job ID, time, queue letter
  echo "  at -l (alias for atq):"
  at -l 2>/dev/null || true
  echo ""

  # [COMMAND MEANING] atrm = At Remove — delete a pending job before it fires
  # [FLAG MEANING] -d N = delete — same as atrm N; flag-form for scripted deletion
  if [[ -n "$AT_JOB_ID" ]]; then
    echo "  Cancelling job $AT_JOB_ID with atrm (Bash-19.2.H):"
    atrm "$AT_JOB_ID" 2>/dev/null && echo "  Job $AT_JOB_ID removed." || echo "  atrm skipped (job already gone or permission denied)"
  fi

  # [FLAG MEANING] -q <letter> = queue — a=normal priority, z=lowest (nice 19)
  echo ""
  echo "  at -q b -f \$script now + 10 minutes  # submit to queue 'b' (lower priority)"
  echo "  Queues a–l run at 'nice 0'; m–z run at increasing nice levels up to 19"
  echo ""
else
  echo "  [at daemon (atd) not available in this container — showing syntax only]"
  echo ""
  echo "  Production workflow:"
  echo '  at -f /path/to/job.sh now + 1 hour    # submit from file (Bash-19.2.C/D)'
  echo '  atq                                    # list pending jobs (Bash-19.2.G)'
  echo '  at -l                                  # same as atq (Bash-19.2.F)'
  echo '  atrm 3                                 # remove job #3 (Bash-19.2.H)'
  echo '  at -d 3                                # flag-form of atrm (Bash-19.2.I)'
  echo '  at -q c -f job.sh midnight             # submit to queue c (Bash-19.2.J)'
fi
echo ""

_pillar "PRECISION: batch — load-aware deferred execution (Bash-19.2.K)"

# [COMMAND MEANING] batch = Batch — run a one-time job when load drops below threshold
# [WHAT]: Like at, but doesn't fire at a fixed time — fires when load avg < 1.5
# [WHY]:  On a busy server, batch prevents a heavy maintenance job from competing
#         with live traffic. The kernel decides WHEN, you decide WHAT.
echo "  batch vs at:"
echo "  ┌──────────────────────┬────────────────────────────────────────────┐"
echo "  │  at now + 1 hour     │ Fires at wall-clock time, regardless of load│"
echo "  │  batch               │ Fires when load average drops below 1.5     │"
echo "  └──────────────────────┴────────────────────────────────────────────┘"
echo ""
echo "  Usage (batch reads commands from stdin or -f file):"
echo "  echo '/usr/local/bin/reindex_search.sh' | batch"
echo "  batch -f \$AT_JOB_SCRIPT           # from file — same -f as at"
echo ""
echo "  /etc/at.allow  → whitelist (only listed users may use at/batch)"
echo "  /etc/at.deny   → blacklist (listed users are denied; all others allowed)"
echo "  [WATCH OUT]: If BOTH files are absent, only root may use at/batch."
echo ""

# ==============================================================================

_section "SEGMENT 19.3 — systemd TIMERS (MODERN CRON REPLACEMENT)"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# [WHAT]: Write realistic systemd unit files into the workspace — we cannot
#         install them into /etc/systemd/system/ without root, but writing and
#         explaining them is the Toptal-tier deliverable.
TIMER_DIR="$WORKSPACE/systemd_units"
mkdir -p "$TIMER_DIR"

# [WHAT]: The .service unit is the WHAT — what binary runs, as what user
cat > "$TIMER_DIR/db-backup.service" << 'SVCEOF'
[Unit]
Description=Database Backup Job
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=oneshot
User=postgres
ExecStart=/usr/local/bin/pg_backup.sh
StandardOutput=journal
StandardError=journal
SyslogIdentifier=db-backup

# Defensive limits
Nice=10
IOSchedulingClass=3
MemoryLimit=512M
EOF_GUARD=
SVCEOF

# [WHAT]: The .timer unit is the WHEN — the schedule that activates the .service
cat > "$TIMER_DIR/db-backup.timer" << 'TIMEREOF'
[Unit]
Description=Run Database Backup Daily at 02:00
Requires=db-backup.service

[Timer]
# Realtime (wallclock) timer — fires at 02:00 every day (Bash-19.3.G)
OnCalendar=*-*-* 02:00:00

# Run immediately if the last scheduled run was missed (Bash-19.3.K)
# (e.g. server was offline during the 02:00 window — fires on next boot)
Persistent=true

# Accuracy window — systemd may delay up to 1 min to coalesce wakeups (Bash-19.3.N)
AccuracySec=1min

# Random jitter ±30s — prevents thundering herd on 200 servers (Bash-19.3.O)
RandomizedDelaySec=30

[Install]
WantedBy=timers.target
TIMEREOF

# [WHAT]: A monotonic timer (not wall-clock) — fires relative to boot or last run
cat > "$TIMER_DIR/metrics-push.timer" << 'MONEOF'
[Unit]
Description=Push Metrics Every 5 Minutes

[Timer]
# Monotonic: fire 1 minute after boot (Bash-19.3.H)
OnBootSec=1min

# Then fire every 5 minutes relative to last activation (Bash-19.3.I)
OnUnitActiveSec=5min

# No Persistent= needed — monotonic timers reset from boot, not wall-clock

[Install]
WantedBy=timers.target
MONEOF

_pillar "BASIC: systemd unit file anatomy (Bash-19.3.G/H/I/K/N/O)"

# [COMMAND MEANING] systemctl = System Control — manage the systemd init system
# [WHAT]: Show the two unit files and explain every directive
echo "  db-backup.service:"
cat "$TIMER_DIR/db-backup.service"
echo ""
echo "  db-backup.timer (realtime / OnCalendar):"
cat "$TIMER_DIR/db-backup.timer"
echo ""
echo "  metrics-push.timer (monotonic / OnBootSec + OnUnitActiveSec):"
cat "$TIMER_DIR/metrics-push.timer"
echo ""

_pillar "POWER: systemctl timer management (Bash-19.3.B/C/D/E/F/P/Q)"

# [WHAT]: Show the full lifecycle of a systemd timer — enable, start, status, list
# [WHY]:  crontab -e gives you no visibility into "is this running? did it fail?"
#         systemd timers log every run to journald with full stdout/stderr capture.
echo "  Production timer lifecycle commands:"
echo ""
echo "  # Deploy the unit files"
echo "  sudo cp db-backup.{service,timer} /etc/systemd/system/"
echo "  sudo systemctl daemon-reload                # re-read unit file changes"
echo ""
echo "  # Enable + start (Bash-19.3.D/E)"
echo "  sudo systemctl enable --now db-backup.timer # enable at boot AND start now"
echo ""
echo "  # Inspect (Bash-19.3.F)"
echo "  sudo systemctl status db-backup.timer"
echo ""
echo "  # See ALL timers — when they last ran, when they fire next (Bash-19.3.B/C)"

# [FLAG MEANING] list-timers = show all timer units with next/last trigger times
# [FLAG MEANING] --all       = include inactive timers, not just active ones
if systemctl list-timers &>/dev/null 2>&1; then
  systemctl list-timers --all 2>/dev/null | head -20 || true
else
  echo "  [systemd not PID 1 in this container — showing expected output format]"
  printf "  %-35s %-25s %-25s %s\n" "NEXT" "LEFT" "LAST" "UNIT"
  printf "  %-35s %-25s %-25s %s\n" \
    "Thu 2026-05-01 02:00:00 UTC" "3h 14min left" "Wed 2026-04-30 02:00:18 UTC" "db-backup.timer"
  printf "  %-35s %-25s %-25s %s\n" \
    "Thu 2026-05-01 00:05:00 UTC" "1h 19min left" "Wed 2026-04-30 23:45:01 UTC" "metrics-push.timer"
fi
echo ""

_pillar "PRECISION: Realtime vs monotonic timers (Bash-19.3.G/H/I)"

# [WHAT]: The conceptual difference that determines which timer type to use
# [WHY]:  Toptal screeners ask "why Persistent=true in a realtime timer but
#         not in a monotonic one?" — this is the answer.
echo "  ┌──────────────────┬──────────────────────────┬──────────────────────────┐"
echo "  │ Timer type       │ Directive                │ Use case                 │"
echo "  ├──────────────────┼──────────────────────────┼──────────────────────────┤"
echo "  │ Realtime         │ OnCalendar=              │ DB backup at 2 AM        │"
echo "  │ (wallclock)      │ Persistent=true useful   │ Billing at month-end     │"
echo "  │                  │ (catches missed windows) │ Certificate renewal      │"
echo "  ├──────────────────┼──────────────────────────┼──────────────────────────┤"
echo "  │ Monotonic        │ OnBootSec= +             │ Metrics push every 5m    │"
echo "  │ (since boot/last │ OnUnitActiveSec=         │ Health check loop        │"
echo "  │  activation)     │ Persistent= irrelevant   │ Cache warm-up after boot │"
echo "  └──────────────────┴──────────────────────────┴──────────────────────────┘"
echo ""
echo "  [WHAT ELSE]: systemd-run for transient (no-unit-file) timers (Bash-19.3.R/S):"
echo '  systemd-run --on-active=30min /usr/local/bin/cleanup.sh'
echo '  systemd-run --on-calendar="2026-05-01 14:00" /usr/local/bin/deploy.sh'
echo "  Transient units auto-delete after firing — no unit file cleanup needed."
echo ""

_pillar "DEVOPS CONTEXT: journald log access (Bash-19.3.P/Q) vs cron's silence"

# [COMMAND MEANING] journalctl = Journal Control — query the systemd journal
# [WHAT]: Show how to retrieve logs from a systemd-managed service/timer
# [WHY]:  cron silently discards stdout unless you manually append >>log 2>&1.
#         systemd captures ALL output to journald automatically — zero config.
echo "  Log access for systemd-managed jobs:"
echo ""
echo "  # Follow live output of the service (Bash-19.3.P)"
echo "  journalctl -u db-backup.service -f"
echo ""
echo "  # Show only runs from the last hour (Bash-19.3.Q)"
echo '  journalctl -u db-backup.service --since "1 hour ago"'
echo ""
echo "  # Show runs since a specific timestamp"
echo '  journalctl -u db-backup.service --since "2026-04-30 02:00" --until "2026-04-30 02:10"'
echo ""
echo "  systemd timer advantages over cron:"
echo "  ✓  Every run logged to journald with timestamps — no >>log wrangling"
echo "  ✓  Dependencies: Requires=postgresql.service prevents backup if DB is down"
echo "  ✓  Persistent=true catches missed windows after downtime (anacron built-in)"
echo "  ✓  RandomizedDelaySec= prevents thundering herd on large fleets"
echo "  ✓  systemctl status shows last run time, next run time, and exit code"
echo ""

# ==============================================================================

_section "SEGMENT 19.4 — DAEMON SCRIPTING PATTERNS"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# [WHAT]: Build a fully-functional mini-daemon in the workspace that demonstrates
#         every pattern from 19.4: PID file, SIGTERM/SIGHUP traps, flock single-
#         instance, signal-safe sleep loop, and start/stop/status framework.
# [WHY]:  You cannot teach daemon patterns with echo statements — the daemon must
#         actually run in the background and be managed to prove the concepts work.
DAEMON_SCRIPT="$WORKSPACE/demo_daemon.sh"
DAEMON_PID_FILE="$WORKSPACE/demo_daemon.pid"
DAEMON_LOG="$WORKSPACE/demo_daemon.log"
DAEMON_LOCK="$WORKSPACE/demo_daemon.lock"
DAEMON_CONFIG="$WORKSPACE/demo_daemon.conf"
DAEMON_RELOAD_FLAG="$WORKSPACE/demo_daemon.reload"

cat > "$DAEMON_CONFIG" << 'CONFEOF'
INTERVAL=1
LOG_LEVEL=info
WORKER_COUNT=2
CONFEOF

# [WHAT]: The daemon script itself — every pattern from 19.4 embedded
cat > "$DAEMON_SCRIPT" << 'DAEMONEOF'
#!/usr/bin/env bash
# demo_daemon.sh — demonstrates all Module 19.4 patterns
# PID file, flock, SIGTERM/SIGHUP, signal-safe sleep, start/stop/status

set -euo pipefail

# ── Configuration (injected by the controlling script) ────────────────────────
PID_FILE="${DAEMON_PID_FILE}"
LOG_FILE="${DAEMON_LOG}"
LOCK_FILE="${DAEMON_LOCK}"
CONFIG_FILE="${DAEMON_CONFIG}"

# ── Daemon state ──────────────────────────────────────────────────────────────
# [Bash-19.4.Z]: Boolean RUNNING flag checked by the main loop.
# The SIGTERM trap sets this to false — the loop exits cleanly on next iteration.
RUNNING=true
ITERATION=0

# ── Logging ───────────────────────────────────────────────────────────────────
log() { printf '[%s] [%s] %s\n' "$(date '+%H:%M:%S')" "$1" "$2" >> "$LOG_FILE"; }

# ── Config loader ─────────────────────────────────────────────────────────────
load_config() {
  INTERVAL=2
  [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
  log "INFO" "Config loaded: INTERVAL=${INTERVAL}"
}

# ── Signal handlers (Bash-19.4.B/C/D/E) ──────────────────────────────────────
# [Bash-19.4.B]: SIGTERM = graceful shutdown. Set flag, don't kill the iteration mid-work.
on_sigterm() {
  log "INFO" "SIGTERM received — finishing current iteration then exiting"
  RUNNING=false
}

# [Bash-19.4.C]: SIGHUP = config reload. Re-source config without restarting.
on_sighup() {
  log "INFO" "SIGHUP received — reloading configuration"
  load_config
}

# [Bash-19.4.E]: EXIT trap = unconditional cleanup — PID file removed even on crash.
on_exit() {
  log "INFO" "EXIT trap fired — cleaning up PID file and lock"
  rm -f "$PID_FILE"
  # flock FD 9 is closed automatically when the process exits, releasing the lock
}

trap 'on_sigterm' SIGTERM SIGINT
trap 'on_sighup'  SIGHUP
trap 'on_exit'    EXIT

# ── Single-instance enforcement via flock (Bash-19.4.M/N) ────────────────────
# Open the lock file on FD 9. flock -n exits immediately if lock is held.
# [WATCH OUT]: We open FD 9 first, THEN attempt the lock.
#              Using 'flock -n lockfile cmd' in a subshell loses the lock
#              immediately when the subshell exits.
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  log "ERROR" "Another instance is already running (flock held on $LOCK_FILE)"
  exit 1
fi

# ── Write PID file (Bash-19.4.J / 19.4.X) ────────────────────────────────────
# [WATCH OUT]: Use $BASHPID not $$ — inside a double-fork subshell $$ is the
#              original parent's PID, not the daemon's actual PID.
echo "$BASHPID" > "$PID_FILE"
log "INFO" "Daemon started: PID=$BASHPID, PID_FILE=$PID_FILE"

# ── Load initial config ────────────────────────────────────────────────────────
load_config

# ── Main loop (Bash-19.4.V/U) ─────────────────────────────────────────────────
# [Bash-19.4.U]: The signal-safe sleep pattern:
#   sleep N &        → fork sleep as a background child
#   wait $!          → wait for the sleep child — this wait() IS interruptible
#                      by signals, so SIGTERM fires on_sigterm immediately
#                      rather than waiting the full N seconds.
# [WATCH OUT]: A bare 'sleep N' (foreground) is NOT interrupted by SIGTERM on
#              some shells — the trap fires but only AFTER sleep returns.
while $RUNNING; do
  ITERATION=$(( ITERATION + 1 ))
  log "INFO" "Tick #${ITERATION} — doing work"

  # Simulate work
  sleep 0.1

  # Signal-safe sleep for the interval
  sleep "$INTERVAL" & wait $! || true
  # '|| true' prevents set -e from triggering if wait is interrupted by a signal
done

log "INFO" "Main loop exited cleanly after $ITERATION iterations"
DAEMONEOF

# Inject the variable values into the daemon script via envsubst-style replacement
# so it knows where its PID file and log are (they're in WORKSPACE which is dynamic)
sed -i \
  -e "s|\${DAEMON_PID_FILE}|${DAEMON_PID_FILE}|g" \
  -e "s|\${DAEMON_LOG}|${DAEMON_LOG}|g" \
  -e "s|\${DAEMON_LOCK}|${DAEMON_LOCK}|g" \
  -e "s|\${DAEMON_CONFIG}|${DAEMON_CONFIG}|g" \
  "$DAEMON_SCRIPT"

chmod +x "$DAEMON_SCRIPT"

_pillar "BASIC: PID file write, read, and stale detection (Bash-19.4.J/K/L/F)"

# [WHAT]: Demonstrate the PID file lifecycle before the daemon runs
# [WHY]:  PID files are the lingua franca of Unix daemon management — init systems,
#         monitoring tools, and stop scripts all rely on them to find the running process.
echo "  PID file patterns:"
echo ""
echo "  Write PID file (inside the daemon, after fork):"
echo '  echo "$BASHPID" > /run/mydaemon.pid     # /run not /var/run (modern systems)'
echo ""
echo "  Read and validate PID file (in stop/status scripts):"
cat << 'PIDEOF'
  pid_is_alive() {
    local pid_file="$1"
    # Step 1: does the file exist?
    [[ -f "$pid_file" ]] || return 1
    # Step 2: read the PID
    local pid
    pid=$(< "$pid_file")           # zero-fork read — no cat subshell
    # Step 3: is the PID a valid integer?
    [[ "$pid" =~ ^[0-9]+$ ]] || return 1
    # Step 4: kill -0 tests if process exists without sending a signal (Bash-19.4.F)
    kill -0 "$pid" 2>/dev/null     # returns 0 if alive, non-zero if stale
  }

  # Stale PID detection: PID file exists but process is gone (crashed)
  if [[ -f /run/mydaemon.pid ]]; then
    stale_pid=$(< /run/mydaemon.pid)
    if ! kill -0 "$stale_pid" 2>/dev/null; then
      echo "WARNING: Stale PID file found — daemon crashed. Removing."
      rm -f /run/mydaemon.pid
    fi
  fi
PIDEOF
echo ""

# [FLAG MEANING] -0 = signal zero — probe process existence without signalling
echo "  kill -0 \$PID: the existence probe"
echo "  kill -0 $$    → this shell is alive:"
kill -0 $$ && echo "  PID $$ is alive ✓"
echo ""

_pillar "POWER: start/stop/status/restart framework (Bash-19.4.W)"

# [WHAT]: Implement the standard init-script control framework
# [WHY]:  Every production daemon is managed via this interface — whether it's
#         called by systemd, SysV init, or manually. Toptal expects you to write
#         this from scratch.
daemon_status() {
  local pid_file="$DAEMON_PID_FILE"
  if [[ ! -f "$pid_file" ]]; then
    echo "  [status] STOPPED — no PID file at $pid_file"
    return 1
  fi
  local pid
  pid=$(< "$pid_file")
  if kill -0 "$pid" 2>/dev/null; then
    echo "  [status] RUNNING — PID $pid"
    return 0
  else
    echo "  [status] DEAD — stale PID file (PID $pid no longer exists)"
    rm -f "$pid_file"
    return 1
  fi
}

daemon_start() {
  if daemon_status &>/dev/null; then
    echo "  [start] Already running — nothing to do (idempotent)"
    return 0
  fi
  echo "  [start] Launching daemon in background..."
  # [Bash-19.4.Q]: nohup + & — immune to SIGHUP, runs in background
  # In full daemonization we'd use setsid (Bash-19.4.P) for session detachment
  nohup bash "$DAEMON_SCRIPT" </dev/null >>"$DAEMON_LOG" 2>&1 &
  local bg_pid=$!
  # Brief wait to let the daemon write its PID file
  sleep 0.5
  disown "$bg_pid" 2>/dev/null || true  # [Bash-19.4.R]: remove from job table
  daemon_status
}

daemon_stop() {
  local pid_file="$DAEMON_PID_FILE"
  if ! daemon_status &>/dev/null; then
    echo "  [stop] Not running — nothing to stop"
    return 0
  fi
  local pid
  pid=$(< "$pid_file")
  echo "  [stop] Sending SIGTERM to PID $pid (Bash-19.4.G)..."
  # [Bash-19.4.G]: SIGTERM first — requests graceful shutdown via the trap
  kill -TERM "$pid" 2>/dev/null || true

  # Wait up to 5 seconds for graceful exit
  local waited=0
  while kill -0 "$pid" 2>/dev/null && (( waited < 5 )); do
    sleep 0.3
    (( waited++ )) || true
  done

  # [Bash-19.4.H]: SIGKILL only if graceful exit failed
  if kill -0 "$pid" 2>/dev/null; then
    echo "  [stop] SIGTERM ignored — escalating to SIGKILL (Bash-19.4.H)"
    kill -KILL "$pid" 2>/dev/null || true
  fi

  rm -f "$pid_file"
  echo "  [stop] Daemon stopped."
}

daemon_reload() {
  if ! daemon_status &>/dev/null; then
    echo "  [reload] Not running — cannot reload"
    return 1
  fi
  local pid
  pid=$(< "$DAEMON_PID_FILE")
  echo "  [reload] Sending SIGHUP to PID $pid (Bash-19.4.C)..."
  # [Bash-19.4.C]: SIGHUP triggers on_sighup() in the daemon — reload config
  kill -HUP "$pid" 2>/dev/null || true
  echo "  [reload] Signal sent — daemon will re-read config on next iteration"
}

echo "  Demonstrating the full start → status → reload → stop lifecycle:"
echo ""

echo "  ── start ──"
daemon_start
echo ""
sleep 0.8

echo "  ── status ──"
daemon_status
echo ""

echo "  ── reload (SIGHUP) ──"
daemon_reload
sleep 0.5
echo ""

echo "  ── stop (SIGTERM) ──"
daemon_stop
echo ""

echo "  ── status after stop ──"
daemon_status || true
echo ""

_pillar "PRECISION: Signal-safe sleep and the RUNNING flag (Bash-19.4.U/Z)"

# [WHAT]: Explain WHY the signal-safe sleep pattern exists and demonstrate it
# [WHY]:  This is the #1 daemon bug in beginner scripts — a foreground sleep
#         in the main loop makes the daemon unresponsive to SIGTERM for up to
#         the entire sleep duration. Toptal screeners specifically test this.
echo "  The two sleep patterns:"
echo ""
echo "  ── WRONG: foreground sleep (daemon ignores SIGTERM for 60 seconds) ──"
cat << 'BADEOF'
  while true; do
    do_work
    sleep 60        # SIGTERM is received but handler fires AFTER sleep returns
  done              # daemon takes 60s to stop — service manager kills it hard
BADEOF
echo ""
echo "  ── CORRECT: signal-safe sleep (Bash-19.4.U) ──"
cat << 'GOODEOF'
  while $RUNNING; do      # (Bash-19.4.Z): RUNNING flag — set false by SIGTERM trap
    do_work
    sleep 60 &            # fork sleep as a background child
    wait $! || true       # wait() IS interruptible — SIGTERM fires handler NOW
  done                    # loop exits within milliseconds of receiving SIGTERM
GOODEOF
echo ""
echo "  [WATCH OUT]: The '|| true' after 'wait \$!' is CRITICAL under set -e."
echo "  When SIGTERM fires, wait is interrupted and returns non-zero (130 for SIGINT,"
echo "  143 for SIGTERM). Without '|| true', set -e kills the script before the"
echo "  RUNNING=false assignment in the trap handler takes effect."
echo ""

_pillar "DEVOPS CONTEXT: setsid, nohup, disown — daemonization methods (Bash-19.4.P/Q/R)"

# [COMMAND MEANING] setsid = Set Session ID — create a new session, detach from TTY
# [WHAT]: Show the three daemonization approaches from lightweight to full POSIX
echo "  Daemonization spectrum:"
echo ""
echo "  ① disown (lightest — just removes from job table, Bash-19.4.R):"
echo '  long_running_cmd &'
echo '  disown $!                  # shell exit → cmd gets SIGHUP unless it handles it'
echo ""
echo "  ② nohup (immune to SIGHUP — survives terminal close, Bash-19.4.Q):"
echo '  nohup long_running_cmd </dev/null >out.log 2>&1 &'
echo '  disown $!'
echo ""
echo "  ③ setsid (full session detach — process becomes its own session leader, Bash-19.4.P):"
echo '  setsid bash -c "exec </dev/null >>/var/log/d.log 2>&1; exec /usr/bin/mydaemon"'
echo ""
echo "  ④ Double-fork (POSIX — guaranteed TTY detachment, used before systemd):"
cat << 'DFORKEOF'
  # First fork: parent exits, orphaning the child (child is adopted by init)
  (
    # Second fork: ensures child is NOT a session leader (cannot re-acquire TTY)
    setsid bash -c '
      exec </dev/null
      exec >>/var/log/daemon.log 2>&1
      exec /usr/bin/mydaemon
    ' &
  ) &
  # Original shell continues immediately — daemon is fully detached
DFORKEOF
echo ""

echo "  Daemon log tail (what actually happened during the demo above):"
if [[ -f "$DAEMON_LOG" ]]; then
  tail -15 "$DAEMON_LOG"
else
  echo "  [log file not found — daemon may not have produced output]"
fi
echo ""

# ==============================================================================
# MODULE 20 — PERFORMANCE OPTIMIZATION AND PROFILING
# ==============================================================================

_section "SEGMENT 20.1 — MEASURING SCRIPT PERFORMANCE"

# ── Mock Data ─────────────────────────────────────────────────────────────────
# [WHAT]: Build data files of various sizes to make timing differences measurable
PERF_DIR="$WORKSPACE/perf"
mkdir -p "$PERF_DIR"

# Generate a 5000-line data file with structured content
awk 'BEGIN{for(i=1;i<=5000;i++) printf "user_%04d:x:%d:1000:User %d:/home/user_%04d:/bin/bash\n",i,1000+i,i,i}' \
  > "$PERF_DIR/large_data.txt"
wc -l "$PERF_DIR/large_data.txt" | awk '{print "  Generated data file: " $1 " lines → " $2}'
echo ""

_pillar "BASIC: time builtin — real, user, sys breakdown (Bash-20.1.A/B/C/D/E)"

# [COMMAND MEANING] time = Time — measure execution duration of a command
# [WHAT]: Show the three-field output of the time builtin and explain each number
# [WHY]:  The ratio of real:user:sys tells you WHERE your script is spending time.
#         real >> user+sys → I/O bound (waiting on disk or network)
#         user >> sys → CPU bound in userspace (computation heavy)
#         sys  >> user → kernel-heavy (many syscalls: fork, read, write, stat)
echo "  Timing a grep over 5000 lines (Bash-20.1.A):"
{ time grep -c 'user_' "$PERF_DIR/large_data.txt" > /dev/null; } 2>&1
echo ""
echo "  Interpretation:"
echo "  real = wall-clock (what you feel waiting)"
echo "  user = CPU time in userspace code (grep's pattern matching engine)"
echo "  sys  = CPU time in kernel (read() syscalls to fetch file blocks)"
echo "  [WATCH OUT]: real < user+sys is IMPOSSIBLE on 1 core but is possible"
echo "  on multi-core when threads run in parallel (GNU parallel, xargs -P)"
echo ""

_pillar "POWER: /usr/bin/time -v — full resource profile (Bash-20.1.F/G/H)"

# [COMMAND MEANING] /usr/bin/time = GNU Time — full resource accounting for a process
# [WHAT]: Use the GNU external time command (NOT the Bash builtin) for rich stats
# [WHY]:  The Bash builtin only shows real/user/sys. GNU time -v adds max RSS,
#         page faults, and context switches — essential for memory leak diagnosis.
if /usr/bin/time --version 2>&1 | grep -q 'GNU'; then
  echo "  /usr/bin/time -v output (Bash-20.1.G):"
  /usr/bin/time -v grep -c 'user_' "$PERF_DIR/large_data.txt" 2>&1 | \
    grep -E 'wall clock|Maximum resident|Minor|Major|context|Page size' || true
  echo ""
  echo "  Key metrics to focus on:"
  echo "  Maximum resident set size → peak RAM usage (diagnose memory leaks)"
  echo "  Minor page faults         → memory mapped but not yet loaded (normal)"
  echo "  Major page faults         → disk reads required (indicates I/O pressure)"
  echo "  Voluntary context switches → process yielded CPU (I/O waits)"
  echo "  Involuntary context switch→ kernel preempted the process (CPU contention)"
  echo ""
  echo "  /usr/bin/time -f format string (Bash-20.1.H) — machine-parseable output:"
  # [FLAG MEANING] -f = format — specify output format with % placeholders
  # [FLAG MEANING] %e = elapsed real time in seconds
  # [FLAG MEANING] %M = maximum resident set size in kilobytes
  # [FLAG MEANING] %F = major page faults
  # [FLAG MEANING] %w = voluntary context switches
  /usr/bin/time -f "  elapsed=%e sec  maxRSS=%M KB  pagefaults=%F  ctxswitches=%w" \
    grep -c 'user_' "$PERF_DIR/large_data.txt" 2>&1 | tail -1 || true
  echo ""
else
  echo "  GNU time not available — install via: apt-get install -y time"
  echo "  /usr/bin/time -v grep pattern file  →  wall clock, max RSS, page faults"
  echo "  /usr/bin/time -f \"%e %M\" cmd       →  machine-parseable: seconds + KB RSS"
fi
echo ""

_pillar "PRECISION: PS4 timestamp profiling — per-command timing (Bash-20.1.I/J/K/L/M/N)"

# [COMMAND MEANING] PS4 = Prompt String 4 — prefix printed before each xtrace line
# [WHAT]: Replace the default '+' PS4 with nanosecond timestamps to turn xtrace
#         into a per-line profiler that shows which command is slow.
# [WHY]:  When a 500-line script runs slow and you don't know where, set -x with
#         a rich PS4 turns every line into a timestamped profiling event.
echo "  PS4 profiling pattern (Bash-20.1.I/J):"
echo ""
echo "  Default PS4 (useless for profiling):"
echo '  PS4="+ "'
echo '  → + grep ...'
echo '  → + awk ...'
echo ""
echo "  Nanosecond timestamp PS4:"
echo "  PS4='+ \$(date \"+%s%N\") '"
echo '  → + 1746012345123456789 grep ...'
echo '  → + 1746012345987654321 awk ...'
echo "  Difference = 864,197,532 ns = ~864 ms → grep was the bottleneck"
echo ""

# [WHAT]: Live demonstration with the production-grade PS4 (Bash-20.1.K)
echo "  Production PS4 with file, line, and function context (Bash-20.1.K):"
OLD_PS4="$PS4"
# shellcheck disable=SC2016
PS4='+(${BASH_SOURCE[0]##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

echo "  Tracing a small block with the rich PS4:"
set -x
TRACE_SAMPLE="hello world"
TRACE_UPPER="${TRACE_SAMPLE^^}"
TRACE_LEN="${#TRACE_SAMPLE}"
set +x

PS4="$OLD_PS4"
echo ""
echo "  Each xtrace line shows: (filename:lineno): funcname(): command"
echo "  This tells you EXACTLY where in which function a slow line lives."
echo ""

# [COMMAND MEANING] BASH_XTRACEFD = Bash X-Trace File Descriptor
# [WHAT]: Redirect xtrace output to its own FD instead of stderr
# [WHY]:  When profiling a script in a pipeline, mixing xtrace into stderr
#         corrupts the output. Sending it to FD 3 (a separate log file)
#         keeps stderr clean while capturing the full trace.
echo "  BASH_XTRACEFD — redirect trace to dedicated log FD (Bash-20.1.N):"
echo '  exec 3>/tmp/trace.log'
echo '  BASH_XTRACEFD=3'
echo '  set -x'
echo '  ... script body ...'
echo '  set +x'
echo '  exec 3>&-        # close trace FD'
echo "  # stderr stays clean; trace.log contains the full annotated execution"
echo ""

_pillar "DEVOPS CONTEXT: strace -c syscall summary (Bash-20.1.O/P/Q/R/S)"

# [COMMAND MEANING] strace = System Call Trace — intercept and count kernel syscalls
# [WHAT]: Use strace -c to generate a syscall frequency/time summary for a script
# [WHY]:  When /usr/bin/time -v shows high sys time or many context switches,
#         strace -c reveals WHICH syscall is dominating — often read(), stat(),
#         or execve() from excessive subshell spawning.
if command -v strace &>/dev/null; then
  echo "  strace -c — syscall summary (Bash-20.1.O):"
  # [FLAG MEANING] -c = count — summarise syscall counts/time, don't print each call
  strace -c grep -c 'user_' "$PERF_DIR/large_data.txt" 2>&1 | \
    grep -v '^grep' | head -20 || true
  echo ""
  echo "  strace -e trace=execve — count only process launches (Bash-20.1.Q):"
  # [FLAG MEANING] -e trace=execve = filter to only the exec() family of calls
  # [WHAT]: Each execve() line = one external program launched (one fork+exec)
  #         High execve() counts in a tight loop = the classic Bash perf killer
  strace -e trace=execve grep -c 'user_' "$PERF_DIR/large_data.txt" 2>&1 | \
    grep -v '^[0-9]' | head -5 || true
  echo ""
else
  echo "  strace not available in this environment — install: apt-get install -y strace"
  echo ""
  echo "  strace -c script.sh          → syscall frequency table (Bash-20.1.O)"
  echo "  strace -f script.sh          → follow all forks/children (Bash-20.1.P)"
  echo "  strace -e trace=execve sh    → count only process launches (Bash-20.1.Q)"
  echo "  strace -T script.sh          → time spent inside each syscall (Bash-20.1.R)"
  echo "  strace -tt script.sh         → microsecond timestamps per syscall (Bash-20.1.S)"
fi
echo ""

# ==============================================================================

_section "SEGMENT 20.2 — REDUCING SUBSHELL OVERHEAD"

# ── Mock Data ─────────────────────────────────────────────────────────────────
SUBSHELL_DATA="$PERF_DIR/sample_path.txt"
printf '/var/log/nginx/access.log\n' > "$SUBSHELL_DATA"
SAMPLE_PATH='/var/log/nginx/access.log'
SAMPLE_STR='Hello World From DevOps'
SAMPLE_FILE="$PERF_DIR/large_data.txt"   # already exists from 20.1

_pillar "BASIC: The cost of \$() — fork+exec on every call (Bash-20.2.A/B)"

# [WHAT]: Make the subshell cost VISIBLE by measuring slow vs fast patterns
# [WHY]:  A script calling $(basename) or $(cat) inside a 10,000-iteration loop
#         spawns 10,000 child processes. On a loaded server this is catastrophic.
echo "  SLOW: \$(cat file) spawns a subshell + cat process (Bash-20.2.B):"
echo '  content=$(cat "$SAMPLE_FILE")    # → fork() + exec(cat) + pipe read + reap'
echo "  Cost: 2 process creations + IPC for every call"
echo ""
echo "  FAST: zero-fork file read (Bash-20.2.C / 20.2.O):"
echo '  IFS= read -rd '"''"' content < "$SAMPLE_FILE"   # stays in-process, no fork'
echo "  Cost: 1 read() syscall sequence"
echo ""

# [WHAT]: Live demonstration — read entire file with zero subshells
echo "  Live demo — IFS= read -rd '' (Bash-20.2.C):"
# [FLAG MEANING] -r = raw — do not interpret backslash sequences
# [FLAG MEANING] -d '' = delimiter is NUL — read until EOF (not newline)
IFS= read -rd '' FILE_CONTENT < "$SAMPLE_FILE" || true   # || true: EOF returns 1
LINE_COUNT_NATIVE="${FILE_CONTENT}"   # variable holds all 5000 lines
echo "  File content captured in-process. First 80 chars:"
echo "  ${FILE_CONTENT:0:80}..."
echo ""

_pillar "POWER: Parameter expansion replacements (Bash-20.2.D/E/F/G/H/I)"

# [WHAT]: Show the zero-fork equivalents side-by-side with the slow versions
# [WHY]:  These are the most common micro-optimizations in production Bash.
#         A tight loop calling $(basename) 50,000 times can save 10+ seconds
#         by switching to ${path##*/}.

echo "  ─── Uppercase / Lowercase conversion ────────────────────────────────"
echo "  SLOW: \$(echo \"\$var\" | tr 'a-z' 'A-Z')  → subshell + tr process"
SLOW_RESULT=$(echo "$SAMPLE_STR" | tr 'a-z' 'A-Z')
echo "  Result: $SLOW_RESULT"
echo ""
# [FLAG MEANING] ^^ = uppercase all characters (Bash 4+) — Bash-20.2.D
echo "  FAST: \${var^^}  → zero-fork built-in (Bash-20.2.D)"
FAST_UPPER="${SAMPLE_STR^^}"
echo "  Result: $FAST_UPPER"
echo ""

# [FLAG MEANING] ,, = lowercase all characters (Bash 4+) — Bash-20.2.E
echo "  FAST: \${var,,}  → zero-fork lowercase (Bash-20.2.E)"
FAST_LOWER="${SAMPLE_STR,,}"
echo "  Result: $FAST_LOWER"
echo ""

echo "  ─── basename / dirname ───────────────────────────────────────────────"
echo "  SLOW: \$(basename \"\$path\")  → fork + exec (basename)"
SLOW_BASE=$(basename "$SAMPLE_PATH")
echo "  Result: $SLOW_BASE"
echo ""
# [FLAG MEANING] ## = strip longest matching prefix — Bash-20.2.F
echo "  FAST: \${path##*/}  → strip everything up to last / (Bash-20.2.F)"
FAST_BASE="${SAMPLE_PATH##*/}"
echo "  Result: $FAST_BASE"
echo ""

# [FLAG MEANING] % = strip shortest matching suffix — Bash-20.2.G
echo "  FAST: \${path%/*}   → strip from last / onward (Bash-20.2.G)"
FAST_DIR="${SAMPLE_PATH%/*}"
echo "  Result: $FAST_DIR"
echo ""

echo "  ─── String length ────────────────────────────────────────────────────"
echo "  SLOW: \$(echo -n \"\$var\" | wc -c)  → fork + wc"
SLOW_LEN=$(echo -n "$SAMPLE_STR" | wc -c)
echo "  Result: $SLOW_LEN"
echo ""
# [FLAG MEANING] # before var name = string length — Bash-20.2.H
echo "  FAST: \${#var}  → zero-fork built-in length (Bash-20.2.H)"
FAST_LEN="${#SAMPLE_STR}"
echo "  Result: $FAST_LEN"
echo ""

echo "  ─── Global string replacement ────────────────────────────────────────"
echo "  SLOW: \$(echo \"\$var\" | sed 's/World/Bash/g')  → fork + sed"
SLOW_REPLACE=$(echo "$SAMPLE_STR" | sed 's/World/Bash/g')
echo "  Result: $SLOW_REPLACE"
echo ""
# [FLAG MEANING] // = replace ALL occurrences (global) — Bash-20.2.I
echo "  FAST: \${var//pattern/replacement}  → zero-fork built-in (Bash-20.2.I)"
FAST_REPLACE="${SAMPLE_STR//World/Bash}"
echo "  Result: $FAST_REPLACE"
echo ""

_pillar "PRECISION: mapfile + \${#arr[@]} replaces wc -l (Bash-20.2.J/K)"

# [COMMAND MEANING] mapfile = Map File — read file lines into a Bash array
# [WHAT]: Use mapfile to slurp a file into an array, then use array length for
#         the line count — eliminates both the cat and wc subshells.
# [FLAG MEANING] -t = trim trailing newline from each element (almost always wanted)
echo "  SLOW: \$(wc -l < file)  → fork + wc (Bash-20.2.K — shows the anti-pattern)"
SLOW_LINECOUNT=$(wc -l < "$SAMPLE_FILE")
echo "  Line count (slow): $SLOW_LINECOUNT"
echo ""

echo "  FAST: mapfile + \${#arr[@]}  → zero-fork built-in (Bash-20.2.J/K)"
mapfile -t PERF_LINES < "$SAMPLE_FILE"
FAST_LINECOUNT="${#PERF_LINES[@]}"
echo "  Line count (fast): $FAST_LINECOUNT"
echo "  Both agree: $([ "$SLOW_LINECOUNT" -eq "$FAST_LINECOUNT" ] && echo "✓" || echo "MISMATCH")"
echo ""
echo "  [WATCH OUT]: mapfile without -t includes the trailing newline in each"
echo "  element. Always use -t unless you explicitly need the newlines."
echo ""

_pillar "DEVOPS CONTEXT: Batch awk vs N sed calls (Bash-20.2.L/M/N)"

# [WHAT]: Show the catastrophic cost of calling sed inside a for loop vs one awk
# [WHY]:  This is the most common Bash performance disaster in production scripts:
#         a loop that processes 10,000 lines by calling sed/grep once per line
#         spawns 10,000 processes. One awk invocation does the same work in 1.
echo "  Batch processing: one awk over N lines (Bash-20.2.L):"
echo ""
echo "  SLOW — N sed calls (spawns one process per line):"
cat << 'SLOWLOOPEOF'
  while IFS= read -r line; do
    # Each iteration forks a subshell + exec(sed) — disastrous at scale
    username=$(echo "$line" | sed 's/:.*//')
    echo "$username"
  done < "$SAMPLE_FILE"
SLOWLOOPEOF
echo ""
echo "  FAST — one awk over all lines (Bash-20.2.L):"
echo "  Single awk call, 5000 lines processed in one process:"
USERCOUNT=$(awk -F: '{print $1}' "$SAMPLE_FILE" | wc -l)
echo "  Extracted $USERCOUNT usernames from $FAST_LINECOUNT lines via single awk"
echo ""

echo "  FAST — printf array to awk (Bash-20.2.M) — batch-process an in-memory array:"
# [WHAT]: When data is already in a Bash array, pipe it to one awk process
# [WHY]:  Avoids writing the array to a temp file AND avoids per-element subshells
SAMPLE_ARRAY=("alpha:1" "beta:2" "gamma:3" "delta:4" "epsilon:5")
printf '%s\n' "${SAMPLE_ARRAY[@]}" | awk -F: '{printf "  %-10s → id=%s\n", $1, $2}'
echo ""

echo "  read -r with here-string — zero-fork inline parsing (Bash-20.2.N):"
# [WHAT]: Feed a string to read via here-string — no echo, no pipe, no subshell
COLON_STR="nginx:www-data:80"
IFS=: read -r SVC_NAME SVC_USER SVC_PORT <<< "$COLON_STR"
echo "  Parsed '$COLON_STR':"
echo "  service=$SVC_NAME  user=$SVC_USER  port=$SVC_PORT  (zero subshells)"
echo ""

# ==============================================================================

_section "SEGMENT 20.3 — BUILT-IN VS EXTERNAL COMMANDS"

_pillar "BASIC: type — command resolution (Bash-20.3.A/B/C)"

# [COMMAND MEANING] type = Type — show how Bash resolves a command name
# [WHAT]: Reveal whether a name resolves to a builtin, function, alias, or binary
# [WHY]:  'type' is the single tool that explains why 'time', 'echo', 'printf', and
#         'test' behave differently depending on how you call them — a classic
#         Toptal gotcha question.
echo "  type for common commands (Bash-20.3.A):"
for CMD in echo printf read test "[" "[[" time cd hash; do
  printf "  %-12s → %s\n" "$CMD" "$(type -t "$CMD" 2>/dev/null || echo 'not found')"
done
echo ""

# [FLAG MEANING] -a = all — show EVERY resolution: alias, function, builtin, PATH binaries
echo "  type -a — all resolutions for 'echo' (Bash-20.3.B):"
type -a echo
echo ""

echo "  type -a — all resolutions for 'time' (Bash-20.3.B):"
type -a time
echo "  [NOTE]: 'time' is a Bash KEYWORD not a builtin — this distinction matters:"
echo "  'time ls | wc' times the WHOLE pipeline (keyword behaviour)"
echo "  '/usr/bin/time ls | wc' only times 'ls' (external binary, pipes AFTER it)"
echo ""

# [FLAG MEANING] -t = type-only — machine-readable single word classification
echo "  type -t for scripted checks (Bash-20.3.C):"
echo "  Use case: guard a script against environments where a tool is missing"
cat << 'TYPECHECKEOF'
  require_builtin() {
    local name="$1"
    local kind
    kind=$(type -t "$name" 2>/dev/null)
    if [[ "$kind" != "builtin" && "$kind" != "keyword" ]]; then
      echo "ERROR: $name is not a builtin in this shell ($kind)" >&2
      exit 2
    fi
  }
  require_builtin printf    # ensures we're using the builtin, not /usr/bin/printf
TYPECHECKEOF
echo ""

_pillar "POWER: builtin, command, printf vs echo (Bash-20.3.D/E/F/G)"

# [COMMAND MEANING] builtin = Builtin — invoke a shell builtin explicitly, bypass functions/aliases
# [WHAT]: Force the call to go to the actual builtin even if a function shadows it
echo "  builtin — bypass function overrides (Bash-20.3.D):"
# Override echo with a noisy wrapper to demonstrate
echo() { printf "[OVERRIDE] %s\n" "$*"; }
echo "This goes through the override"
builtin echo "This bypasses the override and hits the real builtin"
unset -f echo   # restore
echo ""

# [COMMAND MEANING] command = Command — run a command bypassing functions and aliases
# [FLAG MEANING] -v = verify — print the path of the binary (like which, but POSIX)
echo "  command -v — portable 'which' substitute (Bash-20.3.E):"
# [WATCH OUT]: 'which' is an external command that may not be installed.
#              'command -v' is a POSIX builtin — always available, always correct.
for TOOL in bash awk grep python3 nonexistent_tool_xyz; do
  FOUND=$(command -v "$TOOL" 2>/dev/null) && \
    printf "  %-22s → %s\n" "$TOOL" "$FOUND" || \
    printf "  %-22s → NOT FOUND\n" "$TOOL"
done
echo ""

echo "  printf vs echo — why printf wins in portable scripts (Bash-20.3.F/G):"
echo "  ┌──────────────┬────────────────────────────────────────────────────┐"
echo "  │ echo -e      │ Interprets \\n on Linux, but LITERAL on macOS sh   │"
echo "  │ echo -n      │ Prints '-n' literally on some /bin/sh variants     │"
echo "  │ printf '%s'  │ Fully POSIX-specified, consistent on all platforms │"
echo "  │ printf '\\n'  │ Always a newline — no ambiguity                   │"
echo "  └──────────────┴────────────────────────────────────────────────────┘"
echo ""

_pillar "PRECISION: read, [[]], (()) — zero-fork workhorses (Bash-20.3.H/I/J/K)"

# [COMMAND MEANING] read = Read — read a line from stdin into one or more variables
# [WHAT]: read is a builtin — no fork — making it the correct tool for line-by-line
#         processing inside hot loops where awk/cut would spawn per-iteration.
echo "  read -r for in-process field parsing (Bash-20.3.H/I):"
while IFS=: read -r field1 field2 field3 rest; do
  : # inner loop body — all parsing done in-process by read's IFS splitting
done < <(head -3 "$SAMPLE_FILE")
echo "  Processed 3 lines of colon-delimited data using ONLY read builtins"
echo "  (IFS=: tells read to split on colon — no awk, no cut, no fork)"
echo ""

# [COMMAND MEANING] [[ ]] = Extended test — evaluate conditionals without forking
# [WHAT]: All file tests, string comparisons, and regex matches run in the current
#         shell process — no external test binary involved
echo "  [[ ]] — zero-fork conditional (Bash-20.3.J):"
TEST_FILE="$SAMPLE_FILE"
if [[ -f "$TEST_FILE" && -r "$TEST_FILE" ]]; then
  echo "  [[ -f && -r ]] confirmed: file exists and is readable (in-process)"
fi
[[ "${SAMPLE_STR,,}" =~ ^hello ]] && echo "  Regex match via [[ =~ ]] (in-process, no grep fork)"
echo ""

# [COMMAND MEANING] (( )) = Arithmetic evaluation — integer math without forking
# [WHAT]: (( )) evaluates integer expressions inside the current shell — no
#         external expr, no subshell. Returns 0 (true) if result is non-zero.
echo "  (( )) — zero-fork integer arithmetic (Bash-20.3.K):"
X=42; Y=7
(( RESULT = X * Y ))
echo "  (( RESULT = X * Y )) → $RESULT  (no \$(( )) subshell, no expr process)"
for (( IDX=0; IDX<3; IDX++ )); do
  printf "  (( IDX++ )) loop iteration: IDX=%d\n" "$IDX"
done
echo ""

_pillar "DEVOPS CONTEXT: Loop invariant hoisting and hash (Bash-20.3.M/N/O)"

# [COMMAND MEANING] hash = Hash — manage Bash's command location cache table
# [WHAT]: Bash caches the full path of external commands after the first lookup.
#         hash -r clears this cache — explains why new PATH entries need hash -r
#         to take effect in the current shell session.
echo "  hash — command location cache (Bash-20.3.O):"
hash -r   # clear cache for clean demo
# First call — forces a fresh PATH lookup, which populates the hash table
command -v grep > /dev/null
hash -p /bin/grep grep 2>/dev/null || true
hash -t grep 2>/dev/null && \
  printf "  hash cached grep at: %s\n" "$(hash -t grep 2>/dev/null)" || \
  printf "  grep cached in hash table\n"
echo ""
echo "  hash -r          → clear entire hash table (after PATH changes)"
echo "  hash -d grep     → remove only grep from cache"
echo "  [WATCH OUT]: If you install a new binary while a script is running"
echo "  and the old path is cached, the script keeps using the old binary"
echo "  until hash -r is called."
echo ""

echo "  Loop invariant hoisting (Bash-20.3.M):"
echo ""
echo "  BAD — spawns \$(date) on every iteration:"
cat << 'BADLOOPEOF'
  for item in "${items[@]}"; do
    timestamp=$(date '+%Y-%m-%d')   # NEW process per iteration — wasteful
    echo "$timestamp: $item"
  done
BADLOOPEOF
echo ""
echo "  GOOD — hoist the invariant outside the loop:"
cat << 'GOODLOOPEOF'
  TODAY=$(date '+%Y-%m-%d')         # ONE process total
  for item in "${items[@]}"; do
    echo "$TODAY: $item"            # pure string operation — no fork
  done
GOODLOOPEOF
echo ""

echo "  Live demo — hoisted date prefix for 5 items:"
HOIST_ITEMS=("deploy" "smoke-test" "notify" "archive" "cleanup")
HOIST_DATE=$(date '+%Y-%m-%d %H:%M:%S')   # one fork total
for HOIST_ITEM in "${HOIST_ITEMS[@]}"; do
  printf "  [%s] %s\n" "$HOIST_DATE" "$HOIST_ITEM"
done
echo ""

# ==============================================================================

_section "SEGMENT 20.4 — WHEN TO STOP USING BASH"

_pillar "BASIC: The Bash sweet spot (Bash-20.4.A/D)"

# [WHAT]: Articulate exactly where Bash belongs in the language ecosystem
# [WHY]:  Toptal screeners assess meta-judgment. Using Bash for a 2000-line
#         data processor is as wrong as using Python to wrap a 5-line cron job.
echo "  Bash is the RIGHT tool when:"
echo "  ✓  Glue code: orchestrating other programs (systemctl, rsync, curl)"
echo "  ✓  File system operations: find, mv, chmod, chown pipelines"
echo "  ✓  Process management: starting, stopping, signalling services"
echo "  ✓  Simple automation: cron jobs, deploy hooks, CI/CD steps"
echo "  ✓  Script length < ~200 lines with no complex data structures"
echo "  ✓  System bootstrapping (modules 13, 19) where Python may not exist yet"
echo ""
echo "  The 200-line rule (Bash-20.4.D):"
echo "  If your script exceeds 200 lines OR requires:"
echo "    - Nested data structures (arrays of associative arrays)"
echo "    - Real error recovery with retry/backoff state machines"
echo "    - HTTP session management (cookies, auth flows)"
echo "    - JSON/XML parsing beyond simple jq one-liners"
echo "  → Stop and reconsider the language choice."
echo ""

_pillar "POWER: Python escalation triggers and bridge patterns (Bash-20.4.B/E/F)"

# [WHAT]: Show concrete Python bridge patterns invoked from Bash
# [WHY]:  Knowing HOW to escalate (not just when) is the Senior DevOps signal.
#         The pattern: keep Bash as the orchestrator, call python3 -c for tasks
#         that are awkward in pure shell.
echo "  Switch to Python when (Bash-20.4.B):"
echo "  ✗  Complex JSON: more than 3 jq pipes → use python3 json module"
echo "  ✗  HTTP with sessions/retries/auth: curl gymnastics → use requests"
echo "  ✗  Data structures: dict of lists of dicts → impossible in Bash"
echo "  ✗  Error recovery: exponential backoff state machine → unwieldy"
echo ""

echo "  python3 -c bridge patterns (Bash-20.4.E):"
echo ""
echo "  Floating-point arithmetic (Bash has NO floats):"
FLOAT_RESULT=$(python3 -c "print(round(3.14159 * 2**2, 4))")
echo "  python3 -c 'print(round(3.14159 * 2**2, 4))' → $FLOAT_RESULT"
echo ""

echo "  Complex JSON construction (Bash-20.4.F / jq --argjson):"
BUILD_JSON=$(python3 -c "
import json, os, sys
data = {
    'host': os.uname().nodename,
    'pid':  os.getpid(),
    'env':  'production',
    'ts':   __import__('time').strftime('%Y-%m-%dT%H:%M:%SZ')
}
print(json.dumps(data, indent=2))
")
echo "  Structured JSON from Python3 (called inline from Bash):"
echo "$BUILD_JSON" | sed 's/^/  /'
echo ""

echo "  URL encoding (impossible correctly in pure Bash):"
URL_ENCODED=$(python3 -c "
import urllib.parse, sys
raw = 'hello world & user=jesse?q=1+2'
print(urllib.parse.quote(raw, safe=''))
")
echo "  python3 urllib.parse.quote → $URL_ENCODED"
echo ""

_pillar "PRECISION: Go escalation triggers (Bash-20.4.C)"

# [WHAT]: Articulate the Go boundary — performance + distribution
# [WHY]:  DevOps engineers who know when to write Go instead of Bash OR Python
#         are the ones who end up building internal tooling that actually scales.
echo "  Switch to Go when (Bash-20.4.C):"
echo "  ✗  Performance-critical: a Bash loop processing 10M log lines → Go"
echo "  ✗  Static binary distribution: ship one binary to 500 servers, no interpreter"
echo "  ✗  True concurrency: goroutines for parallel API calls vs xargs -P hacks"
echo "  ✗  CLI tools used by other teams: proper --help, flags, error handling"
echo ""
echo "  The language escalation decision tree:"
echo "  ┌─────────────────────────────────────────────────────────────────┐"
echo "  │  < 200 lines, glue/FS/process  → Bash                         │"
echo "  │  > 200 lines OR data structures │"
echo "  │    OR HTTP OR complex errors    → Python                       │"
echo "  │  Performance-critical OR static │"
echo "  │  binary OR true concurrency     → Go                          │"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""

_pillar "DEVOPS CONTEXT: shellcheck and complexity signals (Bash-20.4.G/H/I/J)"

# [COMMAND MEANING] shellcheck = Shell Check — static analysis for Bash/sh/dash scripts
# [WHAT]: Demonstrate shellcheck catching real problems in a deliberately broken snippet
# [WHY]:  shellcheck is non-negotiable in CI/CD. A Toptal engineer ships code that
#         passes shellcheck -S warning with zero suppressions unless documented.
echo "  perl one-liner bridge (Bash-20.4.G) — complex regex transforms:"
echo '  # Strip ANSI escape codes from log output:'
echo "  cat deploy.log | perl -pe 's/\\e\\[[0-9;]*m//g'"
echo '  # Extract all IPv4 addresses from a file:'
echo "  perl -nE 'say \$1 while /\\b(\\d{1,3}(?:\\.\\d{1,3}){3})\\b/g' access.log"
echo ""

if command -v shellcheck &>/dev/null; then
  LINT_TARGET="$WORKSPACE/bad_script.sh"
  cat > "$LINT_TARGET" << 'BADSCRIPTEOF'
#!/bin/bash
# Intentionally broken script for shellcheck demo
FILE=/tmp/data.txt
if [ $FILE = "yes" ]; then
  echo "found"
fi
for f in $(ls /tmp/*.txt); do
  cat $f
done
result=$(echo $FILE | tr 'a-z' 'A-Z')
echo $result
BADSCRIPTEOF

  echo "  shellcheck output on a deliberately broken script (Bash-20.4.H):"
  shellcheck "$LINT_TARGET" 2>&1 || true
  echo ""
  echo "  Every finding above is a real production bug:"
  echo "  SC2086: unquoted \$FILE → word-splits if path has spaces"
  echo "  SC2046: \$(ls) in for loop → breaks on filenames with spaces/newlines"
  echo "  SC2006: legacy backtick syntax → use \$() instead"
else
  echo "  shellcheck not installed — install: apt-get install -y shellcheck"
  echo "  Or: snap install shellcheck / brew install shellcheck"
  echo ""
  echo "  CI/CD integration (Bash-20.4.H):"
  echo "  shellcheck -S warning script.sh  → fail on warnings and above"
  echo "  shellcheck -s sh script.sh       → enforce POSIX compliance"
  echo "  shellcheck -f gcc script.sh      → GCC-format output for IDE integration"
fi
echo ""

echo "  Complexity signals that mean 'rewrite this in Python' (Bash-20.4.I):"
echo "  🚩  Nested associative arrays: declare -A outer; outer[\$key]=...  → Python dict"
echo "  🚩  Manual JSON parsing with grep/sed: brittle, breaks on whitespace changes"
echo "  🚩  Multi-threaded logic: background jobs + wait + FIFOs for IPC → Go channels"
echo "  🚩  HTTP session state: curl with cookie jars, auth refresh → Python requests"
echo "  🚩  bash -c with dynamic strings in it (Bash-20.4.J): injection surface area"
echo "  🚩  Script is 300+ lines and growing — you have crossed the Bash event horizon"
echo ""

echo "  bash -c pattern (Bash-20.4.J) — use with extreme caution:"
echo '  bash -c "echo $USER_INPUT"     # INJECTION VULNERABILITY if input is untrusted'
echo '  bash -c '"'"'echo "$1"'"'"' -- "$USER_INPUT"  # safer: pass via positional param'
echo "  [WATCH OUT]: Presence of bash -c with variable interpolation in a script"
echo "  is a strong code-smell that the script is fighting the language."
echo "  Refactor into a function, or escalate to Python."
echo ""

# ==============================================================================

_section "MODULES 19 & 20 COMPLETE"

echo "  ✓  Module 19.1: crontab MAILTO/SHELL/PATH header, 5-field syntax, @specials"
echo "  ✓  Module 19.1: /etc/cron.d/ drop-in format, cron.daily/ + run-parts anatomy"
echo "  ✓  Module 19.1: Logging pattern (>> log 2>&1), anacron for downtime resilience"
echo ""
echo "  ✓  Module 19.2: at -f for file-based submission, atq/atrm job lifecycle"
echo "  ✓  Module 19.2: at -q queue letters, batch load-aware deferred execution"
echo "  ✓  Module 19.2: /etc/at.allow / /etc/at.deny access control"
echo ""
echo "  ✓  Module 19.3: .service + .timer unit file anatomy"
echo "  ✓  Module 19.3: OnCalendar (realtime) vs OnBootSec+OnUnitActiveSec (monotonic)"
echo "  ✓  Module 19.3: Persistent=true, RandomizedDelaySec, AccuracySec"
echo "  ✓  Module 19.3: systemctl list-timers, journalctl -u, systemd-run transient"
echo ""
echo "  ✓  Module 19.4: Full daemon implemented — PID file, flock single-instance"
echo "  ✓  Module 19.4: SIGTERM/SIGHUP/EXIT traps, RUNNING flag pattern"
echo "  ✓  Module 19.4: Signal-safe sleep (sleep N & wait \$!) explained + demonstrated"
echo "  ✓  Module 19.4: start/stop/status/reload framework — full lifecycle demo"
echo "  ✓  Module 19.4: setsid / nohup / disown daemonization spectrum"
echo ""
echo "  ✓  Module 20.1: time builtin real/user/sys, /usr/bin/time -v/-f"
echo "  ✓  Module 20.1: PS4 nanosecond profiling, BASH_XTRACEFD separation"
echo "  ✓  Module 20.1: strace -c summary, -e trace=execve, -T, -tt"
echo ""
echo "  ✓  Module 20.2: \${var^^/,,}, \${path##*/}, \${path%/*}, \${#var} replacements"
echo "  ✓  Module 20.2: IFS= read -rd '' zero-fork file slurp vs \$(cat)"
echo "  ✓  Module 20.2: mapfile + \${#arr[@]} vs wc -l, batch awk vs N sed calls"
echo "  ✓  Module 20.2: here-string read for inline parsing, printf array | awk"
echo ""
echo "  ✓  Module 20.3: type -a/-t, builtin, command -v (portable which)"
echo "  ✓  Module 20.3: printf vs echo portability, read -r IFS splitting"
echo "  ✓  Module 20.3: [[ ]] and (( )) zero-fork builtins, loop invariant hoisting"
echo "  ✓  Module 20.3: hash command cache, hash -r after PATH changes"
echo ""
echo "  ✓  Module 20.4: The 200-line rule, Bash/Python/Go escalation decision tree"
echo "  ✓  Module 20.4: python3 -c bridge (floats, JSON, URL encode)"
echo "  ✓  Module 20.4: perl one-liner regex bridge, shellcheck CI integration"
echo "  ✓  Module 20.4: Complexity signals — the 6 Bash event horizon warnings"
echo ""
echo "  Workspace auto-cleaned by EXIT trap registered at script start."
echo "  Modules 1–20 complete. Next stop: Module 21 Capstone Projects."
echo ""
echo "  — Mike | FUTO Nigeria Bash Zero-to-Hero Program | Modules 1–20 ✓"
echo ""
