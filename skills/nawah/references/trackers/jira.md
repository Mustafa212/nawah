# Tracker: Jira (Cloud)

*nawah adapter. Project file: `Tracker: jira`, `URL: https://<site>.atlassian.net`,
`Tracker project: <KEY>`, `Connection: token:<ENV_VAR>` with `User env: <ENV_VAR holding the account
e-mail>`, or `mcp:<server>`.*

Contents: Transport · Operations · Create body · CSV

## Transport
- `token:`: REST API v3 with curl: `curl -sS -u "$<USER_ENV>:$<ENV_VAR>" -H "Accept: application/json"
  -H "Content-Type: application/json"`, base `$URL/rest/api/3`. Bodies and responses in
  `ideas/<slug>/.push/` as in the Azure DevOps adapter.
- `mcp:<server>`: the named server's tools for projects, issue search, creating issues and linking.

## Operations

| Operation | How |
|---|---|
| connect | `GET /myself` returns 200 (`accountId`), then `GET /project/<KEY>` returns 200. 401: e-mail or token wrong; 404: key wrong or no access. |
| detect | `GET /project/<KEY>`: `issueTypes[]` with `hierarchyLevel`. A type at level 2 or above (an Initiative): Epic → that type, Feature → `Epic`. Otherwise Epic → `Epic`, Feature → label `feature-<feature-slug>`. Story → `Story`. Points: `GET /field` → the field named `Story point estimate` (team-managed) or `Story Points` (company-managed); keep its id (`customfield_…`), or none. Releases: `GET /project/<KEY>/versions`: versions named `MVP`, `v1`, `v2` present → fixVersions; else labels `release-mvp`, `release-v1`, `release-v2`. Write all of it to `Detected:`. |
| read_backlog | `POST /search/jql` with `{"jql": "project = <KEY> AND issuetype in (Epic, Story) AND statusCategory != Done ORDER BY key", "fields": ["summary", "status", "issuetype", "parent"], "maxResults": 100}`; repeat with `nextPageToken` until `isLast` is true. |
| create | `POST /issue` with the body below; use the response's `key`; URL `$URL/browse/<key>`. |
| link | Dependency: `POST /issueLink` with `{"type": {"name": "Blocks"}, "outwardIssue": {"key": "<predecessor>"}, "inwardIssue": {"key": "<dependent>"}}`: the predecessor blocks the dependent. |
| csv_format | Below. |

## Create body

```json
{
  "fields": {
    "project": {"key": "<KEY>"},
    "issuetype": {"name": "Story"},
    "summary": "<title>",
    "description": {"type": "doc", "version": 1, "content": []},
    "labels": ["nawah", "nawah-<slug>", "release-mvp", "priority-must", "feature-<feature-slug>"],
    "parent": {"key": "<parent key>"},
    "<points field id>": 3,
    "fixVersions": [{"name": "MVP"}]
  }
}
```

- Leave out what `Detected` doesn't support (points, fixVersions or the release label, the feature
  label) and `parent` for top-level items.
- Features as labels (no level above Epic): a feature isn't created (`references/push.md`); its
  stories take the epic as `parent` and carry the label `feature-<feature-slug>`.
- Labels have no spaces; slugs are kebab-case.
- Priority isn't set (schemes differ); it's the label `priority-must`, `-should` or `-could`.
- Description in Atlassian Document Format: one paragraph per field,
  `{"type": "paragraph", "content": [{"type": "text", "text": "Story: …"}]}`; then the criteria:
  `{"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Acceptance criteria"}]}`
  and `{"type": "orderedList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Given …"}]}]}]}`.
  Skip empty fields: Jira rejects empty text nodes.

## CSV
For System → External system import → CSV. Columns:
`Issue Id,Parent,Issue Type,Summary,Description,Labels,Labels,Labels,Story Points,Fix Version`.
`Issue Id` is a running number in the file; `Parent` is the parent row's `Issue Id`. Repeat the
`Labels` column once per label. Map the columns in the importer's field-mapping step.
