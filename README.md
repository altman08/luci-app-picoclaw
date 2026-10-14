<p align="center">
  <img src="Screenshots/logo.svg" alt="PicoClaw LuCI" width="120">
</p>

<h1 align="center">luci-app-picoclaw</h1>

<p align="center">
  <b>Turn your router into an AI assistant — manage <a href="https://github.com/sipeed/picoclaw">PicoClaw</a> from your browser</b><br>
  <sub>Service management · Model config · Hardware control</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-24.10%20%7C%2025.xx%20%7C%20iStoreOS-blue?logo=openwrt" alt="OpenWrt">
  <img src="https://img.shields.io/badge/Version-1.1.6-brightgreen" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</p>

<p align="center">
  English ·
  <a href="README.zh.md">简体中文</a> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.de.md">Deutsch</a> ·
  <a href="README.pt.md">Português</a>
</p>

---

## What is this?

**[PicoClaw](https://github.com/sipeed/picoclaw)** is an AI assistant that runs on your router. It connects to large language models (like ChatGPT, DeepSeek, GLM, etc.) and lets you chat via Feishu, Telegram, Discord, WeChat, and more.

This plugin manages the core CLI and gateway through LuCI, without requiring `picoclaw-launcher`.

**This project adds a web management interface** (a LuCI plugin) for PicoClaw, so you can do everything in your browser: start/stop the service, switch AI models, configure API keys, manage search engines, and more — no command line needed.

> **LuCI** is the web interface framework used by OpenWrt routers. When you open your router's admin page (e.g. 192.168.1.1), that's LuCI.

## Changes on dev

Compared with `master` (`ae324cf`, v1.1.6), `dev` includes:

- **Configuration compatibility**: forms checked against PicoClaw config version 3 at `bbf6893c`; model credentials belong to `model_list[].api_keys`. Multiple keys, duplicate model aliases and advanced model JSON are preserved. The legacy providers section and in-page model guide have been removed.
- **Channels and tools**: named channel instances use their `type`; gateway fields, heartbeat minutes, media cleanup, session scope and search credentials follow the current schema. Skills and memory operations respect the configured workspace.
- **Saving**: untouched fields, credential placeholders and advanced parameters are preserved; numbers, booleans, arrays and JSON retain their types. Selecting a model no longer overwrites its token limit. See the [configuration compatibility notes (Chinese)](docs/config-compatibility.zh.md).
- **Chat**: terminal colors, banners and startup output are filtered. Web chat uses an isolated session; clearing removes its displayed history and temporary results, rotates the session and rejects late replies. Archived core sessions remain on disk.
- **Services**: rc.common/procd manages stopping, fixing the respawn race caused by killing the process directly. Boot autostart uses `enable` / `disable`, without editing PicoClaw JSON; disabling autostart does not stop a running service.
- **UI**: up to 1200px of content width and 480px text inputs, narrow-screen layouts, dark theme support and native checkboxes. The top icon, title and subtitle have been removed.
- **Packaging**: `istore/luci-app-picoclaw` is the sole LuCI package source; obsolete `luci/` and `istore/luasrc/` copies were removed and installer paths updated. Core packaging, three-package SDK builds and standalone APKv3 builds are provided.

The form schema and packaged core have separate version pins: `picoclaw/Makefile` still builds **PicoClaw 0.3.1**. The standalone frontend is **1.1.6-r7**; the SDK LuCI package is **1.1.6-r1**.

## 📸 Screenshots

| Dashboard | Config Editor |
|:---:|:---:|
| ![Dashboard](Screenshots/screenshot_main.png) | ![Config](Screenshots/screenshot_config.png) |

| Hardware Control | Mobile View |
|:---:|:---:|
| ![Hardware](Screenshots/screenshot_hardware.png) | ![Mobile](Screenshots/screenshot_mobile.png) |

## ✨ Features

- **Service Control** — One-click start / stop / restart PicoClaw, set boot-on-start, view real-time logs
- **Channel Management** — View connection status for Feishu, Telegram, Discord, WeChat, etc.
- **Model Config** — Visual form editor for AI models, with built-in provider presets (Zhipu, DeepSeek, Qwen, OpenAI, etc.) — just fill in your API key
- **Search Engine Config** — Let the AI search the web for answers. Supports GLM Search, Baidu, DuckDuckGo, etc. (with China availability hints)
- **Hardware Control** — View system info, USB devices, toggle GPIO pins
- **Skill Management** — View, delete, import PicoClaw skills; 3 built-in presets (diagnostics, backup, app installer)
- **JSON Editor** — Direct config file editing for advanced users

## 📋 Requirements

| | Details |
|---|---|
| **Router OS** | OpenWrt 21.02+ or iStoreOS (with LuCI interface) |
| **PicoClaw binary** | Standalone APK requires a separate binary; SDK packages include a core dependency |
| **Architecture** | Any (pure Lua, works on all architectures) |

## 🚀 Installation

### GitHub Actions APK builds

Pushing to **dev** triggers `.github/workflows/release-openwrt.yml`. Download packages from the run's **Artifacts** (retained for 14 days). Push builds do not publish a Release.

For a release, use **Actions → Release OpenWrt packages → Run workflow**, select a branch, enter a tag and choose whether it is a prerelease. The workflow uses OpenWrt 25.12.5 SDKs for `x86_64`, `aarch64_cortex-a53`, `aarch64_cortex-a72`, `aarch64_generic`, `arm_cortex-a7` and `arm_cortex-a9`. Each build produces:

- `picoclaw`: core 0.3.1 binary and procd init script, without a launcher.
- `luci-app-picoclaw`: LuCI frontend and three preset skills, depending on the core package.
- `luci-i18n-picoclaw-zh-cn`: Simplified Chinese translations.

Files include SDK and architecture suffixes and SHA256 checksums. Install the three packages matching your firmware together with `apk add --allow-untrusted`.

### Standalone frontend APK

Use apk-tools 3.x with the `mkpkg` applet:

```sh
APK="$HOME/.local/bin/apk.static" ./scripts/build-apk-25xx.sh
```

The default output is `release/luci-app-picoclaw-1.1.6-r7.apk`. Override `PKG_VERSION` or pass an output directory as needed. This package contains the controller, view, init script and cache-clearing hooks. It requires a separately installed `/usr/bin/picoclaw`; it does not bundle the binary, launcher, skills or a separate translation package. The interface includes its own language strings.

Upload it to `/tmp` and install:

```sh
apk add --allow-untrusted /tmp/luci-app-picoclaw-1.1.6-r7.apk
```

Reinstall if the same r7 version is already installed. This standalone package owns `/etc/init.d/picoclaw` and conflicts with SDK core packages that own the same file.

### Firmware builds

Add this repository to `feeds.conf.default`:

```text
src-git picoclaw https://github.com/altman08/luci-app-picoclaw.git;dev
```

Update the feed, install its `luci-app-picoclaw` and `picoclaw` entries, and select the frontend and Chinese translations in `make menuconfig`. The core is selected through dependencies. Standard LuCI and packages/golang feeds are required. LuCI sources live in `istore/luci-app-picoclaw`; translations use `po/zh_Hans`.

The following legacy IPK/iStore instructions apply to older opkg systems, rather than the standalone APK above.

### Step 1: Install PicoClaw

PicoClaw is the core AI assistant program — you need to install it first. SSH into your router and run:

```bash
cd /tmp
wget https://github.com/sipeed/picoclaw/releases/download/v0.2.7/picoclaw_Linux_x86_64.tar.gz
tar xzf picoclaw_Linux_x86_64.tar.gz
cp picoclaw /usr/bin/picoclaw && chmod +x /usr/bin/picoclaw
picoclaw --version   # Should display the version number
```

> ⚠️ The link above is for x86_64. If your router uses ARM (most Xiaomi, TP-Link routers), download the correct binary from [PicoClaw Releases](https://github.com/sipeed/picoclaw/releases).

### Step 2: Install LuCI Interface

**Option A: iStore** (recommended, easiest)

Open iStore on your router → search `picoclaw` → click Install

**Option B: Install IPK via command line**

```bash
cd /tmp
wget https://github.com/GennKann/luci-app-picoclaw/releases/latest/download/luci-app-picoclaw_1.1.6-1_all.ipk
opkg install luci-app-picoclaw_1.1.6-1_all.ipk
rm -rf /tmp/luci-*   # Clear LuCI cache
```

After installation, open your browser and visit: `http://<ROUTER_IP>/cgi-bin/luci/admin/services/picoclaw`

## 🤖 Model Configuration

PicoClaw needs to connect to a large language model to work. Think of it as a "client" — it doesn't include AI itself, but calls AI services via their APIs. You need to provide an **API Key** (like a password) so PicoClaw can access the service.

**How to configure:**

1. Go to **Config Editor** tab → find the **Model List** section
2. Click a provider preset button (e.g. "Zhipu GLM", "DeepSeek") — it will auto-fill the API base URL
3. Enter your **API Key** (obtained by registering on the provider's website)
4. Select a **Default Model** from the dropdown
5. Click **Save**

**Supported providers:** Zhipu · DeepSeek · Qwen · OpenAI · Anthropic · OpenRouter · Ollama

> 💡 **Don't have an API Key?** Most providers offer free credits to try:
> - [Zhipu (智谱)](https://open.bigmodel.cn/) — China-based, free credits on signup
> - [DeepSeek](https://platform.deepseek.com/) — China-based, free credits on signup
> - [OpenRouter](https://openrouter.ai/) — Aggregates multiple models

Enter model credentials in the model list, multiple keys separated by commas. Untouched `[NOT_HERE]` placeholders reference credentials managed by PicoClaw in `.security.yml`. LuCI writes configuration directly to `config.json`; it does not move newly entered plaintext credentials into `.security.yml`.

## 🔍 Search Engine

PicoClaw can search the web to answer questions. For users in China, we recommend GLM Search or Baidu:

| Engine | China | Notes |
|---|:---:|---|
| GLM Search | ✅ | Recommended, works in China |
| Baidu | ✅ | Alternative |
| DuckDuckGo / Brave / Tavily / Perplexity | ❌ | Blocked by GFW, works overseas |
| SearXNG | ⚠️ | Self-hosted, depends on where it's deployed |

## ❓ FAQ

| Question | Answer |
|---|---|
| Page doesn't load after install? | Install the PicoClaw binary first (Step 1) — this plugin is just the web UI |
| AI says "no permission to access internet"? | Search engine is blocked — switch to GLM Search or Baidu |
| Can't find in iStore? | Run `opkg update` to refresh, or download the IPK from Releases |
| API key field shows `[NOT_HERE]`? | That's normal — real keys are in `.security.yml`, managed via the LuCI UI |
| What is an API Key? | It's like a password for calling AI services. Register on the provider's site to get one — most offer free credits |
| How to check router architecture? | SSH in and run `uname -m`. Common values: x86_64, aarch64, mipsel |

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## 📜 License

This project is licensed under the **MIT License** — free to use, modify, and distribute, but please retain the author attribution.

Issues and Pull Requests are welcome! 💡

---

Support
-------

If you like this project, you can star this repository or buy me a coffee. :)

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/gennkann)

<details>
<summary>🇨🇳 微信赞赏 (WeChat Pay)</summary>
<img src="Images/wechat_pay.jpg" width="200" alt="WeChat Pay" />
</details>
