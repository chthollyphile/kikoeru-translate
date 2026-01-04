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

if [ -z "$DOCKER_HUB_USERNAME" ]; then
    echo -e "${RED}错误: 未设置 DOCKER_HUB_USERNAME 环境变量${NC}"
    echo "请先设置环境变量: export DOCKER_HUB_USERNAME=your_dockerhub_username"
    exit 1
fi

echo "Docker Hub 用户名: $DOCKER_HUB_USERNAME"
echo "镜像名称: $IMAGE_NAME"
echo "日期标签: $DATE_TAG"
echo ""

# 构建选项
BUILD_3500=false
BUILD_5000=false

# 解析命令行参数
if [ $# -gt 0 ]; then
    case "$1" in
        all|a)
            BUILD_3500=true
            BUILD_5000=true
            ;;
        3500)
            BUILD_3500=true
            ;;
        5000)
            BUILD_5000=true
            ;;
        *)
            echo -e "${RED}无效选项: $1${NC}"
            echo "用法: $0 [all|3500|5000]"
            exit 1
            ;;
    esac
else
    # 交互式选择
    echo -e "${YELLOW}请选择构建选项:${NC}"
    echo "  1) 全部构建 (3500 + 5000)"
    echo "  2) 只构建 3500 (latest)"
    echo "  3) 只构建 5000 (beta)"
    echo ""
    read -p "请输入选项 [1/2/3]: " -n 1 -r BUILD_CHOICE
    echo ""
    
    case "$BUILD_CHOICE" in
        1)
            BUILD_3500=true
            BUILD_5000=true
            echo -e "${GREEN}将构建: 3500 (latest) + 5000 (beta)${NC}"
            ;;
        2)
            BUILD_3500=true
            echo -e "${GREEN}将构建: 3500 (latest)${NC}"
            ;;
        3)
            BUILD_5000=true
            echo -e "${GREEN}将构建: 5000 (beta)${NC}"
            ;;
        *)
            echo -e "${RED}无效选项，取消操作${NC}"
            exit 1
            ;;
    esac
fi
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

# 备份原始 model 目录
if [ -d "cache/model" ]; then
    echo -e "${YELLOW}备份 cache/model 目录...${NC}"
    mv cache/model cache/model_backup
fi

# ==========================================
# 构建 3500 version (latest & date tag)
# ==========================================
if [ "$BUILD_3500" = true ] && [ -d "cache/model-3500" ]; then
    echo -e "${GREEN}Preparing 3500 model...${NC}"
    cp -r cache/model-3500 cache/model
    
    echo -e "${GREEN}构建 $IMAGE_NAME:latest (3500 version) 镜像...${NC}"
    docker build -t "$DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG" \
                 -t "$DOCKER_HUB_USERNAME/$IMAGE_NAME:latest" \
                 -f Dockerfile \
                 .

    echo -e "${GREEN}推送 3500 version 镜像到 Docker Hub...${NC}"
    docker push "$DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG"
    docker push "$DOCKER_HUB_USERNAME/$IMAGE_NAME:latest"
    
    rm -rf cache/model
elif [ "$BUILD_3500" = true ]; then
    echo -e "${RED}Error: cache/model-3500 not found! Skipping latest build.${NC}"
fi

# ==========================================
# 构建 5000 version (beta tag)
# ==========================================
if [ "$BUILD_5000" = true ] && [ -d "cache/model-5000" ]; then
    echo -e "${GREEN}Preparing 5000 model...${NC}"
    cp -r cache/model-5000 cache/model
    
    echo -e "${GREEN}构建 $IMAGE_NAME:beta (5000 version) 镜像...${NC}"
    docker build -t "$DOCKER_HUB_USERNAME/$IMAGE_NAME:beta" \
                 -f Dockerfile \
                 .

    echo -e "${GREEN}推送 5000 version 镜像到 Docker Hub...${NC}"
    docker push "$DOCKER_HUB_USERNAME/$IMAGE_NAME:beta"
    
    rm -rf cache/model
elif [ "$BUILD_5000" = true ]; then
    echo -e "${RED}Error: cache/model-5000 not found! Skipping beta build.${NC}"
fi

# 恢复原始 model 目录
if [ -d "cache/model_backup" ]; then
    echo -e "${YELLOW}恢复 cache/model 目录...${NC}"
    mv cache/model_backup cache/model
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}构建和推送完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "已构建的镜像标签:"
if [ "$BUILD_3500" = true ]; then
    echo "  - $DOCKER_HUB_USERNAME/$IMAGE_NAME:$DATE_TAG"
    echo "  - $DOCKER_HUB_USERNAME/$IMAGE_NAME:latest"
fi
if [ "$BUILD_5000" = true ]; then
    echo "  - $DOCKER_HUB_USERNAME/$IMAGE_NAME:beta"
fi
echo ""
