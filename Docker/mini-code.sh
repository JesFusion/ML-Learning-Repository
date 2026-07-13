#!/usr/bin/env bash
set -euxo pipefail



################################################################################
# SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES
################################################################################
#
# This educational script demonstrates advanced Docker concepts:
#   - Multi-stage build: Breaking a Dockerfile into multiple phases (builder, test, runtime)
#   - FROM AS builder: Naming intermediate stages so we can reference them later
#   - COPY --from=: Copying files from one stage to another
#   - docker build --target: Building only specific stages for debugging
#   - Base image choices: Understanding different Linux distributions (distroless, alpine, debian-slim)
#   - Image size optimization: Making Docker images as small as possible
#   - CGO_ENABLED=0: Compiling Go code without C dependencies
#   - GOOS/GOARCH: Cross-compilation flags for different operating systems and architectures

################################################################################

# The 'echo' command prints text to your terminal screen.
#
# The '-e' flag enables "escape sequences", which lets us use special color 
# variables like '${BLUE}' (blue text) and '${NC}' (No Color - reset to normal).
# This makes the output pretty and easy to read.

echo -e "${BLUE}=== SEGMENT 7: MULTI-STAGE BUILDS AND BASE IMAGES ===${NC}"

# A simple message telling the user what we're about to do.

echo "Creating a Python ML model builder demonstrating multi-stage builds..."

################################################################################
# [WHAT] Create a temporary directory for Segment 7
################################################################################
#
# 'mktemp' is a safe way to create a guaranteed-unique temporary file or folder.
# This is better than manually typing a folder name because it guarantees no 
# two runs will conflict with each other.
#
# The '-d' flag tells mktemp to create a Directory (folder) instead of a file.
#
# We wrap it in '$(...)' to run the command and immediately save its output 
# (the folder path) into the 'SEGMENT7_DIR' variable. This is called "command 
# substitution" because we're substituting the command's output into a variable.

SEGMENT7_DIR=$(mktemp -d)

# 'cd' stands for Change Directory. We are navigating into that brand new 
# temporary folder we just created.
#
# The double quotes around "$SEGMENT7_DIR" are important for safety. They protect 
# the path in case it happens to have spaces in it. Without quotes, Bash might 
# break the path into pieces and cause an error.

cd "$SEGMENT7_DIR"

################################################################################
# STREAMING_CHUNK: Generating the segment 7 runner script
################################################################################

# [WHAT] Create the standalone Bash script for Segment 7 multi-stage builds
#
# This is a "Here Document" (often called "Heredoc"). It's a way to write 
# multiple lines of text into a file all at once.
#
# The syntax 'cat << 'EOF' > segment7_runner.sh' means:
#   - 'cat' is the command (normally used to read files)
#   - '<<' tells Bash: "Read the input below until you see 'EOF'"
#   - 'EOF' is the marker that signals "stop reading" (End Of File)
#   - '> segment7_runner.sh' redirects all that text into a new file
#
# The single quotes around 'EOF' are a critical safety feature. They tell Bash 
# NOT to evaluate any $variables or run any commands right now. Just treat 
# everything as raw text. This is important because we want the variable 
# references inside the new script to remain as variable references, not to 
# be expanded with current values.

cat << 'EOF' > segment7_runner.sh

# ============================================================================
# [SHEBANG] This tells the operating system to use Bash for this script
# ============================================================================
#
# The '#!' at the very start is called a "shebang" (shell magic). It tells the 
# operating system: "When someone tries to run this file, please use the Bash 
# interpreter located at /bin/bash to execute it."
#
# Without this line, the OS wouldn't know which program to use to run the script.

#!/bin/bash

# ============================================================================
# SAFETY NET FOR BASH SCRIPTS: set -euo pipefail
# ============================================================================
#
# This line sets safety options that make the script more reliable.
#
# 'set' is a built-in command that changes how Bash behaves. The flags mean:
#
#   '-e' (errexit): "Exit immediately if any command fails."
#           Without this, the script keeps running even after errors,
#           which can cause cascading problems.
#
#   '-u' (nounset): "Exit if we try to use a variable that doesn't exist."
#           This catches typos in variable names (like $DATABASE_URL
#           when the actual variable is $DATABASE_URI).
#
#   '-o pipefail': "If a chain of commands fails (like cmd1 | cmd2),
#           the whole pipeline is considered failed."
#           Without this, only the last command's exit status is checked,
#           potentially hiding errors in earlier commands.
#
# Together, these flags create a "safety net" that stops the script immediately
# if anything goes wrong, preventing silent failures and data corruption.

set -euo pipefail

# ============================================================================
# Define the project folder name as a variable
# ============================================================================
#
# We create a variable called 'SEGMENT7_PROJECT' to hold the project folder name.
# Variables let us reuse this name throughout the script without typing it 
# repeatedly. If we need to change the folder name later, we only change it 
# in one place.

