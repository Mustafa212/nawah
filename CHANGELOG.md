# Changelog

## 1.4.0 — 2026-10-18
- Trackers through MCP only: `Connection: mcp:<server>` replaces the token, curl and `gh` paths, and
  each adapter maps every operation to the server's tools. Why: one server per project, added at
  local scope in the project's folder, keeps each project on its own org or site, nothing in git, and
  no token in nawah's hands.
- Setup finds a local server that matches the tracker or gives the exact `claude mcp add --scope
  local` command from each server's own docs (Azure DevOps local or remote, GitHub's remote server,
  Atlassian's), then a restart and `/nawah resume`; a project file with `token:` or `gh` is offered
  the migration. Why: servers connect when a session starts, and the user, not nawah, runs the
  command that holds the sign-in or token.
- An operation a server lacks gets an MCP alternative, written on `push-log.md`'s new
  `Alternatives:` line: on GitHub, releases become `release:*` labels when the milestones don't
  exist, and dependencies become a comment when `issue_dependency_write` isn't offered. Why: the
  push stays MCP-only and the log shows what was replaced.
- Hard gate 7 (secrets): nawah never asks for, reads, prints or writes a token.
- The skill description keeps its triggers and what it delivers (723 → 497 characters), since it
  loads into every session. A trigger eval (3 prompts that must fire, 2 that must not, 2 runs each)
  passed on both the old and the new wording.

## 1.3.0 — 2026-10-18
- Backlog: full stories (Given/When/Then, points) for the MVP's features only. A v1 or v2 feature
  stops at its Size (S, M or L) and Open questions: what its stories wait for, usually the riskiest
  assumptions the MVP tests. Why: stories written before the MVP tests those assumptions go stale
  and sit in the tracker looking finished. The lint and the backlog reviewer check it; a tracker
  that keeps features as labels or tags lists the later features in their epic's description.
- Report model: `backlog.pointsByRelease` holds the MVP's points; releases without points keep the
  capability sizing in the duration and build cost, and the drift compares only the releases both
  estimate. Why: with MVP-only points, v1 and v2 would have dropped out of the duration.

## 1.2.0 — 2026-10-18
- Research: a figure a page quotes from another source is traced to that source and cited there (the
  quoting page is Medium at most), and a URL seen only in search results is Low. At merge, the lead
  opens the source of every figure the financial model uses and drops or downgrades a value that
  isn't on the page. Why: market sizes usually reach the web second-hand, with the wrong year,
  region or currency, and went straight into TAM/SAM/SOM.
- Brainstorm: a question of fact that the user doesn't know, or only accepts the recommendation on,
  goes into the brief as an assumption to verify, not as a fact. In existing-project mode, an
  answer that contradicts `snapshot.md` or the code is shown with both, and the user says which is
  right.
- GitHub: dependencies are native blocked-by links (`issues/<n>/dependencies/blocked_by`), so the
  issue shows as blocked; the "Depends on" comment is only the fallback when the endpoint fails.

## 1.1.0 — 2026-10-18
- Brainstorm asks in rounds: every question that doesn't hang on an open one, numbered, each with a
  recommended answer that "yes" accepts. Why: one question per message took many turns, and the
  "usually 4–8 questions" stop cut a complex idea short; it now ends when every brief section and
  every question its answers opened is answered.
- A look-and-feel question gets a throwaway HTML mockup in the idea's folder instead of more
  questions, because talking can't settle it.

## 1.0.0 — 2026-10-17
First release.
- `/nawah`: intake, existing-project snapshot, brainstorm and Idea Brief (Gate 1), cited research by four
  parallel researchers, a self-checking report template with a tested financial model and charts, PDF
  per approved version (Gate 2), backlog with a blind reviewer and a report update (Gate 3), and a
  resumable push.
- Trackers: Markdown file, GitHub Issues, Azure DevOps, Jira Cloud (status in the README).
- `/nawah resume`, `/nawah setup`, `/nawah status`.
