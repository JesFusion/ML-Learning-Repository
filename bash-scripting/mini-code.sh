#!/usr/bin/env bash
set -euxo pipefail



# ============================================================================
#  SEGMENT 7 — FUNCTIONS: MODULARITY AND REUSE
# ============================================================================
# 💡 EXPLANATION: Executes the custom user-defined 'banner' function to visually separate the script output.
banner "SEGMENT 7 — Functions: Modularity & Reuse"

# ─── BASIC: Two definition syntaxes ──────────────────────────────────────────
# 💡 EXPLANATION: Calls the custom 'section' function to print a sub-header.
section "7-BASIC: Function Definition Syntax — POSIX vs. Bash"

# [COMMAND MEANING] name() { } = POSIX-compliant function definition syntax;
#                   the portable form compatible with /bin/sh.
# [COMMAND MEANING] function name { } = Bash-specific syntax; identical behaviour
#                   but not valid in POSIX sh scripts.

# POSIX form (preferred):
# 💡 EXPLANATION: Defines a function named 'get_timestamp' using the standard POSIX `name() { ... }` syntax. This is the recommended way to declare functions because it maximizes script portability across different shells (like ash, dash, zsh).
get_timestamp() {
  # [COMMAND MEANING] date = Prints the current date and time in a specified format.
  # [FLAG MEANING]    +%s = Output as Unix epoch seconds.
# 💡 EXPLANATION: Executes the 'date' command. The '+%s' format string tells 'date' to output the current time as the number of seconds since the Unix Epoch (1970-01-01 00:00:00 UTC). This is printed directly to standard output.
  date +%s
# 💡 EXPLANATION: Closes the 'get_timestamp' function definition.
}

# Bash-specific form (acceptable in bash-only scripts):
# 💡 EXPLANATION: Defines a function named 'get_hostname' using the bash-specific `function name { ... }` syntax. While functionally identical in bash, this syntax will cause errors if the script is ever run with a strict POSIX shell like `/bin/sh`.
function get_hostname {
  # [COMMAND MEANING] hostname = Prints the system's network name.
# 💡 EXPLANATION: Executes the system 'hostname' command, which outputs the computer's network name to standard output.
  hostname
# 💡 EXPLANATION: Closes the 'get_hostname' function definition.
}

# 💡 EXPLANATION: Calls 'pass'. Uses command substitution `$(...)` to execute 'get_timestamp' in a subshell, capturing its output (the epoch string) and interpolating it into the string passed to 'pass'.
pass "POSIX function get_timestamp → $(get_timestamp)"
# 💡 EXPLANATION: Calls 'pass', using command substitution `$(...)` to capture and interpolate the standard output of the 'get_hostname' function.
pass "Bash  function get_hostname  → $(get_hostname)"

# ─── POWER: return vs. stdout capture ────────────────────────────────────────
# 💡 EXPLANATION: Prints the section header distinguishing return codes from standard output data.
section "7-POWER: return N vs. result=\$(fn) — Exit Code vs. Data"

# [WHAT]: Show the fundamental distinction between returning STATUS (0/1) via
#         `return` and returning DATA by printing to stdout and capturing.
# [WHY]:  Bash functions cannot return strings via `return`. The only way to
#         pass data back is via stdout + command substitution.

# [COMMAND MEANING] return = Sets the function's exit status (0–255) and transfers
#                   control back to the caller; does NOT return string data.
# 💡 EXPLANATION: Defines a function 'validate_port' using POSIX syntax.
validate_port() {
# 💡 EXPLANATION: 'local' defines a variable scoped only to this function. '$1' is the first positional argument passed to the function. This assigns the first argument to the local variable 'port'.
  local port="$1"
# 💡 EXPLANATION: Starts a compound conditional using bash '[[ ]]'. 
# First condition: `"$port" =~ ^[0-9]+$` uses regular expression matching ('=~') to verify the string contains ONLY digits (from start '^' to end '$').
# Second condition: `(( port >= 1 && port <= 65535 ))` uses an arithmetic evaluation context to verify the integer value is within the valid TCP/UDP port range. The '&&' means both the regex AND the arithmetic checks must pass.
  if [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 )); then
# 💡 EXPLANATION: If valid, the 'return' builtin exits the function and explicitly sets the function's exit status code to '0' (which conventionally means success in bash).
    return 0  # success
