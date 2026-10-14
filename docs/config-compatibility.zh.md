# PicoClaw 配置兼容性

2026-10-14 对照本地 PicoClaw `bbf6893c` 的 `pkg/config` 核对，当前配置版本为 3。

| 旧插件行为 | 当前配置 / 修正 |
| --- | --- |
| `listen` | `gateway.host` 和 `gateway.port`，兼容旧的 IPv4/IPv6 地址 |
| 顶层 `steering_mode`，值 `parallel` | `agents.defaults.steering_mode`，值 `one-at-a-time` / `all`；并行轮数由 `max_parallel_turns` 控制 |
| 顶层 `media_cleanup` | `tools.media_cleanup`，保留时间和清理间隔以分钟计 |
| 心跳间隔标成秒 | `heartbeat.interval` 的单位是分钟 |
| `providers.*.api_key/base_url` | 凭据和地址属于 `model_list` 条目；不再生成旧 providers 表单 |
| 通道名固定等于类型 | 按 `channel_list` 的实例名读取，以 `type` 选择设置字段，支持多个同类型实例 |
| 旧 `channels` 扁平字段 | `channel_list.<实例名>.settings`；共同字段留在实例顶层 |
| 模型只显示第一把 Key，保存重建条目 | 多 Key 每行一个；逐行保留原条目，同名模型、占位符和高级参数不会因普通保存丢失 |
| 搜索密钥全部用同一种格式 | Brave/Tavily/Kagi/Perplexity 使用 `api_keys`；Gemini/GLM/百度使用 `api_key` |
| 表单保存补入空字段、将数字转成字符串 | 只提交有变化的字段，整数、浮点数、布尔值、数组和 JSON 保持正确类型 |
| 切换模型时自动替换 Token 上限 | 保留用户配置的 Token 上限，不用静态模型推荐值覆盖 |
| `dm_scope` 被已有 `dimensions` 覆盖 | 展示实际作用域，选择新作用域时同步调整维度；支持 `per-peer` |
| 工具和技能目录固定在默认 workspace | 跟随 `agents.defaults.workspace`，支持 `~/` 展开 |

模型表格的高级 JSON 可以设置 `auth_method`、`fallbacks`、`streaming`、
`request_timeout`、`thinking_level`、`extra_body`、`custom_headers` 等参数。
未展示的配置（多代理、路由规则、MCP servers、hooks 等）原样保留，可在 JSON 模式编辑。

`[NOT_HERE]` 是 PicoClaw 的密钥占位符；原始凭据仍由同目录的 `.security.yml`
管理。未编辑的占位符不会转换成数组或写成实际 API Key。

LuCI 源码统一保留在 `istore/luci-app-picoclaw/luasrc/`，SDK 流水线和本地 APK 打包脚本均使用此目录。
