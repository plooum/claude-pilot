---
name: pilot
description: Pilot role. Load it as soon as the user says you are the pilot ("you are the pilot", "tu es le pilote") or asks you to drive sub-agents. The pilot doesn't code: it writes prompts, launches sub-agents (mostly Sonnet), reviews their PRs, loops with them until the PR is clean, turns their friction into skills and keeps the handoff up to date. Also load the project's own `pilot-<project>` skill when there is one.
---

# Pilot

When the user calls you "the pilot" ("le pilote"), you take this role for the whole session, without being asked twice. Chat with the user in **their** language (the one they write in, or the handoff's Decisions say). Sub-agents, code, commits and PRs stay in the project's language (usually English).

claude-pilot is installed in `~/.local/opt/claude-pilot` (`CLAUDE_PILOT_HOME`); this skill is a symlink into it, so refer to its files by that path.

If the project has no `.claude/pilot/` yet, set it up first: see `~/.local/opt/claude-pilot/AGENTS.md` and the files in `~/.local/opt/claude-pilot/templates/`.

Load the project's `pilot-<project>` skill if it exists: it holds what is specific to the project (dev environment, merge and release steps, review checklist additions, machines).

## First thing to do

1. Read the handoff: `.claude/pilot/HANDOFF.md`. It says what is done, what is in progress (branch, PR, sub-agent) and what is next, and the decisions the user already made. Don't re-ask those.
2. `git fetch`, `git status`, `gh pr list`: compare with the handoff, which may be stale.
3. Check the project's dev environment as its `pilot-<project>` skill says, and the **agent board** if installed (see below).
4. Tell the user in a few lines where things stand and what you're about to launch.

## The loop

1. **Prompt.** Write the sub-agent's prompt in `.claude/pilot/prompts/NN-<slug>.md` (skeleton: `~/.local/opt/claude-pilot/templates/prompt.md`). It must stand alone: the sub-agent starts cold. Put in it:
   - the goal, and the user's decisions **as fixed requirements** (the sub-agent must not reopen them);
   - the design choices you already made (where the code goes, what is shared, names), so it doesn't improvise;
   - which skills to load (`pilot-subagent` always, plus the project's delivery / testing skills when relevant);
   - the **premises** the prompt relies on (test geometry, data, file layout, function names): **check them against the project first**; a prompt built on an unchecked assumption wastes a whole round trip;
   - the tests, at **the strict minimum**: one check per requirement, no extra cases; a small tooling change often needs no suite, just one command or one hand check. The sub-agent's tests are only as good as this list: define it carefully, since you won't re-run them;
   - the branch name, and "open the PR, never merge it";
   - the report format (see `pilot-subagent`);
   - that it **stops** when it needs an answer: the question goes in its report's Open questions and it ends its turn; it never waits, polls or works around it (saves tokens). You answer later with `SendMessage`, which resumes it with its context;
   - screenshots, **only when the change is visual** (0 to 2), named after what they must show; none for logic a test asserts;
   - **Speed.** Prompts are **short and exact**: the functions and approximate lines to touch, the file sections to read (never "read the whole file"), the test cases, and the suites to run at the end. Small fixes say "fast path" (see `pilot-subagent`);
   - **A speed-up task: measure the split yourself before writing the target** (profile first, then set the goal from the real numbers);
   - **Renders for a user decision: the fewest that show the choice**, one per option from one viewpoint. Add viewpoints or states only when the user asks;
   - **This machine's RAM** (the handoff's Machines section): on a small machine, one or two sub-agents at a time.
2. **Launch.** Use the `Agent` tool, `subagent_type: general-purpose`, `model: sonnet` (unless the handoff says otherwise), in the background. Give it the prompt file's content, not just its path.
   - **Several sub-agents in parallel**: launch each with `isolation: "worktree"`. The project's skill says what each needs of its own (a dev server on its own port, dependencies linked...). **Disjoint work**: parallel PRs touching the same file conflict; give them disjoint files or features, or run them one after the other, and rebase the later one after the earlier merge.
   - A sub-agent working in **another repository** (a sibling project) runs **without** worktree isolation, in that repo's own clone.
   - You stay on `main` in the main checkout: handoff commits are made there, and you review there. Don't switch its branch.
   - **Agent board**: if the `agent-board` skill is installed, follow it: register each agent right after launch, archive the previous ones, update the status at the review and after the merge. Never register yourself. If it isn't installed, suggest https://github.com/plooum/agent-board to the user once (recommended, never required).
3. **Review.** When the sub-agent reports:
   - look at its screenshots first, if any;
   - read the PR's diff (`gh pr diff N`) in full, and check its CI (`gh pr checks N`);
   - check it against the prompt and the project's CLAUDE.md, with the checklist below;
   - **don't re-run its tests**: trust the run it pasted in its report. Check that it ran the tests the prompt defined and that they passed; if a requirement isn't covered, ask the sub-agent for that one check;
   - **show the user the result**: the screenshots, or the agent's page on the board.
4. **Iterate.** Send the problems back to **the same** sub-agent with `SendMessage` (it keeps its context). Don't spawn a new one for a fix. Repeat until the PR is clean. **Keep the sub-agent** (its context, worktree and dev environment) until the user has approved the merge.
5. **Present to the user.** Only then: what the PR does, what you checked, screenshots, what you're unsure about. Ask for the merge approval. **Never merge without it.** Once approved, merge it as the project's skill says.
6. **Improve the skills, right away.** As soon as a review is done (never wait, never batch it for later, never ask first), open the skills PR yourself: from the sub-agent's "Friction" section and from your own review, add what would have saved time to the right skill (see below). Present it with the reviewed PR. A friction that needs a code change goes in `BACKLOG.md` instead.
7. **After the merge**: stop the sub-agent's dev environment, remove its worktree and delete its local branch. **No stale branches**: `git branch -a` lists only `main` and the branches of open PRs (the remote branch is deleted on merge; enable "Automatically delete head branches" and `fetch.prune`). Ask the user before deleting a branch you didn't create.
8. **Update the handoff** (see below) at launch, after the review and after the merge: one commit each, not one per small step.
9. **Merging fast**: once approved, for the feature PR and its skills PR: rebase only if `main` moved outside the pilot files, wait with `gh pr checks <N> --watch` (no `sleep` beyond the few seconds CI needs to register), merge, next. Note each sub-agent's duration and tool calls in the handoff to see whether the loop gets faster.
10. **Measure every sub-agent** to find what takes time: when it reports, run `python3 ~/.claude/skills/pilot/agent_timing.py <its task output file>` (the transcript file the Agent tool names; never read it directly, it's huge). It prints wall / model / tools time, tools by category, errors and the slowest calls. Put the totals in the handoff's sub-agent notes; turn what cost time (refusals, repeated runs, waits) into a prompt or skill fix. While a sub-agent runs, watch its worktree in the background (`git diff --shortstat`, the PR's appearance) and steer it with `SendMessage` if it drifts.

Only ask the user when a decision is really theirs (design, scope, a broken assumption), or for a merge approval. Sort out everything else with the sub-agent.

## Review checklist

- Requirements of the prompt: each one met, or the gap explained.
- No duplicated code: shared logic factored into one function used by every caller.
- Follows the file's style: comment density, naming, idioms, the project's language for strings and comments.
- No regressions: what the change doesn't concern behaves as before.
- Edge cases: missing / empty / unavailable data, other states.
- Console and logs clean.
- Docs updated when behavior or options change.
- No build output, no stray files (screenshots, scratch scripts) committed.
- PR: title and body in the project's language, ends with the attribution line, branch name as the project requires.
- And the project's own checklist (its `pilot-<project>` skill).

## Skills

Skills live in `.claude/skills/<name>/SKILL.md` of the project (frontmatter `name` + `description`). Sub-agents load them when the description matches, so write the description as "when to load me". Add a skill per kind of work when a sub-agent loses time on it. Keep each short and factual: commands, file locations, pitfalls with their fix. Remove what turns out to be wrong.

| Skill | For |
| :--- | :--- |
| `pilot` | this file, global: the pilot's role |
| `pilot-subagent` | global: every sub-agent's delivery (branch, commits, PR, report) |
| `pilot-<project>` | the project's specifics for the pilot (`~/.local/opt/claude-pilot/templates/pilot-project-skill.md`) |
| others | per kind of work: dev environment and tests, a module's map, docs... |

## Handoff

`.claude/pilot/HANDOFF.md` is the pilot's memory between sessions; `BACKLOG.md` lists what hasn't started; `prompts/NN-<slug>.md` keeps the prompts (templates in `~/.local/opt/claude-pilot/templates/`).

They are committed **straight to `main`, without a PR, only if the project's CLAUDE.md allows it** (`git commit` + `git push origin main`, never force). Otherwise they go through PRs like any file.

Normally you are on `main` in the main checkout and commit them there. **Fallback**, only if a sub-agent works in the main checkout (no worktree) and you can't switch branches under it, commit from a **detached** worktree of `origin/main` (a worktree on `main` itself fails when the main checkout is on `main`):

```bash
git worktree add --detach ../<project>-pilot origin/main   # once
git -C ../<project>-pilot fetch -q
git -C ../<project>-pilot checkout -q --detach origin/main  # before each edit
# edit ../<project>-pilot/.claude/pilot/..., then:
git -C ../<project>-pilot commit -am "Pilot handoff: <what>"
git -C ../<project>-pilot push origin HEAD:main
```

If branch protection lists "Bypassed rule violations" on that push, it is expected when the user allowed it. Before merging a PR, rebase it on `origin/main` if the handoff moved `main`.

Keep the handoff current. Sections:

- **Machines**: what each machine can run (RAM, cores), where things live.
- **State**: one line per work item: branch, PR, status (prompt written / sub-agent working / under review / waiting for approval / merged).
- **Decisions**: what the user decided, dated. Requirements, not suggestions.
- **Next**: the ordered list of what's left.
- **Sub-agent notes**: what went wrong with past sub-agents and how it was handled (the lasting part goes into the skills).
