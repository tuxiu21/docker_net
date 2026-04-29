# docker_net

把一个 OpenVPN `.ovpn` 配置丢进容器,对外暴露一个 SOCKS5 端口,任何外部工具用 `socks5://host:1080` 就能走 VPN 网络。

## 结构

- `Dockerfile` — 基于 `alpine`,装 `openvpn` + `curl`。
- `entrypoint.sh` — 启动时根据环境变量生成 auth 文件,改写 ovpn 让其指向该 auth 文件,然后启动 openvpn。
- `up.sh` — OpenVPN 隧道建立后的钩子脚本,把服务端 push 的 DNS 写入 `/etc/resolv.conf`,确保 DNS 也走 VPN。
- `docker-compose.yml` — 两个服务:
  - `vpn`:跑 openvpn 客户端,负责拨号 + 暴露 1080 端口。
  - `socks5`:`serjs/go-socks5-proxy`,通过 `network_mode: service:vpn` 共享 vpn 容器的网络命名空间。

## 使用

1. 把你的 `.ovpn` 放到项目根目录,确认 compose 里 `volumes` 行映射到正确的文件名(默认 `1757298463444.ovpn`,改成你自己的)。
2. 复制环境变量模板:
   ```bash
   cp .env.sample .env
   # 编辑 .env 填入真实 VPN 用户名/密码;无需密码的 ovpn 留空也行
   ```
3. 启动:
   ```bash
   docker compose up -d --build
   ```
4. 测试:
   ```bash
   curl --socks5-hostname 127.0.0.1:1080 https://ifconfig.me
   ```
   返回的 IP 就是 VPN 出口 IP。

## 通用性

- compose 文件本身不含任何 VPN 服务器特定信息(网段、DNS、ciphers)。
- 兼容老 SoftEther 等只支持 `AES-128-CBC` 的服务器(`--data-ciphers` 已带 fallback)。
- 支持需要账号密码的 ovpn 和纯证书认证的 ovpn:`auth-user-pass` 行存在则替换为指向 auth 文件,不存在 sed 就 no-op。

## 注意

- `.env` 和 `*.ovpn` 已加入 `.gitignore`,不会被提交。
- SOCKS5 默认无认证(`REQUIRE_AUTH=false`),若部署到公网请改成带认证或防火墙限制源 IP。
- 客户端使用代理时建议用 `--socks5-hostname`(域名解析交给代理端),不要用 `--socks5`,以避免本地 DNS 误解析到 VPN 内网假地址。
