echo $SHELL - Tekls you what shell you're using


whoami - prints out your username

# i. WHAT: Prints the network name of the machine.
# ii. WHY: Crucial when managing multiple servers so you don't accidentally reboot the wrong one.
hostname

# 3. EXPLORE THE HIERARCHY
# i. WHAT: Change directory to the Root (The very bottom of the tree).
# ii. WHY: To leave your home folder and see the system structure.
cd /

# i. WHAT: List files to confirm the FHS folders exist.
# ii. WHY: You should see 'bin', 'etc', 'home', 'usr' here.
ls

# i. WHAT: Change directory into the configuration folder.
# ii. WHY: To prove that 'etc' is where config files live.
cd /etc

# i. WHAT: Change directory BACK to your personal workspace (Home).
# ii. WHY: ~ is the safest place to be. We always return here after exploring.
cd ~













































# 1. ESTABLISH BASELINE
# i. WHAT: Print Working Directory.
# ii. WHY: Confirming we start at Home (Expected: /home/jesse).
pwd

# 2. CREATE A DUMMY PROJECT STRUCTURE
# i. WHAT: Create a nested folder structure 'projects/mlops_v1'.
# ii. WHY: To give us a "deep" directory to practice jumping into.
# iii. CHANGE IT?: Changing names changes the path, but logic remains.
mkdir -p projects/mlops_v1

# 3. THE DEEP DIVE
# i. WHAT: Change directory into the newly created folder.
# ii. WHY: Entering our workspace.
cd projects/mlops_v1

# i. WHAT: Verify location.
# ii. WHY: Should output /home/jesse/projects/mlops_v1.
pwd

# 4. THE SYSTEM JUMP (Simulating checking logs)
# i. WHAT: Teleport immediately to the system log directory.
# ii. WHY: In production, you often need to check /var/log while working on code.
cd /var/log

# i. WHAT: List files in 'human-readable' format.
# ii. WHY: To check if log files are huge (GBs) or empty (KBs) without doing math.
ls -lh

# 5. THE RETURN (The Efficiency Hack)
# i. WHAT: Change Directory "Minus" (Previous).
# ii. WHY: Instantly snaps you back to /home/jesse/projects/mlops_v1 without typing it again.
# iii. IMPACT: Saves 10-20 seconds of typing. Crucial during emergencies.
cd -

# 6. VERIFY HIDDEN ASSETS
# i. WHAT: Go to Home.
# ii. WHY: Resetting position.
cd ~

# i. WHAT: List All files including hidden ones.
# ii. WHY: To see .bashrc or .profile which are usually invisible.
ls -a











































# 1. SETUP: CREATE A DEEP STRUCTURE
# i. WHAT: Create nested directories 'simulation/production/logs' inside Home.
# ii. WHY: To create a scenario where "Absolute" vs "Relative" navigation feels different.
# iii. WHAT IF: We change it? We just change the folder names, logic stays the same.
mkdir -p ~/simulation/production/logs

# 2. THE ABSOLUTE PATH APPROACH
# i. WHAT: Change directory starting from Root (/) all the way to logs.
# ii. WHY: This is the "Safe" way. It works no matter where you currently are in the system.
# iii. MLOps CONTEXT: This is how you would write the path in a Cron job script.
cd /home/$(whoami)/simulation/production/logs

# i. WHAT: Print where we are.
# ii. WHY: Confirm we arrived.
pwd

# 3. THE RELATIVE PATH APPROACH
# i. WHAT: Go up two levels (back to 'simulation').
# ii. WHY: We are navigating relative to our current position in 'logs'.
cd ../..

# i. WHAT: Verify we are now in 'simulation'.
# ii. WHY: '..' took us to 'production', the second '..' took us to 'simulation'.
pwd

# 4. TAB COMPLETION DRILL
# i. WHAT: Go back into production/logs using Tab.
# ii. WHY: Type 'cd p' -> [TAB] -> 'cd o' -> [TAB].
# iii. BENEFIT: Prevents typos. If Tab doesn't work, you made a typo or the file doesn't exist.
cd production/logs

















































# 1. THE QUICK CHECK
# i. WHAT: Ask what the 'cat' command is.
# ii. WHY: I heard someone say "cat the file" and I don't know what that means.
whatis cat

# 2. THE CHEAT SHEET
# i. WHAT: Ask 'ls' (list) for its help summary.
# ii. WHY: I forgot the flag to show hidden files and I don't want to open the full manual.
ls --help

# 3. THE DEEP DIVE (Interactive)
# i. WHAT: Open the full manual for the 'rm' (remove) command.
# ii. WHY: I need to know if 'rm' deletes directories recursively.
# iii. ACTION: Once inside, type '/recursive' to search for the flag. Press 'q' to exit.
man rm




















































# 1. THE EFFICIENT CREATION
# i. WHAT: Create a nested directory structure in one command.
# ii. WHY: We need a place to store our "models" and "data". Without -p, this fails.
mkdir -p mlops_lab/data/raw

# 2. THE TOUCH TECHNIQUE
# i. WHAT: Create two empty CSV files inside the raw data folder.
# ii. WHY: Simulating a dataset ingestion. We need files to practice on.
touch mlops_lab/data/raw/dataset_a.csv mlops_lab/data/raw/dataset_b.csv

# 3. VERIFICATION
# i. WHAT: List the files recursively to see the whole tree.
# ii. WHY: Confirming our structure exists before we destroy it.
ls -R mlops_lab

# 4. THE FIRST DELETE (SAFE)
# i. WHAT: Remove a specific file.
# ii. WHY: We decided dataset_a was corrupt.
rm mlops_lab/data/raw/dataset_a.csv

# 5. THE FAILED DELETE (LEARNING MOMENT)
# i. WHAT: Try to remove the 'data' folder without flags.
# ii. WHY: This WILL FAIL. Linux will say "Is a directory".
# iii. LESSON: You cannot delete a container just by pointing at it.
rm mlops_lab/data

