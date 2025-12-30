#!/bin/bash

# Docker Hub 自动构建和推送脚本
# 根据日期自动生成标签并推送到 Docker Hub

set -e

# 获取脚本所在目录的父目录作为项目根目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 配置
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME}"
IMAGE_NAME="kikoeru-translator"
DATE_TAG=$(date +'%Y%m%d')

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Docker 镜像构建和推送脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "项目根目录: $PROJECT_ROOT"
echo "Docker Hub 用户名: $DOCKER_HUB_USERNAME"
echo "镜像名称: $IMAGE_NAME"
echo "日期标签: $DATE_TAG"
echo ""

# 检查是否登录 Docker Hub
# 注意：某些Docker版本或配置可能不显示Username，这里仅作简单检查
if ! docker info 2>/dev/null | grep -q "Username"; then
    echo -e "${YELLOW}警告: 未检测到 Docker Hub 登录状态${NC}"
    echo "请先运行: docker login"
    read -p "是否现在登录? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        echo -e "${RED}取消操作${NC}"
        exit 1
    fi
fi

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 构建镜像
echo -e "${GREEN}构建 $IMAGE_NAME 镜像...${NC}"
docker build -t "$DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG" \
             -t "$DOCKER_HUB_USERNAME/$IMAGE_NAME:latest" \
             -f Dockerfile \
             .

# 推送镜像
echo -e "${GREEN}推送镜像到 Docker Hub...${NC}"
docker push "$DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG"
docker push "$DOCKER_HUB_USERNAME/$IMAGE_NAME:latest"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}构建和推送完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "镜像标签:"
echo "  - $DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG"
echo "  - $DOCKER_HUB_USERNAME/$IMAGE_NAME:latest"
echo ""
