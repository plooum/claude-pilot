# Lignes à ajouter au CLAUDE.md du projet

Adapte, puis colle.

```markdown
## Git workflow

Every change goes through a pull request. Nothing is committed directly on `main`<, with one exception: the pilot's handoff and prompts in `.claude/pilot/` (see **Pilot mode**), committed and pushed straight to `main`>. <Squash-merge, branch naming, CI to check, who approves: the project's rules.> Never merge a PR before the owner's explicit approval.

## Pilot mode

When the user tells an agent it is **the pilot** ("you are the pilot"), it takes that role for the session without further prompting: it loads the `pilot` skill (https://github.com/plooum/claude-pilot; `install.sh` there links it into `~/.claude/skills`) and the project's `pilot-<project>` skill, reads the handoff `.claude/pilot/HANDOFF.md`, and runs the loop: it writes the prompts, launches sub-agents, reviews and iterates on their PRs, turns their friction into skills, and keeps the handoff current. It asks the user only for decisions that are theirs and for merge approvals.

Project skills live in `.claude/skills/`. Sub-agents load them when their description matches.
```

La partie entre `<...>` est l'**exception facultative** : garde-la seulement si le propriétaire autorise les fichiers du pilote (`.claude/pilot/`) à aller directement sur `main`. Sans elle, ils passent par des PR comme n'importe quel fichier. Si le projet utilise le tableau des agents, ajoute : « Sub-agents are followed on the agent board (https://github.com/plooum/agent-board); load the `agent-board` skill before launching them. »
