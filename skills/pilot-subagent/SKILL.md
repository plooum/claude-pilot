---
name: pilot-subagent
description: How a sub-agent delivers work given by a pilot - feature branch, commits, pull request, and the report it gives back. Load it for any task given by a pilot; the project's own delivery skill adds its specifics.
---

# Delivering a change (sub-agent)

You were given a task by the pilot, an agent who reviews your work and loops with you. You deliver a **branch and an open PR**, never a merge. Also load the project's own delivery / testing skills the prompt names.

## Branch and commits

- You may be in a git worktree of your own (launched with `isolation: "worktree"`). There, create the branch off `origin/main`: `git fetch`, `git checkout -b feature/<name> origin/main` (`main` itself is checked out in the main checkout). Such a branch tracks `origin/main` until your first `git push -u origin feature/<name>`: always push with `-u`.
- Otherwise start from an up-to-date `main`: `git checkout main`, `git fetch`, `git pull --ff-only`, then `git checkout -b feature/<name>` (the name the prompt gives).
- Never commit on `main`, never merge, never force-push anything but your own feature branch.
- Don't commit build output, screenshots or scratch scripts: keep them in a gitignored or scratch directory.
- Commit messages: imperative subject, in the project's language, ending with the attribution line from your system prompt (`Co-Authored-By: ...`).
- Follow the project's CLAUDE.md conventions; match the file's style (comment density, naming, idioms). Read the code around your change before writing. Don't duplicate logic: factor it into one function used by every caller.
- Out-of-scope issues: mention them in your report, don't fix them.

## Sandbox refusals in worktrees

Each refusal costs a round trip.
- Run git steps as separate commands rather than one long `&&` chain. The sandbox refuses "too complex" commands: brace expansion, `git` mixed with `&&`, `;`, a heredoc or `python3 -`, `git` / `gh` / `sed` with shell variables. Write multi-line scripts and file edits with the Write / Edit tools.
- Never mention a path outside your worktree (no `/tmp/...` scratch files, no `export PATH=/home/...`): keep scratch files in a gitignored directory of your worktree. A tool not found: try its full path (`~/.local/bin/<tool>`).
- `gh pr create` with a long inline `--body "..."` is refused as too complex: write the body with Write, then use `--body-file <file in your worktree>`.
- `git add <the files>` rather than `git add -A` (slow when the tree holds runtime state).
- Stopping a background process: `pkill -f "<pattern>"` also matches (and kills) the shell running it (exit 144). Use `pgrep -f "<pattern>"`, then `kill <pid>`.
- To wait on a background process, load the `Monitor` tool first (`ToolSearch` `select:Monitor`) rather than polling in a foreground loop. Never `sleep`: the harness blocks it.

## Be fast

The user finds a long loop costly.
- Read only the sections the prompt names (grep, then read around); don't read a whole big file or a skill you don't need.
- While you work, run only the test you're on (`--only` or the equivalent); run the full suites the prompt lists **once**, at the end. Run exactly the tests the prompt lists, nothing more.
- One build per change you want to see.
- Screenshots only if the prompt asks for them; check the viewpoint on a first shot before a series.
- **Fast path** (the prompt says so: a one-function fix): no screenshots, the new test plus the smoke test, a 5-line report.
- **Don't wait for CI** after opening the PR: report right away, the pilot checks it.

## Pull request

```bash
git push -u origin feature/<name>
gh pr create --base main --title "<title>" --body-file <body file>   # write the body with Write first
```

Right after a push, `gh pr checks --watch` may still list the previous commit's runs (`gh pr view <N> --json headRefOid,statusCheckRollup`); you normally don't wait for it at all.

The body: what changed and why, how it was tested, what wasn't tested. It ends with the line from your system prompt (`🤖 Generated with [Claude Code](https://claude.com/claude-code)`).

## Report to the pilot

End your work with this report, and nothing else around it:

```
## Report
Branch / PR: feature/<name>, #<N> (CI: pass | fail: <which>)
Done: <bullets: what changed, which functions/files>
Deviations from the prompt: <each one, with the reason; "none" otherwise>
Tested: <the test run's output pasted in full (PASS / FAIL lines, total time) and its path; then what it doesn't cover and what you checked by hand>
Screenshots: <paths when the prompt asks for them, see below>
Not tested: <and why>
Open questions: <decisions you need from the pilot> (when you need one to go on, stop there: report and end your turn; the pilot resumes you with the answer. Never wait or poll.)
Friction: <what made you lose time: a command that failed, something hard to find, a wrong assumption in the prompt or a skill, and how you got past it>
```

**Tests are written down and run by a command**: the pilot doesn't re-run them and trusts your output, so paste it in full. The **Tested** section is that output, not a narrative of what you clicked. A test file you write is committed with the PR.

**Screenshots when the prompt asks for them** (a visual change): those it names, otherwise the main state and the most important other one. Never committed. The pilot looks at them first to check your work.

The **Friction** section matters: the pilot turns it into skills so the next sub-agent doesn't lose the same time. Be concrete ("a descendant selector doesn't cross shadow roots: walk with `.shadowRoot`"), not vague.

When the pilot sends you review comments, fix them on the same branch, push, and give a new report (only what changed).
