# Docker 部署说明

## 前置条件
- 系统中已安装 Docker。
- Nvidia GPU 支持：安装 NVIDIA 驱动程序和 `nvidia-container-toolkit`。
- Docker Compose（通常包含在 Docker Desktop 中，Linux 上则为 `docker-compose-plugin`）。

## 快速开始（推荐）

我们推荐使用 Docker Compose 来管理应用程序。项目中已经提供了一个 `docker-compose.yml.example` 模板文件。

1.  **准备工作**：
    将示例配置复制到一个名为 `docker-compose.yml` 的新文件中：
    ```bash
    cp docker-compose.yml.example docker-compose.yml
    ```

2.  **配置**：
    打开 `docker-compose.yml` 并编辑环境变量：
    - `KIKOERU_URL`: 你的 Kikoeru 服务器的 URL。
    - `KIKOERU_USER`: 你的用户名（默认admin，没开用户验证的话不用改）。
    - `KIKOERU_PASSWORD`: 你的密码（默认123456，没开用户验证的话不用改）。
    - `WORKER_NAME`: 该 Worker 实例的唯一名称，用于区分翻译服务器。翻译服务之间通过这个名字相互区别，注意名字里只能有字母数字下划线

3.  **运行**：
    运行以下命令在后台启动容器（它会自动拉取镜像）：
    ```bash
    docker-compose up -d
    ```

    该命令将会：
    - 拉取镜像 `docker.io/papersman/kikoeru-translator:latest`。
    - 启动名为 `kikoeru-translator` 的容器。
    - 应用 GPU 配置（示例中默认启用）。

4.  **查看日志**：
    检查应用程序是否正常运行：
    ```bash
    docker-compose logs -f
    ```

## 手动运行（替代方案）

如果你不想使用 Docker Compose，也可以直接运行 `docker` 命令。

### 1. 拉取镜像

```bash
docker pull docker.io/papersman/kikoeru-translator:latest
```

### 2. 运行容器

**开启 GPU 支持（推荐）：**

```bash
docker run -d --name kikoeru-translator --gpus all \
  -e KIKOERU_URL="http://your-kikoeru-server.com" \
  -e KIKOERU_USER="your_username" \
  -e KIKOERU_PASSWORD="your_password" \
  -e WORKER_NAME="docker_translator_manual" \
  -v ./db_data:/app/db \
  docker.io/papersman/kikoeru-translator:latest
```

**仅 CPU（非常慢）：**

```bash
docker run -d --name kikoeru-translator \
  -e KIKOERU_URL="http://your-kikoeru-server.com" \
  -e KIKOERU_USER="your_username" \
  -e KIKOERU_PASSWORD="your_password" \
  -e WORKER_NAME="docker_translator_manual" \
  -v ./db_data:/app/db \
  docker.io/papersman/kikoeru-translator:latest
```

## 数据持久化

配置会将你的 Token 和任务状态保存在 `db` 目录中。
在 `docker-compose.yml` 中，这被映射到了宿主机上的 `./db_data`：

```yaml
    volumes:
      - ./db_data:/app/db
```

这确保了如果你重启容器，除非 Token 过期，否则无需重新登录。