SEGMENT7_PROJECT="ml_model_builder_segment7"

# ============================================================================
# [WHAT] Custom function to print debug info with timestamps
# ============================================================================
#
# We are creating a custom function named 'log_info'. Functions are like 
# custom commands that bundle up code so we can reuse it by just typing 
# its name instead of repeating the same code over and over.
#
# When we call 'log_info "some message"', that message becomes available 
# inside the function as '$1' (the first argument).
#
# This function will be used throughout the script to print consistent,
# timestamped log messages. This makes it easy to track what the script
# is doing and when.

log_info() {
  # 'echo' prints text to the screen.
  #
  # 'date '+%Y-%m-%d %H:%M:%S'' grabs the current date and time from the system
  # and formats it nicely (e.g., 2023-10-25 14:30:00). The format codes mean:
  #   %Y = 4-digit year
  #   %m = 2-digit month (01-12)
  #   %d = 2-digit day (01-31)
  #   %H = 2-digit hour in 24-hour format (00-23)
  #   %M = 2-digit minute (00-59)
  #   %S = 2-digit second (00-59)
  #
  # The '$(...)' syntax captures the date command's output and inserts it 
  # into the echo statement.
  #
  # '$1' is a special variable that holds the first argument passed to this 
  # function. So if we call 'log_info "Hello"', then $1 = "Hello".
  #
  # Together, this line prints something like:
  #   [2023-10-25 14:30:00] INFO: Hello

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

# ============================================================================
# Using our custom log_info function
# ============================================================================
#
# We call our custom function! The text inside the quotes becomes '$1' 
# inside the log_info function.

log_info "Setting up Segment 7: ML Model Builder with multi-stage builds"

# ============================================================================
# [WHAT] Create the project directory structure
# ============================================================================
#
# 'mkdir' is a command that stands for "make directory". It creates folders.
#
# The '-p' flag is very useful:
#   - It creates any parent folders that don't exist yet
#   - It doesn't crash if the folder already exists
#   - 'p' stands for "parents"
#
# So 'mkdir -p "$SEGMENT7_PROJECT/src"' means: "Create a folder called
# '$SEGMENT7_PROJECT', and inside it, create a folder called 'src'. If either
# folder already exists, don't complain—just keep going."
#
# Without the '-p' flag, mkdir would fail if any part of the path was missing.

mkdir -p "$SEGMENT7_PROJECT/src"

# ============================================================================
# Create a folder for our trained machine learning models
# ============================================================================
#
# We need a separate folder where the trained AI models will be saved.
# In our multi-stage Dockerfile, the builder stage will create these models,
# and the final stage will copy just the models here (not all the 
# training dependencies).

mkdir -p "$SEGMENT7_PROJECT/models"

# ============================================================================
# Create a folder for our automated tests
# ============================================================================
#
# We'll add a test stage to our Dockerfile to verify that the model works
# correctly before shipping it. Tests go in a separate folder.

mkdir -p "$SEGMENT7_PROJECT/tests"

# ============================================================================
# [ACTION] Move inside our newly created project folder
# ============================================================================
#
# Now we change directory into the project folder. All commands from here 
# on out will run inside this folder until we 'cd' somewhere else.

cd "$SEGMENT7_PROJECT"

################################################################################
# STREAMING_CHUNK: Writing the Python Machine Learning training script
################################################################################

# ============================================================================
# [WHAT] Create ML model training script for the builder stage
# ============================================================================
#
# Another Heredoc! This time we are writing a Python script into the file 
# 'src/train_model.py'. This script will run in the BUILDER STAGE of our 
# multi-stage Dockerfile. The builder stage is the stage that installs all 
# the heavy dependencies (like scikit-learn, TensorFlow) and does all the 
# CPU-intensive training work. The final image won't include any of this.

cat << 'PYEOF' > src/train_model.py

# ============================================================================
# Python shebang
# ============================================================================
#
# This tells the operating system: "If someone runs this file directly 
# (like ./train_model.py), use Python 3 to execute it."
#
# '/usr/bin/env python3' is more portable than '/usr/bin/python3' because 
# 'env' finds Python wherever it's installed, rather than assuming a 
# specific path.

#!/usr/bin/env python3

"""
ML model training script.

This script runs in the BUILDER STAGE of a multi-stage Dockerfile.
- It loads a dataset (Iris flowers)
- Trains an AI model (Random Forest classifier)
- Saves the trained model to /models/iris_model.pkl

The final container will only copy the trained model file, NOT this script
or the training libraries (scikit-learn, etc.). This keeps the final image small.
"""

# ============================================================================
# [IMPORT] 'sys' - Interact with the Python interpreter
# ============================================================================
#
# 'sys' is a built-in Python module that lets us interact with the Python 
# interpreter itself. We use it to access things like command-line arguments,
# exit codes, and system configuration.

import sys

# ============================================================================
# [IMPORT] 'logging' - Print diagnostic messages
# ============================================================================
#
# 'logging' is Python's built-in tool for printing diagnostic messages.
# Unlike 'print()', logging lets us:
#   - Add timestamps automatically
#   - Control the level (DEBUG, INFO, WARNING, ERROR)
#   - Redirect messages to files or other places
#
# This is much better than print() for production code and debugging.

import logging

# ============================================================================
# [IMPORT] 'pickle' - Save and load Python objects
# ============================================================================
#
# 'pickle' is a tool that takes a live Python object (like a trained AI model)
# and converts it into a byte stream (serializes it) so it can be saved to a
# file. Later, we can load the file and unpickle it to get the object back.
#
# Think of it like taking a snapshot of an object's state and saving it to disk.

import pickle

# ============================================================================
# [IMPORT] 'os' - Interact with the operating system
# ============================================================================
#
# 'os' lets us interact with the operating system (like reading folders,
# checking if files exist, getting environment variables, etc.).

import os

# ============================================================================
# [IMPORT] 'Path' from 'pathlib' - Work with file paths safely
# ============================================================================
#
# 'pathlib' is a modern Python module for working with file paths.
# 'Path' is a class that makes working with file paths much easier and safer,
# especially when you need to work across different operating systems
# (Windows, Linux, Mac) that use different path separators (\ vs /).
#
# Instead of manually concatenating strings like "models/" + "iris_model.pkl",
# we can use Path objects like: Path("/models") / "iris_model.pkl"

from pathlib import Path

# ============================================================================
# [IMPORT] Scikit-learn - Machine learning library
# ============================================================================
#
# Scikit-learn (sklearn) is a massive, well-known machine learning library
# with hundreds of pre-built AI algorithms.
#
# 'load_iris' brings in a famous beginner dataset: measurements of iris flowers.
# This dataset is simple, small, and perfect for learning.

from sklearn.datasets import load_iris

# ============================================================================
# [IMPORT] 'train_test_split' - Divide data for testing
# ============================================================================
#
# When training an AI model, we need to:
#   1. Show it training data so it can learn
#   2. Test it on separate data it's never seen before
#
# 'train_test_split' randomly divides our data into a "training" pile and 
# a "testing" pile. This ensures the test data is completely fresh and 
# gives us an honest measure of how well the model works.

from sklearn.model_selection import train_test_split

# ============================================================================
# [IMPORT] 'RandomForestClassifier' - The AI algorithm
# ============================================================================
#
# 'RandomForestClassifier' is our actual AI algorithm. It works by building
# lots of decision trees (100, in our case) and having them vote on the answer.
# It's called "Random Forest" because:
#   - "Random": Each tree is built using random subsets of the data
#   - "Forest": There are many trees
#   - "Classifier": It classifies data into categories
#
# This algorithm is great for beginners because it works well on many types
# of data and doesn't require much tuning.

from sklearn.ensemble import RandomForestClassifier

# ============================================================================
# [IMPORT] Scoring and reporting tools
# ============================================================================
#
# These tools help us grade how well our AI did:
#   - 'accuracy_score': Calculates what percentage of guesses were correct
#   - 'classification_report': Gives detailed statistics about performance
#     on each category (precision, recall, F1-score)

from sklearn.metrics import accuracy_score, classification_report

# ============================================================================
# Configure logging to show INFO level messages
# ============================================================================
#
# logging.basicConfig() sets up the logging system.
# level=logging.INFO means: "Show me INFO messages and more serious ones
# (WARNING, ERROR, CRITICAL). Don't show DEBUG messages."

logging.basicConfig(level=logging.INFO)

# ============================================================================
# Create a logger for this specific file
# ============================================================================
#
# Each Python file can have its own logger. This one will identify messages
# as coming from this file. '__name__' is a special variable that equals
# the module name (in this case, '__main__').

logger = logging.getLogger(__name__)

# ============================================================================
# [FUNCTION] train_model() - The main training logic
# ============================================================================
#
# This function handles all the machine learning work:
#   1. Load the iris dataset
#   2. Split it into training and testing portions
#   3. Train the Random Forest classifier
#   4. Evaluate how accurate it is
#   5. Save the trained model to a file
#
# By putting all this logic in a function, we can:
#   - Reuse it easily
#   - Test it separately
#   - Call it from other scripts

def train_model():
    """Train a simple ML model and save it."""
    
    # ====================================================================
    # Load the iris dataset
    # ====================================================================
    logger.info("Loading Iris dataset")
    
    # The iris dataset is a collection of measurements from 150 iris flowers.
    # Each flower has 4 measurements (sepal length, sepal width, petal length, 
    # petal width) and is labeled with its species (Setosa, Versicolor, 
    # or Virginica).
    #
    # 'X' holds the features (measurements) - the INPUT data
    # 'y' holds the target answers (species names) - the OUTPUT we want to predict
    
    iris = load_iris()
    X, y = iris.data, iris.target
    
    # ====================================================================
    # Split the data: 80% training, 20% testing
    # ====================================================================
    logger.info("Splitting data: 80% train, 20% test")
    
    # We take 20% of the data and hide it from the AI during training so we can
    # test it later with fresh data. This is called "held-out test set" and gives
    # us an honest measure of how well the model works on new data it's never seen.
    #
    # 'random_state=42' ensures the random split is exactly the same every time
    # we run the script. This makes results reproducible (same result every run).
    # The number 42 is arbitrary—any number works, but 42 is a famous "magic number"
    # in computer science!
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # ====================================================================
    # Train the Random Forest classifier
    # ====================================================================
    logger.info("Training Random Forest classifier")
    
    # We create an empty AI brain (100 decision trees).
    # n_estimators=100 means we'll build 100 trees and have them vote
    # random_state=42 again ensures reproducibility
    
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    
    # Now we feed the model the training data so it can learn!
    # This is the heavy, CPU-intensive part where the algorithm actually runs
    # and builds its decision trees based on patterns in the data.
    
    model.fit(X_train, y_train)
    
    # ====================================================================
    # Evaluate the model on the test data
    # ====================================================================
    logger.info("Evaluating model")
    
    # We ask the trained AI to guess the answers for our hidden test data.
    # It doesn't know the real answers yet—we're testing it.
    
    y_pred = model.predict(X_test)
    
    # Now we compare the AI's guesses to the real answers.
    # accuracy_score returns a percentage (0.0 to 1.0) of how many were correct.
    
    accuracy = accuracy_score(y_test, y_pred)
    
    # Print the accuracy score, formatted to 4 decimal places
    # (e.g., 0.9667 means 96.67% correct)
    
    logger.info(f"Accuracy: {accuracy:.4f}")
    
    # ====================================================================
    # Save the trained model to a file
    # ====================================================================
    
    # We define exactly where we want to save our trained AI brain.
    # In Docker, this will be /models/iris_model.pkl
    
    model_path = Path("/models/iris_model.pkl")
    
    # Create the /models directory if it doesn't exist
    # parents=True creates any parent directories needed
    # exist_ok=True doesn't error if the folder already exists
    
    model_path.parent.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"Saving model to {model_path}")
    
    # Open the file in 'wb' (Write Binary) mode, and use pickle.dump to
    # stuff our trained AI model into the file. The 'with' statement ensures
    # the file gets closed properly even if something goes wrong.
    
    with open(model_path, 'wb') as f:
        pickle.dump(model, f)
    
    logger.info("Model training complete")
    
    # Hand the model object and its accuracy score back to whoever called this function
    return model, accuracy


