# Tracker: Azure DevOps

*nawah adapter. Project file: `Tracker: azure-devops`, `URL: https://dev.azure.com/<org>`,
`Tracker project: <project>`, `Connection: token:<ENV_VAR>` (a PAT with Work Items read & write) or
`mcp:<server>`.*

Contents: Transport · Operations · Create body · CSV

## Transport
- `token:`: REST API 7.1 with curl: `curl -sS -u ":$<ENV_VAR>" -H "Accept: application/json"`.
  `$ORG` is the URL, `$PROJECT` the project name (spaces as `%20` in paths). Write each request body
  with the Write tool to `ideas/<slug>/.push/body.json` and send it with `--data-binary
  @<path>`; save the response with `-o ideas/<slug>/.push/response.json` and read the fields you
  need. Check the HTTP status with `-w '%{http_code}'`.
- `mcp:<server>`: the named server's tools for projects, work item types, queries, creating work
  items and linking them. Same fields and rules as below.

## Operations

| Operation | How |
|---|---|
| connect | `GET $ORG/_apis/projects/$PROJECT?api-version=7.1` returns 200 with the project's `id`. 401 or 203 (a sign-in page): the token is wrong or expired. 404: the project name is wrong. MCP: the server's project tool finds `$PROJECT`. |
| detect | `GET $ORG/$PROJECT/_apis/wit/workitemtypes?api-version=7.1`: a `User Story` type → Agile; `Product Backlog Item` → Scrum; `Requirement` → CMMI; otherwise `Issue` → Basic. Then `GET $ORG/$PROJECT/_apis/wit/workitemtypes/<story type>/fields?api-version=7.1` (type URL-encoded): is `Microsoft.VSTS.Common.AcceptanceCriteria` there, and which points field (`Microsoft.VSTS.Scheduling.StoryPoints` in Agile, `…Effort` in Scrum and Basic, `…Size` in CMMI). Write `Detected: <process>; story type <type>; AC field <yes/no>; points <field>`. |
| read_backlog | `POST $ORG/$PROJECT/_apis/wit/wiql?api-version=7.1` with `{"query": "SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project AND [System.WorkItemType] IN (<the epic, feature and story types from `Detected:`; Basic has no Feature, so `'Epic', 'Issue'`>) AND [System.State] <> 'Removed' ORDER BY [System.Id]"}`; then `GET $ORG/$PROJECT/_apis/wit/workitems?ids=<up to 200 ids>&fields=System.Id,System.Title,System.State,System.WorkItemType,System.Parent&api-version=7.1`. |
| create | `POST $ORG/$PROJECT/_apis/wit/workitems/$<type>?api-version=7.1` (the `$` is literal, the type URL-encoded: `$User%20Story`; put the URL in single quotes so the shell doesn't expand `$User`), header `Content-Type: application/json-patch+json`, body below. Use the response's `id` and `_links.html.href`. |
| link | Dependency (the item depends on a predecessor): `PATCH $ORG/$PROJECT/_apis/wit/workitems/<id>?api-version=7.1`, `Content-Type: application/json-patch+json`, body `[{"op": "add", "path": "/relations/-", "value": {"rel": "System.LinkTypes.Dependency-Reverse", "url": "$ORG/$PROJECT/_apis/wit/workItems/<predecessor id>"}}]`. A parent link that failed at create: the same with `System.LinkTypes.Hierarchy-Reverse` and the parent's URL. |
| csv_format | Below. |

## Create body

```json
[
  {"op": "add", "path": "/fields/System.Title", "value": "<title>"},
  {"op": "add", "path": "/fields/System.Description", "value": "<HTML description>"},
  {"op": "add", "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria", "value": "<ol><li>Given … When … Then …</li></ol>"},
  {"op": "add", "path": "/fields/<points field>", "value": 3},
  {"op": "add", "path": "/fields/Microsoft.VSTS.Common.Priority", "value": 1},
  {"op": "add", "path": "/fields/System.Tags", "value": "nawah; nawah:<slug>; MVP"},
  {"op": "add", "path": "/fields/System.AreaPath", "value": "<default area path>"},
  {"op": "add", "path": "/relations/-", "value": {"rel": "System.LinkTypes.Hierarchy-Reverse", "url": "$ORG/$PROJECT/_apis/wit/workItems/<parent id>"}}
]
```

- Leave out: the AC line when `Detected` says no AC field (the criteria go in the description under
  `<h3>Acceptance criteria</h3>`); points and priority for epics and features; the area path when
  there's no default; the relation for items without a parent.
- Priority: Must 1, Should 2, Could 3.
- Basic process (no Feature type): a story's parent is its epic, and its feature becomes the tag
  `feature:<feature title>`.
- Description HTML: `<p><b>Story:</b> …</p><p><b>Value:</b> …</p><p><b>Out of scope:</b> …</p><p><b>NFR:</b> …</p><p><b>Open questions:</b> …</p>`;
  an epic: Goal and Success metric; a feature: Description. Escape `&`, `<` and `>` in the text.

## CSV
For Boards → Import work items. Columns:
`ID,Work Item Type,Title 1,Title 2,Title 3,Description,Acceptance Criteria,<points field name>,Priority,Tags`.
`ID` stays empty. The hierarchy comes from the title column: epics in `Title 1`, features in `Title 2`,
stories in `Title 3`, each row directly after its parent. Points field name: `Story Points` (Agile),
`Effort` (Scrum, Basic), `Size` (CMMI). Basic: stories in `Title 2` under their epic; no `Title 3`.
