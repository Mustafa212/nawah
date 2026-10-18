# Step 6 — Decompose

Contents: Order of work · backlog.md format · Writing stories · Quality rules · Estimates and the report update · Blind review · CSV · Gate 3

## Order of work
1. Epics from the report's capabilities (one per major capability or user journey), features under
   them, stories under the MVP's features only (see "Later releases"). Existing-project mode: when new features belong under an epic the
   tracker already has, write that epic with its title and `Parent: existing <tracker id>`; the push
   doesn't create it again and puts its features under that item. Leave out what the tracker already
   has.
2. Write `ideas/<slug>/backlog.md` in the format below, in the backlog language.
3. Estimate every story; update the report (below).
4. Blind review, up to three rounds.
5. Write `backlog.csv`.
6. Gate 3.

## backlog.md format
These labels are a contract: the push and the tracker adapters read them.

```
# Backlog — <idea title>
Report version: <n>    Total points: <n>    Duration: <durationWeeks> weeks
Reference: <story id> = <points> points

## Traceability
| Brief MVP item | Stories |
|---|---|
| <item from the brief's "MVP scope: In"> | <story ids> |

## E1 — <title>
Goal: <text>
Success metric: <text>
Release: MVP | v1 | v2
Parent: none | existing <tracker id>

### F1.1 — <title>
Description: <text>
Release: MVP | v1 | v2
Size: S | M | L                     (v1 and v2 features only)
Open questions: <what its stories wait for>   (v1 and v2 features only)

#### S1.1.1 — <title>
Story: As a <role>, I want <capability>, so that <benefit>
Value: <text>
Priority: Must | Should | Could
Release: MVP | v1 | v2
Points: <1 | 2 | 3 | 5 | 8>
Depends on: <story ids, or none>
Acceptance criteria:
1. Given <context> When <action> Then <outcome>
2. Given <context> When <action> Then <outcome>
3. Given <context> When <action> Then <outcome>
Out of scope: <text or none>
NFR: <text or none>
Open questions: <text or none>
```

Headings use an em dash (`—`). Ids are numbered in order: `F2.3` is the third feature of `E2`,
`S2.3.1` the first story of `F2.3`.

## Later releases
Only MVP features get stories. A v1 or v2 feature stops at its `Size` (S, M or L, the report's
capability sizing) and `Open questions`: the decisions and results its stories wait for, usually the
riskiest assumptions the MVP tests. Stories written before the MVP tests those assumptions go stale
and sit in the tracker looking finished; they're written when that release is planned.

## Writing stories
- **Title:** what the user does ("Sign up with a phone number"), not a component ("OTP API").
- **Story:** a specific role from the brief; never "a user" alone. Always open with "As a" or "As an"
  ("As a counter staff member", not "As counter staff"): the format requires it, and the reviewer
  checks it (R8).
- **Value:** why it matters, tied to the brief's problem or a report figure.
- **Acceptance criteria:** numbered, each `Given … When … Then …` on one line, with an observable
  outcome (a message, a state, a number, a time limit) and concrete values ("within 60 seconds", "3
  wrong attempts"). At least three: the main path, the most important edge case, the most important
  error.
- **Out of scope:** what a reader might assume is included but isn't.
- **NFR:** performance, security, accessibility, localisation, when they apply to this story.
- **Open questions:** anything still undecided. A story with open questions isn't ready; Gate 3 lists
  it.

## Quality rules
1. INVEST: independent where possible, negotiable, valuable, estimable, small, testable.
2. At least three acceptance criteria in Given/When/Then.
3. Points 1, 2, 3, 5 or 8. More than 8: split it by workflow step, business rule, data variation or
   interface.
4. Every brief "MVP scope: In" item maps to at least one story; every story is under an MVP feature,
   every feature under an epic; every MVP feature has at least one story.
5. `Depends on` names existing stories, without cycles; an MVP story never depends on a v1 or v2 one.
6. No duplicates within the backlog or, in existing-project mode, with the tracker's backlog.
7. An MVP feature's release is the earliest of its stories'; an epic's, the earliest of its features'.

## Estimates and the report update
- Pick a typical story as the reference (3 points) and size the rest against it; one point is about
  half an ideal developer-day.
- In `report.html`, set the data block's `backlog.pointsByRelease` to the MVP's points (`{ "MVP": <n> }`;
  v1 and v2 keep the capability sizing, and the drift compares the MVP alone), raise
  `meta.version` by one, update the `delivery` section's text if it describes the old range, and run
  `report.sh check` until `ok`.
- `bash "${CLAUDE_PLUGIN_ROOT}/scripts/report.sh" values "<report.html>"`: read `durationWeeks`,
  `sizedWeeks`, `buildCost` and `drift` (the raw `drift` number is in the JSON). Write the backlog
  header's Duration from `durationWeeks`.
- The report's figures now follow the backlog. Gate 3 shows the change; a drift above 0.2 (20 %) is
  flagged at the top of the Gate 3 summary.

## Blind review
1. Dispatch `nawah:backlog-reviewer` with: the path of `brief.md`, the path of `backlog.md`, and in
   existing-project mode the tracker's existing items inside `<tracker>` … `</tracker>`. Nothing from
   the conversation.
2. A malformed report (no findings table, or rows without a rule): send it back once.
3. Triage every finding in your reply, as a table: `Finding | Fix or reject | Reason`. A rejection
   needs a concrete reason (why the rule doesn't apply here), never "fine as is".
4. Apply the fixes. Round 2 and 3: a fresh reviewer with the same inputs plus the rejected findings
   inside `<rejected>` … `</rejected>`. Stop when a round has no finding you accept, or after round 3;
   what is still open goes to Gate 3.

## CSV
Write `ideas/<slug>/backlog.csv` before Gate 3: in the import format of the project's tracker (its
adapter's `csv_format`), or the generic format when there is no tracker or it is `file`:

```
ID,Parent ID,Type,Title,Description,Acceptance Criteria,Priority,Points,Release,Tags
```

`ID` and `Parent ID` are the local ids (`E1`, `F1.1`, `S1.1.1`). A v1 or v2 feature's Size and Open
questions go in its Description. Quote every field with `"`, double
any `"` inside, keep line breaks inside the quotes, UTF-8. The header line is written exactly as
shown, without quotes.

## Gate 3
Show, in this order:
1. If the drift is above 20 %: "The backlog changes the report: <sizedWeeks> → <durationWeeks>
   weeks, build cost now <buildCost>."
2. Counts: epics and features per release, the MVP's stories and points; duration.
3. Open review findings and stories with open questions.
4. The report update: version <n>, what changed.
5. The exact target: "<e> epics, <f> features, <s> stories → <tracker> `<url>` / `<project>`, tags
   <the tags or labels every item gets: `nawah`, `nawah:<slug>`; Jira `nawah`, `nawah-<slug>`>".
   When the tracker keeps features as labels (Jira without a level above Epic) or tags (Azure DevOps
   Basic), say "<f> features as labels" (or "as tags"): they aren't created. GitHub: also the labels
   and milestones the push will create because they don't exist yet. No tracker: "No tracker: the
   backlog and `backlog.csv` only."
6. Ask: "Approve the backlog, report version <n> and this push?"

On yes: render `report-v<n>.pdf` (as at Gate 2), `Gates: … backlog <date>`, `Step: 7` (or `done` when
there's no tracker); with a tracker, write `push-log.md`'s header with its `Approved:` line
(`references/push.md`) before the first call, then push.