# ============================================================================
# Classic Python trick: Only run this code if the file is run directly
# ============================================================================
#
# This line means: "If I run this script directly (like python train_model.py),
# execute the code below. But if another file imports this (like another Python
# file saying 'from train_model import train_model'), don't run this code."
#
# This is a Python convention that separates:
#   - Code that should always run (imports, function definitions)
#   - Code that should only run when the file is the main program
#
# The '__name__' variable is special: it equals '__main__' when the file
# is run directly, but equals the module name when imported.

if __name__ == '__main__':
    # Run our training function and grab the results
    model, accuracy = train_model()
    
    # Print a success message
    print(f"SUCCESS: Model trained with {accuracy:.4f} accuracy")

# ============================================================================
# [END] Close the Python training script Heredoc
# ============================================================================

PYEOF

# Log that we successfully created the training script
log_info "Model training script created at src/train_model.py"

################################################################################
# STREAMING_CHUNK: Writing the Python inference script
################################################################################

# ============================================================================
# [WHAT] Create model prediction/inference script
# ============================================================================
#
# Another Heredoc! This script is what our FINAL container will run.
# Notice how it doesn't need to train anything!
#
# In a multi-stage build:
#   - The BUILDER STAGE runs train_model.py and creates iris_model.pkl
#   - The FINAL STAGE copies just the iris_model.pkl file
#   - The FINAL STAGE runs predict.py, which loads and uses the model
#
# This is efficient because the final image doesn't include:
#   - scikit-learn, TensorFlow, PyTorch (heavy training libraries)
#   - This script
#   - The training script
#
# Only what's needed to RUN the model, not train it.