# 💡 EXPLANATION: Closes the 'if' block.
  fi
# 💡 EXPLANATION: If the 'if' condition was not met, execution reaches here. 'return 1' exits the function with an exit status code of '1' (indicating failure).
  return 1  # failure
# 💡 EXPLANATION: Closes the 'validate_port' function definition.
}

# [COMMAND MEANING] result=$(fn) = Command substitution that captures all stdout
#                   of a function as the return data by forking a subshell.
# 💡 EXPLANATION: Defines a function 'calculate_checksum'.
calculate_checksum() {
# 💡 EXPLANATION: Assigns the first positional argument '$1' to the function-scoped 'local' variable 'input'.
  local input="$1"
# 💡 EXPLANATION: 'echo' prints the input string. 
# '|' pipes it into 'md5sum', which generates an MD5 hash of the string (output looks like: hash_value  -). 
# '|' pipes that output into 'cut'. '-d' '' sets the delimiter to a space character. '-f1' extracts only the first field (the hash itself, dropping the filename/hyphen part). The final extracted hash string is printed to standard output.
  echo "${input}" | md5sum | cut -d' ' -f1
# 💡 EXPLANATION: Closes the 'calculate_checksum' function definition.
}

# 💡 EXPLANATION: 'if validate_port 8080' executes the function, passing '8080' as the first argument. The 'if' statement evaluates the function's EXIT STATUS code (0 or 1), NOT its standard output. Since 8080 is valid, the function returns 0 (true), so the 'if' block executes.
if validate_port 8080; then
# 💡 EXPLANATION: Executes 'pass' to log the successful validation.
  pass "validate_port: 8080 is valid (return 0 received)"
# 💡 EXPLANATION: Closes the 'if' block.
fi

# 💡 EXPLANATION: Executes 'calculate_checksum' in a subshell `$(...)`, passing it a string argument. The function's standard output (the hashed string) is captured by the subshell and assigned to the variable 'CHECKSUM'.
CHECKSUM=$(calculate_checksum "production-deploy-v2.3.1")
# 💡 EXPLANATION: Logs the captured checksum value using the 'pass' function.
pass "calculate_checksum: '$CHECKSUM'"

# ─── PRECISION: declare -n nameref — Safe array passing ──────────────────────
# 💡 EXPLANATION: Prints the section header for namerefs.
section "7-PRECISION: declare -n — Nameref for Array Passing"

# [COMMAND MEANING] declare -n = Creates a nameref: a variable that is a
#                   transparent alias for another variable by name reference.
#                   This is the ONLY safe way to pass arrays to functions.
# [WATCH OUT]: The nameref variable name must NOT shadow the original array name
#              or you get a circular reference error.

# 💡 EXPLANATION: Defines the function 'process_server_list'.
process_server_list() {
# 💡 EXPLANATION: 'declare -n' creates a nameref (reference variable) named '_servers'. It assigns it the value of '$1' (the first argument passed to the function, which should be the *name* of a variable, not its contents). Any operation on '_servers' will now affect the target variable directly.
  declare -n _servers="$1"  # _servers is now an alias for whatever array name was passed
# 💡 EXPLANATION: 'local' scopes the variable to this function. '-i' declares 'count' specifically as an integer variable, and initializes it to 0.
  local -i count=0
# 💡 EXPLANATION: Begins a loop over the array. Since '_servers' is a nameref pointing to an array, `"${_servers[@]}"` expands to all elements of that referenced array, quoted safely.
  for srv in "${_servers[@]}"; do
# 💡 EXPLANATION: Uses arithmetic evaluation `(( ))` to increment the integer 'count' variable.
    (( count++ ))
# 💡 EXPLANATION: Calls the custom 'info' function to log each server being processed.
    info "  nameref processing server[$count]: $srv"
# 💡 EXPLANATION: Closes the 'for' loop block.
  done
# 💡 EXPLANATION: Logs success. `${#_servers[@]}` evaluates the total number of elements in the referenced array.
  pass "Nameref: processed ${#_servers[@]} servers from the caller's array"
# 💡 EXPLANATION: Closes the 'process_server_list' function definition.
}

