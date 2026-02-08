# 项目简介
本固件适配斐讯 N1。已经对项目进行修改，只支持24.10.4的openwrt
并且不做精简。可以再本地进行编译，已经适配，具体看使用方法。
# 本地编译
本项目支持使用 Docker 在本地进行编译，无需手动配置环境。


## 前置要求
- 安装 [Docker](https://www.docker.com/)
- 约 30GB 可用磁盘空间
- 稳定的网络连接

## 使用方法
```bash
# 克隆仓库
git clone https://github.com/sixban6/N1-OpenWrt.git
cd N1-OpenWrt

# 开始编译（首次运行会自动构建 Docker 镜像）
./build.sh

# 调试模式：编译前进入容器 Shell
./build.sh --ssh

# 仅进入容器 Shell
./build.sh --shell

# 清理编译环境
./build.sh --clean
```

编译完成后，固件输出在 `output/` 目录。