# 6. THE NUCLEAR OPTION (CONTROLLED)
# i. WHAT: Recursively Force remove the entire 'mlops_lab' folder.
# ii. WHY: We are done with this experiment. Clean up the workspace.
# iii. DANGER: Double check the path before hitting Enter. 'rm -rf' does not forgive.
rm -rf mlops_lab







































# 1. SETUP: CREATE THE MESS
# i. WHAT: Create a folder and dump mixed file types into it.
# ii. WHY: Simulating a download folder containing code, images, and data mixed together.
mkdir -p downloads
touch downloads/model.py downloads/script.sh downloads/image1.jpg downloads/data.csv

# 2. CREATE DESTINATIONS
# i. WHAT: Create specific folders for each file type.
# ii. WHY: A clean workspace is a clean mind (and fewer bugs).
mkdir -p project/src project/images project/data

# 3. THE WILDCARD MOVE (IMAGES)
# i. WHAT: Move all files ending in .jpg from downloads to project/images.
# ii. WHY: Instead of moving one by one, we grab them all with *.jpg.
mv downloads/*.jpg project/images/

# 4. THE RENAME (USING MV)
# i. WHAT: Move model.py to src AND rename it to main.py at the same time.
# ii. WHY: Refactoring code often requires renaming the entry point.
mv downloads/model.py project/src/main.py

# 5. THE BACKUP (COPY)
# i. WHAT: Create a backup of the data before we touch it.
# ii. WHY: Always backup raw data. If your cleaning script is buggy, you can restart.
cp downloads/data.csv project/data/data_backup.csv

# 6. FINAL CLEANUP
# i. WHAT: Force delete the downloads folder.
# ii. WHY: We have extracted everything valuable. The shell is effectively the trash can.
rm -rf downloads




















































# 1. SETUP: GENERATE DUMMY DATA
# i. WHAT: Create a CSV file with a header and 100 rows of data.
# ii. WHY: We need a file with enough content to practice 'head' vs 'tail'.
echo "id,model_name,accuracy" > training_data.csv
for i in {1..100}; do echo "$i,model_v$i,$RANDOM"; done >> training_data.csv

# 2. THE HEAD INSPECTION
# i. WHAT: View the first 5 lines of the CSV.
# ii. WHY: To verify the column names (id, model_name) before we try to load it into Pandas.
# iii. CHANGE IT?: Change -n to 20 to see more rows.
head -n 5 training_data.csv

# 3. THE TAIL INSPECTION
# i. WHAT: View the last 3 lines.
# ii. WHY: To see the most recent data points added (should be roughly id 98, 99, 100).
tail -n 3 training_data.csv

# 4. THE CAT DISASTER (SIMULATED)
# i. WHAT: Dump the whole file.
# ii. WHY: Since our file is only 100 lines, this is safe. 
# iii. NOTE: Notice how it floods your terminal history. Imagine if this was 1 million lines.
cat training_data.csv

# 5. THE LESS EXPERIENCE
# i. WHAT: Open the file in the pager.
# ii. WHY: Practice navigating without cluttering the terminal history.
# iii. ACTION: Press 'q' to exit after running this.
less training_data.csv










































# 1. CREATE A BUGGY SCRIPT
# i. WHAT: Create a python file with a deliberate syntax error (missing parenthesis).
# ii. WHY: To simulate a broken production script.
echo "print('Starting Model Training..." > broken_model.py

# 2. VERIFY THE BUG
# i. WHAT: Run the script to see it fail.
# ii. WHY: Confirming the error message exists.
python3 broken_model.py
# Expected Output: SyntaxError: EOL while scanning string literal

# 3. THE FIX (Interactive Step)
# i. WHAT: Open the file in the nano editor.
# ii. WHY: We need to close the quote and parenthesis.
nano broken_model.py

# --- INSTRUCTIONS INSIDE NANO ---
# A. Use arrow keys to go to the end of the line.
# B. Add: ')'   (So it looks like: print('Starting Model Training...'))
# C. Press Ctrl+O (Save).
# D. Press Enter (Confirm filename).
# E. Press Ctrl+X (Exit).
# -------------------------------

# 4. VERIFY THE FIX
# i. WHAT: Run the script again.
# ii. WHY: To confirm our manual edit worked.
python3 broken_model.py
# Expected Output: Starting Model Training...






































# 1. SETUP: CREATE A TEST FILE
# i. WHAT: Create a simple empty file named 'secret_model.pkl'.
# ii. WHY: We need a file owned by the current user to examine default permissions.
# iii. WHAT IF: If we don't create it, ls will fail.
touch secret_model.pkl

# 2. INSPECT PERMISSIONS (THE DECODE)
# i. WHAT: List details for the file we just created.
# ii. WHY: To see the 'rwx' string. Look for output like '-rw-r--r--'.
# iii. WHAT IF: If you ignore this, you won't know if your colleague can overwrite your model.
ls -l secret_model.pkl

# 3. IDENTITY CHECK
# i. WHAT: Run the 'id' command.
# ii. WHY: To see your 'uid' (User ID) and 'gid' (Group ID).
# iii. WHAT IF: If you are in the 'docker' group, you can control containers. If not, you can't.
id

# 4. THE FORBIDDEN DOOR (FAIL TEST)
# i. WHAT: Try to list the contents of the /root directory (The admin's home).
# ii. WHY: /root is usually owned by root with permissions 'drwx------' (User only).
# iii. EXPECTED RESULT: "Permission denied". This confirms the OS is enforcing the rules.
ls /root

# 5. CHECKING BINARY PERMISSIONS
# i. WHAT: Check permissions of the 'ls' program itself.
# ii. WHY: To see why everyone is allowed to run this command.
# iii. LOOK FOR: You will likely see '-rwxr-xr-x'. The final 'x' means "Others can Execute".
ls -l /bin/ls


















































# 1. SETUP: Create dummy assets for the simulation
# We create a directory to ensure we don't mess up your actual home folder.
mkdir -p mlops_permission_lab
cd mlops_permission_lab

# Create a "script" and a "dataset"
touch training_pipeline.py
touch model_weights.h5

echo "--- Initial State ---"
# ls -l: List in long format to see permission bits (e.g., -rw-r--r--)
ls -l

# ==========================================
# PART 1: NUMERIC MODE (The Precise Way)
# ==========================================

echo -e "\n--- Locking down Model Weights (Numeric 600) ---"
# WHAT: Set permissions to 600 (User: Read/Write, Group: None, Others: None).
# WHY: Model weights or API keys are sensitive. We do not want 'Group' or 'Others' to even read them.
# WHAT IF WE CHANGE IT? If we used 644, anyone on the server could steal your IP.
chmod 600 model_weights.h5

# Verify the change
ls -l model_weights.h5

echo -e "\n--- Making Script Publicly Executable (Numeric 755) ---"
# WHAT: Set permissions to 755 (User: R/W/X, Group: R/X, Others: R/X).
# WHY: Standard permission for scripts/binaries. The owner can edit, but everyone else can only run it.
# WHAT IF WE CHANGE IT? If we used 777, anyone could edit the script and inject malicious code. Never use 777.
chmod 755 training_pipeline.py

# Verify the change
ls -l training_pipeline.py

# ==========================================
# PART 2: SYMBOLIC MODE (The Quick Way)
# ==========================================

echo -e "\n--- Making Script Executable via Symbol (Symbolic +x) ---"
# Create a new script for this test
touch deploy.sh

# WHAT: Add execute (+x) permission to ALL users (User, Group, Others).
# WHY: This is the most common command you will run ("chmod +x script.sh") to make a text file runnable.
chmod +x deploy.sh

ls -l deploy.sh

echo -e "\n--- Revoking Write Access for Group (Symbolic g-w) ---"
# Create a shared config file
touch shared_config.yaml
chmod 664 shared_config.yaml # Initially verify rw-rw-r--

# WHAT: Remove write (-w) permission specifically for the Group (g).
# WHY: You realized your teammates (Group) shouldn't be editing this config file, only reading it.
chmod g-w shared_config.yaml

ls -l shared_config.yaml

# ==========================================
# PART 3: OWNERSHIP (chown)
# ==========================================

echo -e "\n--- Changing Ownership (chown) ---"
# Note: Changing ownership usually requires sudo because you are giving away a file.
# We will use sudo here. If you don't have sudo, this step will fail (which is expected behavior).

# WHAT: Change the owner of 'model_weights.h5' to the current user (noop) and group to 'root'.
# WHY: In MLOps, we often change ownership to 'www-data' (web server) or a specific service user for security.
# SYNTAX: chown user:group filename
# WHAT IF WE CHANGE IT? If the web server doesn't own the file, your API will crash with "Permission Denied".
echo "Attempting to change group ownership to root (requires password)..."
sudo chown $USER:root model_weights.h5

ls -l model_weights.h5

echo -e "\n--- Cleanup ---"
# Remove the lab directory
cd ..
rm -rf mlops_permission_lab
echo "Lab completed. Directory cleaned up."



































































#!/bin/bash

# FILE: 02_privilege_check.sh
# SEGMENT: 3.4 Elevated Privileges
# GOAL: Audit user privileges, interact with sudo, and understand root access.

# ==========================================
# PART 1: IDENTITY MANAGEMENT
# ==========================================

echo "--- Who am I? ---"
# WHAT: Print the current username.
# WHY: In automation scripts, you need to know if you are 'jesse' or 'root' to decide paths (e.g., /home/jesse vs /root).
whoami

echo "--- User ID Checks ---"
# WHAT: Print the User ID (uid) and Group IDs (gid).
# WHY: The 'root' user always has uid=0. This is how scripts check if they have superpowers.
id

# ==========================================
# PART 2: SUDO AUDIT (Managing Sudoers)
# ==========================================

echo -e "\n--- Checking Sudo Privileges ---"
# WHAT: List (-l) the allowed commands for the current user.
# WHY: This reads the /etc/sudoers file effectively. It tells you if you can run ALL commands or just specific ones.
# WHAT IF WE CHANGE IT? If this fails, you are not in the 'sudo' group and cannot administer the server.
sudo -l

# ==========================================
# PART 3: ELEVATED EXECUTION (sudo)
# ==========================================

echo -e "\n--- Executing as Root (sudo) ---"
# WHAT: Update the file modification timestamp using root privileges.
# WHY: If a file belongs to root (like system logs), a normal 'touch' fails. 'sudo touch' works.
# This proves we can borrow root powers for a single command.
sudo touch /tmp/root_test_file

# Verify owner is root
ls -l /tmp/root_test_file

# Clean up
sudo rm /tmp/root_test_file

# ==========================================
# PART 4: THE ROOT SHELL (sudo su)
# ==========================================

echo -e "\n--- Concept: Switching to Root Shell ---"
# We DO NOT execute 'sudo su' in a script because it launches a new interactive shell
# and pauses the script until you exit that shell.
# I will print the command you would use manually.

echo "To switch entirely to the root user (The God Mode), you would run:"
echo "  $ sudo su"
echo "Warning: Your prompt will change from '$' to '#'. Proceed with caution."

# Checking for root in a script (Standard Pattern)
if [ "$EUID" -ne 0 ]; then
  echo "Current status: You are NOT running this script as root (Safe)."
else
  echo "Current status: You ARE running as root (Dangerous)."
fi





































































#!/bin/bash

# FILE: 03_package_ops.sh
# SEGMENT: 4.1 Debian Package Management
# GOAL: Manage the software lifecycle (Update, Install, Remove, Purge).

# NOTE: This script uses 'sudo' heavily as package management is a system-level task.

# ==========================================
# PART 1: REFRESHING THE CATALOG (apt update)
# ==========================================

echo "--- Step 1: Updating Package Catalog ---"
# WHAT: Downloads the latest package lists from the repositories.
# WHY: Your local computer doesn't know a new version of 'git' exists until you run this.
# WHAT IF WE SKIP IT? 'apt install' might fail because it tries to download an old version that no longer exists on the server.
sudo apt update

# ==========================================
# PART 2: INSTALLATION (apt install)
# ==========================================

echo -e "\n--- Step 2: Installing a Tool (Example: 'htop') ---"
# WHAT: Installs the 'htop' system monitor.
# PARAMETER -y: Automatically answer "yes" to prompts.
# WHY: In automated MLOps pipelines (Dockerfiles), the build fails if the computer waits for you to press 'y'.
sudo apt install -y htop

# Verify installation
which htop

# ==========================================
# PART 3: UPGRADING (apt upgrade)
# ==========================================

echo -e "\n--- Step 3: Upgrading Installed Software (Simulation) ---"
# WHAT: Upgrades all currently installed packages to their newest versions found in the catalog.
# PARAMETER -s: Simulate (Dry-Run).
# WHY: We strictly use simulation here because running a full upgrade on your workstation might take 30 minutes.
# WHAT IF WE CHANGE IT? Removing '-s' would actually upgrade your OS packages.
sudo apt upgrade -s

# ==========================================
# PART 4: REMOVAL vs PURGE
# ==========================================

echo -e "\n--- Step 4: Removing a Tool (apt remove) ---"
# WHAT: Removes the binaries for 'htop' but KEEPS configuration files.
# WHY: If you plan to reinstall it later and want your custom color settings back, use remove.
sudo apt remove -y htop

echo -e "\n--- Step 5: Purging a Tool (apt purge) ---"
# WHAT: Removes binaries AND configuration files.
# WHY: You messed up the config so bad you want a clean slate, or you want to free up every byte of disk space.
# We will reinstall htop just to purge it, to demonstrate the command.
sudo apt install -y htop > /dev/null # Quiet install
sudo apt purge -y htop

echo "Package operations complete."





















































































#!/bin/bash
# -----------------------------------------------------------------------------
# SEGMENT 4.2: MANAGING REPOSITORIES
# GOAL: Install software from a "Boutique" store (PPA) instead of the main OS store.
# SCENARIO: We want the latest Python version (e.g., Python 3.12), but Ubuntu 
#           only ships with 3.10 by default. We need the "deadsnakes" PPA.
# -----------------------------------------------------------------------------

# 1. PRE-FLIGHT CHECK: UPDATE CURRENT CATALOG
# WHAT: Refresh the list of software available from the *current* repositories.
# WHY: If we don't do this, the system might try to download old versions of tools.
# WHAT IF WE SKIP: You might get "404 Not Found" errors when trying to install standard tools.
echo "Updating standard repository catalog..."
sudo apt update

# 2. INSTALL PREREQUISITES
# WHAT: Install the 'software-properties-common' package.
# WHY: This package contains the 'add-apt-repository' command itself. 
#      Minimally installed Linux servers (like inside Docker) often don't have this command.
# WHAT IF WE SKIP: The command 'add-apt-repository' will return "Command not found".
# -y: Automatically answer "yes" to "Do you want to install?" prompt.
echo "Installing prerequisites..."
sudo apt install -y software-properties-common

# 3. ADD THE PPA (PERSONAL PACKAGE ARCHIVE)
# WHAT: Register the 'deadsnakes' team's PPA to our system's list of trusted sources.
#      'ppa:deadsnakes/ppa' is the address of the "store".
# WHY: This specific PPA is the industry standard for getting newer Python versions on Ubuntu.
# WHAT IF WE CHANGE IT: Changing the string changes which "store" we trust. 
#      Only add PPAs from trusted developers!
echo "Adding the Deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa -y

# 4. REFRESH CATALOG AGAIN
# WHAT: Run update again.
# WHY: Now that we added the store (Step 3), we need to actually download *their* catalog.
#      (Note: Modern Ubuntu often does this automatically after add-apt-repository, 
#      but explicit is better than implicit in engineering).
# WHAT IF WE SKIP: The system won't know that 'python3.12' exists yet.
echo "Refreshing catalog with new PPA data..."
sudo apt update

# 5. INSTALL THE SOFTWARE
# WHAT: Install Python 3.12 specifically.
# WHY: Because we need features from the new version not available in the default system Python.
# WHAT IF WE CHANGE IT: We could install 'python3.9' or 'python3.11' from this same PPA.
echo "Installing Python 3.12 from the new PPA..."
sudo apt install -y python3.12

# 6. VERIFY
# WHAT: Check the version of the installed binary.
# WHY: Trust but verify. Ensure the installation actually worked.
echo "Verification:"
python3.12 --version

echo "Segment 4.2 Complete."














































































#!/bin/bash
# -----------------------------------------------------------------------------
# SEGMENT 4.3: COMPILING FROM SOURCE
# GOAL: Build a tool (htop) from raw code because we pretend it's not in the app store.
# SCENARIO: You are on a secure server with no internet access to 'apt', but you 
#           managed to sneak in a .tar.gz file of a tool you need.
# -----------------------------------------------------------------------------

# 1. SETUP BUILD ENVIRONMENT
# WHAT: Install 'build-essential'.
# WHY: This installs GCC (C Compiler), Make, and other tools needed to "cook" the code.
#      You cannot compile C code without a compiler.
# WHAT IF WE SKIP: The './configure' step later will fail immediately.
echo "Installing compilers (The Oven)..."
sudo apt install -y build-essential libncurses5-dev libncursesw5-dev
# Note: ncurses libraries are specifically needed for 'htop' to draw graphics in the terminal.

# 2. DOWNLOAD SOURCE CODE
# WHAT: Download the compressed source code using 'wget'.
# WHY: We need the raw ingredients. 
#      Usually, you get this URL from the project's GitHub releases page.
# WHAT IF WE CHANGE IT: You would download a different program.
echo "Downloading htop source code..."
wget https://github.com/htop-dev/htop/releases/download/3.2.2/htop-3.2.2.tar.gz

# 3. EXTRACT THE ARCHIVE
# WHAT: Unpack the 'tarball'.
#      tar: The tape archive utility.
#      -x: Extract (pull out).
#      -z: Gunzip (decompress).
#      -v: Verbose (show us the files as they come out).
#      -f: File (operate on the specific filename provided next).
# WHY: The computer cannot read compressed files directly; we must open the box.
# WHAT IF WE SKIP: You just have a locked box you can't use.
echo "Extracting the tarball..."
tar -xzvf htop-3.2.2.tar.gz

# 4. ENTER THE DIRECTORY
# WHAT: Change directory into the folder we just extracted.
# WHY: The compilation commands (configure, make) must be run *inside* the folder 
#      where the source code lives.
echo "Entering source directory..."
cd htop-3.2.2

# 5. THE HOLY TRINITY - STEP 1: CONFIGURE
# WHAT: Run the configuration script provided by the developer.
# WHY: This checks your specific computer. "Do you have a CPU? Do you have RAM? 
#      Where are your libraries?" It creates a 'Makefile' customized for YOUR machine.
# WHAT IF WE SKIP: You won't have a 'Makefile', so you can't run 'make'.
echo "Step 1: Configuring (Checking ingredients)..."
./configure

# 6. THE HOLY TRINITY - STEP 2: MAKE
# WHAT: Run the 'make' command.
# WHY: This is the actual compilation. It turns human-readable C code into 
#      machine-readable binary code (0s and 1s).
# WHAT IF WE SKIP: You have a recipe but no cake.
echo "Step 2: Making (Baking the cake)..."
make

# 7. THE HOLY TRINITY - STEP 3: INSTALL
# WHAT: Run 'make install' with sudo permissions.
# WHY: This takes the binary we just built and copies it to /usr/local/bin.
#      This lets any user on the system run 'htop' just by typing it.
# WHAT IF WE SKIP: You can run the program from this folder, but you can't run it system-wide.
echo "Step 3: Installing (Serving the cake)..."
sudo make install

# 8. VERIFY
# WHAT: Run the newly compiled program's version check.
echo "Verification:"
htop --version

echo "Segment 4.3 Complete."












































































#!/bin/bash
# -----------------------------------------------------------------------------
# SEGMENT 4.4: PYTHON ENVIRONMENT MANAGEMENT
# GOAL: Create a safe, isolated space for Python libraries.
# SCENARIO: You are starting a new project called 'finance_bot'. You need 'pandas'.
#           You must NOT install pandas into the global system.
# -----------------------------------------------------------------------------

# 1. THE FORBIDDEN COMMAND (DO NOT RUN THIS)
# WHAT: Attempting to pip install globally with sudo.
# WHY IT IS BAD: This overwrites files the OS needs. 
#      If Ubuntu relies on 'urllib3' version 1.2 and you force install version 2.0,
#      your system might crash or 'apt' might stop working.
# echo "NEVER DO THIS: sudo pip install pandas"

# 2. INSTALL VENV TOOL
# WHAT: Install the 'python3-venv' package.
# WHY: Ubuntu creates a slim Python by default to save space. The tool to create
#      virtual environments is often an optional add-on we must install first.
# WHAT IF WE SKIP: The command 'python3 -m venv' will fail.
echo "Installing the venv creator tool..."
sudo apt install -y python3-venv

# 3. CREATE PROJECT DIRECTORY
# WHAT: Make a folder for our project.
# WHY: Good hygiene. Keep projects separate.
echo "Creating project folder..."
mkdir -p ~/projects/finance_bot
cd ~/projects/finance_bot

# 4. CREATE THE VIRTUAL ENVIRONMENT
# WHAT: Ask Python to run the 'venv' module and create a folder named '.venv'.
#      -m: Run library module as a script.
#      .venv: The name of the folder. The dot (.) makes it hidden (standard practice).
# WHY: This creates a sandbox. Inside '.venv' is a full copy of the Python executable
#      and an empty 'lib' folder.
# WHAT IF WE CHANGE IT: You can name it 'my_env', but '.venv' is the industry standard.
echo "Creating virtual environment (.venv)..."
python3 -m venv .venv

# 5. ACTIVATE THE ENVIRONMENT
# WHAT: Source the activate script inside the bin folder of the venv.
#      source: Read and execute commands from a file in the *current* shell.
# WHY: This changes your $PATH variable. It puts the '.venv/bin' folder at the very front.
#      So when you type 'python', it looks in the venv first, not the system.
# WHAT IF WE SKIP: You will still be using the System Python, defeating the purpose.
echo "Activating environment..."
source .venv/bin/activate

# 6. VERIFY ACTIVATION
# WHAT: Print the location of the python executable.
# WHY: To confirm we are inside the matrix. It should say '.../finance_bot/.venv/bin/python'.
#      If it says '/usr/bin/python', something went wrong.
echo "Checking which python we are using:"
which python

# 7. INSTALL LIBRARIES SAFELY
# WHAT: Install pandas using pip.
# WHY: Now that we are activated, 'pip' puts the files inside '.venv/lib/python3.x/site-packages'.
#      The global OS is untouched.
# WHAT IF WE SKIP: Your code won't run because it lacks dependencies.
echo "Installing pandas safely..."
pip install pandas

# 8. FREEZE REQUIREMENTS
# WHAT: Save a list of all installed libraries to a file.
# WHY: So another engineer can replicate your environment exactly.
#      'pip freeze' outputs the list. '>' redirects that output to a file.
# WHAT IF WE SKIP: You lose track of what your project needs to run.
echo "Saving requirements..."
pip freeze > requirements.txt

# 9. DEACTIVATE
# WHAT: Run the 'deactivate' command.
# WHY: Exit the sandbox and return to the normal system shell.
# WHAT IF WE SKIP: You stay in the venv. If you navigate to another project, 
#      you might accidentally install the wrong libraries there.
echo "Deactivating..."
deactivate

echo "Segment 4.4 Complete. You are safe from breaking the OS."











































































































#!/bin/bash


# Create a directory in the current user's home folder named sensitive_data
cd ~ && mkdir -p sensitive_data # -p means parent. A safety that prevents errors if the folder already exists

# Set the permissions of sensitive_data so that only the owner can Read, Write, and Execute. No one else (group or public) should have ANY access
chmod 700 sensitive_data # Read (4), Write (2), Execute (1), No Permission (0). We granted the user (4 + 2 + 1) while giving groups and others (0)


# Explicitly set the ownership of this folder to the current user (use $USER) and the current user's group
sudo chown $USER:$USER sensitive_data


# Ensure the package list is up to date
sudo apt update


# Kevin needs Python 3.12, but the server defaults to 3.10. Add the deadsnakes PPA programmatically

sudo apt install -y software-properties-common # -y automatically answers yes during a process, which makes the process faster and enables automation
sudo add-apt-repository ppa:deadsnakes/ppa -y


# Install python3.12, python3.12-venv, and the utility tool jq (JSON processor) using apt

# Ensure the script assumes "Yes" to prompts so it doesn't hang waiting for input
sudo apt install -y python3.12 python3.12-venv jq



# Create a temporary directory named temp_build.
mkdir -p temp_build && cd "./temp_build/"


sudo apt install -y build-essential libncurses5-dev libncursesw5-dev



# Download the htop version 3.2.2 source code (URL: https://github.com/htop-dev/htop/releases/download/3.2.2/htop-3.2.2.tar.gz)

# the link "https://github.com/htop-dev/htop/releases/download/3.2.2/htop-3.2.2.tar.gz" is no longer valid and returns a 404. I scrambled the net to get this one

URL=https://github.com/htop-dev/htop/releases/download/3.2.2/htop-3.2.2.tar.xz

wget $URL


# the following was done with AI help, since I couldn't download the .tar.gz file

# ===================================== Start of AI help =====================================
tar -xf htop-3.2.2.tar.xz # -xf is for Extract & File. Extract pulls out the contents, and File ensures that the filename mentioned next is the one acted on


cd "./htop-3.2.2/"

# Prepare the build

./configure

# Compile the source code
make

# Install the software (requires sudo)

sudo make install


# ===================================== End of AI help =====================================


# Critical Step: Clean up after yourself. Remove the temp_build directory after the installation is done

rm -rf temp_build # -rf is for recursive & force, enabling us to delete a folder recursively and by force


# Create a directory named project_kevin
mkdir -p project_kevin && cd project_kevin

# Inside it, create a virtual environment named .venv using the Python 3.12 executable you installed in Section 2
python3.12 -m venv .venv # -m ensures that the library module is run as a script


# Activate the environment
source .venv/bin/activate

# Install numpy (safety check: ensure it installs inside the venv)
pip install numpy


# Generate a requirements.txt file inside project_kevin
pip freeze > requirements.txt

# Deactivate the environment
deactivate





























































































































































#!/bin/bash
# ==============================================================================
# SEGMENT 5.1: MONITORING - Process Surveillance Tools
# ==============================================================================
# Author: Jesse Nwachukwu
# Purpose: Demonstrate how to monitor system processes, CPU, and memory usage
# MLOps Context: Essential for identifying resource bottlenecks during model training
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION 1: The `top` Command - Real-Time Process Monitoring
# ------------------------------------------------------------------------------

echo "=========================================="
echo "DEMONSTRATION 1: Using 'top' Command"
echo "=========================================="
echo ""

# What: Display information about the `top` command
# Why: Before running an interactive command, we explain what the user will see
# How: Using echo to provide context
echo "The 'top' command provides a REAL-TIME view of system processes."
echo "It continuously updates (default: every 3 seconds)."
echo ""
echo "When you run 'top', you'll see:"
echo "  - CPU usage breakdown (user, system, idle)"
echo "  - Memory (RAM) usage"
echo "  - Swap usage (virtual memory on disk)"
echo "  - List of processes sorted by resource consumption"
echo ""

# What: Explanation of top's key columns
# Why: Users need to understand what each column means when they see it
echo "Key Columns in 'top':"
echo "  PID    = Process ID (unique identifier for each process)"
echo "  USER   = Who owns this process"
echo "  %CPU   = Percentage of CPU being used by this process"
echo "  %MEM   = Percentage of RAM being used by this process"
echo "  TIME+  = Total CPU time consumed (format: minutes:seconds.centiseconds)"
echo "  COMMAND= The actual program running"
echo ""

# What: Interactive commands available inside top
# Why: Users need to know how to control top once it's running
echo "Interactive Commands (press these keys while 'top' is running):"
echo "  M = Sort by memory usage (find RAM hogs)"
echo "  P = Sort by CPU usage (find CPU hogs)"
echo "  k = Kill a process (you'll be prompted for PID)"
echo "  q = Quit top"
echo "  h = Show help menu"
echo ""

# What: Run top in batch mode for demonstration
# Why: We use batch mode (-b) to capture one snapshot without entering interactive mode
# Parameter -b: Batch mode (non-interactive, outputs to stdout)
# Parameter -n 1: Number of iterations (we only want 1 update, not continuous)
# Why -n 1: Captures a single snapshot so we can display it in this script
# What happens if we don't use -n 1: top would run forever, blocking the script
echo "Running 'top' in batch mode (1 iteration) to show current snapshot:"
echo ""
top -b -n 1 | head -n 20  # Only show first 20 lines for readability
# What: | head -n 20 does
# Why: top's output can be 100+ lines, we truncate to keep the demo clean
# Parameter -n 20: Show only the first 20 lines

echo ""
echo "Press Enter to continue to htop demonstration..."
read -r  # Pause for user to review the output
# What: read -r does
# Why: Waits for user input before continuing (interactive learning)
# Parameter -r: Raw input mode (doesn't interpret backslashes as escape characters)

# ------------------------------------------------------------------------------
# SECTION 2: The `htop` Command - Enhanced Process Monitoring
# ------------------------------------------------------------------------------

echo ""
echo "=========================================="
echo "DEMONSTRATION 2: Using 'htop' Command"
echo "=========================================="
echo ""

# What: Check if htop is installed before trying to use it
# Why: htop is not installed by default on Ubuntu, we need to verify first
# How: Using the 'command -v' built-in to check if a command exists
if ! command -v htop &> /dev/null; then
    # What: &> /dev/null does
    # Why: Redirects both stdout and stderr to /dev/null (the void)
    # Why we need this: command -v outputs text if found, we only care about exit code
    
    echo "WARNING: htop is not installed on this system."
    echo ""
    echo "htop is an improved version of top with:"
    echo "  - Color-coded output (green, blue, red for different resource types)"
    echo "  - Visual CPU/Memory bars for each core"
    echo "  - Mouse support (click on processes!)"
    echo "  - Tree view (see parent-child process relationships)"
    echo "  - F-key shortcuts for common actions"
    echo ""
    
    # What: Provide installation instructions
    # Why: htop must be installed via apt package manager
    echo "To install htop, run:"
    echo "  sudo apt update"
    echo "  sudo apt install htop"
    # Why sudo: Installing system packages requires root privileges
    # What apt update does: Refreshes the list of available packages
    # What apt install does: Downloads and installs the specified package
    echo ""
else
    # What: htop is installed, explain its features
    # Why: Prepare the user for what they'll see when they run it
    echo "htop is installed! Here's what makes it better than top:"
    echo ""
    echo "VISUAL FEATURES:"
    echo "  - Each CPU core gets its own bar graph"
    echo "  - Memory and Swap shown as visual bars"
    echo "  - Color coding: Green=Used, Blue=Buffers, Yellow=Cache"
    echo ""
    echo "NAVIGATION:"
    echo "  F1 = Help screen"
    echo "  F2 = Setup (customize display)"
    echo "  F3 = Search for a process by name"
    echo "  F4 = Filter (show only processes matching a pattern)"
    echo "  F5 = Tree view (show process hierarchy)"
    echo "  F6 = Sort by (CPU%, MEM%, TIME, etc.)"
    echo "  F9 = Kill a process"
    echo "  F10 = Quit"
    echo ""
    echo "MOUSE SUPPORT:"
    echo "  - Click on a process to select it"
    echo "  - Click on column headers to sort"
    echo "  - Scroll with mouse wheel"
    echo ""
    
    # What: Explain why we're not running htop in this script
    # Why: htop is fully interactive and can't be demonstrated in batch mode
    echo "NOTE: htop is a fully interactive tool (no batch mode)."
    echo "To use it, simply type: htop"
    echo ""
    
    # What: Provide a use-case example
    # Why: Students learn better with concrete scenarios
    echo "MLOps Use Case:"
    echo "You're training 4 models in parallel. Open htop and:"
    echo "  1. Press F5 (tree view) to see if your launcher script spawned 4 children"
    echo "  2. Press F6, select 'MEM%' to see which model is using most RAM"
    echo "  3. If one model is stuck at 100% CPU on core 1 while others are idle,"
    echo "     you know your parallelization isn't working correctly."
    echo ""
fi

echo "Press Enter to continue to ps command demonstration..."
read -r

# ------------------------------------------------------------------------------
# SECTION 3: The `ps` Command - Process Snapshot
# ------------------------------------------------------------------------------

echo ""
echo "=========================================="
echo "DEMONSTRATION 3: Using 'ps' Command"
echo "=========================================="
echo ""

# What: Explain the difference between ps and top/htop
# Why: Students need to understand when to use each tool
echo "'ps' gives a ONE-TIME SNAPSHOT of processes (unlike top/htop which update continuously)."
echo "Think of it as taking a Polaroid photo of the current system state."
echo ""

# DEMO 3A: Basic ps (shows only current user's processes in current terminal)
echo "--- Demo 3A: Basic 'ps' (current terminal only) ---"
# What: ps with no arguments
# Why: Shows the most limited view (only processes attached to this terminal)
# What this is useful for: Checking if you have background jobs in THIS specific terminal
ps
# Expected output: Usually just 2 lines (the bash shell and the ps command itself)

echo ""
echo "Notice: Only 2-3 processes shown (your shell and this script)."
echo "This is because basic 'ps' only shows processes in the current terminal session."
echo ""

# DEMO 3B: ps aux (the power command)
echo "--- Demo 3B: 'ps aux' (ALL processes, ALL users) ---"
echo ""
echo "Breaking down 'ps aux':"
echo "  a = Show processes for ALL users (not just you)"
echo "  u = Display USER-oriented format (show who owns each process)"
echo "  x = Include processes WITHOUT a controlling terminal (daemons, background services)"
echo ""

# What: Run ps aux and display first 15 lines
# Why: ps aux typically outputs 100+ lines, we truncate for demonstration
ps aux | head -n 15
# What: | head -n 15 does
# Why: Pipes output to head, which shows only first 15 lines
# Parameter -n 15: Specifies how many lines to display

echo ""
echo "Column Breakdown:"
echo "  USER  = Process owner (root, jesse, postgres, etc.)"
echo "  PID   = Process ID (the unique identifier)"
echo "  %CPU  = Percentage of one CPU core being used"
echo "  %MEM  = Percentage of total RAM being used"
echo "  VSZ   = Virtual memory size (total allocated, including swap)"
echo "  RSS   = Resident Set Size (actual physical RAM in use RIGHT NOW)"
echo "  TTY   = Which terminal launched this (? = no terminal, it's a daemon)"
echo "  STAT  = Process state:"
echo "           R  = Running (actively using CPU)"
echo "           S  = Sleeping (waiting for something)"
echo "           D  = Uninterruptible sleep (usually disk I/O, can't be killed easily)"
echo "           Z  = Zombie (dead but not cleaned up by parent)"
echo "           T  = Stopped (paused with Ctrl+Z)"
echo "           +  = In foreground process group"
echo "  START = When this process started"
echo "  TIME  = Total CPU time consumed"
echo "  COMMAND = The actual command running"
echo ""

# DEMO 3C: Using ps aux with grep (finding specific processes)
echo "--- Demo 3C: Finding Specific Processes with 'ps aux | grep' ---"
echo ""

# What: Search for all bash processes
# Why: Demonstrates how to filter ps output to find specific programs
echo "Finding all bash shell processes:"
ps aux | grep bash | grep -v grep
# What: First grep does
# Why: Filters ps output to only lines containing "bash"
# What: Second grep -v grep does
# Why: Removes the grep command itself from results (the -v flag inverts the match)
# What happens without "grep -v grep": You'd see the grep process itself in results

echo ""
echo "MLOps Use Case:"
echo "  ps aux | grep python     # Find all Python processes"
echo "  ps aux | grep postgres   # Find database processes"
echo "  ps aux | grep 'train.py' # Find your specific training script"
echo ""

# DEMO 3D: Using ps with custom formatting
echo "--- Demo 3D: Custom ps Format (showing only specific columns) ---"
echo ""
echo "Instead of seeing ALL columns, we can choose exactly what to display:"
echo ""

# What: Custom ps format showing only PID, user, memory, and command
# Why: When diagnosing memory issues, we only care about these specific columns
# Parameter -eo: -e shows all processes, -o specifies custom output format
# Parameter pid,user,%mem,comm: The columns to display (comma-separated)
echo "Showing only: PID, USER, %MEM, and COMMAND"
ps -eo pid,user,%mem,comm | head -n 10
# What: -eo does
# Why: -e = show all processes, -o = use custom output format
# Parameter pid,user,%mem,comm: Comma-separated list of columns to display
# Why these columns: Perfect for memory leak investigations
# What happens if we used different columns: ps -eo pid,%cpu,time,comm would show CPU-focused data

echo ""
echo "This format is perfect for scripting because you get ONLY the data you need."
echo ""

# DEMO 3E: Sorting ps output by memory usage
echo "--- Demo 3E: Finding Top Memory Consumers ---"
echo ""
echo "Which processes are eating the most RAM?"
echo ""

# What: Sort all processes by memory usage (highest first) and show top 10
# Why: Critical for diagnosing "out of memory" errors during model training
# Parameter --sort=-%mem: Sort by memory percentage (- means descending order)
ps aux --sort=-%mem | head -n 11  # 11 lines because first line is the header
# What: --sort=-%mem does
# Why: Sorts output by %MEM column in descending order (highest memory first)
# Why the minus sign (-): Means descending order; without it, lowest memory would be first
# Parameter head -n 11: Show 11 lines (1 header + 10 processes)

ps -eo pid,%mem,comm --sort=-%mem | head -n 15

echo ""
echo "MLOps Scenario:"
echo "Your training script crashed with 'OOMKilled' (Out Of Memory)."
echo "Run: ps aux --sort=-%mem | head -n 20"
echo "You discover a data loader is using 45% of RAM due to a bug."
echo "You fix the memory leak and rerun successfully."
echo ""

# ------------------------------------------------------------------------------
# SECTION 4: Real-World MLOps Process Monitoring Example
# ------------------------------------------------------------------------------

echo "Press Enter to see a simulated MLOps monitoring workflow..."
read -r
echo ""
echo "=========================================="
echo "REAL-WORLD SCENARIO: Debugging a Slow Training Server"
echo "=========================================="
echo ""

# What: Simulate an MLOps engineer's troubleshooting workflow
# Why: Show how these commands work together in practice
echo "Scenario: Your model training is taking 3x longer than usual."
echo "Your debugging workflow:"
echo ""

echo "Step 1: Check overall system load"
# What: Use uptime to check load average
# Why: Quick way to see if system is overloaded
uptime
# What: uptime shows
# Why: Displays how long system has been running + load average (1min, 5min, 15min)
# What load average means: Number of processes waiting for CPU time
# Why it matters: If load > number of CPU cores, system is overloaded

echo ""
echo "Step 2: Identify CPU hogs"
# What: Find top 5 CPU-consuming processes
# Why: See if something unexpected is stealing CPU from your training
ps aux --sort=-%cpu | head -n 6
# What: --sort=-%cpu does
# Why: Sorts by CPU usage (descending), helps find processes hogging CPU time
# Parameter head -n 6: Show header + top 5 processes

echo ""
echo "Step 3: Identify memory hogs"
# What: Find top 5 memory-consuming processes
# Why: Maybe something is causing swapping (using disk as RAM), which is 1000x slower
ps aux --sort=-%mem | head -n 6

echo ""
echo "Step 4: Check for zombie processes (dead processes not cleaned up)"
# What: Search for zombie processes (state Z)
# Why: Zombies can accumulate and eventually prevent new processes from spawning
ps aux | grep defunct
# What: "defunct" means
# Why: Zombie processes show as "<defunct>" in the COMMAND column
# What causes zombies: Parent process didn't wait() for child process to finish
# Why this matters: If you have 1000+ zombies, you might hit the process limit

echo ""
echo "Analysis Complete!"
echo ""
echo "=============================================="
echo "MONITORING SUMMARY - KEY TAKEAWAYS"
echo "=============================================="
echo ""
echo "1. Use 'top' for quick, universal monitoring (works everywhere)"
echo "2. Use 'htop' for interactive, visual debugging (install it first)"
echo "3. Use 'ps aux' for scripting and automation (grep-able output)"
echo "4. Use 'ps aux --sort=-%mem' to find memory leaks"
echo "5. Use 'ps aux --sort=-%cpu' to find CPU bottlenecks"
echo ""
echo "Next Up: Segment 5.2 (Job Control) - Learning to multitask in the terminal!"
echo ""












