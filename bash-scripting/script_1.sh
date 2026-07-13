#!/usr/bin/env bash

set -euo pipefail


source "$(pwd)/bash-scripting/funcs.sh"



log() {

  if [[ $# -eq 1 ]]; then
    
    local input_level=0

    local message="$1"

    local log_file=""

  elif [[ $# -eq 2 ]]; then

    local input_level="$1"

    local message="$2"

    local log_file=""

  elif [[ $# -eq 3 ]]; then

    local input_level="$1"

    local message="$2"
    
    local log_file="$3" # Optional: pass a file path to enable JSON logging
  
  else

    echo "To many input arguments. Max arguments is 3" >&2

    exit 1

  fi

  
  local level color

  local reset="\e[0m"

  # 1. Map Levels and ANSI Colors
  case "${input_level,,}" in # ,, converts to lowercase (Bash 4+)
    0|debug)    level="DEBUG";   color="\e[36m" ;; # Cyan
    1|info)     level="INFO";    color="\e[32m" ;; # Green
    2|warning)  level="WARNING"; color="\e[33m" ;; # Yellow
    3|error)    level="ERROR";   color="\e[31m" ;; # Red
    4|critical) level="CRITICAL";color="\e[41;37m" ;; # White on Red
    *)          level="LOG";     color="\e[37m" ;;
  esac

  # 2. Context Detection
  # If FUNCNAME[1] is empty or "main", it's a regular line.
  local caller_name="${FUNCNAME[1]:-main}"
  local context_msg
  if [[ "$caller_name" == "main" ]]; then
    context_msg="Script Root"
  else
    context_msg="Function: $caller_name()"
  fi

  # 3. Console Output (Formatted)
cat <<EOF | xargs -0 printf
Level: ${color}[${level}]${reset}, ${context_msg}
File: ${BASH_SOURCE[1]}
Line Number: ${BASH_LINENO[0]}
Output: ${message}
EOF


  # 4. File Output (JSON Format)
  if [[ -n "$log_file" ]]; then
    # Create valid JSON string
    local timestamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
    printf '{"timestamp":"%s","level":"%s","file":"%s","caller":"%s","line":%d,"message":"%s"}\n' \
      "$timestamp" "$level" "${BASH_SOURCE[1]}" "$caller_name" "${BASH_LINENO[0]}" "$message" >> "$log_file"
  fi
}






workspace_folder="/media/sf_DevOps-MlOps/linux/ML-Learning-Repository/bash-scripting/workspace/"

rm -rf "$workspace_folder"

mkdir -p "$workspace_folder"


# trap 'rm -rf "$workspace_folder"' EXIT

# cd "$WORKSPACE"

cd "$workspace_folder"



if false; then

  cat <<EOF > "shebang_that_was_hardcoded.sh"
#!/bin/bash

echo "I use a hardcoded path. If bash lives elsewhere, I break."
EOF

  cat shebang_that_was_hardcoded.sh

  # cat > "$WORKSPACE/portable_shebang.sh" << 'EOF'
  #...!/usr/bin/env bash
  # echo "I ask env to find bash on PATH. I work on any Unix system."
  # EOF

  cat > "shebang_that_is_portable.sh" << 'EOF'
#!/usr/bin/env bash

echo "I ask env to find bash on PATH. I work on any Unix system."
EOF

  cat shebang_that_is_portable.sh

  chmod +x "shebang_that_is_portable.sh" "shebang_that_was_hardcoded.sh"



  echo "Both scripts made executable via chmod +x"



  echo "" > setup_files.txt

  for file_for_startup in /etc/profile "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.bash_logout"; do
    if [[ -f "$file_for_startup" ]]; then

      cat "$file_for_startup" >> setup_files.txt

      echo -e "\n\n===================================== SECTION =====================================\n\n" >> setup_files.txt

      echo "EXISTS: $file_for_startup"

    else
      echo "ABSENT: $file_for_startup (would be sourced if it existed)"
    fi
  done




  cat <<EOF
This script's PID = $$

This script's PPID = $(ps -p $$ -o ppid= --no-headers 2>/dev/null | tr -d ' ' || echo 'N/A')

PID 1 cmdline =  $(cat /proc/1/comm 2>/dev/null || echo 'N/A')
EOF

  mv "setup_files.txt" "demo_of_shebang.sh"

  cat <<EOF > "demo_of_shebang.sh"
