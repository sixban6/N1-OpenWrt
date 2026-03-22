# 项目简介
本固件适配斐讯 N1 旁路由模式，追求轻量，不具备 PPPoE、WiFi 相关功能。
固件仅包含默认皮肤以及下列 luci-app
- luci-app-podman: 管理Docker用的
- luci-app-samba4: 存储共享

## 和原项目的区别
- 加入针对Proxy的内核模块
- 添加了ca_bundle
- 改为稳定版本的24.10


