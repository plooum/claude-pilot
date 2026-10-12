---
name: pilot-<project>
description: <Project>'s specifics for the pilot - dev environment, merge and release steps, review checklist additions, machines. Load it together with the `pilot` skill when you are the pilot of <project>.
---

# Pilot of <project>

Complements the global `pilot` skill with what is specific to this project. Keep it short and factual.

## Dev environment

- Start / check / stop: `<commands>`. Check it at the start of the session.
- Per worktree: what a sub-agent needs of its own (port, dependencies linked, build step), and how it stops it when done.
- Parallelism: how many sub-agents at a time on each machine, and why.

## Review checklist (additions)

- <project-specific item: e.g. docs in two languages, a version file not bumped in a feature PR, generated files not committed>

## Merge

1. <Rebase rule: when `main` moved, what to ignore (e.g. only the pilot's files).>
2. <Merge command and subject format, e.g. `gh pr merge <N> --squash --delete-branch`.>
3. <After: clean the worktree, stop its dev environment, check CI on `main`.>

## Releases

<Tag naming and semver rules, who publishes, release notes language, what CI attaches.>

## Machines

<Name: RAM, cores, tool locations (`~/.local/bin`...). Mirrors the handoff's Machines section.>

## Skills of the project

| Skill | For |
| :--- | :--- |
| `<delivery / testing skill>` | <when to load it> |