#!/totally/fake/path/to/bash
echo "My shebang is garbage, but bash invocation still works."
EOF



  bash "demo_of_shebang.sh"

  env -i bash "demo_of_shebang.sh"

  rm -f "demo_of_shebang.sh" "shebang_that_is_portable.sh" "shebang_that_was_hardcoded.sh"



  

  declare -i jesse_age=20

  declare -r serious_variable="Don't you dare re-assign this variable!"

  declare -x gift_for_child="This is for my child"

  declare -a jesse_siblings=("favour" "caleb" "goodness" "chiedozie")

  declare -A user_info=( [name]="Nwachukwu Jesse" [status]="cool" [summary]="Jesse is cool" )



  cat <<EOF
Jesse age in next 7 years is $((jesse_age+7))

declare -r: constant value   → $serious_variable
declare -x: exported var     → $gift_for_child
declare -a: siblings[1]        → ${jesse_siblings[1]}
declare -A: my_info[status]         → ${user_info[summary]}
EOF



  #... Prove -r actually blocks re-assignment
  # if ! (declare -r LOCKED="yes"; LOCKED="no") 2>/dev/null; then
    # pass "declare -r: re-assignment correctly blocked"
  # fi


  # Prove -r actually blocks re-assignment
  if ! (declare -r jesse="cool"; jesse="not cool") 2>/dev/null; then
    echo "declare -r: re-assignment correctly blocked"
  fi



  global_variable="I am a global variable"

  function_of_scopes(){
    global_variable='I can be re-assigned'

    local local_variable="I am a local variable"

    local -i local_integer=35

    local -r local_readonly="Non-reassignable variable"

    local -a local_array=("Kaleo" "Linko" "Poppa")

    local -A local_associative_array=( ['status']='charged' [amount]="$local_integer" )

    echo "${local_associative_array[amount]}"
  }

  function_of_scopes



  if [[ -z "${local_variable:-}" ]]; then
    echo "After function : local_variable is GONE (local scope confirmed)"
  fi



  regular_variable="Just chilling out!"

  unset regular_variable

  if [[ -z "${regular_variable:-}" ]]; then
    echo "unset confirmed: regular_variable has been ${regular_variable:-"removed"}"
  fi


  function_that_is_calling() {
    log "This message came from inside function_that_is_calling()"
  }

  # caller_function
  # pass "Segment 2 complete — Variables, scope, and introspection."

  function_that_is_calling

  log 1 "Jesse is sooo cooool!"









