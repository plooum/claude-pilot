# Pilot handoff

Read by the next pilot first (see the `pilot` skill). Committed straight to `main` if the project's CLAUDE.md allows it, otherwise through PRs. Keep it current.

_Last update: <date>, pilot session <n> (<model>, <machine>): <one line>._

## Machines

- <machine>: <RAM, cores>, how many sub-agents at a time, where the main checkout is.

## State

One line per work item: branch, PR, status (prompt written / sub-agent working / under review / waiting for approval / merged).

- Nothing in progress.

## Decisions (user)

Requirements, not suggestions. Dated.

- <date>: language of the chat with the user: <language>.
- <date>: sub-agents' model: <model>.
- <date>: pilot files straight on `main`: <yes / no, through PRs>.

## Next

1. <what's left, in order>

## Sub-agent notes

What went wrong with past sub-agents and how it was handled (the lasting part goes into the skills). Per agent: prompt, wall time, tool calls.

- <prompt NN>: <wall>, <tool calls>, <what cost time>.
