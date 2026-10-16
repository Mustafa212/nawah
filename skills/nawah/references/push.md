# Step 7 — Push

Contents: Before the first call · Order · Fields · push-log.md · Reruns and resume · Failure · End

## Before the first call
- Gate 3 was approved in this conversation, or on resume `state.md` shows the backlog approved and
  `push-log.md`'s `Target:` is the project's current tracker target (see `references/status.md`).
- Read the project file and `references/trackers/<Tracker>.md`. Run its `connect`; on failure show
  the error and the fix, offer the CSV instead, and stop with `Next:` saying what to fix.
- Read `push-log.md` if it exists.
- Request bodies go in `ideas/<slug>/.push/` (create it); never a token in them.

## Order
1. Epics, in id order; then features; then stories.
2. An epic with `Parent: existing <tracker id>` isn't created: log it with that tracker id and `Pending:
   none`, and create its features under that item.
3. Create each item with its parent link in the same call when the tracker allows it (see the
   adapter); otherwise `link` right after.
4. Write the item's push-log row as soon as the call returns, before the next item, with `Pending`: `deps` when its backlog `Depends on:` isn't `none`; else `parent` when the parent link wasn't made in the create call; else `none`.
5. When every item exists: for each row whose `Pending` is `deps` (or `parent`), make the missing links with `link`, then set that row's `Pending` to `none`.

## Fields
What goes where is in the adapter. From `backlog.md`:
- Title: the heading's text after the id and the dash.
- Epic: Goal and Success metric in the description. Feature: Description.
- Story: Story, Value, Out of scope, NFR and Open questions in the description; the acceptance
  criteria in the tracker's acceptance-criteria field when it has one, else under an "Acceptance
  criteria" heading in the description; Points and Priority in their fields when the tracker has them.
- Tags on every item: `nawah` and `nawah:<slug>` (Jira: `nawah-<slug>`), plus the release where the
  tracker keeps releases as tags or labels.

## push-log.md

```
# Push log — <slug>
Target: <tracker> <url> <tracker project>

| Local id | Tracker id | URL | Created at | Hash | Pending |
|---|---|---|---|---|---|
| E1 | 1234 | https://… | 2026-10-16T19:40Z | 3355210114 | none |
```

- `Hash`: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/item-hash.sh" "<backlog.md>" <local id>`, at create
  time.
- `push-log.md` lives in `ideas/<slug>/`. On the first push create it with its title, the `Target:` line and the table header. `Created at`: `date -u +%Y-%m-%dT%H:%MZ`.
- `Pending`: `parent` (the parent link failed), `deps` (dependency links not done yet), or `none`.

## Reruns and resume
- A local id already in the log is never created again.
- A row whose `Pending` isn't `none`: do only what's pending.
- A row whose hash no longer matches `item-hash.sh` now: list it as changed, with what changed, so
  the user can update it in the tracker; nawah doesn't edit pushed items.
- Nothing missing and nothing pending: start the reply with the words "Nothing to push", then the counts.

## Failure
Stop at the first failed call. Show the error, what exists (from the log), what remains, and the fix
if you know it. Set `Next:` in `state.md` to "`/nawah resume <slug>` continues the push" and stop.

## End
Show the counts per type, the link of the first epic (and a query or filter link when the tracker
has one), and the path of `backlog.csv`. `Step: done`. Then the run's ending checklist in `SKILL.md`.
