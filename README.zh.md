<p align="center">
  <img src="Screenshots/logo.svg" alt="PicoClaw LuCI" width="120">
</p>

<h1 align="center">luci-app-picoclaw</h1>

<p align="center">
  <b>让你的路由器变成 AI 助手 — 在浏览器里管理 PicoClaw</b><br>
  <sub>服务管理 · 模型配置 · 硬件控制</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-24.10%20%7C%2025.xx%20%7C%20iStoreOS-blue?logo=openwrt" alt="OpenWrt">
  <img src="https://img.shields.io/badge/Version-1.1.6-brightgreen" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</p>

<p align="center">
  <a href="README.md">English</a> ·
  简体中文 ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.de.md">Deutsch</a> ·
  <a href="README.pt.md">Português</a>
</p>

---

## 这是什么？

**[PicoClaw](https://github.com/sipeed/picoclaw)** 是一个运行在路由器上的 AI 助手程序，它可以让你的路由器接入大语言模型（如智谱 GLM、DeepSeek、ChatGPT 等），并通过飞书、Telegram、Discord、微信等通道与你对话。

本插件直接管理 PicoClaw 核心 CLI 和 gateway，提供适用于 OpenWrt 的 LuCI 配置界面，不依赖 `picoclaw-launcher`。

**本项目就是给 PicoClaw 加一个网页管理界面**（LuCI 插件），让你在浏览器里就能完成所有操作——启动服务、切换模型、配置 API Key、管理搜索引擎等，不需要敲命令行。

> **LuCI** 是 OpenWrt 路由器的 Web 管理界面框架，你平时进路由器后台（如 192.168.1.1）看到的就是 LuCI。

## dev 分支更新

相对 `master`（`ae324cf`，v1.1.6），`dev` 已完成以下修改：

- **配置兼容**：按 PicoClaw `bbf6893c` 的配置版本 3 核对表单。模型密钥统一在 `model_list[].api_keys` 配置，支持多 Key、同名模型和高级 JSON；删除旧提供商密钥区及页面内的 AI 模型配置指南。
- **通道与工具**：支持按 `type` 配置具名通道实例；修正网关、心跳分钟单位、媒体清理、会话作用域和搜索引擎密钥格式。技能和记忆操作跟随自定义工作目录。
- **保存行为**：保留未编辑字段、密钥占位符和高级模型参数，正确保存数字、布尔值、数组与 JSON，不再自动覆盖模型 Token 上限。详细字段变化见 [配置兼容性说明](docs/config-compatibility.zh.md)。
- **网页对话**：过滤终端 ANSI 色码、ASCII 横幅及启动输出；使用独立会话。清空对话会删除网页历史和临时任务结果，并更换会话，避免旧回复重新出现；核心保存的历史会话归档仍保留。
- **服务管理**：通过 rc.common/procd 停止服务，修复直接杀进程后被 respawn 拉起的问题。开机自启通过 `enable` / `disable` 管理，不修改 PicoClaw JSON 配置；关闭自启不会停止当前服务。
- **界面**：内容区最大宽度由 960px 调整为 1200px，文字输入框最多 480px，适配窄屏和深色主题；滑块统一改为复选框，移除顶部图标、标题及副标题。
- **源码与打包**：只保留 `istore/luci-app-picoclaw` 作为 LuCI 包源码，删除 `luci/` 和 `istore/luasrc/` 历史副本，并修正安装脚本引用。新增核心包、SDK 三包流水线和真正的 APKv3 本地打包。

配置表单对照的新源码版本与 SDK 核心包版本不同：`picoclaw/Makefile` 当前仍固定为 **PicoClaw 0.3.1**。本地独立前端包版本为 **1.1.6-r7**，SDK LuCI 包版本为 **1.1.6-r1**。

## 📸 截图

| 仪表盘 | 配置编辑 |
|:---:|:---:|
| ![主界面](Screenshots/screenshot_main.png) | ![配置](Screenshots/screenshot_config.png) |

| 硬件控制 | 移动端 |
|:---:|:---:|
| ![硬件](Screenshots/screenshot_hardware.png) | ![手机](Screenshots/screenshot_mobile.png) |

## ✨ 功能

- **服务控制** — 一键启动 / 停止 / 重启 PicoClaw，设置开机自启，查看实时运行日志
- **通道管理** — 查看飞书、Telegram、Discord、微信等通道的连接状态
- **模型配置** — 可视化表单配置 AI 模型，内置供应商预设（智谱、DeepSeek、通义、OpenAI 等），填入 API Key 即可使用
- **搜索引擎配置** — 让 AI 能联网搜索信息，支持智谱搜索、百度、DuckDuckGo 等（含国内可用性提示）
- **硬件控制** — 查看路由器系统信息、USB 设备，控制 GPIO 开关
- **技能管理** — 查看、删除、导入 PicoClaw 技能；内置 3 个预设（系统诊断、配置备份、智能安装）
- **JSON 编辑器** — 直接编辑底层配置文件，适合高级用户

## 📋 系统要求

| | 说明 |
|---|---|
| **路由器系统** | OpenWrt 21.02+ 或 iStoreOS（需有 LuCI 界面） |
| **PicoClaw 主程序** | 独立前端 APK 需另装核心；SDK 三包安装会带入核心包 |
| **路由器架构** | 不限（纯 Lua，所有架构通用） |

## 🚀 安装

### GitHub Actions 编译 APK

仓库提供 `.github/workflows/release-openwrt.yml`。推送到 **dev** 分支会自动编译，
生成的包在该次 Actions 运行的 **Artifacts** 下载，保留 14 天。自动构建不发布 Release。

需要发布时，在 GitHub **Actions → Release OpenWrt packages → Run workflow**
选择分支并填写发布标签，
例如 `v1.1.6-apk.1`，并选择是否标记为预发布。

流水线使用 OpenWrt 25.12.5 SDK，分别编译 `x86_64`、`aarch64_cortex-a53`、
`aarch64_cortex-a72`、`aarch64_generic`、`arm_cortex-a7` 和 `arm_cortex-a9`。
每种架构上传以下三个 APK 和 SHA256 校验文件到 Actions artifacts；手动触发时，全部成功后发布到 GitHub Release：

- `picoclaw`：PicoClaw 0.3.1 核心及 procd 服务，不包含 launcher。
- `luci-app-picoclaw`：LuCI 管理界面及三个 OpenWrt 预设技能，依赖 `picoclaw`。
- `luci-i18n-picoclaw-zh-cn`：LuCI 简体中文语言包。

发布文件名附带 SDK 版本和架构，避免不同构建相互覆盖。安装时选择与你的固件匹配的架构，
下载同一组的三个 APK，然后在路由器上执行：

```sh
apk add --allow-untrusted ./picoclaw-*.apk ./luci-app-picoclaw-*.apk ./luci-i18n-picoclaw-zh-cn-*.apk
```

PicoClaw 源码版本与 SHA256 固定在 `picoclaw/Makefile`；升级时必须同时更新版本和校验值。
LuCI 源码包位于 `istore/luci-app-picoclaw`，中文翻译位于其 `po/zh_Hans` 目录。
将本仓库加入 `feeds.conf.default` 后，也可选择 `luci-app-picoclaw` 随固件构建，依赖会带入核心包。

### 本地打包独立前端 APK

需要支持 `mkpkg` 的 apk-tools 3.x。运行：

```sh
APK="$HOME/.local/bin/apk.static" ./scripts/build-apk-25xx.sh
```

默认生成 `release/luci-app-picoclaw-1.1.6-r7.apk`。可通过 `PKG_VERSION` 覆盖版本号，
或传入输出目录。该包包含 LuCI controller、view、启动脚本和缓存清理钩子，
不包含核心二进制、launcher、技能文件或独立中文翻译包；界面内置中文及其他语言。
需要自行提供 `/usr/bin/picoclaw`。

```sh
apk add --allow-untrusted /tmp/luci-app-picoclaw-1.1.6-r7.apk
```

若路由器已经安装同版本 r7，需要重新安装才能应用重打包后的改动。
独立前端包自带 `/etc/init.d/picoclaw`，不能与同样拥有该文件的 SDK 核心包混装。
SDK 三包适合成套安装，独立前端包适合已有手动安装核心二进制的设备。

### 编译到固件

在 OpenWrt 源码的 `feeds.conf.default` 中添加：

```text
src-git picoclaw https://github.com/altman08/luci-app-picoclaw.git;dev
```

更新并安装 feed 后，选择 `luci-app-picoclaw` 和中文语言包，`picoclaw` 核心由依赖带入：

```sh
./scripts/feeds update picoclaw
./scripts/feeds install -p picoclaw luci-app-picoclaw picoclaw
make menuconfig
```

构建环境还需提供标准 LuCI 和 packages/golang feed；实际核心架构支持由 golang feed 决定。

以下是原版 IPK/iStore 安装方式，适用于使用 opkg 的旧版系统，不适用于上述独立 APK。

### 第一步：安装 PicoClaw 主程序

PicoClaw 是 AI 助手的核心程序，需要先装好它。通过 SSH 登录路由器，执行：

```bash
cd /tmp
wget https://github.com/sipeed/picoclaw/releases/download/v0.2.7/picoclaw_Linux_x86_64.tar.gz
tar xzf picoclaw_Linux_x86_64.tar.gz
cp picoclaw /usr/bin/picoclaw && chmod +x /usr/bin/picoclaw
picoclaw --version   # 确认安装成功，应显示版本号
```

> ⚠️ 上面是 x86_64 架构的下载链接。如果你的路由器是 ARM 架构（如大多数小米、TP-Link 路由器），请到 [PicoClaw Releases](https://github.com/sipeed/picoclaw/releases) 下载对应架构的版本。

### 第二步：安装 LuCI 管理界面

**方式一：iStore 商店**（推荐，最简单）

在路由器后台打开 iStore → 搜索 `picoclaw` → 点击安装

**方式二：命令行安装 IPK**

```bash
cd /tmp
wget https://github.com/GennKann/luci-app-picoclaw/releases/latest/download/luci-app-picoclaw_1.1.6-1_all.ipk
opkg install luci-app-picoclaw_1.1.6-1_all.ipk
rm -rf /tmp/luci-*   # 清除 LuCI 缓存
```

安装完成后，打开浏览器访问：`http://<路由器IP>/cgi-bin/luci/admin/services/picoclaw`

## 🤖 模型配置

PicoClaw 需要接入大语言模型才能工作。你可以把它理解为一个"客户端"——它本身不包含 AI，而是调用各家 AI 服务的接口。你需要提供 **API Key**（类似密码），让 PicoClaw 有权调用对应的服务。

**配置步骤：**

1. 在**配置编辑**标签页 → 找到**模型列表**区域
2. 点击供应商预设按钮（如"智谱 GLM"、"DeepSeek"），会自动填入 API 地址
3. 填入你的 **API Key**（在各 AI 供应商官网注册后获取）
4. 从下拉菜单选择**默认模型**
5. 点击**保存**

**支持供应商：** 智谱 · DeepSeek · 通义千问 · OpenAI · Anthropic · OpenRouter · Ollama

> 💡 **没有 API Key？** 大部分供应商都提供免费额度，注册即可试用：
> - [智谱开放平台](https://open.bigmodel.cn/) — 国内，注册送免费额度
> - [DeepSeek](https://platform.deepseek.com/) — 国内，注册送免费额度
> - [OpenRouter](https://openrouter.ai/) — 海外，聚合多家模型

模型 Key 在模型列表中填写，多把 Key 每行一个。`[NOT_HERE]` 表示由 PicoClaw 的 `.security.yml` 管理的密钥，未编辑时原样保留。LuCI 保存时直接写入 `config.json`，不负责把新填的明文密钥迁移到 `.security.yml`。

## 🔍 搜索引擎

PicoClaw 可以联网搜索信息来回答问题。国内用户建议选择智谱搜索或百度：

| 引擎 | 国内可用 | 说明 |
|---|:---:|---|
| 智谱搜索 | ✅ | 推荐，国内直连 |
| 百度 | ✅ | 备选 |
| DuckDuckGo / Brave / Tavily / Perplexity | ❌ | 被 GFW 屏蔽，海外可用 |
| SearXNG | ⚠️ | 需自己搭建，取决于部署位置 |

## ❓ 常见问题

| 问题 | 解答 |
|---|---|
| 安装后页面打不开？ | 需要先安装 PicoClaw 主程序（见第一步），本插件只是管理界面 |
| AI 回复"没有权限访问网络"？ | 搜索引擎被墙了，切换为智谱搜索或百度 |
| iStore 里搜不到？ | 运行 `opkg update` 刷新软件源，或直接下载 IPK 安装 |
| API Key 那栏显示 `[NOT_HERE]`？ | 这是正常的，真实密钥存在 `.security.yml` 里，通过 LuCI 界面管理即可 |
| 不清楚什么是 API Key？ | 简单说就是你调用 AI 服务的密码，去对应供应商官网注册获取，大部分有免费额度 |
| 路由器架构怎么看？ | SSH 登录后执行 `uname -m`，常见有 x86_64、aarch64、mipsel |

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)。

## 📜 开源协议

本项目遵循 **MIT License**，可自由使用、修改与分发，但请保留作者署名。

欢迎提交 Issue / Pull Request 一起完善项目 💡

---

Support
-------

如果你喜欢这个项目，可以给仓库点个 Star，或者请我喝一杯咖啡 :)

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/gennkann)

<details>
<summary>🇨🇳 微信赞赏</summary>
<img src="Images/wechat_pay.jpg" width="200" alt="微信收款码" />
</details>
