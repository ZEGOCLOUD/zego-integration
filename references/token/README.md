# 服务端 Token 生成（客户端 SDK 鉴权）

ZEGO 客户端 SDK 登录/进房需要 Token，**Token 必须在服务端用 Server Assistant SDK 生成**（ServerSecret 不能进客户端）。当前版本统一用 token04。

本目录文件：

- `sdk-urls.md` — 各语言 Server Assistant SDK 下载地址与推荐存放目录
- `api-spec.md` — Token 端点的接口规范

配套资产（相对本 skill 根目录）：

- `examples/token/` — Go/Java/Python/Node/PHP/C# 的端点实现示例
- `scripts/download_sdk.py` — 按语言下载 Server Assistant SDK（默认下载到当前目录，`--output` 指定位置）

## 工作流

### 1. 识别服务端语言

从项目特征判断：`go.mod`→Go、`pom.xml`/`build.gradle`→Java、`requirements.txt`/`pyproject.toml`→Python、`package.json`→Node.js、`composer.json`→PHP、`.csproj`→C#、`CMakeLists.txt`→C++。判断不了就问用户。

### 2. 下载 SDK

```bash
python3 <skill>/scripts/download_sdk.py --language <GO|CPP|JAVA|PYTHON|NODEJS|PHP|CSHARP>
```

默认下载到当前目录，建议用 `--output` 直接指定目标位置（各语言建议路径见 `sdk-urls.md`）。语言不在列表内时下载 NODEJS 版作参考再翻译。

### 3. 实现 Token 端点

```
GET /api/zego/token?userId=<必填>&effectiveTime=<缺省3600>&payload=<可选JSON权限载荷>
```

- 响应为纯文本 Token；`400` 缺参数、`500` 生成失败。完整规范见 `api-spec.md`。
- 直接参考 `examples/token/` 对应语言的实现。

### 4. 配置环境变量

```
ZEGO_APP_ID=1234567890
ZEGO_SERVER_SECRET=xxxxxxxx
```

本地放 `.env`，生产放部署环境；不要提交真实密钥。

## 注意事项

1. 默认有效期 3600 秒，按安全需求调整。
2. payload 可传 JSON 权限数据（房间/推流权限控制）。
3. 客户端在需要时向服务端换取新 Token，不在客户端缓存长期 Token。
4. **客户端 loginRoom 的 userID 必须与生成 Token 时传入的 userID 完全一致**，否则登录失败——这是最常见的集成错误。
5. 客户端侧如何使用 Token（哪个接口传、kickedOut 重连处理等），查阅文档仓库中对应平台的「使用 Token 鉴权」类文档，例如：`rg -l -i "token" <产品平台路径>/communication/`，共享片段见 `<DOCS_ROOT>/snippets/common/zh/token/generate-temporary-token.mdx` 及各产品 `snippets/privilege-token.mdx`。