# 💡 EXPLANATION: 'declare -a' explicitly declares a variable named 'PROD_SERVERS' as an indexed array and initializes it with three string elements.
declare -a PROD_SERVERS=("web-01.prod" "web-02.prod" "db-01.prod")
# 💡 EXPLANATION: Calls the 'process_server_list' function. Crucially, it passes the STRING literal "PROD_SERVERS" (the name of the array variable), NOT the expanded array contents (which would be `${PROD_SERVERS[@]}`). The function uses this string to create the nameref alias.
process_server_list PROD_SERVERS  # Pass the NAME of the array, not its value

# ─── DEVOPS: export -f and call-stack introspection ──────────────────────────
# 💡 EXPLANATION: Prints the section header for exporting functions.
section "7-DEVOPS: export -f — Functions to Child Processes"

# [COMMAND MEANING] export -f funcname = Serializes the function definition into
#                   the environment so spawned child bash processes can use it.
# [WATCH OUT]: export -f is the mechanism exploited by the Shellshock CVE-2014-6271
#              vulnerability. Never export functions that process untrusted input.
# 💡 EXPLANATION: Defines a simple single-line function 'greet_server' that echos its first argument.
greet_server() { echo "  Deployed to: $1"; }
# 💡 EXPLANATION: The 'export' built-in with the '-f' (function) flag modifies the environment variables so that any subshell or child bash process spawned from this script will inherit the definition of the 'greet_server' function.
export -f greet_server

# 💡 EXPLANATION: Spawns a completely new instance of the bash shell using 'bash -c'. It passes a string to execute. This new bash instance doesn't normally know about functions defined in the parent script. However, because 'greet_server' was exported with 'export -f', this child shell successfully executes it.
bash -c 'greet_server "prod-cluster-3"'
# 💡 EXPLANATION: Logs success for the function export test.
pass "export -f: function called successfully in child bash process"

# [COMMAND MEANING] source = Executes a file in the current shell context,
#                   importing its functions and variables without a fork.
# [COMMAND MEANING] . (dot) = POSIX-compliant alias for source; works in /bin/sh.
# [WHAT ELSE]: Always source library files at the top of your script after
#              set -euo pipefail so errors in the library abort early.

# 💡 EXPLANATION: Logs the successful completion of Segment 7.
pass "Segment 7 complete — Functions, namerefs, and export -f."


# ============================================================================
#  SEGMENT 8 — ARRAYS AND ASSOCIATIVE ARRAYS
# ============================================================================
# 💡 EXPLANATION: Executes the custom 'banner' function to introduce Segment 8.
banner "SEGMENT 8 — Arrays & Associative Arrays"

# ─── BASIC: Indexed arrays ────────────────────────────────────────────────────
# 💡 EXPLANATION: Prints a section header for indexed array basics.
section "8-BASIC: Indexed Arrays — Declaration, Expansion & Safety"

# [WHAT]: Build an array and demonstrate every critical expansion form.
# [WHY]:  Most array bugs come from using ${arr[*]} instead of ${arr[@]},
#         or forgetting to quote the expansion.

# 💡 EXPLANATION: 'declare -a' explicitly declares the variable 'DEPLOY_TARGETS' as an indexed (numerically keyed) array, initializing it with four string elements enclosed in parentheses.
declare -a DEPLOY_TARGETS=("web-01" "web-02" "db-primary" "cache-01")

# [COMMAND MEANING] ${arr[@]} = Expands every element as individually quoted words;
#                   the ALWAYS-correct form for passing arrays as arguments.
# [COMMAND MEANING] ${arr[*]} = Joins all elements into a single string with IFS[0].
# [COMMAND MEANING] ${#arr[@]} = Count of elements in the array.
# [COMMAND MEANING] ${!arr[@]} = List of all indices (keys for sparse arrays).
# 💡 EXPLANATION: Expanding with '[*]' joins all elements into a single string separated by the first character of the IFS variable (default is a space). It's printed via 'pass'.
pass "Indexed array contents  : ${DEPLOY_TARGETS[*]}"
# 💡 EXPLANATION: Expanding with an octothorp '#' before the array name `{#arr[@]}` returns the total number of elements present in the array.
pass "Element count \${#arr[@]}: ${#DEPLOY_TARGETS[@]}"
# 💡 EXPLANATION: Expanding with an exclamation mark '!' before the array name `{!arr[*]}` returns a list of all currently populated index keys (e.g., "0 1 2 3").
pass "All indices \${!arr[@]}  : ${!DEPLOY_TARGETS[*]}"
# 💡 EXPLANATION: Accesses a single specific element of the array using its numeric index: `[2]`, which corresponds to "db-primary" since bash arrays are zero-indexed.
pass "Element [2]             : ${DEPLOY_TARGETS[2]}"

