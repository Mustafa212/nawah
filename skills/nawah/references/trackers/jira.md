# Tracker: Jira (Cloud)

*nawah adapter. Project file: `Tracker: jira`, `URL: https://<site>.atlassian.net`,
`Tracker project: <KEY>`, `Connection: mcp:<server>` (Atlassian's MCP server; `references/setup.md`).*

Contents: Transport · Operations · Create body · CSV

## Transport
The named server's Jira tools, each naming the site `URL` (or its cloud id, when the tool asks for
one). Atlassian's server lists only its primary tools at first: find the others with `discover` and
call them through `executeRead` or `executeWrite`.

## Operations

| Operation | How |
|---|---|
| connect | `listJiraProjects` lists `<KEY>`. Not listed: wrong key, no access, or not signed in (`/mcp`). |
| detect | `listJiraProjectIssueTypesMetadata` for `<KEY>`: issue types with their hierarchy level. A type at level 2 or above (an Initiative): Epic → that type, Feature → `Epic`. Otherwise Epic → `Epic`, Feature → label `feature-<feature-slug>`. Story → `Story`. Points: `getJiraIssueTypeMetaWithFields` for Story → the field named `Story point estimate` (team-managed) or `Story Points` (company-managed); keep its id (`customfield_…`), or none. Releases: `getJiraProjectVersions`: versions named `MVP`, `v1`, `v2` present → fixVersions; else labels `release-mvp`, `release-v1`, `release-v2`. Write all of it to `Detected:`. |
| read_backlog | `searchJiraIssuesUsingJql` with `project = <KEY> AND issuetype in (Epic, Story) AND statusCategory != Done ORDER BY key` (summary, status, issuetype, parent), every page. |
| create | `createJiraIssue` with the body below; use the result's `key`; URL `$URL/browse/<key>`. |
| link | Dependency: `createJiraIssueLink` with type `Blocks` (check the name with `listJiraIssueLinkTypes`), the predecessor as the outward issue and the dependent as the inward one: the predecessor blocks the dependent. |
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
- The fields `createJiraIssue` takes, with these values. Description: Markdown when the tool takes
  it; in Atlassian Document Format, one paragraph per field,
  `{"type": "paragraph", "content": [{"type": "text", "text": "Story: …"}]}`; then the criteria:
  `{"type": "heading", "attrs": {"level": 3}, "content": [{"type": "text", "text": "Acceptance criteria"}]}`
  and `{"type": "orderedList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Given …"}]}]}]}`.
  Skip empty fields: Jira rejects empty text nodes.

## CSV
For System → External system import → CSV. Columns:
`Issue Id,Parent,Issue Type,Summary,Description,Labels,Labels,Labels,Story Points,Fix Version`.
`Issue Id` is a running number in the file; `Parent` is the parent row's `Issue Id`. Repeat the
`Labels` column once per label. Map the columns in the importer's field-mapping step.