# ===================================== SEGMENT 3 — QUOTING, WORD SPLITTING & PARAMETER EXPANSION =====================================

  



  var_3="Nwachukwu Jesse"


  echo "Double-quoted: \"$var_3\" (expansion ✔, splitting ✘)"

  echo 'Single quoted: ''$var_3'' (expansion ✘, literal)'


  ansi_c_var=$'fist line\nsecond line\ttab'

  echo -e "ANSI-C Quoting Output" && echo "$ansi_c_var"



  ifs_saved="$IFS"

  the_csv_line="alpha,beta,gamma,delta"

  IFS=',' read -ra segment_3_fields <<< "$the_csv_line"

  IFS="$ifs_saved"

  log "IFS=',' split: ${#segment_3_fields[@]} fields -> [${segment_3_fields[*]}]"


  export segment_3_temporary_directory=$(mktemp -d)

  echo "PID of main shell = $BASHPID"

  (
    echo "PID of sub-shell = $BASHPID"

    shopt -s nullglob

    segment_3_matches=( "$segment_3_temporary_directory"/*.nonexistent )

    log "nullglob on empty dir: ${#segment_3_matches[@]} matches (no crash, no literal pattern)"

    rm -rf "$segment_3_temporary_directory"

    shopt -u nullglob
  )


  name="FILEPATH GREETING REQUIRED_VAR I_EXIST"

  echo "${name,,}"




  the_empty_variable=""

  assigned_variable="VARIABLE_EXISTS"


  # ${var:=default}
  if [ ! -v USER_NAME ]; then
    unset USER_NAME
  fi

  echo "My name is ${USER_NAME:="Jesse"}"

  echo "The variable 'USER_NAME' was set to $USER_NAME"

  # ${var:-default}
  echo "the variable 'the_greet' is ${the_empty_variable:-"empty"}"

  # {var:+alt}
  echo "The variable 'assigned_variable' has already been ${assigned_variable:+"set"}"

  # ${var:?error}
  if false; then
    echo "Error: ${a_variable_that_does_not_exist:?"variable 'a_variable_that_does_not_exist' is unset!"}"
  fi


  path_to_file="/home/jesfusion/Documents/ml/My-Learning/ML-Learning-Repository/logs/print.log"


  cat <<EOF
  path_to_file="/home/jesfusion/Documents/ml/My-Learning/ML-Learning-Repository/logs/print.log"

  There are ${#path_to_file} characters in the variable 'path_to_file'

  The base file is ${path_to_file##*/}

  The file-path to the base file is ${path_to_file%/*}

  The file-path is ${path_to_file#*/}
EOF




  long_string="What if you are on an older version of Bash?"

  host_variable="do not use the $ sign before the variable name when using the -v flag."

  strong_quote="WE CAN EITHER LAUGH IN THE FACE OF DEATH OR DIE TRYING NOT TO!!"

  cat <<EOF
  long_string="What if you are on an older version of Bash?"

  ${long_string:5:6}

  ${long_string: -5:4} is a scripting language

  host_variable="do not use the $ sign before the variable name when using the -v flag."

  ${host_variable^^}

  ${host_variable^}

  strong_quote="WE CAN EITHER LAUGH IN THE FACE OF DEATH OR DIE TRYING NOT TO!!"

  ${strong_quote,,}

  ${strong_quote,}
EOF


  math_var="2 - 4 - 6 - 8 - 10"


  ALIAS="LINENO"

  cat <<EOF
  ${math_var//-/+} = 30

  ${math_var/-/+} = -18

  We are at $ALIAS (line number) ${!ALIAS}
EOF


  if false; then
    All String Operations:

    ${#var}                     # length of string
    ${var:2:5}                  # substring: offset 2, length 5
    ${var#pattern}              # remove shortest prefix matching pattern
    ${var##pattern}             # remove longest prefix matching pattern (greedy)
    ${var%pattern}              # remove shortest suffix matching pattern
    ${var%%pattern}             # remove longest suffix matching pattern (greedy)
    ${var/pattern/replacement}  # replace first match
    ${var//pattern/replacement} # replace all matches

  fi



  #... $@ vs $* — the critical quoting difference
  #... [WHAT ELSE]: "$*" is only useful when you intentionally want all args as one word,
  #...              e.g., building a CSV string. "$@" is the correct default everywhere else.
  # demo_args() {
    # info "  \"\$@\" → ${#@} separately quoted words (correct for passing args)"
    # info "  \"\$*\" → 1 joined string: '$*'"
  # }
  # demo_args "arg one" "arg two" "arg three"

  # pass "Segment 3 complete — Quoting, IFS, and expansion arsenal loaded."

  fuse_arguments(){
    cat <<EOF
  Arguments: $@

  ${#@} arguments were passed to $FUNCNAME

  $*

  1 joined string: '$*'
EOF
  }

  fuse_arguments "argument one" "argument two" "argument three"










# ===================================== SEGMENT 4 — THE ENVIRONMENT, PATH, AND CREDENTIAL SAFETY =====================================

  


  export environment_variable="This is an environment variable"

  declare -x environment_variable2="This is also an environment variable"


  log "Export result: $(env | grep environment_variable | head -1)"

  log "declare -x result: $(env | grep environment_variable2 | head -1)"



  inline_scope_checking=$(testing_the_scope="Just with this command" env | grep testing_the_scope || echo "The variable is absent among the list of environmental variables")

  log "VAR=value command scoping: parent shell sees → $inline_scope_checking"



  isolated_env=$(env -i NAME="Nwachukwu Jesse" STATUS="Jesse is cool" bash -c 'echo "The information reaching me is that $STATUS"')

  echo "env -i output: $isolated_env"


  # 4-PRECISION: PATH Hygiene — The Injection Attack Vector


  echo "Current Path: $PATH"

  if echo "$PATH" | grep -qE '(^|:)\.(:|$)'; then
    log "WARNING: '.' detected in PATH — this is a security vulnerability"
  else
    log "PATH is safe — '.' is not in the search path"

  fi




  # if ps aux | grep -q "bash"; then

  #   echo "Bash exists"

  # else
  #   echo "Bash doesn't exist"

  # fi


  secret_temporary_file=$(mktemp)


  echo "9whd93wqq33nsfdnssnin339rh3bd3rdhf93r" > "$secret_temporary_file"


  chmod 600 "$secret_temporary_file"


  read -r AWS_TOKEN < "$secret_temporary_file"

  log "AWS Token = $AWS_TOKEN"


  echo "Secret read safely from file: ${AWS_TOKEN:0:6} (truncated)"


  unset "$secret_temporary_file" && rm -f "$secret_temporary_file"



  log "Key insight: '/proc/$$/environ' is the graveyard of leaked secrets"

  # cat "/proc/$$/environ" &> '/media/sf_DevOps-MlOps/linux/ML-Learning-Repository/file.txt'

















  # ===================================== SEGMENT 5 — CONDITIONALS: test, [[, AND SHORT-CIRCUIT LOGIC =====================================


  file_for_segment_5=$(mktemp)


  echo "File name = $file_for_segment_5" > "$file_for_segment_5"


  # echo "EXPLANATION: Writes "test content" to the newly created temporary file" >> "$file_for_segment_5"


  # read -r output < "$file_for_segment_5"


  # echo "$output"

  fileName_link=$(mktemp -u)

  ln -s "$file_for_segment_5" "$fileName_link"


  # integert tests...

  number=20

  if [ "$number" -eq 20 ] && \
  [ "$number" -ne 38 ] && \
  [ "$number" -lt 95 ] && \
  [ "$number" -le 21 ] && \
  [ "$number" -gt 2 ] && \
  [ "$number" -ge 4 ]; then

    echo "Integer comparison flags verified for value: $number"
  fi


  # string tests...

  empty_string=""

  non_empty_string=","


  if [ -z "$empty_string" ] && \
  [ -n "$non_empty_string" ]; then

    echo "String tests confirmed"
  fi





  # file tests...

  test_file="seg_6.sh"

  cat <<EOF > "$test_file"
#!/usr/bin/env bash
set -euxo pipefail

echo ""
EOF

  chmod u+x "$file_for_segment_5"


  if [[ -e "$test_file" ]] && \
  [[ -f "$test_file" ]] && \
  [[ ! -d "$test_file" ]] && \
  [[ -r "$test_file" ]] && \
  [[ -w "$test_file" ]] && \
  [[ -x "$test_file" ]] && \
  [[ -s "$test_file" ]]&& \
  [[ -L "$fileName_link" ]]; then
  # Others are:
  # -p file   # is a named pipe (FIFO)
  # -S file   # is a socket
  # -nt       # newer than (by modification time)
  # -ot       # older than
  # -ef       # same file (same inode/device — detects hardlinks)


    echo "File test flags verified!"
  fi



  long_variable="devops-is-fun-to-learn"


  if [[ "$long_variable" == devops-is-fun* ]]; then
    log 2 "glob pattern matching verified!"
  fi


  line_in_log="
  Level: [WARNING], Script Root
  File: /media/sf_DevOps-MlOps/linux/ML-Learning-Repository/bash-scripting/script_1.sh
  Line Number=650
  Output: glob pattern matching verified!
  "

  the_pattern='Line Number=([0-9]+)'


  if [[ "$line_in_log" =~ $the_pattern ]]; then
    cat <<EOF
Full-Match: ${BASH_REMATCH[0]}

First Capture Group: ${BASH_REMATCH[1]}
EOF

  fi




  # my_name="Nwachukwu Jesse"
  my_name="She is beautiful"

  case "$my_name" in
  "My mama is sick")
    echo "case 1 correct!";;

  "She is beautiful"|"Jesse is cool")
    echo "case 2 correct!";;

  *)
    echo "No macthing string was found..."
  esac


  var4="je"

  case "$var4" in

  *"naksu is an assasin"*)
    echo "case 1 correct, glob is $var4";;

  *"she is coming"*|"je")
    echo "case 2 correct, glob is $var4";&

  "the tea is delicious")
    
    echo "case 3 correct, glob is $var4";;

  *)
    echo "No macthing string was found..."
  esac






  declare -i today

  today=$(date +%w)

  declare -a days_of_the_week=("sunday" "monday" "tuesday" "wednesday" "thursday" "friday" "saturday")

  declare -i today=6


  string="Today is $(
    case "$today" in

    0)
      echo "${days_of_the_week[$today]}";;
    
    1)
      echo "${days_of_the_week[$today]}";;
    
    2)
      echo "${days_of_the_week[$today]}";&

    3)
      echo "${days_of_the_week[$today]}";;

    4)
      echo "${days_of_the_week[$today]}";;

    5)
      echo "${days_of_the_week[$today]}";;&

    6)
      echo "${days_of_the_week[$today]}";&
    
    *)
      echo "case mechanism learnt. Moving on...";;

    esac
  )"



  echo "$string"



  echo "command 1 executed" && echo "command 2 executed" || echo "command 3 executed"



  (echo "$non_existent_variable") &> /dev/null || { echo "variable 'non_existent_variable' does not exist"; }


  rm -f "$file_for_segment_5" "$fileName_link" && unset "$file_for_segment_5" "$fileName_link"
















  # ===================================== SEGMENT 6 — LOOPS AND ITERATION PATTERNS =====================================



  segment_6_folder="$workspace_folder"


  echo "monday" > "$segment_6_folder/A_server.log"

  echo "tuesday"> "$segment_6_folder/B_server.log"

  cat <<EOF > "$segment_6_folder/C_server.log"
