#!/bin/bash
# install.sh — 把 zego-integration skill 安装到本机 agent 的 skills 目录
#
# 用法:
#   ./install.sh                                  # 自动探测 skills 目录
#   ZEGO_SKILL_DIR=~/.claude/skills ./install.sh  # 显式指定安装位置
#   curl -fsSL https://raw.githubusercontent.com/ZEGOCLOUD/zego-integration/main/install.sh | bash
#
# 国内网络（GitHub 直连不稳）用镜像执行:
#   curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/ZEGOCLOUD/zego-integration/main/install.sh | bash
#
# 克隆通道: 直连 → ghfast.top → gh-proxy.com（与 skill 内脚本同一套回退链）

set -euo pipefail

REPO="ZEGOCLOUD/zego-integration"
SKILL_NAME="zego-integration"

# ---------------- 定位源 ----------------
# 脚本若在仓库内（旁边有 SKILL.md），直接安装当前目录；否则从 GitHub 克隆
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || script_dir=""
if [ -n "$script_dir" ] && [ -f "$script_dir/SKILL.md" ] && grep -q "^name: $SKILL_NAME" "$script_dir/SKILL.md"; then
  src="$script_dir"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  cloned=""
  for prefix in "" "https://ghfast.top/" "https://gh-proxy.com/"; do
    echo "克隆 ${prefix}https://github.com/$REPO.git ..."
    if git clone --depth 1 "${prefix}https://github.com/$REPO.git" "$tmp/$SKILL_NAME"; then
      cloned=1
      break
    fi
  done
  [ -n "$cloned" ] || { echo "错误: 克隆失败（直连与镜像均不可达），请检查网络或配置代理后重试。" >&2; exit 1; }
  src="$tmp/$SKILL_NAME"
fi

# ---------------- 定位目标 ----------------
if [ -n "${ZEGO_SKILL_DIR:-}" ]; then
  target_root="$ZEGO_SKILL_DIR"
else
  target_root=""
  for d in "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.zcode/skills"; do
    if [ -d "$d" ]; then target_root="$d"; break; fi
  done
  # 一个都没找到时用跨 agent 共享的 ~/.agents/skills
  target_root="${target_root:-$HOME/.agents/skills}"
fi

dest="$target_root/$SKILL_NAME"

# 防误删：目标已存在且内容不属于本 skill 时中止
if [ -e "$dest" ]; then
  if [ ! -f "$dest/SKILL.md" ] || ! grep -q "^name: $SKILL_NAME" "$dest/SKILL.md"; then
    echo "错误: $dest 已存在且不是 ${SKILL_NAME}，请手动处理后再安装。" >&2
    exit 1
  fi
  rm -rf "$dest"
fi

# ---------------- 安装 ----------------
mkdir -p "$target_root"
# 保留 .git，便于后续 git pull 更新
cp -R "$src" "$dest"

echo ""
echo "已安装: $dest"
echo ""
echo "验证: 重启 agent 会话后，对其说「帮我用 ZEGO 实现一个 1v1 视频通话」或「查一下 ZEGO 错误码 1230004」。"
echo "更新: git -C $dest pull（或 npx skills update）"