# Appending elements
# [COMMAND MEANING] arr+=("element") = Appends to the end of an existing array.
# 💡 EXPLANATION: Uses the `+=` operator with array syntax `(...)` to append a new element, "monitor-01", to the end of the 'DEPLOY_TARGETS' array.
DEPLOY_TARGETS+=("monitor-01")
# 💡 EXPLANATION: Logs the new size of the array after the append operation.
pass "After arr+=: count is now ${#DEPLOY_TARGETS[@]}"

# Slicing
# [COMMAND MEANING] ${arr[@]:offset:length} = Returns a slice of the array.
# 💡 EXPLANATION: Uses bash array slicing syntax `${array[@]:offset:length}` to extract a subset of the array. Starting at index 1, it takes 3 elements. The result is assigned to a new array named 'SEG8_SLICE'.
SEG8_SLICE=("${DEPLOY_TARGETS[@]:1:3}")
# 💡 EXPLANATION: Logs the contents of the newly sliced array.
pass "Array slice [1:3]: ${SEG8_SLICE[*]}"

# Copying an array
# [COMMAND MEANING] new=("${old[@]}") = Shallow copy by re-expanding all elements.
# 💡 EXPLANATION: Creates an exact duplicate of 'DEPLOY_TARGETS'. By wrapping `"${DEPLOY_TARGETS[@]}"` in parentheses, it takes the individually quoted expanded elements and assigns them as new elements into the 'BACKUP_TARGETS' array.
BACKUP_TARGETS=("${DEPLOY_TARGETS[@]}")
# 💡 EXPLANATION: Logs the element count of the copied array.
pass "Array copy: BACKUP_TARGETS has ${#BACKUP_TARGETS[@]} elements"

# unset a specific element — creates a sparse array
# [COMMAND MEANING] unset arr[N] = Removes element N; leaves a gap (sparse array).
# [WATCH OUT]: After unset arr[1], indices are NO LONGER contiguous.
#              Always iterate with ${!arr[@]} when you have sparse arrays.
# 💡 EXPLANATION: 'unset' deletes a specific element from the array based on its index. Deleting index [1] creates a "sparse array" where the keys are now 0, 2, 3, 4 (index 1 is missing).
unset DEPLOY_TARGETS[1]
# 💡 EXPLANATION: Logs the current index keys of the array. Because `unset` was used, the output will demonstrate the gap in the indices.
pass "After unset [1]: indices are now [${!DEPLOY_TARGETS[*]}] (sparse!)"

# ─── POWER: mapfile for bulk loading ─────────────────────────────────────────
# 💡 EXPLANATION: Prints a section header for the 'mapfile' built-in command.
section "8-POWER: mapfile -t — Bulk Load Command Output Into Array"

# [COMMAND MEANING] mapfile = Reads lines from stdin into an indexed array; Bash 4+.
# [FLAG MEANING]    -t = Trim; strips the trailing newline from each element.
# [WATCH OUT]: mapfile REQUIRES Bash 4+. On macOS without brew bash, this will fail.
#              Add a bash version guard: (( BASH_VERSINFO[0] >= 4 )) || die
# 💡 EXPLANATION: 'mapfile' (or 'readarray') reads lines from standard input into an array variable named 'RUNNING_PROCS'. 
# '-t' removes the trailing newline character from each line before storing it.
# '< <(...)' uses process substitution to feed the output of a command pipeline into mapfile. 
# The pipeline `ps -eo comm= | sort -u | head -5` lists all running processes, strips formatting, sorts them uniquely, and grabs the first 5 lines.
mapfile -t RUNNING_PROCS < <(ps -eo comm= | sort -u | head -5)
# 💡 EXPLANATION: Logs the total number of lines mapfile loaded into the array.
pass "mapfile loaded ${#RUNNING_PROCS[@]} process names:"
# 💡 EXPLANATION: Loops over the elements of the populated 'RUNNING_PROCS' array.
for proc in "${RUNNING_PROCS[@]}"; do
# 💡 EXPLANATION: Uses 'info' to log each individual process name.
  info "  $proc"
# 💡 EXPLANATION: Closes the 'for' loop block.
done