cat << 'PREDEOF' > src/predict.py

# ============================================================================
# Python shebang for the prediction script
# ============================================================================

#!/usr/bin/env python3

"""
Model prediction/inference script.

This script:
1. Loads a pre-trained model (copied from the builder stage)
2. Makes predictions using that model
3. Returns probabilities for each class

It does NOT train anything. It only uses a trained model that was built
in the builder stage. This is what goes in the FINAL runtime stage.

Because it only loads and runs the model, the final image only needs:
   - Python
   - pickle (built-in)
   - numpy (small)
   - The model file

It does NOT need scikit-learn, which saves about 200+ MB of image size!
"""

# ============================================================================
# [IMPORT] Pickle and logging
# ============================================================================

import pickle
import logging
from pathlib import Path

# ============================================================================
# [IMPORT] NumPy - Standard numerical computing library
# ============================================================================
#
# NumPy is the standard library for handling arrays and numbers in Python.
# Machine learning libraries depend on NumPy, so it has to be installed in the
# final image. But NumPy is much smaller than scikit-learn.

import numpy as np

# ============================================================================
# Configure logging
# ============================================================================

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# [FUNCTION] load_model() - Wake up the saved AI brain
# ============================================================================
#
# This function loads a pre-trained model that was saved by the training script.
# It unpickles the binary file and reconstructs the model object.

