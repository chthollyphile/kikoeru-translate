# Docker Deployment Instructions

## Prerequisites
- Docker installed on your system.
- For GPU support (recommended): NVIDIA drivers and `nvidia-container-toolkit` installed.
- Docker Compose (usually included with Docker Desktop, or `docker-compose-plugin` on Linux).

## Quick Start (Recommended)

We recommend using Docker Compose to manage the application. A template file `docker-compose.yml.example` is provided.

1.  **Preparation**:
    Copy the example configuration to a new file named `docker-compose.yml`:
    ```bash
    cp docker-compose.yml.example docker-compose.yml
    ```

2.  **Configuration**:
    Open `docker-compose.yml` and edit the environment variables:
    - `KIKOERU_URL`: URL of your Kikoeru server.
    - `KIKOERU_USER`: Your username.
    - `KIKOERU_PASSWORD`: Your password.
    - `WORKER_NAME`: A unique name for this worker instance.

3.  **Build and Run**:
    Run the following command to build the image and start the container in the background:
    ```bash
    docker-compose up -d --build
    ```

    This command will:
    - Build the image `kikoeru-translator:latest`.
    - Start the container named `kikoeru-translator`.
    - Apply the GPU configurations (enabled by default in the example).

4.  **View Logs**:
    To check if the application is running correctly:
    ```bash
    docker-compose logs -f
    ```

## Manual Build & Run (Alternative)

If you prefer not to use Docker Compose, you can run `docker` commands directly.

### 1. Build the Image

```bash
docker build -t kikoeru-translator:latest .
```

### 2. Run the Container

**With GPU Support (Recommended):**

```bash
docker run -d --name kikoeru-translator --gpus all \
  -e KIKOERU_URL="http://your-kikoeru-server.com" \
  -e KIKOERU_USER="your_username" \
  -e KIKOERU_PASSWORD="your_password" \
  -e WORKER_NAME="docker_translator_manual" \
  -v ./db_data:/app/db \
  kikoeru-translator:latest
```

**CPU Only:**

```bash
docker run -d --name kikoeru-translator \
  -e KIKOERU_URL="http://your-kikoeru-server.com" \
  -e KIKOERU_USER="your_username" \
  -e KIKOERU_PASSWORD="your_password" \
  -e WORKER_NAME="docker_translator_manual" \
  -v ./db_data:/app/db \
  kikoeru-translator:latest
```

## Data Persistence

The configuration keeps your token and task state in the `db` directory.
In `docker-compose.yml`, this is mapped to `./db_data` on your host machine:

```yaml
    volumes:
      - ./db_data:/app/db
```

This ensures that if you restart the container, you won't need to re-login unless the token expires.
