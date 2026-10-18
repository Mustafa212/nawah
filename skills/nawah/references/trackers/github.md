# Tracker: GitHub Issues

*nawah adapter. Project file: `Tracker: github`, `URL: github.com/<owner>/<repo>`, `Connection:
mcp:<server>` (GitHub's MCP server with the `default` and `labels` toolsets; `references/setup.md`).*

## Transport
The named server's tools, with `owner` and `repo` from `URL`. A write tool takes a `method`.

## Operations

| Operation | How |
|---|---|
| connect | `list_issues` (state open, one per page) and `list_label` succeed for the repository. A 401 or an empty answer: the server's token is missing or wrong (`references/setup.md`). |
| detect | Issue types: `list_issue_types`; names for epic, feature and story present → issue types, else labels `type:epic`, `type:feature`, `type:story`. Milestones: `ui_get` method `milestones`; `MVP`, `v1`, `v2` present → milestones, else the labels `release:MVP`, `release:v1`, `release:v2` (the server can't create milestones). Dependencies: whether the server lists `issue_dependency_write`. Write `Detected: types <names \| labels>; releases <milestones \| labels>; dependencies <links \| comments>`. |
| read_backlog | `list_issues`, state open, every page; `search_issues` with `repo:<owner>/<repo> is:issue is:open` when listing fails. |
| create | First, once per push: `list_label`, then `label_write` method `create` (never `update`: it rewrites an existing label) for each of `nawah`, `nawah:<slug>`, the `type:*` labels when types are labels, the `release:*` labels when releases are labels, and `priority:must`, `priority:should`, `priority:could` that isn't listed. Then per item: `issue_write` method `create` with the fields below and `parent_issue_number` for its parent, so the parent is linked in the same call → `number`, `id`, URL. Log the tracker id as `#<number> (id <id>)`. |
| link | Dependencies: with `issue_dependency_write`, mark the issue blocked by each predecessor (its `id` from `push-log.md`); on resume, first read the existing ones (`issue_dependency_read`) and skip them. Without it: `add_issue_comment` with "Depends on #<n>, #<m>". A parent link that failed at create: `sub_issue_write` method `add` with the child's `id`. |
| csv_format | GitHub has no CSV import: write the generic CSV and say so. |

## Create fields

| Field | Value |
|---|---|
| `title` | `<title>` |
| `body` | `<markdown>` |
| `labels` | `["nawah", "nawah:<slug>", "priority:must"]`, plus `type:*` and `release:*` labels where `Detected:` uses labels |
| `milestone` | the milestone's number for the item's release, when releases are milestones |
| `type` | `Story`, when issue types were detected |

- Body: the item's block from `backlog.md` without its heading, with the acceptance criteria under
  `### Acceptance criteria` as a numbered list.
- Releases as labels or dependencies as comments: write it on `push-log.md`'s `Alternatives:` line.
