# EaglerSPRelay 增强版

Eaglercraft 单人游戏"对局域网开放"的 WebRTC 信令中继。中继只负责牵线配对，
不传输任何游戏数据。

基于 lax1dude 的 EaglerSPRelay 源码（源码内版本号 0.1a）修改。

## 原作者关于非商业分发的声明

lax1dude 及 DarverDevs 组织在多个公开渠道表示，Eaglercraft 相关项目在
**非商业环境下**可以自由使用和分发。以下为可直接访问的声明来源与原文内容。

### 来源一：DarverDevs 组织 GitHub 主页

- **URL**: https://raw.githubusercontent.com/darverdevs/.github/main/profile/README.md
- **原文**:
  > All the plugins/projects on our page are free to use and distribute in a
  > Non Commercial setting! Check the specified project for its license for a
  > better explaination.

DarverDevs 的成员名单中包含 LAX1DUDE 本人，该声明由其所在组织发布。

### 来源二：Creative Commons 许可文件

- **URL**: https://gitlab.com/BIGJ42/eaglercraft-laxidude-official/-/blob/main/LICENSE
- **原文**:
  > This work is licensed under a Creative Commons Attribution-NonCommercial
  > 4.0 International License
  > http://creativecommons.org/licenses/by-nc/4.0/

该许可证明确采用 CC BY-NC 4.0 协议，"NC"即 NonCommercial（非商业性使用）。

### 关于官方 LICENSE 文件中的限制条款

Eaglercraft 各版本源码附带的 LICENSE 文件包含
`All Rights Reserved` 及 `NOT FOR COMMERCIAL OR MALICIOUS USE` 等条款，
对分发行为有严格限制。但 DarverDevs 主页声明同时指出
"Check the specified project for its license"，表明具体授权需以项目许可证为准。
鉴于官方站点已关闭、原始许可证文件中的部分分发限制条款与组织公开声明
存在冲突，本改版在**严格非商业**前提下进行分发。

### 本改版的分发原则

本改版严格遵守上述非商业条件：

- 不收取任何费用
- 不含任何形式的广告
- 不接受捐赠或赞助
- 不提供任何付费增值内容

## 相对官方原版新增的功能

### 原生 wss（TLS）

官方原版只提供明文 `ws://`。本版可在同一端口上只提供 TLS 加密连接。

证书放在本目录，支持两种格式：

- PEM：`wss-key-file` 指向 PKCS#8 私钥，`wss-cert-file` 指向证书链。
  Let's Encrypt / acme.sh 的产物可直接使用，证书链顺序会自动重排。
- 密钥库：把 `wss-key-file` 留空，`wss-cert-file` 指向 `.p12` 或 `.jks`。

相关配置：`wss-enable`、`wss-cert-file`、`wss-key-file`、`wss-key-password`

证书缺失或无效时会拒绝启动，不会静默回退到明文。

### 内置 STUN 服务器

官方原版把 STUN/TURN 清单原样转发给客户端，完全依赖 `relays.txt` 里的公共服务器
（公共免费 STUN 常有过载或不可达）。

本版内置一个 RFC 5389 STUN 服务器，通过 UDP 监听在与 WebSocket 相同的端口号上，
并排在 ICE 列表首位供客户端优先使用。

对外公布的地址自动推导，优先级为：显式配置 > 绑定的具体 IP > 客户端实际连接所用的域名。
因此绑定 `0.0.0.0` 时无需任何配置即可正确工作。

相关配置：`stun-enable`、`stun-external-address`、`stun-rfc3489-legacy`

### IP 封禁

官方原版没有封禁功能，只能依赖限流。本版新增按 IP 封禁：

- 被封 IP 在 WebSocket 握手阶段即被拒绝，并收到具体原因
- 该 IP 已建立的连接会被立即断开
- 发给它的 STUN 请求一并忽略
- 名单存于 `banlist.json`（UTF-8，可手工编辑）

控制台命令：`banip <地址> [原因]`、`unbanip <地址>`、`banlist`

### 世界列表可见范围

官方原版（以及客户端本身的机制）只能看到与自己同 IP 开放的世界，
因此处于不同网络的玩家互相看不见，即便在同一个中继上。

本版默认改为所有人可见全部开放世界，并提供开关保留原行为。

相关配置：`world-list-scope`，取值 `global`（默认）或 `local`

### 控制台命令

原来只有 `stop` 和 `reset`，本版新增：

- `list` —— 列出当前开放的世界，含加入码、房主 IP、在线玩家数、隐藏标记
- `help` —— 命令列表，跟随系统语言输出中文或英文

### 其他

- 自动生成的 `relayConfig.ini` 带完整中英双语注释，以 UTF-8 写入
- `start.bat` / `start.sh` 强制 UTF-8 输出；`start.bat` 会临时切换控制台代码页，
  并在退出时恢复
- `EaglerSPRelay.jar` 已合并依赖并设置入口类，`java -jar` 可直接运行

## 修复的问题

1. **`onError` 空指针** —— 端口被占用等服务器级错误时原版会抛 NPE，
   留下一个没有在监听的僵尸进程。现在输出明确错误并以非零状态码退出。

2. **`IPacket69Pong` 越界 off-by-one** —— 判断条件是长度大于 255 却截断到 256，
   导致注释恰好 256 字符时被整体序列化为空。

3. **限流锁定分支静默断开** —— `ratelimitPacketLocked` 定义了却从未发送，
   被锁定的用户只会看到一个没有任何说明的断开。现在会先发送原因。
