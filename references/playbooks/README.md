# 场景最佳实践指引（playbooks）

本目录存放**针对具体产品/场景的集成经验与踩坑指引**，是对通用集成工作流的补充。

## 使用方式

处理集成任务前，先看本目录是否有匹配的指引：文件名即产品/场景英文 slug（如 `rtc.md`、`ai-agent.md`）。命中则先读指引再开工。

## 当前指引

| 文件 | 适用 |
|---|---|
| `rtc.md` | 实时音视频（Video Call / 实时语音 / 低延迟直播 / Live Streaming）客户端集成，含 Web/React/Next.js 实战经验 |
| `ios.md` | RTC iOS 客户端集成（SwiftUI + SPM、模拟器自动化验证、与 Web 互通联调） |
| `android.md` | RTC Android 客户端集成（Gradle/Maven、无 Android Studio 环境搭建、模拟器自动化验证、与 Web 互通联调） |
| `ai-agent.md` | 实时互动 AI Agent（语音通话 / 数字人）集成 |
