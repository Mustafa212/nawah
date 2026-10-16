# Setup — project files and tracker profiles

## When
`/nawah setup [project]`; from intake when an existing project has no project file; at Gate 3 when
the user wants to push and the idea has no project.

## Project file
`projects/<project>.md`, where `<project>` is a kebab-case name the user chooses (default: the
repository folder's name):

```
Project: <name>
Repos: <path>, <path> | none
Tracker: azure-devops | jira | github | file | none
URL: https://dev.azure.com/<org> | https://<site>.atlassian.net | github.com/<owner>/<repo> | <file path>
Tracker project: <project name or key>
Connection: mcp:<server name> | token:<ENV_VAR> | gh | none
User env: <ENV_VAR>          (Jira with a token only: the account's e-mail)
Detected: <written by detect>
Defaults: <Azure DevOps area path, extra tags>
```

Each client or organisation gets its own project file; the plugin itself names none.

## Questions (one at a time; skip what's known)
1. Project name.
2. Repositories (paths), for existing-project mode; `none` for a new product.
3. Tracker: Azure DevOps / Jira / GitHub Issues / a Markdown file / none.
4. Where:
   - Azure DevOps: `https://dev.azure.com/<org>` and the project's name.
   - Jira: `https://<site>.atlassian.net` and the project key.
   - GitHub: `<owner>/<repo>`.
   - File: the path of the Markdown file.
5. Connection:
   - an MCP server already connected for that org or site: list the connected servers whose tools
     match the tracker and offer them; or
   - a token in an env var: Azure DevOps PAT with Work Items (Read & write); Jira API token, plus the
     account e-mail in a second env var; or
   - GitHub: `gh`, logged in (`gh auth status`).
   Ask for the env var's **name** only, never the token. If it isn't set in this session
   (`printenv <NAME> >/dev/null`), tell the user how to set it (Windows: `setx <NAME> "<value>"`, then
   restart Claude Code; macOS/Linux: `export <NAME>=…` in the shell profile) and stop setup until
   they're back.
6. Defaults: Azure DevOps area path; extra tags. Both optional.

## Connect and detect
Run the adapter's `connect`, then `detect`, and write the result to `Detected:`. Show the project file
and one table of how epics, features and stories will map. On failure show the error and the likely
cause: wrong URL or project, token expired or missing a scope, MCP server not connected, `gh` not
logged in.

## Credentials
- The project file holds the env var's name, never its value.
- Reference the variable inside commands (`"$NAME"`); never echo it, never pass `-v` to curl, never
  write it to a file.
