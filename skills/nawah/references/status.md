# State, resume and status

## state.md

```
Idea: <title>
Slug: <slug>
Mode: new | existing
Project: <project or none>
Repos: <paths or none>
Audience: investor | management | client
Language: ar | en
Backlog language: en | ar
Market: <countries>
Currency: <ISO code>
Team: <developers, monthly cost, velocity>
Prepared by: <name>
Step: <1–7 | done>
Gates: brief <date or ->, report v<n> <date or ->, backlog <date or ->
Stale: <steps whose output an earlier change invalidated, or none>
Next: <one line: what happens next, or what the user must do>
Last updated: <YYYY-MM-DDTHH:MMZ>
```

`Step` is the step in progress. A gate's date is set when the user approves it.

## /nawah resume [slug]
1. No slug: list unfinished ideas (`Step` not `done`), newest `Last updated` first, and ask which.
2. Read `state.md`, then the reference of its `Step`. Say in one line: "<Idea>: step <n>. <Next>"
3. Continue that step. A gate passed before the stop isn't asked again, unless `Stale:` names it.
4. Step 7: read `push-log.md` and say what exists and what remains. When `Gates:` shows the backlog
   approved and the log's `Target:` is the project's current tracker target, continue the push: that
   approval covers exactly these items and this target. A changed target, or items added to the
   backlog after the approval, go through Gate 3 again.
5. `Step: done` with a tracker: compare `push-log.md` with `backlog.md` as `references/push.md`
   describes for reruns. Nothing missing or pending: say "Nothing to push", with the counts. Anything
   missing goes through Gate 3 again.

## /nawah status
Read only the `state.md` files under `ideas/`. One table, newest `Last updated` first:

| Idea | Mode | Audience | Step | Gates | Last updated | Next |
|---|---|---|---|---|---|---|

No ideas: say so and suggest `/nawah <idea>`.

## Changing an earlier decision
When the user changes the brief after Gate 2, or the report after Gate 3: update the file, set
`Stale:` to the later outputs (for example `report, backlog`), say which steps must be redone, and
redo them in order, each with its gate.
