#!/usr/bin/env bash 
# Instructs the system to use the 'env' command to locate the bash interpreter in the system's PATH, ensuring portability across different OS environments.
# use the above instead of #!/bin/bash

# production safety net...
# Enforces strict execution: '-e' exits on errors, '-u' exits on undefined variables, and '-o pipefail' ensures errors within piped commands aren't masked.
set -euo pipefail













# ===================================== MODULE 1, SEGMENT 1.1: SCRIPT INVOCATION & THE SHEBANG =====================================


# Uses 'read' to ingest a multi-line string (Here-Document) into the 'info' variable; '|| true' prevents strict mode from crashing if read hits EOF before a delimiter.
read -r -d '' info <<EOM || true
This script is being executed by -> $BASH

Version: $BASH_VERSION

'env bash' resolves to: $(which bash)

# Closes the Here-Document block, terminating the multi-line string assignment to the 'info' variable.
EOM



# Prints the contents of the 'info' variable, using '-e' to interpret the explicit newline character '\n' at the end for spacing.
echo -e "$info\n"


# testing strict mode flags...

# Initializes a standard local variable with a string value.
defined_variable=Jesse

# Prints the interpolated string containing the previously defined variable.
echo "My name is $defined_variable"

# Starts a conditional block configured to evaluate to false, ensuring the code inside is completely bypassed during execution.
if false; then

    # Demonstrates what would happen without the if-false block: the script would crash here due to the '-u' strict flag because this variable doesn't exist.
    echo "$undefined_variable" # => bash: undefined_variable: unbound variable

    # This line would never be reached in a real execution because the above line would trigger an unbound variable error and halt the script.
    echo "Jesse is cool" # this won't run. The script would stop here becuase of the 'set -u' flag

# Closes the disabled conditional block.
fi



# Searches for a specific string in a file; appending '|| true' guarantees the command evaluates as a success even if grep finds nothing, preventing a script crash.
grep "jesse is cool" ./requirements.txt || true # '|| true' masks a failure and tells bash to ignore if failed and continue moving

# Sets a state variable to track the current phase of our mock pipeline.
the_pipeline_stage='preprocessing'

# Prints the current state of the pipeline phase to the terminal.
echo "Continuing data pipeline at stage: $the_pipeline_stage"


# Opens a subshell environment, meaning any variables modified inside this block will NOT affect the parent shell's memory.
(

    # Mutates the pipeline state variable, but this change is strictly isolated to the temporary subshell memory space.
    the_pipeline_stage='training' # This change will NOT escape back to the parent

    # Prints the locally mutated variable from inside the subshell to show it actually changed within this scope.
    echo "Moving pipeline to stage: $the_pipeline_stage"
    
# Closes the subshell, completely destroying its isolated environment and reverting all variable states back to the parent.
)

# Prints the variable again to prove that the parent shell's value ('preprocessing') remained completely unchanged by the subshell execution.
echo "Verifying pipeline stage: $the_pipeline_stage"


# command substitution => $()

# Uses command substitution '$()' to execute the 'hostname' system command and capture its standard output directly into a variable.
the_current_host=$(hostname)

# Prints the captured hostname with surrounding newlines for cleaner terminal output.
echo -e "\nCaptured hostname via subshell: ${the_current_host}\n"



# Initializes a counter variable at zero in the parent shell.
count=0

# Pipes text into a while loop; crucially, bash creates a subshell to execute the right side of a pipe, fully isolating the loop's environment.
echo "Attempting to increment..." | while read -r line; do

    # Prints the string that was piped into the loop.
    echo $line

    # Performs arithmetic expansion to increment the counter, but this ONLY increments the isolated subshell's copy of 'count'.
    count=$((count + 1))

    # Prints the successfully incremented local copy of the counter inside the loop.
    echo -e "\nValue inside pipe subshell = $count"
# Ends the while loop and destroys the pipe's subshell, discarding the incremented 'count' value.
done

# Prints the parent's counter, proving it remained '0' because the pipe subshell's changes were lost upon completion.
echo -e "\nParent shell count = $count\n"



# ===================================== MODULE 1, SEGMENT 1.2: FUNDAMENTAL SYNTAX & TOKENIZATION =====================================

# Defines a variable with a string containing spaces.
my_name='Nwachukwu Jesse Chijioke'


# Uses 'set --' to replace the script's positional parameters ($1, $2, etc.) with the unquoted variable, causing bash to perform word splitting on the spaces.
set -- $my_name

# Prints the number of arguments ($#) and the newly split positional parameters ($1, $2, $3) to prove word splitting occurred.
echo "Unquoted \$my_name splits into $# separate words: '$1', '$2' & '$3'"


# Replaces the positional parameters again, but this time quotes the variable, preventing word splitting so the entire string becomes a single argument.
set -- "$my_name"

# Proves that quoting preserves the spaces, resulting in exactly 1 single argument parameter ($1) representing the whole string.
echo -e "\nQuoted \"\$my_name\" is preserved as $# single argument: '$1'\n"


# sequential execution with semicolons (;)...

# Uses the semicolon (;) control operator to sequentially execute multiple independent commands from left to right on a single line.
echo "Doing something" ; echo "Doing something else" ; echo "Doing another thing after that"


# Starts an active conditional block that will always evaluate to true.
if true; then
    
    # Opens a subshell to group commands specifically to be run asynchronously in the background.
    (
        # Pauses the background subshell for a fraction of a second to ensure the parent shell's echo below has time to run first.
        sleep 0.1
        
        # Prints a delayed message proving that background processes operate independently of the main script flow.
        echo "This will be the last command to run because it is in the background and has to wait to be executed"
    
    # Closes the subshell and uses the ampersand (&) to immediately push the entire block into the background, allowing the parent script to continue.
    ) &

    # Uses the special variable '$!' to capture and store the Process ID (PID) of the most recently executed background job.
    bckgnd_PID=$!
