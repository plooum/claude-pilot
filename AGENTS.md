# AGENTS.md: being the pilot of a project

For an AI agent told "you are the pilot of this project, follow https://github.com/plooum/claude-pilot". Do these in order.

1. **Install.** Check `ls ~/.claude/skills/pilot ~/.claude/skills/pilot-subagent`. If missing:
   `git clone https://github.com/plooum/claude-pilot ~/.local/opt/claude-pilot && ~/.local/opt/claude-pilot/install.sh`
   It symlinks the two skills into `~/.claude/skills` (no hook, no settings change; idempotent; it leaves alone anything else already there). A new session may be needed to see the skills: until then, read `~/.local/opt/claude-pilot/skills/pilot/SKILL.md` directly.
2. **Agent board (recommended, never required).** A live board of the sub-agents. Ask the user, then follow https://github.com/plooum/agent-board `AGENTS.md`. Without it, the pilot works the same.
3. **Set the project up**, if it has no `.claude/pilot/` yet, from `~/.local/opt/claude-pilot/templates/`:
   - `.claude/pilot/HANDOFF.md`, `BACKLOG.md` and an empty `prompts/` directory;
   - the "Pilot mode" and "Git workflow" lines in the project's `CLAUDE.md` (`CLAUDE-pilot-section.md`);
   - a `pilot-<project>` skill in `.claude/skills/` (`pilot-project-skill.md`): dev environment, merge steps, release rules, review checklist, machines;
   - a delivery / testing skill for the sub-agents if the project has tests or a dev environment worth documenting.

   **Ask the user** the decisions this needs, and record them dated in the handoff: may the pilot files go straight on `main`, without a PR? Which language for the chat with them? Which model for the sub-agents (default Sonnet)? Which machine and how much RAM? Commit the setup the way the project allows (a PR unless the CLAUDE.md says otherwise).
4. **Start.** Load the `pilot` skill (and `pilot-<project>`) and run its loop: read the handoff, check the repo's state, tell the user where things stand.
