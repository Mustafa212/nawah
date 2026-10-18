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
Connection: mcp:<server name> | none
Detected: <written by detect>
Defaults: <Azure DevOps area path, extra tags>
```

Each client or organisation gets its own project file; the plugin itself names none. `Connection:
none` is for the file tracker and for no tracker.

## Questions (one at a time; skip what's known)
1. Project name.
2. Repositories (paths), for existing-project mode; `none` for a new product.
3. Tracker: Azure DevOps / Jira / GitHub Issues / a Markdown file / none.
4. Where:
   - Azure DevOps: `https://dev.azure.com/<org>` and the project's name.
   - Jira: `https://<site>.atlassian.net` and the project key.
   - GitHub: `<owner>/<repo>`.
   - File: the path of the Markdown file.
5. Connection: an MCP server, local to this project (below).
6. Defaults: Azure DevOps area path; extra tags. Both optional.

## The MCP server
Trackers are reached only through an MCP server added at **local scope** in the project's folder:
it loads only in that project and stays private to the user, so each project talks to its own org or
site and nothing is committed. The folder is the first of `Repos:`; for a new product, the folder
nawah runs in.

1. **Look for one.** `claude mcp list`, then `claude mcp get <name>` for each server whose tools
   match the tracker. Offer the ones whose scope is local to this project and whose org, site or
   repository matches `URL`. Yes: `Connection: mcp:<name>`.
2. **None: give the command** for the tracker, filled in, with the name `<tracker>-<org, site or
   owner>`. The user runs it in their terminal from that folder (or as `! <command>` here), so any
   sign-in or token stays with them; nawah never asks for, reads or writes a token.

   | Tracker | Command | Then | Source |
   |---|---|---|---|
   | Azure DevOps | `claude mcp add --scope local --transport stdio ado-<org> -- npx -y @azure-devops/mcp <org> -d core work-items` | needs Node.js 20+; signs in with the Microsoft account on first use | github.com/microsoft/azure-devops-mcp, docs/GETTINGSTARTED.md |
   | Azure DevOps (remote, when the org has registered a Microsoft Entra app for Claude Code) | `claude mcp add --scope local --transport http ado-<org> https://mcp.dev.azure.com/<org> --client-id <client id> --callback-port 3118` | `/mcp` to sign in | learn.microsoft.com/azure/devops/mcp-server/remote-mcp-server |
   | GitHub | `claude mcp add --scope local --transport http github-<owner> https://api.githubcopilot.com/mcp/ -H "X-MCP-Toolsets: default,labels" -H 'Authorization: Bearer ${GITHUB_MCP_PAT}'` | a fine-grained PAT (Issues: read and write) in the env var `GITHUB_MCP_PAT`; the single quotes keep `${…}` for Claude Code to expand at start | github.com/github/github-mcp-server, docs/installation-guides/install-claude.md and docs/remote-server.md |
   | Jira | `claude mcp add --scope local --transport http jira-<site> https://mcp.atlassian.com/v2/mcp` | `/mcp` to sign in (OAuth 2.1) | support.atlassian.com/rovo/docs/getting-started-with-the-atlassian-remote-mcp-server |

3. **Restart.** Servers connect when a session starts, so the user restarts Claude Code in that
   folder and runs `/nawah resume` (or `/nawah setup` again). Check `claude mcp get <name>` shows
   the local scope and a connection, then write `Connection: mcp:<name>`.

**Migration.** A project file with `Connection: token:…` or `gh` (nawah before 1.4.0): say that
nawah now works through MCP only, give the step 2 command, and after the user's yes replace the line
with `Connection: mcp:<name>` and delete any `User env:` line.

## Connect and detect
Run the adapter's `connect`, then `detect`, and write the result to `Detected:`. Show the project file
and one table of how epics, features and stories will map. On failure show the error and the likely
cause: wrong URL or project, the server not connected in this session (restart in the project's
folder), not signed in (`/mcp`), or an empty or wrong token in the server's own config.

## Credentials
Sign-ins and tokens live in the MCP server's config, added by the user. A header token is written
as `${VAR}` for Claude Code to expand, never as a literal. nawah never prints a token, puts one in a
file or argument, or reads one from the environment.