def load_model(model_path="/models/iris_model.pkl"):
    """Load a pre-trained model from disk."""
    
    logger.info(f"Loading model from {model_path}")
    
    # Open the file in 'rb' (Read Binary) mode
    with open(model_path, 'rb') as f:
        # Use pickle.load to resurrect the AI model from the binary file!
        # It reconstructs the exact model object that was saved
        model = pickle.load(f)
    
    logger.info("Model loaded successfully")
    return model


# ============================================================================
# [FUNCTION] predict() - Use the AI brain to make predictions
# ============================================================================
#
# This function takes a trained model and feature measurements,
# and returns the model's prediction and confidence scores.

def predict(model, features):
    """Make a prediction with the model.
    
    Args:
        model: A trained RandomForestClassifier
        features: A list of 4 measurements (sepal_length, sepal_width,
                 petal_length, petal_width)
    
    Returns:
        A dictionary with the prediction, probabilities, and class names
    """
    
    logger.info(f"Making prediction for features: {features}")
    
    # We feed the features (measurements) into the AI, and it spits out
    # a prediction (which species it thinks the flower is).
    # The [features] syntax wraps our single measurement in a list because
    # the model expects a 2D array (multiple flowers).
    
    prediction = model.predict([features])
    
    # It also spits out how confident it is about its guess.
    # This gives us probabilities for each possible class (species).
    # probabilities[0] is the probabilities array for the first flower.
    
    probabilities = model.predict_proba([features])
    
    # We package the results into a nice dictionary and return it
    return {
        'prediction': int(prediction[0]),  # Convert to regular Python int
        'probabilities': probabilities[0].tolist(),  # Convert to regular list
        'class_names': ['Setosa', 'Versicolor', 'Virginica']  # Readable names
    }


# ============================================================================
# Classic Python trick again: Only run if this file is the main program
# ============================================================================

if __name__ == '__main__':
    # Load the resurrected model
    model = load_model()
    
    # Create a sample iris measurement for testing
    # These are real measurements from an Iris Setosa flower
    sample = [5.1, 3.5, 1.4, 0.2]
    
    # Ask the AI what kind of flower it thinks this is!
    result = predict(model, sample)
    
    # Print the results in a human-readable format
    print(f"Prediction: {result['class_names'][result['prediction']]}")
    print(f"Probabilities: {result['probabilities']}")

# ============================================================================
# [END] Close the prediction script Heredoc
# ============================================================================

PREDEOF

# Log that we created the prediction script
log_info "Prediction script created at src/predict.py"

################################################################################
# STREAMING_CHUNK: Writing Dockerfiles for different base images
################################################################################

# ============================================================================
# [WHAT] Create a standard multi-stage Dockerfile
# ============================================================================
#
# This demonstrates the basic multi-stage pattern:
#   1. BUILDER STAGE: Install dependencies, train the model
#   2. TEST STAGE: Run tests on the trained model
#   3. RUNTIME STAGE: Minimal image with just the model and prediction script

cat << 'DOCKEREOF' > Dockerfile

# ============================================================================
# STAGE 1: BUILDER
# ============================================================================
#
# This stage does all the heavy work: installing dependencies and training the model.
# We call this stage 'builder' using the 'AS' keyword so we can reference it later.

FROM python:3.11-slim AS builder

# Set metadata for this image
LABEL stage="builder" description="Builder stage with training dependencies"

# Create a working directory (a folder inside the container where our code runs)
WORKDIR /build

# Copy our training script into the builder stage
COPY src/train_model.py .

# Install the heavy machine learning libraries
# 'pip install' is Python's package manager (like npm for Node.js or gem for Ruby)
# These libraries are needed for training but NOT for inference/prediction
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0

# Actually run the training script. After this line, the trained model
# will exist at /models/iris_model.pkl inside the container
RUN python train_model.py

# ============================================================================
# STAGE 2: TEST
# ============================================================================
#
# This optional stage runs tests to make sure the model works.
# We can build just this stage with 'docker build --target test' for debugging.

