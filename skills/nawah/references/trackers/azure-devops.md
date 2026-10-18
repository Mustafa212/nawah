# Tracker: Azure DevOps

*nawah adapter. Project file: `Tracker: azure-devops`, `URL: https://dev.azure.com/<org>`,
`Tracker project: <project>`, `Connection: mcp:<server>` (the Azure DevOps MCP server for that org;
`references/setup.md`).*

Contents: Transport · Operations · Create fields · CSV

## Transport
The named server's tools, which take an `action` argument. The local server (`@azure-devops/mcp`)
and the remote one (`mcp.dev.azure.com`) share the names below; where they differ, it says so.

## Operations

| Operation | How |
|---|---|
| connect | `core_list_projects` lists `$PROJECT`. Not listed: wrong project name, or the account has no access to it. |
| detect | `wit_work_item` `get_type` for `User Story` → Agile; else `Product Backlog Item` → Scrum; else `Requirement` → CMMI; else `Issue` → Basic. From the story type's fields: is `Microsoft.VSTS.Common.AcceptanceCriteria` there, and which points field (`Microsoft.VSTS.Scheduling.StoryPoints` in Agile, `…Effort` in Scrum and Basic, `…Size` in CMMI). Write `Detected: <process>; story type <type>; AC field <yes/no>; points <field>`. |
| read_backlog | WIQL `SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project AND [System.WorkItemType] IN (<the epic, feature and story types from `Detected:`; Basic has no Feature, so `'Epic', 'Issue'`>) AND [System.State] <> 'Removed' ORDER BY [System.Id]` through `wit_query` `wiql` (local server) or `wit_query_by_wiql` (remote, MCP Insiders); without either, `search_workitem` for the project's items. Then `wit_work_item` `get_batch` (up to 200 ids) for Id, Title, State, WorkItemType and Parent. |
| create | `wit_work_item_write` `create` with the type and the fields below. Use the result's `id` and its web URL. The parent goes on with `link` right after (`Pending: parent` until then). |
| link | `wit_work_item_link_write` `link` from the item: type `predecessor` to each item it depends on (`System.LinkTypes.Dependency-Reverse`), type `parent` to its parent (`System.LinkTypes.Hierarchy-Reverse`). |
| csv_format | Below. |

## Create fields

| Field | Value |
|---|---|
| `System.Title` | `<title>` |
| `System.Description` | `<HTML description>` |
| `Microsoft.VSTS.Common.AcceptanceCriteria` | `<ol><li>Given … When … Then …</li></ol>` |
| `<points field>` | `3` |
| `Microsoft.VSTS.Common.Priority` | `1` |
| `System.Tags` | `nawah; nawah:<slug>; MVP` |
| `System.AreaPath` | `<default area path>` |

- Leave out: the AC line when `Detected` says no AC field (the criteria go in the description under
  `<h3>Acceptance criteria</h3>`); points and priority for epics and features; the area path when
  there's no default; the parent link for items without a parent.
- Priority: Must 1, Should 2, Could 3.
- Basic process (no Feature type): a feature isn't created (`references/push.md`); a story's parent
  is its epic, and its feature becomes the tag `feature:<feature title>`.
- Description HTML: `<p><b>Story:</b> …</p><p><b>Value:</b> …</p><p><b>Out of scope:</b> …</p><p><b>NFR:</b> …</p><p><b>Open questions:</b> …</p>`;
  an epic: Goal and Success metric; a feature: Description. Escape `&`, `<` and `>` in the text.

## CSV
For Boards → Import work items. Columns:
`ID,Work Item Type,Title 1,Title 2,Title 3,Description,Acceptance Criteria,<points field name>,Priority,Tags`.
`ID` stays empty. The hierarchy comes from the title column: epics in `Title 1`, features in `Title 2`,
stories in `Title 3`, each row directly after its parent. Points field name: `Story Points` (Agile),
`Effort` (Scrum, Basic), `Size` (CMMI). Basic: stories in `Title 2` under their epic; no `Title 3`.