the
old
man
recently
just
kicked
the
bucket
EOF


  echo "wednesday" > "$segment_6_folder/D_server.conf"


  cat <<EOF > "$segment_6_folder/info.txt"
thursday
friday
The glob expands before the loop runs. If no files match, without 'nullglob' you loop once with the literal glob string — which is almost certainly a bug
EOF



  shopt -s nullglob

  for file in "$segment_6_folder"/*.log; do

    file_name="${file##*/}" # take the value of file, look from the beginning (##) and delete the longest match up to the last forward slash (/)
    
    echo "for glob: processing → $file_name"

    declare -i line_no=1

    while read -r line; do # -r prevents backslash from being treated as an escape character
      echo "Line $line_no = $line"

      line_no=$((line_no + 1))

    done < "$file_name"

  done

  shopt -u nullglob



  seg_6_sh_script="${workspace_folder}segment_6_bash_script.sh"


  echo '#!/usr/bin/env bash

  file_analyzation() {
    local the_file="$1"

    echo "Analysing file => ( $the_file )"
  }


  for this_file in "$@"; do
    
    file_analyzation "$this_file"

  done
  ' > "$seg_6_sh_script"




  chmod u+x "$seg_6_sh_script"

  "$seg_6_sh_script" file1.txt file2.txt file3.txt file4.txt file5.txt file6.txt


  rm -f "$seg_6_sh_script"





  declare -i var6=0

  unset x


  for (( x=0; x<=9; x++ )); do

    (( var6 += x )) || true

    echo "[var6 = $var6, x = $x]"
  done



  clear

  cat <<EOF > "${workspace_folder}file.txt"

