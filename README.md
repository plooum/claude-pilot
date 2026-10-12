# claude-pilot

AI agent asked to be the pilot: read [AGENTS.md](AGENTS.md).

A pilot workflow for [Claude Code](https://claude.com/claude-code): one agent (the pilot) writes short exact prompts, launches sub-agents in git worktrees, reviews and iterates on their pull requests, turns their friction into skills and keeps a handoff for the next session. It never merges without the user's approval.

## What's inside

- `skills/pilot`: the pilot's role and loop (global skill), with `agent_timing.py` to measure each sub-agent.
- `skills/pilot-subagent`: how a sub-agent delivers (branch, commits, PR, report format) (global skill).
- `templates/`: the handoff, backlog and prompt skeletons, the lines to add to a project's `CLAUDE.md`, and the skeleton of a project's own `pilot-<project>` skill.
- `install.sh`: links the two skills into `~/.claude/skills`.

The project-specific parts (dev environment, merge and release steps, review checklist additions) stay in each project, in its `pilot-<project>` skill.

## Install

```bash
git clone https://github.com/plooum/claude-pilot ~/.local/opt/claude-pilot
~/.local/opt/claude-pilot/install.sh
```

Idempotent: re-run it to update. `CLAUDE_PILOT_HOME` changes the target directory. For testers of an unmerged branch: `CLAUDE_PILOT_REF=<branch> ./install.sh` clones that branch instead of the default one. No hook, no settings change; an existing skill of the same name is left alone with a warning. Start a new Claude Code session to see the skills.

## Start a pilot in a project

Tell the project's agent: "you are the pilot of this project, follow https://github.com/plooum/claude-pilot". It installs, sets the project up from `templates/` (asking you the few decisions it needs) and starts the loop. Next sessions: "you are the pilot" is enough, the handoff does the rest.

## Agent board

Recommended, never required: [plooum/agent-board](https://github.com/plooum/agent-board) shows the sub-agents live (status, browser, tests). The pilot skill uses it when its skill is installed.

## License

GPL-3.0, see [LICENSE](LICENSE).
