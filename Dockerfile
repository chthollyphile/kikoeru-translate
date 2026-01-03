# Use NVIDIA CUDA base image with cuDNN 9 support to fix missing library errors
# This is required because CTranslate2/ONNXRuntime needs system-level CUDA/cuDNN libraries
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Set default paths for the application
    DB_PATH=/app/db \
    INPUT_PATH=/app/cache/input \
    OUTPUT_PATH=/app/cache/output \
    MODEL_PATH=/app/cache/model \
    # Optional: JSON string for transcription parameters
    TRANSCRIBE_PARAMS="" \
    # Ensure CUDA libraries are in LD_LIBRARY_PATH
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
# python3-pip and python3-venv are needed since we are on a base Ubuntu image now
# ffmpeg is required for audio processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create a symbolic link for python if it doesn't exist (python3 -> python)
RUN ln -s /usr/bin/python3 /usr/bin/python

# Copy the requirements file into the container at /app
COPY requirements.txt /app/

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app

# The .dockerignore file ensures that cache/cudnn (Windows DLLs) are excluded,
# but cache/model is included as requested.

# Create necessary directories that might be excluded by .dockerignore but needed at runtime
RUN mkdir -p /app/db /app/cache/input /app/cache/output

# Run the worker script when the container launches
CMD ["python", "run_kikoeru_worker.py"]
