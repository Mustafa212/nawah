# Step 2 — Context (existing project)

## Scouts
One `nawah:scout` per repository in `state.md` `Repos:`, all in one message. Each brief:

```
Repository: <absolute path>
Idea: <the idea from intake>
Extra documents: <paths the user pointed to, or none>
```

A scout that fails or returns a malformed report: send it back once, then continue with what you
have and list the gap in the snapshot.

## Existing backlog
When the project file has a tracker: the adapter's `connect`, then `read_backlog`; keep id, type,
title, state and parent. If `connect` fails, say so, continue without it, and note it in the
snapshot.

## snapshot.md
`ideas/<slug>/snapshot.md`, merged from the scouts and the backlog:

```
# Project Snapshot — <project>
Date: <YYYY-MM-DD>    Repos: <paths>

## What the product does today
## Stack
| Repo | Languages and frameworks | Data store | Hosting hints |
|---|---|---|---|
## Modules
| Module | Purpose | Key paths |
|---|---|---|
## Data model
| Entity | Key fields | Path |
|---|---|---|
## Features related to the idea
| Feature | Where | Notes |
|---|---|---|
## Where the idea plugs in
## Constraints and risks to the existing system
## Existing backlog (<tracker>)
| Id | Type | Title | State |
|---|---|---|---|
## Unknowns
```

Facts keep their file paths; inferences stay marked "(inferred)".

## Confirm
Show a short version (what it does, stack, related features, where the idea plugs in, unknowns) and
the file's full path, and ask: "Is this an accurate picture of the project? Correct anything that's
wrong or missing." Apply the corrections to `snapshot.md`. A wrong picture of the project makes the
whole report wrong, so don't skip this. Then `Step: 3`.