-e file   # exists (any type)
-f file   # exists and is a regular file
-d file   # exists and is a directory
-r file   # readable
-w file   # writable
-x file   # executable
-s file   # exists and has size > 0
-L file   # is a symbolic link
-p file   # is a named pipe (FIFO)
-S file   # is a socket
-nt       # newer than (by modification time)
-ot       # older than
-ef       # same file (same inode/device — detects hardlinks)

EOF


  declare -i no_of_lines=0


  while IFS='' read -r this_line || [[ -n "$this_line" ]]; do # IFS = Internal Field Separator

    (( no_of_lines++ )) || true

  done < "${workspace_folder}file.txt"


  echo "while read line count: $no_of_lines lines processed (incl. no-newline final line)"






  items_collected=()



  while IFS='' read -r this_item; do

    items_collected+=("$this_item")

  done < <(
    echo "Local Governments in Enugu are:
    Aninri
    Awgu
    Enugu East
    Enugu North
    Enugu South
    Ezeagu
    Igbo Etiti
    Igbo Eze North
    Igbo Eze South
    Isi Uzo
    Nkanu East
    Nkanu West
    Nsukka
    Oji River
    Udenu
    Udi
    Uzo Uwani
    "
  )



  echo "Process substitution: collected ${#items_collected[@]} items in current shell"


  echo "Items in the array are: ${items_collected[*]}"



  user_status=false

  declare -a siblings_names=("jesse" "favour" "caleb" "goodness" "chiedozie")

  declare -a siblings_ages=(20 19 17 13 7)


  for name in "${siblings_names[@]}"; do

    for age in "${siblings_ages[@]}"; do

      echo "Name: $name, Age: $age"

      if [[ "$name" == "caleb" && "$age" == "17" ]]; then

        user_status=true

        break 2    

      fi  

    done

  done



  echo "break 2: exited nested loop at caleb/17 found $user_status"



  if [ -t 0 ]; then
    echo "true"

  else
    echo "false"

  fi

  declare -a menu_options=("Refresh system repos with apt update" "Peek into bashrc" "View the tree structre of this repo")


  PS3="What do you want to do? (Type 1, 2, or 3): "

  select user_choice in "${menu_options[@]}"; do
    case $user_choice in
      "${menu_options[0]}")
        
        echo "Updating Repositories..." && sleep 1.5

        sudo apt update
        
        break
        ;;
      
      "${menu_options[1]}")

        echo "Peeking into .bashrc..." && sleep 1.5

        tail -15 ~/.bashrc

        break
        ;;

      "${menu_options[2]}")

        echo "Viewing the tree of ML-Learning-Repository..." && sleep 1.5

        cd "/media/sf_DevOps-MlOps/linux/ML-Learning-Repository/" && tree

        break
        ;;

      *)
        
        echo "Invalid option. Your raw input was: \"$REPLY\""
        echo "Please pick a number from the menu."
        ;;
    esac

  done





  cd "$workspace_folder" && rm -f *


