# Tracker: GitHub Issues

*nawah adapter. Project file: `Tracker: github`, `URL: github.com/<owner>/<repo>`, `Connection: gh`
(or `mcp:<server>`).*

## Transport
The GitHub CLI: `gh api` with request bodies written to `ideas/<slug>/.push/body.json` and sent with
`--input`; responses read with `--jq`. MCP: the named server's issue tools.

## Operations

| Operation | How |
|---|---|
| connect | `gh auth status` succeeds, and `gh api repos/<owner>/<repo> --jq .permissions.push` prints `true`. |
| detect | Issue types: `gh api graphql -f query='query { repository(owner: "<owner>", name: "<repo>") { issueTypes(first: 25) { nodes { name } } } }'`; names for epic, feature and story present → issue types, else labels `type:epic`, `type:feature`, `type:story`. Milestones: `gh api "repos/<owner>/<repo>/milestones?state=all" --paginate --jq '.[] \| "\(.number) \(.title)"'`. Write `Detected: types <names \| labels>; milestones <MVP, v1, v2 present>`. |
| read_backlog | `gh issue list --repo <owner>/<repo> --state open --limit 500 --json number,title,labels,state`. |
| create | First, once per push: `gh label list --repo <owner>/<repo> --limit 500 --json name --jq '.[].name'`, then `gh label create <name> --repo <owner>/<repo>` (never `--force`: it rewrites an existing label) for each of `nawah`, `nawah:<slug>`, the `type:*` labels when types are labels, and `priority:must`, `priority:should`, `priority:could` that isn't listed; `gh api repos/<owner>/<repo>/milestones -f title=<MVP \| v1 \| v2>` for each release used that has no milestone. Then per item: `gh api repos/<owner>/<repo>/issues --method POST --input <body.json>` → `number`, `id`, `html_url`. Parent: `gh api repos/<owner>/<repo>/issues/<parent number>/sub_issues --method POST -F sub_issue_id=<child id>` (the `id`, not the number). Log the tracker id as `#<number> (id <id>)`. |
| link | Dependencies, as GitHub's own blocked-by links, so the issue shows as blocked: `gh api repos/<owner>/<repo>/issues/<number>/dependencies/blocked_by --method POST -F issue_id=<predecessor id>` for each predecessor (its `id` from `push-log.md`, not its number). On resume, first `gh api repos/<owner>/<repo>/issues/<number>/dependencies/blocked_by --jq '.[].id'` and skip the ones listed. If the endpoint fails (403, 404 or 410, for example on an older GitHub Enterprise Server), fall back to `gh issue comment <number> --repo <owner>/<repo> --body "Depends on #<n>, #<m>"` and say so in the push summary. A parent link that failed at create: the `sub_issues` POST from `create` again. |
| csv_format | GitHub has no CSV import: write the generic CSV and say so. |

## Create body

```json
{
  "title": "<title>",
  "body": "<markdown>",
  "labels": ["nawah", "nawah:<slug>", "priority:must"],
  "milestone": 1,
  "type": "Story"
}
```

- `type` only when issue types were detected; otherwise add the `type:*` label.
- `milestone` is the milestone's number for the item's release.
- Body: the item's block from `backlog.md` without its heading, with the acceptance criteria under
  `### Acceptance criteria` as a numbered list.
