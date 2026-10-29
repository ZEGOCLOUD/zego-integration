# zego-integration

> An Agent Skill that turns any AI coding agent into a ZEGO/ZEGOCLOUD integration expert: offline docs lookup, error codes, API reference, token04 & server-API signature implementation, SDK downloads. Works with ZCode, Claude Code, Codex, Cursor and any agent that reads the open [SKILL.md](SKILL.md) format.

An [Agent Skill](SKILL.md) for AI coding agents. It caches the full official ZEGO docs repo locally (~12,000 source files) so the agent can integrate ZEGO products, troubleshoot error codes, look up API parameters, implement token04 authentication and server API signatures, and download SDKs/demos — all offline after the first sync. Works out of the box in both global and China-mainland network environments via mirror fallbacks.

> The skill content is written in Chinese (ZEGO's docs are Chinese-first); agents handle translation naturally.

## Installation

### Option 1: skills CLI (recommended)

```bash
npx skills add ZEGOCLOUD/zego-integration
```

Auto-detects your installed agents (ZCode / Claude Code / Codex / Cursor, …) and installs into the right location.

### Option 2: one-line script

```bash
curl -fsSL https://raw.githubusercontent.com/ZEGOCLOUD/zego-integration/main/install.sh | bash
```

For China-mainland networks (direct GitHub access unreliable):

```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/ZEGOCLOUD/zego-integration/main/install.sh | bash
```

The script has a built-in clone fallback chain (direct → ghfast.top → gh-proxy.com). Set `ZEGO_SKILL_DIR=<dir>` to choose the install location explicitly.

### Option 3: manual clone

```bash
# Global / with a proxy
git clone https://github.com/ZEGOCLOUD/zego-integration.git ~/.agents/skills/zego-integration

# China mainland, direct
git clone https://ghfast.top/https://github.com/ZEGOCLOUD/zego-integration.git ~/.agents/skills/zego-integration
```

Pick the directory matching your agent: `~/.agents/skills/` (cross-agent shared, ZCode), `~/.claude/skills/` (Claude Code), `~/.codex/skills/` (Codex), etc.

## Usage

Restart your agent session after installing, then just ask:

- "Build a 1v1 video call with ZEGO in Next.js / iOS / Android"
- "What does ZEGO error code 1230004 mean?"
- "What are the parameters of loginRoom? Any differences between Web and Android?"
- "How do I generate token04 on the server side? Give me a Go implementation"
- "What does this docs page say: https://doc-zh.zego.im/..."

The first use downloads a docs snapshot (~40MB compressed, ~200MB unpacked, cached in `~/.cache/zego-integration/`; incremental updates afterwards).

## Features

| Capability | Details |
|---|---|
| Docs lookup | Full ZEGOCLOUD/docs_all cached locally; grep search + source reading; public URL ↔ local file mapping |
| Product routing | Product × platform × docs-path table (RTC / voice call / low-latency live streaming / ZIM / AI Agent / digital human / whiteboard, …) |
| Error codes | Offline lookup across all products |
| API reference | Method-level parameter details; resolves in-doc `@apiName` short links |
| Token auth | token04 generation spec + Go/Java/Python/Node/PHP/C# endpoint examples + Server Assistant SDK download |
| Server API | Request signature mechanism with multi-language implementations |
| SDK downloads | Client SDKs / demos / repos (with China mirror fallback) |
| Playbooks | Battle-tested per-scenario guides (Web/iOS/Android integration pitfalls, simulator testing, …), continuously extended |

## Updating

- CLI install: `npx skills update`
- Clone install: `git -C ~/.agents/skills/zego-integration pull`
- Docs snapshots refresh automatically on first skill use per session (10-min throttle) — nothing to do manually

---

## Maintenance (for repo maintainers)

### Layout

| Location | Role |
|---|---|
| `SKILL.md` | Entry point & task routing, read by the loading agent |
| `references/` | Lookup knowledge (product map, repo structure, search strategy, token/signature specs) |
| `references/playbooks/` | Per-scenario best-practice guides, continuously extended |
| `scripts/` | Docs snapshot updater, search & URL tools, SDK downloads |
| `examples/` | Multi-language token & signature examples |
| `install.sh` | One-line installer (with China mirror fallback) |

Principle: `SKILL.md` and `references/` contain only what a skill user needs to know; anything about extending or maintaining the skill belongs in this section.

### Adding a playbook

Add an md file under `references/playbooks/` — **no SKILL.md change needed** — and update the index table in that directory's `README.md`:

1. File name: product/scenario English slug (e.g. `zim.md`, `whiteboard.md`, `live-audio-room.md`).
2. First two lines state the scope, fixed format (existing playbooks use the equivalent Chinese keys — keep the directory consistent):

   ```
   > Product: ZIM (in-app chat)
   > Scenario: client SDK integration, messaging / conversation management
   ```

3. Body: key doc paths for the scenario (inside the docs repo), platform differences & pitfalls, version/config requirements, verification methods. Reference docs by repo-relative path, not public URL.
4. Write only experience & caveats — general workflow lives in SKILL.md.

### Other conventions

- **`references/products-platforms.md`** is maintained alongside docs snapshots; when upstream adds products, sync it (authoritative source: `instances` in `docuo.config.*.json`).
- **Dual-network support**: all download scripts use a "direct → gh-proxy.com → gh-proxy.net" fallback chain (git clone uses ghfast.top instead of gh-proxy.net — the latter's 302 breaks git). After changing download logic, verify it still works in a restricted (China-mainland) network.
- **Docs cache** defaults to `~/.cache/zego-integration/docs_all` (override with `ZEGO_DOCS_ROOT`), 600s TTL throttle, state file `docs_all.state` next to the snapshot.
- **Regression after changes**: `python3 -m py_compile scripts/*.py`, `bash -n scripts/*.sh`, then run `update_docs.sh` once (expect `STATUS=cached`) and any search tool to confirm path resolution.

## License

[MIT](LICENSE)