fi









# ===================================== SEGMENT 7 — FUNCTIONS: MODULARITY AND REUSE =====================================



acquire_the_time() {
  date +%s
}


function get_the_name_of_the_host {
  hostname
}


echo "POSIX function acquire_the_time -> $(acquire_the_time)"

echo "Bash function get_the_name_of_the_host -> $(get_the_name_of_the_host)"


add_two_numbers() {
  declare -i first_number="$1"

  declare -i second_number="$2"

  the_addition=$((first_number + second_number))

  echo "$the_addition"
}




echo "The sum of 2000 and 3000 is $(add_two_numbers 2000 3000)"



port_validation() {

  local the_port="$1"

  if [[ "$the_port" =~ ^[0-9]+$ ]] && (( the_port >= 1 && the_port <= 65535 )); then
    
    echo "Port $the_port is valid. Proceeding..."

    return 0 # successful (assigned only to number 0)
  
  fi

  return 1 # failed (failure is for any number >= 1)

}




checksum_calculation() {
  
  local the_input="$1"

  echo "$the_input" | md5sum | cut -d' ' -f1
  
}



# echo "jesse is cool" | md5sum | cut -d' ' -f1



if port_validation 9103; then

  echo "port_validation: 9013 is valid (return 0 received)"

fi




the_checksum=$(checksum_calculation "bash-script-segmenmt-7")


echo "checksum_calculation: \"$the_checksum\""




number_comparer(){
  declare -n args="$1"

  declare -i the_first_number="${args[0]}"
  
  declare -i the_second_number="${args[1]}"

  if (( the_first_number > the_second_number )); then
    
    echo "$the_first_number is greater than $the_second_number"
  
  else

    echo "$the_second_number is greater than $the_first_number"

  fi
}



declare -a arguments=(143 238)


number_comparer arguments




evaluate_list_of_servers() {

  declare -n the_servers="$1"

  local -i server_number=0


  for server in "${the_servers[@]}"; do

    (( server_number++ )) || true

    echo "Processing server $server_number: $server"
  done

  # server_number=$((server_number + 1))


  if [ "${#the_servers[@]}" -eq $server_number ]; then
    
    echo "Accurately processed $server_number servers"
  
  else

    echo "[WARNING] ${#the_servers[@]} uploaded, but $server_number processed"

  fi
}






declare -a production_servers=("web-01.prod" "web-02.prod" "db-01.prod" "dock-02.dev" "k8-01.prod")



evaluate_list_of_servers production_servers





server_that_greets() {
  
  echo "Server was deployed to $1"

}




export -f server_that_greets


bash -c 'echo""

declare -a servers=("server-1" "server-2" "server-3")

for sv in "${servers[@]}"; do
  server_that_greets "$sv"
done

'



if false; then

  cat <<'EOF' > "${workspace_folder%workspace/}funcs.sh"
  #!/usr/bin/env bash
  set -euo pipefail


  jesse_echo() {
    output_message="$1"

    echo "[BASH-SCRIPTING] $output_message"
  }

EOF

fi






jesse_echo "Segment 7 complete — Functions, namerefs, and export -f"




































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