FROM python:3.11-slim AS test

LABEL stage="test" description="Test stage for model validation"

WORKDIR /test

# Copy the prediction script
COPY src/predict.py .

# Copy the trained model from the builder stage
# The syntax 'COPY --from=builder' means: "Copy from the 'builder' stage"
COPY --from=builder /models /models

# Install just NumPy (the prediction script only needs NumPy, not scikit-learn)
RUN pip install --no-cache-dir numpy==1.24.0

# Run the prediction script as a simple smoke test
# If the model can make a prediction, the test passes
RUN python predict.py

# ============================================================================
# STAGE 3: RUNTIME (FINAL)
# ============================================================================
#
# This is the stage that becomes the final image people download.
# It only contains what's needed to RUN the model, not train or test it.
#
# Starting from python:3.11-slim base image (already small)

FROM python:3.11-slim AS runtime

LABEL description="Production runtime with trained model"

# Set environment variables that affect Python behavior
# PYTHONUNBUFFERED=1 makes Python print immediately instead of buffering
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy the prediction script from the builder stage
COPY src/predict.py .

# Copy the trained model from the builder stage
COPY --from=builder /models /models

# Install just the minimal dependencies needed for prediction
# Notice we don't install scikit-learn - we don't need it!
RUN pip install --no-cache-dir numpy==1.24.0

# The default command to run when someone starts a container from this image
CMD ["python", "predict.py"]

# The final image is small because it only includes:
# - Python interpreter
# - NumPy
# - Our prediction script
# - Our trained model file
#
# It does NOT include:
# - scikit-learn
# - The training script
# - The test script
# - This Dockerfile
#
# This makes it much smaller than the builder stage!

DOCKEREOF

log_info "Standard Dockerfile (multi-stage) created"

# ============================================================================
# [WHAT] Create a distroless variant Dockerfile
# ============================================================================
#
# "Distroless" images are special images that contain ONLY the application
# and its runtime dependencies. They don't include:
#   - Shell (sh, bash)
#   - Package manager (apt, yum)
#   - Standard utilities (ls, grep, etc.)
#
# This makes them extremely small and secure (no shell means attackers can't 
# easily get inside). But they're harder to debug because there's no shell.

cat << 'DISTROLESSEOF' > Dockerfile.distroless

# ============================================================================
# BUILDER STAGE: Same as before
# ============================================================================

FROM python:3.11-slim AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using distroless base image
# ============================================================================
#
# 'python:3.11-distroless' is an official Python distroless image.
# It contains only Python and essential runtime files.
#
# Distroless images are tiny (around 100MB for Python vs 200+MB for slim)
# but you can't shell into them for debugging (no /bin/bash).

FROM python:3.11-distroless

LABEL description="Minimal distroless image with trained model"

WORKDIR /app

# Copy files from builder
COPY src/predict.py .
COPY --from=builder /models /models

# The predict.py script needs numpy, which should already be in distroless
# (distroless includes the Python standard library and common packages)

# Distroless images expect the command as an absolute path or in the form
# of an array (because there's no shell to parse it)
CMD ["/usr/bin/python3", "predict.py"]

DISTROLESSEOF

log_info "Distroless Dockerfile created"

# ============================================================================
# [WHAT] Create an Alpine Linux variant Dockerfile
# ============================================================================
#
# Alpine Linux is an extremely minimal Linux distribution (only 5-10 MB base image).
# It uses 'musl libc' instead of 'glibc' (the standard C library).
#
# Pros: Extremely small images
# Cons: Some software doesn't work with musl, and it can be slower for some operations

cat << 'ALPINEEOF' > Dockerfile.alpine

# ============================================================================
# BUILDER STAGE: Using alpine base
# ============================================================================

FROM python:3.11-alpine AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using alpine base
# ============================================================================
#
# 'python:3.11-alpine' is a Python image based on Alpine Linux.
# This results in a very small final image (around 80-100MB).
#
# Note: Alpine uses 'musl libc' instead of 'glibc', which can cause
# compatibility issues with some Python packages, but scikit-learn works fine.

FROM python:3.11-alpine

LABEL description="Alpine Linux image with trained model"

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY src/predict.py .
COPY --from=builder /models /models

# Alpine uses apk (not apt) as its package manager, so pip is used for Python packages
RUN pip install --no-cache-dir numpy==1.24.0

CMD ["python", "predict.py"]

ALPINEEOF

log_info "Alpine Dockerfile created"

# ============================================================================
# [WHAT] Create a Debian variant Dockerfile
# ============================================================================
#
# Debian-slim is a middle ground:
#   - Larger than Alpine (around 100-150MB) but much smaller than standard Debian
#   - Has better software compatibility than Alpine (uses glibc)
#   - Good balance of size and compatibility

cat << 'DEBIANEOF' > Dockerfile.debian

