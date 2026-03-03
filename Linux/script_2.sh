#!/bin/bash



echo $SHELL - Tells you what shell you're using


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































































































































################################################################################
# PROCESS MANAGEMENT & RESOURCE TRIAGE FOR MLOPS
################################################################################
# Author: The Architect (for Jesse @ FUTO)
# Purpose: Demonstrate job control, process termination, and resource monitoring
# Curriculum: Segments 5.2, 5.3, 5.4
# Production Context: Managing multiple ML training jobs on a single server
################################################################################

################################################################################
# THE ENTERPRISE INGESTION LAYER
################################################################################
# This section ensures the script runs safely in any environment.
# It sets up strict error handling, logging, and cleanup procedures.
################################################################################

# WHAT: Enable "strict mode" - the script will exit immediately if any command fails
# WHY: In production, silent failures are deadly. If data ingestion fails but training
#      continues with stale data, you've just wasted hours of GPU time.
# WHAT IF we remove this: A failed command might go unnoticed, causing cascading failures
set -e

# WHAT: Exit if we try to use an undefined variable
# WHY: Typos in variable names ($MODLE_NAME instead of $MODEL_NAME) should crash the
#      script immediately, not silently pass empty strings to commands.
# WHAT IF we remove this: You might accidentally delete /data/$UNDEFINED_VAR/* which
#      becomes /data/* - deleting your entire dataset.
set -u

# WHAT: Make pipelines fail if ANY command in the pipe fails (not just the last one)
# WHY: Without this, "cat missing_file.txt | grep error" succeeds (because grep succeeds)
#      even though cat failed. You'd miss the missing file error.
# WHAT IF we remove this: Errors in the middle of data pipelines go unnoticed
set -o pipefail

################################################################################
# LOGGING INFRASTRUCTURE
################################################################################
# Every production script needs timestamped, categorized logging.
# This allows you to debug failures weeks later by reading logs.
################################################################################

# WHAT: Define the path where all script logs will be written
# WHY: Logs scattered across /tmp get deleted on reboot. Centralized logs are auditable.
# WHAT IF we change this: Make sure the directory exists and has write permissions
LOG_FILE="/tmp/process_management_$(date +%Y%m%d_%H%M%S).log"