# ─── PRECISION: Associative arrays ───────────────────────────────────────────
# 💡 EXPLANATION: Prints the section header introducing associative arrays (hash maps).
section "8-PRECISION: Associative Arrays — The Bash Hash Map"

# [WHAT]: Build an env-config hash map and demonstrate key existence testing.
# [WHY]:  Associative arrays replace giant if/elif chains and clunky grep-based
#         config lookups. They're O(1) lookup vs. O(n) linear search.
# 💡 EXPLANATION: 'declare -A' (uppercase A) is required to define a variable as an Associative array (key-value pairs, hash map) rather than a standard numerically indexed array. This requires Bash 4.0+.
declare -A SERVICE_CONFIG
# 💡 EXPLANATION: Assigns the string "db-primary.internal" to the key "db_host" in the SERVICE_CONFIG map.
SERVICE_CONFIG[db_host]="db-primary.internal"
# 💡 EXPLANATION: Assigns the string "5432" to the key "db_port".
SERVICE_CONFIG[db_port]="5432"
# 💡 EXPLANATION: Assigns the string "prod_app" to the key "db_name".
SERVICE_CONFIG[db_name]="prod_app"
# 💡 EXPLANATION: Assigns the string "redis-01.internal" to the key "cache_host".
SERVICE_CONFIG[cache_host]="redis-01.internal"
# 💡 EXPLANATION: Assigns the string "6379" to the key "cache_port".
SERVICE_CONFIG[cache_port]="6379"

# [COMMAND MEANING] ${!map[@]} = All keys in the associative array.
# [COMMAND MEANING] [[ -v map[key] ]] = Existence check without error; Bash 4.2+.
# 💡 EXPLANATION: Expands the array using the '!map[*]' syntax to retrieve and log a list of all currently assigned keys (db_host, db_port, etc.). Order is not guaranteed.
pass "Associative array keys: ${!SERVICE_CONFIG[*]}"
# 💡 EXPLANATION: Demonstrates standard key-based value retrieval and logs it using 'pass'.
pass "db_host → ${SERVICE_CONFIG[db_host]}"

# 💡 EXPLANATION: Uses a bash compound conditional `[[ ]]`. The '-v' flag (Bash 4.2+) checks if a specific variable or array key has been set. It evaluates to true if the key 'db_port' exists in the 'SERVICE_CONFIG' array.
if [[ -v SERVICE_CONFIG[db_port] ]]; then
# 💡 EXPLANATION: Logs confirmation that the key exists and prints its value.
  pass "[[ -v map[key] ]]: db_port exists → ${SERVICE_CONFIG[db_port]}"
# 💡 EXPLANATION: Closes the 'if' block.
fi

# 💡 EXPLANATION: The '!' negates the evaluation. This checks if the key 'missing_key' has NOT been set in the array.
if ! [[ -v SERVICE_CONFIG[missing_key] ]]; then
# 💡 EXPLANATION: Logs confirmation that the missing key check functioned correctly.
  pass "[[ -v ]]: missing_key correctly absent"
# 💡 EXPLANATION: Closes the 'if' block.
fi

# Joining array elements with a custom delimiter
# [COMMAND MEANING] IFS=','; "${arr[*]}" = Joins array elements using IFS[0] as
#                   the delimiter; restore IFS immediately after.
# 💡 EXPLANATION: Creates a new indexed array 'ALL_KEYS' containing all keys extracted from the 'SERVICE_CONFIG' associative array.
ALL_KEYS=("${!SERVICE_CONFIG[@]}")
# 💡 EXPLANATION: Temporarily saves the current state of the Internal Field Separator (IFS) to 'SAVED_IFS'. Then redefines the current IFS to be a comma.
SAVED_IFS="$IFS"; IFS=','
# 💡 EXPLANATION: Expands the 'ALL_KEYS' array using the '[*]' syntax. Because IFS is currently a comma, bash joins all elements into a single string, separated by commas.
KEYS_CSV="${ALL_KEYS[*]}"
# 💡 EXPLANATION: Immediately restores the IFS to its previous state to prevent unintended side effects later in the script.
IFS="$SAVED_IFS"
# 💡 EXPLANATION: Logs the final CSV string containing the joined keys.
pass "Keys as CSV (IFS join): $KEYS_CSV"

# 💡 EXPLANATION: Prints a success message concluding Segment 8.
pass "Segment 8 complete — Arrays and hash maps mastered."