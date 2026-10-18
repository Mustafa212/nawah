# nawah

**From a raw idea to a business report you can send, and a backlog in your tracker.**

nawah (نواة, a seed) is a Claude Code plugin. Give it an idea, new or for a product you already have,
and it:

1. thinks the idea through with you, in rounds of questions, until you approve a one-page **Idea Brief**;
2. researches the market, local and global competitors, prices and regulation, with a source for every claim;
3. writes a polished **report** for investors, management or a client (Arabic or English): market size,
   competition and positioning, revenue model and three-scenario financials, go-to-market, delivery plan
   and cost, a validation plan and risks, delivered as a PDF;
4. breaks it into **epics, features and user stories** with Given/When/Then acceptance criteria, checked
   by a reviewer that never saw your conversation;
5. pushes them to **Azure DevOps, Jira or GitHub Issues**, and always writes a CSV you can import anywhere.

You approve at three gates: the brief, the report, and the backlog with its exact push target. Nothing
reaches a tracker without your yes.

## Install

```
/plugin marketplace add Mustafa212/nawah
/plugin install nawah@nawah
```

## Use

| Command | Does |
|---|---|
| `/nawah <idea>` | Starts an idea. In a git repository it offers to apply the idea to that project. `--repo <path>` (repeatable), `--project <name>`, `--new`. |
| `/nawah resume [idea]` | Continues where you stopped. |
| `/nawah setup [project]` | A project file: its repositories and tracker. |
| `/nawah status` | Your ideas and where each one stands. |

## Requirements
- Claude Code, with web search for the research step.
- Edge, Chrome or Chromium for the PDF (or set `NAWAH_BROWSER`). Without one, you get the HTML report and
  print it yourself. Snap-packaged Chromium can't open files in hidden folders such as `~/.claude`: set
  `NAWAH_BROWSER` to another browser, or `NAWAH_HOME` to a visible folder.
- For a tracker: its MCP server, added at local scope in the project's folder (Azure DevOps, GitHub or
  Atlassian's; `/nawah setup` gives the command). nawah never handles a token.

## Trackers

| Tracker | Status |
|---|---|
| Markdown file | tested |
| GitHub Issues | experimental |
| Azure DevOps | experimental |
| Jira Cloud | experimental |

Experimental trackers are complete but haven't passed a live test yet.

## Where things are
Everything lives outside your repositories, in `~/.claude/nawah/` (or `$NAWAH_HOME`): `config.md`,
`projects/<project>.md`, and one folder per idea with its brief, research, report (HTML and one PDF per
approved version), backlog, CSV and push log.

## How the report stays honest
Every figure the report computes (unit economics, 36-month projections, break-even, ROI, duration, build
cost) comes from one data block through a tested model inside the page; the text binds to those values
instead of retyping them. The page checks itself: a missing source, an unknown figure or an empty
section shows an error instead of a broken report. Research figures carry citations; anything without a
source is marked as an estimate.

## Develop

```
node tests/model_test.js          # the financial and duration model
bash tests/report_sh_test.sh      # check / values / pdf in a headless browser
bash tests/template_test.sh       # the template in English and Arabic
bash tests/lint_backlog_test.sh   # the backlog lint
bash tests/item_hash_test.sh      # push-log checksums
bash tests/check.sh               # contracts between the files
bash tests/headless/<name>.sh     # headless Claude runs (cost tokens)
```

## Credits and license
MIT. See `NOTICE` for the methods and projects this draws on.
