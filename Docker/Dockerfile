
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
