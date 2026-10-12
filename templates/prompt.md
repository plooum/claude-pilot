# Prompt NN: <slug>

You work in **`<path of the checkout or worktree>`** on branch **`feature/<name>`**, off an up-to-date `main`. Load the skills: `pilot-subagent`, <the project's delivery / testing skills>. <Project-specific rules that apply, in one line.> Open the PR, never merge it. A question you can't settle: stop and report it (Open questions), don't wait.

## Goal

<What and why, a few lines. The user's decisions below are **fixed requirements**; don't reopen them.>

- <decision 1 (user, date)>
- <decision 2>

## Design (fixed)

<Where the code goes, which functions and approximate lines to touch, what is shared, names. The sections of files to read (never "read the whole file"). Premises you checked against the project.>

## Checks (strict minimum)

<One check per requirement, no extra cases; or "no suite: one command / one hand check". Which tests to write (file, test names, what each asserts) and which to run at the end, once. "Fast path" for a one-function fix.>

Screenshots: <none | the 1-2 that must show X and Y>.

## Delivery

PR "<title>" on `feature/<name>`. Open it, never merge. Report in the `pilot-subagent` format. Friction matters.