# WHAT: Function to log informational messages with timestamps
# WHY: When debugging a failed job at 3 AM, timestamps tell you exactly when things broke
# WHAT IF we remove timestamps: You won't know if a process took 5 seconds or 5 hours
log_info() {
    # $1 refers to the first argument passed to this function
    # "date +%Y-%m-%d %H:%M:%S" generates timestamps like: 2026-02-01 14:30:45
    # We print to both the terminal (stdout) AND the log file using 'tee -a'
    echo "[INFO][$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

# WHAT: Function to log warning messages (non-fatal issues)
# WHY: Warnings indicate something unusual but recoverable (e.g., "Disk 85% full")
# WHAT IF we ignore warnings: Small issues snowball into production outages
log_warn() {
    # We use >&2 to print to stderr (standard error stream) instead of stdout
    # This allows you to separate normal output from warnings/errors when redirecting
    echo "[WARN][$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE" >&2
}

# WHAT: Function to log error messages (fatal issues)
# WHY: Errors should be loud and obvious. They indicate the script cannot continue safely.
# WHAT IF we don't log errors: Future you (debugging a crash) has no idea what went wrong
log_error() {
    echo "[ERROR][$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE" >&2
}

################################################################################
# CLEANUP HANDLER (The Safety Net)
################################################################################
# This function runs when the script exits (normally OR abnormally).
# It ensures temporary resources are cleaned up even if the script crashes.
################################################################################

# WHAT: Function that runs cleanup tasks before script termination
# WHY: If your script creates temporary files or background processes, they should
#      be cleaned up even if the script is killed with Ctrl+C or crashes
# WHAT IF we don't clean up: Temp files fill the disk, zombie processes leak memory
cleanup() {
    log_info "Running cleanup procedures..."
    
    # WHAT: Kill all background jobs started by THIS script
    # WHY: If we started training jobs in the background, they should die with the script
    # WHAT IF we don't kill them: Orphaned processes keep running forever, wasting resources
    # 'jobs -p' lists the PIDs of all background jobs in the current shell
    # 'xargs kill -15' sends SIGTERM (polite exit) to each PID
    # '2>/dev/null' suppresses error messages if there are no jobs to kill
    jobs -p | xargs -r kill -15 2>/dev/null || true
    
    log_info "Cleanup complete. Exiting."
}

# WHAT: Register the cleanup function to run on script exit
# WHY: 'trap' catches signals (EXIT, SIGINT, SIGTERM) and runs our cleanup function
# WHAT IF we remove this: Ctrl+C leaves background processes and temp files behind
# EXIT = normal script termination
# SIGINT = Ctrl+C
# SIGTERM = kill command (default signal)
trap cleanup EXIT SIGINT SIGTERM

################################################################################
# SEGMENT 5.4: RESOURCE TRIAGE FUNCTIONS
################################################################################
# These functions check system health BEFORE starting resource-intensive tasks.
# In production, you run these before launching training jobs to avoid OOM crashes.
################################################################################

# WHAT: Function to check available RAM and warn if low
# WHY: Starting a training job when RAM is 95% full guarantees an OOM crash
# WHAT IF we skip this check: Your 8-hour training job crashes at hour 7 due to OOM
check_memory() {
    log_info "Checking available memory..."
    
    # WHAT: Run 'free' command and extract the 'available' memory in MB
    # WHY: 'free -m' outputs memory in megabytes (human-readable)
    #      'awk' is a text processing tool - here it extracts the 7th column of the 2nd row
    #      (which is the 'available' memory)
    # WHAT IF we use 'free' instead of 'used': 'free' memory doesn't include reclaimable cache,
    #      so it's misleading. 'available' is the real usable memory.
    local available_mb=$(free -m | awk 'NR==2 {print $7}')
    
    log_info "Available memory: ${available_mb} MB"
    
    # WHAT: If available memory is less than 500 MB, log a warning
    # WHY: 500 MB is arbitrary but reasonable for demo purposes. In production,
    #      this threshold depends on your workload (training BERT needs 16GB+)
    # WHAT IF we set this too low: We don't catch memory pressure until it's too late
    if [ "$available_mb" -lt 500 ]; then
        log_warn "Low memory detected! Available: ${available_mb} MB"
        log_warn "Consider killing unused processes or reducing batch size"
    else
        log_info "Memory check passed: ${available_mb} MB available"
    fi
}

# WHAT: Function to check available disk space and warn if low
# WHY: Model checkpoints can be 10-50 GB each. Running out of disk mid-training
#      means you lose ALL progress (checkpoint save fails = crash)
# WHAT IF we skip this check: Your dataset download fails at 99% with "No space left"
check_disk_space() {
    log_info "Checking disk space..."
    
    # WHAT: Extract the disk usage percentage for the root filesystem (/)
    # WHY: 'df -h /' shows disk usage for the root partition
    #      'awk' extracts the 5th column (Use%) and 'tr -d %' removes the % symbol
    # WHAT IF we check /home instead: Different filesystems might be on different disks
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    
    log_info "Disk usage: ${disk_usage}%"
    
    # WHAT: If disk usage exceeds 80%, log a warning
    # WHY: At 90%+ usage, performance degrades (especially on SSDs). At 100%, writes fail.
    # WHAT IF we set this to 95%: By then, it's too late to prevent failures
    if [ "$disk_usage" -gt 80 ]; then
        log_warn "High disk usage detected: ${disk_usage}%"
        log_warn "Consider cleaning up old datasets or logs"
        
        # WHAT: Show the top 5 largest files/directories in /tmp (common junk location)
        # WHY: This gives actionable cleanup targets. Often, old logs or datasets live here.
        # WHAT IF we skip this: You know disk is full but don't know WHAT to delete
        log_info "Top 5 largest items in /tmp:"
        du -sh /tmp/* 2>/dev/null | sort -rh | head -5 | tee -a "$LOG_FILE" || true
    else
        log_info "Disk space check passed: ${disk_usage}% used"
    fi
}

################################################################################
# SEGMENT 5.2: JOB CONTROL DEMONSTRATION
################################################################################
# These functions simulate real MLOps workflows with background processes.
################################################################################

# WHAT: Simulate a long-running data preprocessing job
# WHY: In real MLOps, preprocessing (cleaning, augmentation, feature extraction) can
#      take hours. We simulate this with a sleep loop that prints progress.
# WHAT IF this was a real script: Replace this with actual data processing code
simulate_preprocessing() {
    log_info "Starting data preprocessing (simulated)..."
    
    # WHAT: Loop 10 times, sleeping 2 seconds each iteration
    # WHY: Simulates a task that takes 20 seconds total. Real preprocessing is slower.
    # WHAT IF we remove the loop: The function exits instantly (not realistic)
    for i in {1..10}; do
        # WHAT: Print progress to show the process is alive
        # WHY: Long-running processes should log progress (for monitoring/debugging)
        # WHAT IF we don't log: You can't tell if the process is stuck or just slow
        echo "Preprocessing batch $i/10..."
        
        # WHAT: Sleep for 2 seconds
        # WHY: Simulates CPU-intensive work. Real preprocessing uses actual compute.
        # WHAT IF we reduce to 0.1 seconds: The demo finishes too fast to observe job control
        sleep 2
    done
    
    log_info "Preprocessing complete!"
}

# WHAT: Simulate a model training job
# WHY: Training is the longest part of ML pipelines (hours to days). We simulate
#      this to demonstrate how to manage long-running processes.
# WHAT IF this was real: This would call PyTorch/TensorFlow training loops
simulate_training() {
    # WHAT: $1 is the first argument passed to this function (the model name)
    # WHY: Functions should be reusable. Passing the model name allows us to
    #      run multiple training jobs with different models.
    # WHAT IF we hardcode the name: We can't run parallel experiments
    local model_name=$1
    
    log_info "Starting training for model: $model_name (simulated)..."
    
    # WHAT: Loop 15 times, printing epoch progress
    # WHY: Training happens in epochs. Real training logs loss/accuracy per epoch.
    # WHAT IF we skip logging: You can't monitor training progress or detect divergence
    for epoch in {1..15}; do
        echo "[$model_name] Epoch $epoch/15 - Loss: $(echo "scale=4; 1/$epoch" | bc)"
        sleep 2
    done
    
    log_info "Training complete for model: $model_name"
}

################################################################################
# SEGMENT 5.2: BACKGROUND JOB DEMONSTRATION
################################################################################

demonstrate_job_control() {
    log_info "=== DEMONSTRATING JOB CONTROL ==="
    
    # WHAT: Start a preprocessing job in the BACKGROUND (using &)
    # WHY: The & symbol runs the command in the background, returning control to the script
    #      immediately. Without &, the script would BLOCK here for 20 seconds.
    # WHAT IF we remove &: The script waits for preprocessing to finish before continuing
    simulate_preprocessing &
    
    # WHAT: Capture the PID (Process ID) of the background job we just started
    # WHY: $! is a special variable containing the PID of the most recent background process.
    #      We need this PID to kill the process later.
    # WHAT IF we don't save the PID: We can't target this specific process for termination
    PREPROCESS_PID=$!
    
    log_info "Preprocessing started in background with PID: $PREPROCESS_PID"
    
    # WHAT: Start two training jobs in the background (for different models)
    # WHY: In production, you often run multiple experiments in parallel (testing different hyperparameters or architectures)
    # WHAT IF we run them in foreground: We'd have to wait for model1 to finish
    #      before model2 even starts (serial execution = slower)
    simulate_training "bert_v1" &
    TRAIN1_PID=$!
    
    simulate_training "gpt_v2" &
    TRAIN2_PID=$!
    
    log_info "Training jobs started:"
    log_info "  - bert_v1: PID $TRAIN1_PID"
    log_info "  - gpt_v2: PID $TRAIN2_PID"
    
    # WHAT: Wait 5 seconds before listing jobs
    # WHY: Gives the background processes time to start and produce output
    # WHAT IF we skip this: 'jobs' might show empty if we call it too quickly
    sleep 5
    
    log_info "Listing active jobs..."
    # WHAT: The 'jobs' command shows all background processes started by THIS shell
    # WHY: In production, you might have dozens of jobs. 'jobs' is your dashboard.
    # WHAT IF we use 'ps' instead: 'ps' shows ALL system processes (too noisy)
    jobs
    
    log_info "Waiting for all background jobs to complete..."
    # WHAT: 'wait' blocks until ALL background jobs finish
    # WHY: Without 'wait', the script would exit immediately, killing all background jobs (because they're child processes of the script)
    # WHAT IF we remove 'wait': The jobs get killed mid-execution when cleanup() runs
    wait
    
    log_info "All jobs completed successfully!"
}

################################################################################
# SEGMENT 5.3: PROCESS TERMINATION DEMONSTRATION
################################################################################

demonstrate_termination() {
    log_info "=== DEMONSTRATING PROCESS TERMINATION ==="
    
    # WHAT: Start a "runaway" process (infinite loop that never ends naturally)
    # WHY: In production, bugs can cause infinite loops. We need to know how to kill them.
    # WHAT IF this was real: Think of a data pipeline stuck retrying a failed API call
    log_info "Starting a runaway process (infinite loop)..."
    
    # WHAT: Start an infinite while loop in the background
    # WHY: while true runs forever. 'sleep 1' prevents it from consuming 100% CPU.
    # WHAT IF we don't background it: The script gets stuck here forever
    while true; do
        echo "Runaway process is running..." >> /tmp/runaway.log
        sleep 1
    done &
    
    # WHAT: Save the PID of the runaway process
    # WHY: We need this to demonstrate killing it with different signals
    # WHAT IF we lose this PID: We'd have to use 'ps' or 'pgrep' to find it again
    RUNAWAY_PID=$!
    
    log_info "Runaway process started with PID: $RUNAWAY_PID"
    
    # WHAT: Let it run for 3 seconds so we can verify it's running
    # WHY: Demonstrates the process is alive before we kill it
    # WHAT IF we skip this: The kill happens so fast you can't verify behavior
    sleep 3
    
    # WHAT: Check if the process is still running using 'ps'
    # WHY: 'ps -p PID' returns exit code 0 if the process exists, 1 if it doesn't
    #      We redirect output to /dev/null because we only care about the exit code
    # WHAT IF we don't check: We might try to kill an already-dead process
    if ps -p $RUNAWAY_PID > /dev/null; then
        log_info "Process $RUNAWAY_PID is running. Attempting graceful termination (SIGTERM)..."
        
        # WHAT: Send SIGTERM (signal 15) to the process
        # WHY: SIGTERM is the "polite" way to kill. It allows the process to catch the signal and clean up (save state, close files, etc.)
        # WHAT IF the process ignores SIGTERM: We'll need to use SIGKILL (9) next
        kill -15 $RUNAWAY_PID
        
        # WHAT: Wait 3 seconds to see if the process exits gracefully
        # WHY: Processes need time to handle SIGTERM and shutdown cleanly
        # WHAT IF we wait too long: In production, you'd wait 10-30 seconds max
        sleep 3
        
        # WHAT: Check if the process is STILL running after SIGTERM
        # WHY: Some processes ignore SIGTERM (infinite loops, hung I/O)
        # WHAT IF it exited: The 'else' block confirms graceful termination
        if ps -p $RUNAWAY_PID > /dev/null; then
            log_warn "Process did not respond to SIGTERM. Using SIGKILL (9)..."
            
            # WHAT: Send SIGKILL (signal 9) - the "nuclear option"
            # WHY: SIGKILL cannot be caught or ignored. The OS forcibly terminates the process.
            #      No cleanup happens. Files may be corrupted. Resources may leak.
            # WHAT IF we always use SIGKILL: You risk data corruption. Always try SIGTERM first.
            kill -9 $RUNAWAY_PID
            
            log_info "Process $RUNAWAY_PID forcefully terminated with SIGKILL"
        else
            log_info "Process $RUNAWAY_PID terminated gracefully with SIGTERM"
        fi
    fi
    
    # WHAT: Demonstrate killing by process name using 'pkill'
    # WHY: Sometimes you don't have the PID (the process was started by another script)
    #      or you want to kill ALL processes matching a pattern
    # WHAT IF you use the wrong pattern: You might kill critical system processes
    log_info "Demonstrating pkill (kill by name)..."
    
    # WHAT: Start another background process with a unique identifier
    # WHY: We'll use this identifier to target it with pkill
    # WHAT IF we don't use a unique name: pkill might kill unrelated processes
    while true; do
        echo "Target process for pkill demo"
        sleep 1
    done &
    
    PKILL_TARGET_PID=$!
    log_info "Started pkill target with PID: $PKILL_TARGET_PID"
    
    sleep 2
    
    # WHAT: Use pkill to kill the process by matching its command
    # WHY: 'pkill -f' matches the full command line, not just the process name
    #      This is more precise than 'pkill bash' (which would kill ALL bash processes)
    # WHAT IF we remove -f: We might kill the wrong processes
    # The || true prevents the script from crashing if pkill finds no matches
    log_info "Using pkill to terminate processes containing 'pkill demo'..."
    pkill -f "pkill demo" || true
    
    sleep 1
    
    # WHAT: Verify the process was killed
    # WHY: Confirms pkill worked as expected
    # WHAT IF it's still running: Our pattern didn't match correctly
    if ps -p $PKILL_TARGET_PID > /dev/null 2>&1; then
        log_warn "pkill failed to kill process $PKILL_TARGET_PID"
    else
        log_info "pkill successfully terminated the target process"
    fi
}

################################################################################
# MAIN EXECUTION
################################################################################
# This is the entry point of the script. It orchestrates all demonstrations.
################################################################################

main() {
    log_info "Starting Process Management & Resource Triage demonstration"
    log_info "Log file: $LOG_FILE"
    
    # WHAT: Run resource checks BEFORE starting any jobs
    # WHY: In production, you check system health before launching expensive operations
    # WHAT IF we skip this: Jobs might fail due to insufficient resources
    check_memory
    check_disk_space
    
    echo ""
    log_info "Resource checks complete. Press ENTER to continue to job control demo..."
    # WHAT: Wait for user input before continuing
    # WHY: Allows you to review resource check output before jobs start flooding the screen
    # WHAT IF we remove this: Everything happens too fast to observe
    read -r
    
    # WHAT: Demonstrate background jobs and job control
    # WHY: This is the core workflow for running parallel ML experiments
    # WHAT IF we skip this: You miss the most important part of the curriculum
    demonstrate_job_control
    
    echo ""
    log_info "Job control demo complete. Press ENTER to continue to termination demo..."
    read -r
    
    # WHAT: Demonstrate process termination techniques
    # WHY: You need to know how to kill runaway/stuck processes in production
    # WHAT IF we skip this: You can't handle hung processes or infinite loops
    demonstrate_termination
    
    log_info "All demonstrations complete!"
    log_info "Check the log file for full details: $LOG_FILE"
}

# WHAT: Call the main function to start the script
# WHY: Wrapping everything in a main() function is a best practice. It makes the
#      script's entry point explicit and allows for easier testing/debugging.
# WHAT IF we put code directly at the script level: It's harder to control execution flow and the code becomes less modular
main
















































































# shut down in case of any error...
# The 'set -e' command modifies the shell's behavior so that if any command fails (returns a non-zero exit status), the entire script will immediately terminate, preventing cascading errors.
set -e


# declaring vars and using them...
# Initializes a local variable named 'name' and assigns it the string value "Jesse" for later use in the script.
name="Jesse"

# Creates a variable called 'name_of_project' and assigns it a descriptive string representing the project's title.
name_of_project="Onyx-metal-fabrication-model-pipeline"

# Sets up a variable named 'm_version' to store the current version string "v1.0.11" of the project.
m_version="v1.0.11"


# NOTE: This prints the literal string "name" to the console, rather than the variable's value, because it lacks the '$' prefix required for variable interpolation.
echo name

# Prints the value stored in the 'name' variable ("Jesse") to the terminal, successfully using the '$' prefix for variable expansion.
echo $name

# Uses 'echo -e' to enable interpretation of backslash escapes; here, '\n' prints a newline before displaying the combined string containing the project name and version variables.
echo -e "\nName of Project: $name_of_project (Version $m_version)"



# Demonstrates a common pitfall: Bash looks for a variable named 'm_version_current' (which is undefined) instead of 'm_version', resulting in empty output for the variable part.
echo "Without curly braces: $m_version_current"

# Uses curly braces '${}' to explicitly define the boundaries of the 'm_version' variable name, safely appending the string "_current" directly to its value.
echo "With curly braces: ${m_version}_current"


# Safely expands the 'name' variable within a larger string using curly braces, then prints the full sentence to the console.
echo "${name} is a cool dude!"


# Constructs a complex string for a log file name by concatenating the project name, version, and the current date (dynamically generated by executing the 'date' command in a subshell using '$(...)').
log_file_name="${name_of_project}_${m_version}_$(date +%d-%m-%Y).log"

# Prints the newly constructed dynamic log file name to the terminal so the user can see what it generated.
echo "Log filename: ${log_file_name}"


# Creates an absolute file path by executing 'pwd' (print working directory) in a subshell, then appending a slash and the dynamically generated log file name.
path="$(pwd)/$log_file_name"

# Uses the 'touch' command to create a new, empty file at the absolute path specified by the 'path' variable (or updates its timestamp if it already exists).
touch "$path"

# Immediately removes (deletes) the file we just created using 'rm', with the '-f' (force) flag ensuring it won't prompt for confirmation or throw an error if the file is missing.
rm -f "$path"


# normal vars and exported vars...

# Defines a standard local variable holding a secret token; this variable is only accessible within the current shell script and will NOT be passed to any child processes.
local_secret_var="sk29e0394k23492k40139391k34j3l"

# The 'export' command makes 'exported_secret_var' an environment variable, meaning it WILL be inherited and accessible by any child processes or subshells spawned by this script.
export exported_secret_var="sk29e0394k23492k40139391k34j3l"



# Starts a new child Bash process (subshell) using the '-c' flag to execute the multi-line string of commands that follows.
bash -c '
    # Attempts to print the local secret, but it will evaluate to empty because "local_secret_var" was not exported to this child process environment.
    echo "Local: API token is ${local_secret_var}"
    
    # Successfully prints the exported secret, proving that variables marked with "export" are passed down to child processes like this one.
    echo "Exported: API token is ${exported_secret_var}"

    # Pauses the execution of this child subshell for 400 seconds, simulating a long-running process or simply keeping the script active.
    sleep 400
# Closes the multi-line string and finishes the command passed to the "bash -c" subshell.
'


# ===================================== SEGMENT 6.2: PERSISTENCE =====================================

# Defines a variable 'bashrc_location' that stores the absolute path to the current user's .bashrc configuration file by utilizing the $HOME environment variable.
bashrc_location="$HOME/.bashrc"

# Prints the resolved path of the .bashrc file to the terminal so the user can verify exactly which file is being targeted for potential modification.
echo ".bashrc Location = $bashrc_location"



# Starts a conditional block with a hardcoded 'false' condition, effectively disabling all the code inside this block so it acts purely as disabled/reference code and will never actually run.
if false; then

    # Opens a command group block using curly braces, which allows us to collect the standard output of multiple commands inside it and redirect them all at once.
    {
        # Outputs a shell command designed to create an environment variable 'doc' pointing to a specific Documents folder.
        echo 'export doc="/home/jesfusion/Documents"'

        # Outputs a shell command to create another environment variable 'sht' pointing to a specific Screenshots folder.
        echo 'export sht="/home/jesfusion/Pictures/Screenshots"'

        # Outputs an alias definition 'vv' which, when run, will activate a specific Python virtual environment for machine learning.
        echo 'alias vv="source /home/jesfusion/Documents/ml/ml-env/bin/activate"'

    # Closes the command group and appends ('>>') all the echoed strings from inside the group directly to the bottom of the user's .bashrc file without overwriting its existing content.
    } >> "$bashrc_location"

    # Reloads the .bashrc file into the current active shell session so the newly added exports and aliases become immediately available to use.
    source ~/.bashrc


    # Changes the current working directory to the path stored in the newly defined 'sht' (Screenshots) variable.
    cd $sht

    # Changes the directory again, this time jumping to the path stored in the 'doc' (Documents) variable.
    cd $doc

    # Executes the custom alias 'vv' to activate the Python virtual environment that was just appended to the .bashrc file.
    vv

# Closes the 'if false' conditional block, marking the end of the disabled script section.
fi





# ===================================== SEGMENT 6.3: SECRETS MANAGEMENT =====================================



# Creates an environment variable named 'name' and uses 'export' to ensure it is inherited by and accessible to any child processes (like Python scripts) spawned by this shell.
export name="Nwachukwu Jesse Chijioke"

# Exports a PostgreSQL database connection string (containing credentials and host info) as an environment variable to keep the sensitive secret out of hardcoded application logic.
export db_password="postgresql+psycopg2://postgres:djakdlldka30er@localhost:2006/postgres"


# Begins another disabled conditional block ('if false'), preventing the subsequent Python script creation and execution sequence from actually running during normal script execution.
if false; then

    # Starts a 'heredoc' that takes all following text up until the 'EOF' marker and redirects it to create or overwrite a file named 'test_.py'.
    cat <<EOF > test_.py
    # Inside the generated Python script: imports the built-in 'os' module to interact with the operating system, specifically to read the environment variables we exported in Bash.
    import os
    # Inside the generated Python script: imports the 'create_engine' function from the SQLAlchemy library to manage database connection pools.
    from sqlalchemy import create_engine
    # Inside the generated Python script: imports the Pandas data manipulation library and aliases it as 'pd' for convenience.
    import pandas as pd

    # Inside the generated Python script: retrieves the value of the 'name' environment variable securely from the OS and stores it in the 'user_name' Python variable.
    user_name = os.environ.get('name')

    # Inside the generated Python script: opens a multi-line formatted string (f-string) in a print function to output a greeting.
    print(f"""
    # Inside the generated Python script: embeds the retrieved 'user_name' variable directly into the string text.
    My name is {user_name}
    # Inside the generated Python script: closes the multi-line f-string and the print function call.
    """)

    # Inside the generated Python script: securely retrieves the database connection string from the 'db_password' environment variable instead of hardcoding it in the source code.
    con_string = os.environ.get("db_password")

    # Inside the generated Python script: initializes a SQLAlchemy database engine using the retrieved connection string to establish connectivity.
    engine = create_engine(con_string)

    # Inside the generated Python script: starts a Pandas function call to execute a SQL query and load the results directly into a DataFrame called 'trans_dataset'.
    trans_dataset = pd.read_sql_query(
        # Inside the generated Python script: specifies the raw SQL query string to fetch all records from the 'transactions' table.
        sql = "SELECT * FROM transactions",

        # Inside the generated Python script: passes the previously created SQLAlchemy engine to Pandas so it knows how to communicate with the database.
        con = engine
    # Inside the generated Python script: closes the Pandas read_sql_query function call.
    )


    # Inside the generated Python script: takes a random sample of 10 rows from the dataset and prints them, formatted as a visually appealing Markdown table using the "fancy_grid" style.
    print(trans_dataset.sample(10).to_markdown(tablefmt = "fancy_grid"))

# Marks the end of the heredoc, signaling Bash to stop writing text into 'test_.py' and return to normal script execution.
EOF

    # Executes the newly generated 'test_.py' Python script using the python interpreter.
    python test_.py

    # Cleans up by forcefully ('-f') deleting the 'test_.py' script after it finishes running, leaving no temporary files cluttering the directory.
    rm -f test_.py

# Closes the disabled conditional block that contains the Python script generation and execution logic.
fi


# Uses the 'printenv' command to explicitly print the value of the 'db_password' environment variable to the terminal, verifying it was exported correctly.
printenv db_password

# Uses the 'printenv' command to print the value of the 'name' environment variable to the terminal to confirm it is available in the current shell environment.
printenv name





# loding a .env file in bash...



# Creates a variable to store a temporary file path in '/tmp', using '$$' (which represents the current script's Process ID) to ensure the filename is completely unique and avoids collisions.
DEMO_ENV_FILE="/tmp/demo_project_env_$$"

# Starts another heredoc, this time using single quotes around 'EOF' to prevent Bash from evaluating/expanding any variables inside the text block, writing the raw contents straight into our temporary .env file.
cat > "$DEMO_ENV_FILE" << 'EOF'
# Inside the mocked .env file: a standard warning comment reminding developers that this file should remain local and never be committed to version control.
# .env — LOCAL ONLY. NEVER COMMIT THIS FILE.
# Inside the mocked .env file: defines a placeholder mock OpenAI API key.
OPENAI_API_KEY=sk-your-real-key-here
# Inside the mocked .env file: defines a mock database connection URL.
DATABASE_URL=postgresql://jesse:password@localhost:5432/mlops_db
# Inside the mocked .env file: defines a mock URL pointing to a local MLflow tracking server.
MLFLOW_TRACKING_URI=http://localhost:5000
# Inside the mocked .env file: defines a mock AWS S3 bucket path for storing machine learning models.
MODEL_REGISTRY_BUCKET=s3://jesse-models
# Inside the mocked .env file: sets a boolean flag variable to enable debugging mode.
DEBUG=true
# Inside the mocked .env file: specifies the current deployment environment, explicitly set to 'development'.
ENVIRONMENT=development
# Ends the heredoc, finalizing the creation of our temporary mock .env file containing the mock configuration.
EOF



# Prints the generated path of the temporary .env file so the user can see exactly where it was stored in the /tmp directory.
echo "$DEMO_ENV_FILE"


# Turns on the 'allexport' option (also known as 'set -o allexport') in Bash, which means any variables defined or modified from this point forward will be automatically exported to the environment without needing the 'export' keyword.
set -a

# Uses process substitution '<()' to run 'sed' on the .env file (stripping out comments starting with '#' and deleting empty lines), and then uses 'source' to execute those cleaned-up variable assignments directly in the current shell.
source <(sed 's/#.*//g; /^\s*$/d' "$DEMO_ENV_FILE")

# Turns off the 'allexport' option ('+a') so that future variable assignments revert to their normal behavior and are not automatically exported to child processes.
set +a


# Prints an empty line to the console to visually separate the upcoming variable output from any previous terminal logs.
echo ""
# Prints the newly sourced 'DATABASE_URL' environment variable to the console to verify it was successfully parsed and loaded from the .env file.
echo "DATABASE_URL:           $DATABASE_URL"
# Prints the newly sourced 'ENVIRONMENT' variable to the console to confirm it was loaded correctly.
echo "ENVIRONMENT:            $ENVIRONMENT"
# Prints the newly sourced 'DEBUG' variable to the console to check its evaluated value.
echo "DEBUG:                  $DEBUG"
# Prints the newly sourced 'MODEL_REGISTRY_BUCKET' variable, proving the dynamic 'sed' and 'source' pipeline worked perfectly to load all .env values.
echo "MODEL_REGISTRY_BUCKET:  $MODEL_REGISTRY_BUCKET"