# Closes the conditional block.
fi

# Prints a message immediately from the main script thread while the background subshell is still actively sleeping.
echo -e "\nThis command will execute before the background process above\n"


# Logs the captured background process ID to the console.
echo "Background job launched with PID: $bckgnd_PID"


# Uses the 'wait' command to explicitly pause the main script until the specified background PID finishes executing, then prints a success message.
wait "$bckgnd_PID" && echo -e "\nBackground job $bckgnd_PID has completed\n"


# Built-in binaries...

# Uses 'type -a' to query the system about the 'echo' command, proving it is built directly into the bash shell itself rather than being an external file.
echo "Built-in binaries:" && type -a echo
# Queries the 'cd' command to show it is also a fundamental shell built-in.
echo "" && type -a cd
# Queries 'pwd' to show it operates as a shell built-in function as well.
echo "" && type -a pwd


# External Binaries...

# Queries the location of the external Python interpreter, catching failures with '|| true' just in case Python isn't installed in the environment.
echo -e "\nExternal Binaries:" && (type -a python3.12 || true)
# Queries the physical path location of the external Docker binary, swallowing errors if missing.
echo "" && (type -a docker || true)
# Queries the physical path location of the external Git binary, swallowing errors if missing.
echo "" && (type -a git || true)




# Proving why 'cd' MUST be a built-in

# Prints the starting working directory before attempting any path navigation.
echo -e "\nCurrent directory BEFORE cd: $(pwd)\n"

# Changes the shell's current working directory to a relative path (Note: this relies on a 'Logging' folder existing, otherwise strict mode will halt execution).
cd "./Logging"

# Prints the new directory location to confirm the path traversal was successful.
echo "Current directory AFTER cd: $(pwd)"

# Uses 'cd -' to jump back to the previous directory, redirecting its standard output to /dev/null to silence the automatic path printout.
cd - > /dev/null

# Confirms the script successfully returned to the original root directory.
echo -e "\nReturned to previous directory: $(pwd)\n"




# ===================================== MODULE 1, SEGMENT 1.3: QUOTING MECHANISMS & LITERAL STRINGS =====================================


# single quoting...

# Demonstrates single quotes, which enforce strict literal interpretation and entirely prevent variable expansion.
echo 'My name is $my_name'


# double quoting...
# Demonstrates double quotes, which allow variables ($) and command substitutions ($()) to be dynamically evaluated while keeping the string unified.
echo -e "\nMy name is $my_name and today's date is $(date +%Y-%m-%d)\n" # allows variable and command substitution



# No quotes (word splitting AND glob expansion are active)

# Assigns an unquoted wildcard string to a variable.
text_files=*.txt

# Prints a basic header string.
echo -e "list of txt files:"

# Evaluates the unquoted variable, allowing the shell to perform "globbing" (expanding the asterisk into a list of actual matching .txt files in the directory).
ls $text_files # glob expansion

# Prints a blank line for output readability.
echo ""


# backslash escaping...

# Uses backslashes to escape inner double quotes so they are printed literally instead of prematurely ending the string boundaries.
echo "and Jesse said \"I am cool!\""


# Uses a backslash to escape the dollar sign, preventing variable interpolation and printing the literal string '$my_name'.
echo -e "\nMy name is \$my_name\n"

# line continuation...
# Initiates the touch command and uses a trailing backslash to continue the single logical command onto the next physical line.
touch file1 \
# Continues passing file arguments to the touch command, terminating the line with another backslash.
file2 file3 \
# Continues passing more file arguments.
file4 file5 \
# Finishes the touch command, then chains a sleep command using '&&', and uses another backslash to continue to the removal step.
file6 file7 && \
# Pauses for a fraction of a second, then chains the 'rm' command using another backslash continuation.
sleep 0.1 && \
# Starts removing the newly created files, continuing the arguments to the next line.
rm -f file1 \
# Continues listing files to be removed.
file2 file3 \
# Continues listing files to be removed.
file4 file5 \
# Provides the final files to the 'rm' command, completing this massive multi-line single execution chain.
file6 file7




# ANSI-C Quoting

# Building a tab-separated ML metrics log header using ($'')...


# Uses ANSI-C quoting ($'...') to allow bash to interpret backslash escape sequences like '\t' as actual, literal tab characters during variable assignment.
tsv_header=$'Epoch\tTrain_Loss\tVal_Loss\tAccuracy'
# Assigns a row of mocked machine learning metrics, using the same ANSI-C quoting to inject raw tab spaces between values.
tsv_row1=$'1\t0.8821\t0.9134\t0.6712'
# Assigns the second row of mocked tab-separated metrics.
tsv_row2=$'2\t0.5643\t0.5901\t0.8234'
# Assigns the third and final row of mocked tab-separated metrics.
tsv_row3=$'3\t0.3102\t0.3344\t0.9101'


# Prints a standard string header to introduce the upcoming data table.
echo "Tab-separated training metrics table:"
# Prints the variable containing the tab-formatted header row.
echo "$tsv_header"
# Prints the first data row, aligning perfectly with the header thanks to the tab characters.
echo "$tsv_row1"
# Prints the second data row.
echo "$tsv_row2"
# Prints the third data row, finalizing the visual table layout in the terminal.
echo "$tsv_row3"














