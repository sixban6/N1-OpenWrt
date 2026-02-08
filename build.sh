#!/bin/bash
#
# N1-OpenWrt 本地编译脚本
# 使用 Docker 容器进行编译，无需手动配置环境
#

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="n1-openwrt-builder"
CONTAINER_NAME="n1-openwrt-build"
REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="v24.10.4"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 显示帮助
show_help() {
    cat << EOF
N1-OpenWrt 本地编译脚本

用法: ./build.sh [选项]

选项:
    --ssh       编译前进入容器 Shell（调试模式）
    --clean     清理编译环境和输出
    --shell     仅进入容器 Shell，不编译
    -h, --help  显示帮助信息

示例:
    ./build.sh          # 开始编译
    ./build.sh --ssh    # 调试模式，编译前可手动调整配置
    ./build.sh --clean  # 清理环境
EOF
}

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "未安装 Docker，请先安装 Docker"
    fi
    if ! docker info &> /dev/null; then
        error "Docker 服务未运行，请启动 Docker"
    fi
}

# 构建 Docker 镜像
build_image() {
    info "检查 Docker 镜像..."
    if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
        info "构建 Docker 镜像（首次运行需要几分钟）..."
        docker build -t "$IMAGE_NAME" "$SCRIPT_DIR/docker"
    else
        info "Docker 镜像已存在"
    fi
}

# 清理环境
clean_env() {
    info "清理编译环境..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    rm -rf "$SCRIPT_DIR/openwrt" "$SCRIPT_DIR/output"
    info "清理完成"
}

# 编译固件
do_build() {
    local ssh_mode=$1
    
    # 创建输出目录
    mkdir -p "$SCRIPT_DIR/output"
    
    # 编译脚本
    local build_script='
set -e

cd /home/builder

echo "==> 克隆 ImmortalWrt 源码..."
if [ ! -d "openwrt" ]; then
    git clone '"$REPO_URL"' -b '"$REPO_BRANCH"' --single-branch --depth=1 openwrt
fi

cd openwrt

echo "==> 更新 feeds..."
./scripts/feeds update -a
bash /build/armsr/armv8/diy/diy.sh
./scripts/feeds update -a
./scripts/feeds install -a

echo "==> 加载 N1 配置..."
rm -rf files .config
cp -rf /build/armsr/armv8/N1/files ./
cp /build/armsr/armv8/N1/.config ./

echo "==> 下载软件包..."
make defconfig
make download -j$(nproc)

echo "==> 开始编译..."
make -j$(($(nproc) + 1)) || make -j1 V=s

echo "==> 复制输出文件..."
cp -f bin/targets/armsr/armv8/*rootfs.tar.gz /output/ 2>/dev/null || true
cp -f bin/targets/armsr/armv8/*.img* /output/ 2>/dev/null || true

echo "==> 编译完成！输出文件在 output/ 目录"
'

    info "启动编译容器..."
    
    if [ "$ssh_mode" = "true" ]; then
        warn "SSH 调试模式：进入容器后执行以下命令开始编译："
        echo "  cd /home/builder && git clone $REPO_URL -b $REPO_BRANCH --single-branch --depth=1 openwrt"
        echo ""
        docker run -it --rm \
            --name "$CONTAINER_NAME" \
            -v "$SCRIPT_DIR:/build:ro" \
            -v "$SCRIPT_DIR/output:/output" \
            "$IMAGE_NAME" \
            /bin/bash
    else
        docker run -it --rm \
            --name "$CONTAINER_NAME" \
            -v "$SCRIPT_DIR:/build:ro" \
            -v "$SCRIPT_DIR/output:/output" \
            "$IMAGE_NAME" \
            /bin/bash -c "$build_script"
    fi
}

# 仅进入 Shell
enter_shell() {
    info "进入容器 Shell..."
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        -v "$SCRIPT_DIR:/build:ro" \
        -v "$SCRIPT_DIR/output:/output" \
        "$IMAGE_NAME" \
        /bin/bash
}

# 主函数
main() {
    local ssh_mode=false
    local clean_mode=false
    local shell_mode=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --ssh)
                ssh_mode=true
                shift
                ;;
            --clean)
                clean_mode=true
                shift
                ;;
            --shell)
                shell_mode=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "未知选项: $1"
                ;;
        esac
    done

    check_docker
    build_image

    if [ "$clean_mode" = "true" ]; then
        clean_env
        exit 0
    fi

    if [ "$shell_mode" = "true" ]; then
        enter_shell
        exit 0
    fi

    do_build "$ssh_mode"
}

main "$@"
