# Step 7 — Push

Contents: Before the first call · Order · Fields · push-log.md · Reruns and resume · Failure · End

## Before the first call
- Gate 3 was approved in this conversation, or on resume `state.md` shows the backlog approved and
  `push-log.md`'s `Target:` and `Approved:` lines still hold (see `references/status.md`).
- Read the project file and `references/trackers/<Tracker>.md`. Run its `connect`; on failure show
  the error and the fix, offer the CSV instead, and stop with `Next:` saying what to fix.
- At a Gate 3 yes, write `push-log.md`'s header (below) before the first call; otherwise read it.
- Every call goes through the project's MCP server (`Connection:`); no token in any argument.

## Order
1. Epics, in id order; then features; then stories.
2. An epic with `Parent: existing <tracker id>` isn't created: log it with that tracker id and `Pending:
   none`, and create its features under that item.
3. A feature the tracker keeps as a label or tag (Jira without a level above Epic, Azure DevOps
   Basic; see `Detected:` and the adapter) isn't created: log it with Tracker id `label:<label>`
   (Jira, for example `label:feature-shop-sign-up`) or `tag:<tag>` (Azure DevOps), URL `-`, `Pending:
   none`. Its stories take the epic as parent and carry that label or tag. A v1 or v2 feature there
   has no stories to carry it, so it goes into its epic's description under "Later features" (title,
   Size, Open questions) and is logged with Tracker id `in-epic:<epic local id>`.
4. Create each item with its parent link in the same call when the tracker allows it (see the
   adapter). Write its push-log row as soon as the call returns, before the next call, with `Pending`
   listing the links it still lacks: `parent` when the create call didn't link its parent, `deps` when
   its backlog `Depends on:` isn't `none`, `parent, deps` for both, else `none`.
5. A parent the create call didn't link: `link` it right away; as soon as that succeeds, remove
   `parent` from the row's `Pending`.
6. When every item exists: first every `parent` still pending, then every `deps`, with `link`. After
   each link succeeds, remove that value from the row's `Pending` (nothing left: `none`).

## Fields
What goes where is in the adapter. From `backlog.md`:
- Title: the heading's text after the id and the dash.
- Epic: Goal and Success metric in the description. Feature: Description, and for a v1 or v2 feature
  its Size and Open questions.
- Story: Story, Value, Out of scope, NFR and Open questions in the description; the acceptance
  criteria in the tracker's acceptance-criteria field when it has one, else under an "Acceptance
  criteria" heading in the description; Points and Priority in their fields when the tracker has them.
- Tags on every item: `nawah` and `nawah:<slug>` (Jira: `nawah-<slug>`), plus the release where the
  tracker keeps releases as tags or labels.

## push-log.md

```
# Push log — <slug>
Target: <tracker> <url> <tracker project>
Approved: <e> epics, <f> features, <s> stories, <YYYY-MM-DD>
Alternatives: <none | what the server couldn't do and what replaced it>

| Local id | Tracker id | URL | Created at | Hash | Pending |
|---|---|---|---|---|---|
| E1 | 1234 | https://… | 2026-10-16T19:40Z | 3355210114 | none |
```

- `push-log.md` lives in `ideas/<slug>/`. At each Gate 3 yes, before the first call, write its title,
  the `Target:` line, the `Approved:` line (the counts shown at Gate 3, today's date) and the table
  header; when it already exists, update `Approved:` and keep the rows.
- `Hash`: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/item-hash.sh" "<backlog.md>" <local id>`, at create
  time. `Created at`: `date -u +%Y-%m-%dT%H:%MZ`.
- `Pending`: the links still missing, as a list: `parent`, `deps`, `parent, deps`, or `none`.
- `Alternatives:` each operation the MCP server lacks and the MCP call used instead, from the
  adapter (for example `releases as labels: no milestone tool`, `dependencies as comments: no
  dependency tool`), written before the first call and shown in the push summary.

## Reruns and resume
- A local id already in the log is never created again.
- A row whose `Pending` isn't `none`: make each link it lists, as in step 6 of Order (`parent`
  before `deps`).
- A row whose hash no longer matches `item-hash.sh` now: list it as changed, with what changed, so
  the user can update it in the tracker; nawah doesn't edit pushed items.
- Nothing missing and nothing pending: start the reply with the words "Nothing to push", then the counts.

## Failure
Stop at the first failed call. Show the error, what exists (from the log), what remains, and the fix
if you know it. Set `Next:` in `state.md` to "`/nawah resume <slug>` continues the push" and stop.

## End
Show the counts per type, the link of the first epic (and a query or filter link when the tracker
has one), and the path of `backlog.csv`. `Step: done`. Then the run's ending checklist in `SKILL.md`.