# ============================================================================
# BUILDER STAGE: Using Debian slim base
# ============================================================================

FROM python:3.11-slim AS builder

WORKDIR /build
COPY src/train_model.py .
RUN pip install --no-cache-dir \
    scikit-learn==1.3.0 \
    numpy==1.24.0
RUN python train_model.py

# ============================================================================
# RUNTIME STAGE: Using Debian slim base
# ============================================================================
#
# 'python:3.11-slim' is based on Debian GNU/Linux, stripped down.
# Larger than Alpine but better software compatibility.
#
# This is a good default choice: smaller than standard Debian,
# but more compatible than Alpine.

FROM python:3.11-slim

LABEL description="Debian slim image with trained model"

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY src/predict.py .
COPY --from=builder /models /models

RUN pip install --no-cache-dir numpy==1.24.0

CMD ["python", "predict.py"]

DEBIANEOF

log_info "Debian slim Dockerfile created"

################################################################################
# STREAMING_CHUNK: Writing docker-compose.yaml
################################################################################

# ============================================================================
# [WHAT] Create docker-compose.yaml for easy multi-variant builds
# ============================================================================
#
# Docker Compose is a tool that lets us define multiple containers in one file.
# Here we're defining how to build all four variants of our image.

cat << 'COMPOSEEOF' > docker-compose.yaml

# Docker Compose version
version: '3.8'

# ============================================================================
# Define services (what we're building)
# ============================================================================

services:
  # Standard variant (python:3.11-slim)
  
  model_standard:
    build:
      context: .
      # When no dockerfile is specified, it defaults to 'Dockerfile'
    container_name: model_standard
    environment:
      # Set an environment variable inside the container
      PYTHONUNBUFFERED: "1"
  
  # ========================================================================
  # Distroless variant (smallest and most secure, but hardest to debug)
  # ========================================================================
  
  model_distroless:
    build:
      context: .
      dockerfile: Dockerfile.distroless
    container_name: model_distroless
    # Distroless images cannot have a shell environment, so we limit the args
  
  # ========================================================================
  # Alpine variant (very small, musl libc)
  # ========================================================================
  
  model_alpine:
    build:
      context: .
      dockerfile: Dockerfile.alpine
    container_name: model_alpine
    environment:
      PYTHONUNBUFFERED: "1"
  
  # ========================================================================
  # Debian variant (good balance of size and compatibility, glibc)
  # ========================================================================
  
  model_debian:
    build:
      context: .
      dockerfile: Dockerfile.debian
    container_name: model_debian
    environment:
      PYTHONUNBUFFERED: "1"

# ============================================================================
# [END] Close the docker-compose.yaml Heredoc
# ============================================================================

COMPOSEEOF

log_info "docker-compose.yaml created with multi-variant builds"

################################################################################
# STREAMING_CHUNK: Writing the helper build script
################################################################################

# ============================================================================
# [WHAT] Create a Bash helper script to build and compare all variants
# ============================================================================
#
# This script provides convenient commands to:
#   1. Build all four image variants
#   2. Compare their sizes
#   3. Build only specific stages for debugging

cat << 'SCRIPTEOF' > build_variants.sh

# ============================================================================
# Bash shebang
# ============================================================================

#!/bin/bash

# ============================================================================
# === MULTI-STAGE BUILD VARIANTS ===
# ============================================================================
#
# This script helps you build and test all four variants of the ML model image

# ============================================================================
# [SAFETY] Set error handling options
# ============================================================================
#
# See the explanation earlier in this file for details on set -euo pipefail

set -euo pipefail

echo "Building multiple variants to compare base images..."
echo ""

# ============================================================================
# Build standard multi-stage (python:3.11-slim)
# ============================================================================
#
# This is the baseline variant using python:3.11-slim as the base image.

echo "Building standard (python:3.11-slim) variant:"

# 'docker build -t' builds an image and tags it with a name.
# '-t model:standard' creates a tag called 'model:standard'
# '.' means "use the Dockerfile in the current directory"

docker build -t model:standard .
echo ""

# ============================================================================
# Build distroless variant
# ============================================================================
#
# Distroless is the smallest and most secure option, but hardest to debug.

echo "Building distroless variant:"

# '-f' explicitly tells Docker which file to use.
# Without it, Docker would look for 'Dockerfile' by default.
# '-f Dockerfile.distroless' says: "Use Dockerfile.distroless instead"

docker build -f Dockerfile.distroless -t model:distroless .
echo ""

# ============================================================================
# Build alpine variant
# ============================================================================
#
# Alpine is very small (5MB base) but has musl instead of glibc.

echo "Building alpine variant:"
docker build -f Dockerfile.alpine -t model:alpine .
echo ""

# ============================================================================
# Build debian variant
# ============================================================================
#
# Debian is a good middle ground: not as small as Alpine,
# but better compatibility and uses glibc.

