<p align="center">
  <img src="Screenshots/logo.svg" alt="PicoClaw LuCI" width="120">
</p>

<h1 align="center">luci-app-picoclaw</h1>

<p align="center">
  <b>Turn your router into an AI assistant — manage <a href="https://github.com/sipeed/picoclaw">PicoClaw</a> from your browser</b><br>
  <sub>Service · Channels · Models · Scheduled tasks · MCP · Skills · Hardware</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-24.10%20%7C%2025.xx%20%7C%20iStoreOS-blue?logo=openwrt" alt="OpenWrt">
  <img src="https://img.shields.io/badge/Version-1.2.1-brightgreen" alt="Version">
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

**[PicoClaw](https://github.com/sipeed/picoclaw)** is an AI assistant that runs **on your router** — it connects to large language models (DeepSeek, GLM, Qwen, OpenAI…) and chats with you over Feishu, Telegram, Discord, WeChat and more.

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
- **Packaging**: `istore/luci-app-picoclaw` is the sole LuCI package source; obsolete `luci/` and `istore/luasrc/` copies were removed and installer paths updated. Core and optional launcher packages, SDK builds and standalone APKv3 builds are provided.

The form schema and packaged core have separate version pins: `picoclaw/Makefile` builds **PicoClaw 0.3.1-r2**. The standalone frontend is **1.2.1-r1**; the SDK LuCI package is **1.2.1-r1**.

## ✨ Features

Nine tabs on a single page:

| Tab | What you can do |
|---|---|
| **Channels** | See and toggle Feishu / Telegram / Discord / WeChat … connection status |
| **Chat** | Talk to your assistant without leaving the router's web UI |
| **Config Editor** | Guided form for `config.json`, plus a raw JSON mode for advanced tweaks |
| **Logs** | Live PicoClaw output — errors, LLM calls, token usage |
| **Hardware** | System info, USB devices, GPIO toggles |
| **Scheduled Tasks** | Cron / interval jobs — create, enable, disable, delete |
| **MCP Servers** | Add or remove MCP servers (stdio / http / sse) |
| **Skills** | Browse, install, import and delete agent skills |
| **Models & Auth** | Model list, default model, enable/disable, API key status, thinking level |

Plus one-click service start / stop / restart, boot-on-start, search engine presets, and a JSON editor.

## 📋 Requirements

| | Details |
|---|---|
| **Router OS** | OpenWrt 21.02+ or iStoreOS (with LuCI interface) |
| **PicoClaw binary** | Standalone APK requires a separate binary; SDK packages include a core dependency |
| **Architecture** | Any (pure Lua, works on all architectures) |

## 🚀 Installation

### GitHub Actions APK builds

Run `.github/workflows/release-openwrt.yml` manually to build and publish packages. Packages are also available from the run's **Artifacts** (retained for 14 days).

For a release, use **Actions → Release OpenWrt packages → Run workflow**, select a branch, enter a tag and choose whether it is a prerelease. The workflow uses OpenWrt 25.12.5 SDKs for `x86_64`, `aarch64_cortex-a53`, `aarch64_cortex-a72`, `aarch64_generic`, `arm_cortex-a7` and `arm_cortex-a9`. Each build produces:

- `picoclaw`: core 0.3.1 binary and procd init script, without a launcher.
- `picoclaw-launcher`: optional web console with its frontend embedded, depending on `picoclaw`.
- `luci-app-picoclaw`: LuCI frontend and three preset skills, depending on the core package.
- `luci-i18n-picoclaw-zh-cn`: Simplified Chinese translations.

Files include SDK and architecture suffixes and SHA256 checksums. Install the three packages matching your firmware together with `apk add --allow-untrusted`.

Install the launcher APK separately if needed. On a router, run `picoclaw-launcher -console -no-browser -public` and open `http://<router-ip>:18800`. The launcher manages the gateway; stop `/etc/init.d/picoclaw` before starting a gateway from the launcher.

`picoclaw version` displays the version, Git commit, build time and Go version. The SDK embeds the same metadata fields as upstream GoReleaser, using `SOURCE_DATE_EPOCH` for a reproducible build timestamp. Building the launcher also requires `node/host`; the recipe downloads pnpm 10.33.0 with SHA256 verification and builds the frontend before compiling the Go backend.

### Standalone frontend APK

Use apk-tools 3.x with the `mkpkg` applet:

```sh
APK="$HOME/.local/bin/apk.static" ./scripts/build-apk-25xx.sh
```

The default output is `release/luci-app-picoclaw-1.2.1-r1.apk`. Override `PKG_VERSION` or pass an output directory as needed. This package contains the controller, view, init script and cache-clearing hooks. It requires a separately installed `/usr/bin/picoclaw`; it does not bundle the binary, launcher, skills or a separate translation package. The interface includes its own language strings.

Upload it to `/tmp` and install:

```sh
apk add --allow-untrusted /tmp/luci-app-picoclaw-1.2.1-r1.apk
```

Reinstall if the same r7 version is already installed. This standalone package owns `/etc/init.d/picoclaw` and conflicts with SDK core packages that own the same file.

### Firmware builds

Add this repository to `feeds.conf.default`:

```text
src-git picoclaw https://github.com/altman08/luci-app-picoclaw.git;dev
```

Update the feed, install its `luci-app-picoclaw` and `picoclaw` entries, and select the frontend and Chinese translations in `make menuconfig`. The core is selected through dependencies. Standard LuCI and packages/golang feeds are required. LuCI sources live in `istore/luci-app-picoclaw`; translations use `po/zh_Hans`.

The following steps describe the upstream iStore, IPK and APK distributions.

### Step 1: Install PicoClaw

This plugin is only the web UI. PicoClaw itself is a separate program — install it first over SSH:

```bash
cd /tmp
wget https://github.com/sipeed/picoclaw/releases/download/v0.3.1/picoclaw_Linux_x86_64.tar.gz
tar xzf picoclaw_Linux_x86_64.tar.gz
cp picoclaw /usr/bin/picoclaw && chmod +x /usr/bin/picoclaw
picoclaw version    # Should display the version number
```

> ⚠️ That link is **x86_64**. ARM routers (most Xiaomi, TP-Link) need `picoclaw_Linux_arm64.tar.gz` or `picoclaw_Linux_armv7.tar.gz` — see [PicoClaw Releases](https://github.com/sipeed/picoclaw/releases). Run `uname -m` to find out which one you have.

### Step 2 — Install this plugin

**Option A — iStore** (easiest)

Open iStore on your router → search `picoclaw` → click Install

**Option B — IPK** (OpenWrt with `opkg`)

```bash
cd /tmp
wget https://github.com/GennKann/luci-app-picoclaw/releases/latest/download/luci-app-picoclaw_1.2.1-1_all.ipk
opkg install luci-app-picoclaw_1.2.1-1_all.ipk
rm -rf /tmp/luci-*   # clear the LuCI cache
```

**Option C — APK** (OpenWrt 25.x with `apk`)

```bash
cd /tmp
wget https://github.com/GennKann/luci-app-picoclaw/releases/latest/download/luci-app-picoclaw-1.2.1-r1.apk
apk add --allow-untrusted luci-app-picoclaw-1.2.1-r1.apk
rm -rf /tmp/luci-*   # clear the LuCI cache
```

> The APK is unsigned, so `--allow-untrusted` is required.

**Building from source**

```bash
# IPK (opkg systems)
python3 scripts/build-ipk.py

# APK v3 (OpenWrt 25.x / apk systems) — run on the router itself
sh scripts/build-apk-v3.sh
```

> Windows clones: if `core.autocrlf` is enabled, Git converts LF to CRLF on checkout.
> LuCI's Lua/HTML parser only accepts LF (CRLF causes `unfinished string`), so run
> `dos2unix` on the files you deploy, or set `git config core.autocrlf false`.

### Step 3 — Open it

`http://<ROUTER_IP>/cgi-bin/luci/admin/services/picoclaw`

Then add a model and an API key — see [Model Configuration](#-model-configuration).

## 📸 Screenshots

| Channels | Models & Auth |
|:---:|:---:|
| ![Channels](Screenshots/screenshot_main.png) | ![Models](Screenshots/screenshot_models.png) |

| Skills | Scheduled Tasks |
|:---:|:---:|
| ![Skills](Screenshots/screenshot_skills.png) | ![Cron](Screenshots/screenshot_cron.png) |

## 🤖 Model Configuration

PicoClaw needs an **API key** (think of it as a password) for at least one model provider.

**Fastest way — the UI:**

1. Open the **Models & Auth** tab
2. Click **Add model** and pick a preset (DeepSeek / Zhipu GLM / Qwen / OpenAI / Anthropic / OpenRouter / Ollama) — API base and model ID are filled in for you
3. Paste your **API key**
4. Click **Set as default**, then **Save**

**Or from the terminal** (keeps the key out of `config.json`):

```bash
picoclaw model add -b https://api.deepseek.com/v1 -k sk-xxx -m deepseek-flash -n deepseek-flash
picoclaw model deepseek-flash        # set as default
```

> 🔒 Keys entered in the UI are written to PicoClaw's `.security.yml`, not into `config.json`.

**Thinking level** — every model row has a dropdown (default / low / medium / high / max / adaptive) mapped to `thinking_level`. Whether it actually changes the answer depends on the provider: DeepSeek honours low/high/max, some vendors only accept `adaptive`, and unsupported values fall back to the default.

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
| OpenWrt 25.x refuses the IPK? | 25.x uses `apk`, not `opkg` — grab the `.apk` and run `apk add --allow-untrusted` |
| Saving the config reports "unknown field(s)"? | PicoClaw 0.3.1 validates `config.json` strictly. Stick to `model_name`, `provider`, `model`, `api_base`, `api_keys`, `enabled`, `thinking_level` — `max_tokens` belongs in `agents.defaults` |

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
