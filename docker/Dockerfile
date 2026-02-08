# OpenWrt 编译环境
# 基于 Ubuntu 24.04，预装所有编译依赖
# 支持 ARM64 (Apple Silicon Mac) 和 AMD64

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装编译依赖（已移除 ARM64 不支持的 32 位库）
RUN apt-get update && apt-get install -y \
    ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache clang cmake cpio curl device-tree-compiler fastjar flex gawk gettext \
    git gnutls-dev gperf haveged help2man intltool \
    libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
    libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
    libreadline-dev libssl-dev libtool lld llvm lrzsz mkisofs msmtp \
    nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip \
    python3-ply python3-pyelftools python3-setuptools qemu-utils quilt rsync scons \
    squashfs-tools subversion swig texinfo uglifyjs upx unzip vim wget \
    xmlto xxd zlib1g-dev zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN useradd -m -s /bin/bash builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

# 设置 Git 配置
RUN git config --global user.email "builder@local" \
    && git config --global user.name "Builder"

CMD ["/bin/bash"]
