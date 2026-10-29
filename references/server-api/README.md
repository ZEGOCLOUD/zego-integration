# 服务端 API 集成（统一签名机制）

所有 ZEGO 产品（RTC/ZIM/AI Agent…）的服务端 API 共用同一签名机制与请求结构。

本目录文件：

- `signature-mechanism.md` — 签名算法详解与签名错误码
- `server-api-structure.md` — 请求/响应完整格式

配套资产（相对本 skill 根目录）：`examples/signature/`（Go/Java/Python/Node/PHP/C# 签名实现）。

## 核心概念

```
Signature = md5(AppId + SignatureNonce + ServerSecret + Timestamp)
```

- `AppId`/`ServerSecret` 从 [ZEGO 控制台](https://console.zego.im/)（海外 [console.zegocloud.com](https://console.zegocloud.com)）获取。
- `SignatureNonce`：16 位十六进制随机串（如 `secrets.token_hex(8)`）。
- `Timestamp`：秒级 Unix 时间戳（容差 10 分钟）。
- 签名 10 分钟有效，**每次请求重新生成**，签名与请求里的 Nonce/Timestamp 必须一致。
- `ServerSecret` 严禁进客户端、严禁提交版本控制。

## 工作流

1. **确认要调的 API**：在文档仓库对应产品的 `server/api-reference/` 下找同名 `.yaml`（优先）或 `.mdx`，确认 Action、参数、错误码。例如 RTC 的服务端文档在 `core_products/real-time-voice-video/zh/server/api-reference/`。
2. **实现签名**：从 `examples/signature/` 拷对应语言实现。
3. **组装请求**：公共参数 `AppId`、`SignatureNonce`、`Timestamp`、`Signature`、`SignatureVersion=2.0`、`Action`，加上 API 专属业务参数。
4. **解析响应**：统一结构 `{"Code": 0, "Message": "Succeed", "RequestId": "...", "Data": {...}}`。

## 常见 API 域名

| 产品 | API Host |
|---|---|
| RTC | `rtc-api.zego.im` |
| ZIM | `zim-api.zego.im` |
| AI Agent | `aigc-aiagent-api.zegotech.*`（以文档仓库 `core_products/aiagent/zh/server/` 的 yaml 为准） |

各产品的域名与接口清单以本地文档仓库的 yaml 为权威来源，不要凭记忆写。

## 快速参考

- 错误码：`0` 成功；`100000004` 签名过期（换新时间戳重生成）；`100000005` 签名无效（检查算法与参数拼接）。
- ID 规则：UserId ≤32 字节 `[a-zA-Z0-9-_]`；RoomId/StreamId ≤128 字节同字符集；AgentId ≤128 字节放宽字符集。
