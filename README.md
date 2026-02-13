# cq — Code Query CLI

A lightweight Claude Code wrapper that spawns haiku sub-agents to explore codebases. Designed to be called by a coding agent's Bash tool so it can offload code understanding without spending its own context.

```
Main coding agent (Opus/Sonnet)
  → bash: cq "how does auth work?"
    → claude -p (Haiku) explores the codebase
    → returns concise summary
  → main agent uses the answer, context stays clean
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kywch/cc-code-query-cli/main/install.sh | bash
```

Or manually:

```bash
curl -fsSL https://raw.githubusercontent.com/kywch/cc-code-query-cli/main/cq -o ~/.local/bin/cq && chmod +x ~/.local/bin/cq
```

To update:

```bash
cq --update
```

Requires:
- `bash` (pre-installed on macOS, Linux, WSL; on Alpine: `apk add bash`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (with active subscription)
- `jq` (`sudo apt install jq` / `brew install jq`)

## Usage

```bash
# Ask about the current project
cq "how does the auth middleware work?"

# Target a specific directory
cq -d /path/to/project "trace the request lifecycle"

# Use a stronger model for complex questions
cq -m sonnet "explain the architecture of this system"

# Get JSON output (includes cost, turns, metadata)
cq --json "where is UserService defined?"

# More turns for deep exploration
cq -t 50 "trace the full payment flow end to end"

# Pipe a query
echo "find all API endpoints" | cq
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-d <dir>` | `.` | Target project directory |
| `-m <model>` | `haiku` | Model to use |
| `-t <turns>` | `30` | Max agentic turns |
| `--json` | off | Full JSON output with metadata |
| `-s <prompt>` | built-in | Override the system prompt |
| `-h` | — | Show help |
| `-v` | — | Show version |
| `--update` | — | Self-update to latest version |

## How it works

1. `cq` invokes `claude -p` with read-only tools (Read, Glob, Grep, Task) and a system prompt tuned for code exploration
2. The agent explores the codebase using up to N turns (default 30)
3. If the turn limit is hit before the question is fully answered, a second pass automatically summarizes the findings and suggests a follow-up query (`NEEDS_MORE_EXPLORATION: ...`)
4. The result is printed to stdout — ready for a calling agent to consume

## Use from another Claude Code session

Add to your project's `CLAUDE.md`:

```markdown
## Code exploration

Use `cq` for codebase questions before reading files directly:
  bash: cq "how does X work?"

If the response contains NEEDS_MORE_EXPLORATION, run the suggested follow-up query.
```

Then the coding agent will naturally call `cq` via its Bash tool whenever it needs to understand code.

## Why

- **Save context**: The main coding agent stays focused on writing code, not reading files
- **Save cost**: Haiku is cheap; exploration is disposable
- **Better answers**: A dedicated exploration agent with the right prompt does a thorough job
- **Subscription-friendly**: Uses `claude -p` which runs on your existing subscription

## License

MIT