echo "Building debian-slim variant:"
docker build -f Dockerfile.debian -t model:debian .
echo ""

# ============================================================================
# Compare image sizes
# ============================================================================
#
# Now let's see which variant is smallest!

echo "=== IMAGE SIZE COMPARISON ==="

# 'docker images' lists all images on your computer.
# '| grep' filters the output to show only lines containing "model:"

docker images | grep "model:"
echo ""

# ============================================================================
# Demonstrate the --target flag
# ============================================================================
#
# The '--target' flag tells Docker to stop building at a specific stage.
# This is useful for debugging or just building the builder stage.

echo "Building only the builder stage (for testing/debugging):"

# '--target builder' tells a multi-stage Dockerfile to stop at the 'builder'
# stage and ignore the rest (test and runtime stages).
# This is faster for debugging because you don't wait for tests to run.

docker build --target builder -t model:builder-only .
echo ""

echo "Building only the test stage:"
docker build --target test -t model:test-only .
echo ""

# ============================================================================
# Summary
# ============================================================================

echo "=== BUILD COMPLETE ==="
echo ""
echo "You now have four variant images:"
echo "  model:standard    - Standard multi-stage (good balance)"
echo "  model:distroless  - Smallest but no shell"
echo "  model:alpine      - Very small, musl libc"
echo "  model:debian      - Good compatibility, reasonable size"
echo ""
echo "To run a container:"
echo "  docker run --rm model:standard"
echo ""
echo "To compare sizes:"
echo "  docker images | grep model:"
echo ""

# ============================================================================
# [END] Close the build_variants.sh Heredoc
# ============================================================================

SCRIPTEOF

# Make the script executable
chmod +x build_variants.sh

log_info "Build variants script created at build_variants.sh"

################################################################################
# STREAMING_CHUNK: Writing the .dockerignore file
################################################################################

# ============================================================================
# [WHAT] Create a .dockerignore file
# ============================================================================
#
# .dockerignore works like .gitignore but for Docker.
# It tells Docker: "When copying files into the image, skip these files/folders."
#
# This keeps images small by excluding files we don't need:
#   - .git directories (we don't need git history in the image)
#   - __pycache__ (compiled Python bytecode, will be regenerated)
#   - Tests (we run tests in the test stage, not the final stage)
#   - Documentation (users don't need docs in the image)

cat << 'IGNOREEOF' > .dockerignore

# ============================================================================
# [WHAT] Files to ignore when building Docker images
# ============================================================================

# Git repository data
.git
.gitignore

# Python bytecode and caches
__pycache__
*.pyc
*.pyo
.pytest_cache
.coverage
htmlcov

# IDE files
.vscode
.idea
*.swp
*.swo

# System files
.DS_Store

# Documentation and changelog
*.md
docs/
CHANGELOG

# Temporary files
.env
.env.local
tmp/
temp/
*.tmp

# Alternative Dockerfiles (we don't want these in every image)
Dockerfile.alpine
Dockerfile.debian
Dockerfile.distroless

# ============================================================================
# [END] Close the .dockerignore Heredoc
# ============================================================================

IGNOREEOF

log_info ".dockerignore created"

# ============================================================================
# Final logging and instructions
# ============================================================================

log_info "Segment 7 setup complete"
log_info "To build multi-stage images:"
log_info "  docker build -t model:standard ."
log_info "  docker build -f Dockerfile.distroless -t model:distroless ."
log_info "  docker build -f Dockerfile.alpine -t model:alpine ."
log_info "  docker build -f Dockerfile.debian -t model:debian ."
log_info "  OR: bash build_variants.sh (builds all variants)"

# ============================================================================
# [END] Close the very first, massive Heredoc
# ============================================================================
#
# This 'EOF' closes the Heredoc we opened at the beginning of the script.
# Everything between the first 'cat << 'EOF'' and this line has been written
# into the 'segment7_runner.sh' file.

EOF

# ============================================================================
# Make the script executable and run it
# ============================================================================
#
# 'chmod +x' stands for "change mode to executable".
# This tells the operating system that this file is a program that can be run.

chmod +x segment7_runner.sh

# ============================================================================
# [ACTION] Execute the script we just created
# ============================================================================
#
# We run the giant script using bash. This will execute all the commands inside,
# creating all the project files, Dockerfiles, and helper scripts.

bash segment7_runner.sh

# ============================================================================
# Print a success message
# ============================================================================
#
# Print a pretty green success message to show the user we're done.

echo -e "${GREEN}✓ Segment 7 complete: Multi-stage ML model builder project created${NC}"

# ============================================================================
# Return to the original directory
# ============================================================================
#
# 'cd -' goes back to the directory we were in before we ran this script.
# It's like an "undo" for directory navigation. This is useful because we did
# 'cd "$SEGMENT7_DIR"' earlier, and now we want to go back home.

cd -