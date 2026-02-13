# cq — Code Query CLI

A lightweight code-exploration CLI that answers questions about any codebase. Powered by Claude Code under the hood, it works from **any workflow** — a coding agent's shell tool, your terminal, CI scripts, or anything that can call a command and read stdout.

```
Any coding agent / terminal
  → bash: cq "how does auth work?"
    → Claude (Haiku) explores the codebase
    → returns concise summary
  → caller uses the answer, context stays clean
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kywch/cq/main/install.sh | bash
```

Or manually:

```bash
curl -fsSL https://raw.githubusercontent.com/kywch/cq/main/cq -o ~/.local/bin/cq && chmod +x ~/.local/bin/cq
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

# Interactive mode — conversational Q&A about the codebase
cq
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-d <dir>` | `.` | Target project directory |
| `-m <model>` | `haiku` | Model: `haiku`, `sonnet`, `opus` |
| `-t <turns>` | `30` | Max agentic turns (increase for deeper exploration) |
| `--no-diagram` | off | Disable mermaid diagrams in output |
| `--json` | off | Full JSON output with metadata |
| `-i` | off | Enter interactive mode (also: run `cq` with no arguments) |
| `-s <prompt>` | built-in | Override the system prompt |
| `-h` | — | Show help |
| `-v` | — | Show version |
| `--update` | — | Self-update to latest version |

## Interactive mode

Run `cq` with no arguments (or `cq -i`) to enter interactive mode — a REPL for conversational code exploration:

```
$ cq
cq v0.1.6 — interactive mode (haiku, max 30 turns/query)
project: my-project (/home/user/projects/my-project)
type /help for commands, /quit or Ctrl-D to exit

cq (haiku) my-project > how does auth work?
exploring ....
done — 12 turns, 8s, 45.2k in / 2.1k out / 38.0k cached

[answer]

cq (haiku) my-project > trace the login flow
exploring ....
done — 8 turns, 6s, 52.1k in / 1.8k out / 44.3k cached

[answer, with context from previous exploration]
```

Sessions are resumed automatically — each follow-up question builds on what Claude already explored. Type `/new` to start a fresh session for unrelated questions.

| Command | Action |
|---------|--------|
| `/new` | Reset session (forget previous context) |
| `/stats` | Show session statistics (queries, tokens) |
| `/help` | Show available commands |
| `/quit` | Exit (or Ctrl-D) |

## How it works

### Single-query mode

1. `cq` invokes `claude -p` with read-only tools (Read, Glob, Grep, Task) and a system prompt tuned for code exploration
2. The agent explores the codebase using up to N turns (default 30)
3. If the turn limit is hit before the question is fully answered, a second pass automatically summarizes the findings and suggests a follow-up query (`NEEDS_MORE_EXPLORATION: ...`)
4. The result is printed to stdout — ready for a calling agent to consume

### Interactive mode

1. A REPL loop reads questions and runs each through the same exploration pipeline
2. After the first query, subsequent queries use `--resume` to preserve session context — Claude remembers what files it already explored
3. If a query hits the turn limit, the summary pass runs and the user can ask a natural follow-up to continue
4. `/new` resets the session for unrelated questions

## Use from any coding agent

`cq` prints plain text to stdout, so it works with any tool that can run a shell command: Claude Code, Cursor, Windsurf, Copilot, Aider, Codex CLI, and others.

Add to your project's agent instructions (e.g. `CLAUDE.md`, `.cursorrules`, or equivalent):

```markdown
## Code exploration

Use `cq` for codebase questions before reading files directly:
  bash: cq "how does X work?"
  bash: cq "trace the request lifecycle"  # may include mermaid diagrams
  bash: cq --no-diagram "trace the request lifecycle"  # plain text only

If the response contains NEEDS_MORE_EXPLORATION, run the suggested follow-up query.
cq is stateless — each invocation starts fresh. The follow-up query already includes
context about what was found, so the next run can skip known ground.
```

The coding agent will naturally call `cq` via its shell tool whenever it needs to understand code.

## Why

- **Works everywhere**: Any agent or terminal that can run a command can use `cq`
- **Save context**: Your coding agent stays focused on writing code, not reading files
- **Save cost**: Haiku is cheap; exploration is disposable
- **Better answers**: A dedicated exploration agent with the right prompt does a thorough job
- **Subscription-friendly**: Runs on your existing Claude subscription via `claude -p`

## License

MIT
