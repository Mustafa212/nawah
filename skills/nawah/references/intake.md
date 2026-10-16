# Step 1 — Intake

Ask only what isn't known yet from the command, the project file or `config.md`. One question per
message; offer choices with the default first. Write each answer to `state.md` as you get it.

## The idea
The command's text after `/nawah` and its flags is the idea. None: ask "What's the idea, in a
sentence or two?"

## Slug and folder
`<slug>`: the idea's short title in kebab-case, ASCII letters, digits and hyphens only, at most 40
characters (translate or transliterate a non-Latin title into English). If `ideas/<slug>/` exists,
add `-2`, `-3`… Create the folder and `state.md` (format in `references/status.md`) with `Step: 1`.

## Mode
1. `--new`: new project.
2. `--project <name>`: read `projects/<name>.md`; existing project with its `Repos:`.
3. `--repo <path>` (repeatable): existing project with those repositories. Each path must be an
   existing folder; ask to fix a wrong one. If a project file lists the same repositories, use it.
4. Otherwise, if the current folder is inside a git repository (`git rev-parse --show-toplevel`
   succeeds): ask "Apply this idea to `<repo folder name>` (existing project), or treat it as a new
   project?" Default: existing.
5. Otherwise ask: new project, or an existing one (then ask for its path).

An existing project without a project file: offer `/nawah setup` now (it records the repositories
and the tracker). The user may skip it; the run then continues with `Project: none` (no backlog read,
no push, CSV only).

## The other answers (one question each; defaults from `config.md` where it has them)
- **Audience:** investor / management / client.
- **Report language:** formal Arabic (Modern Standard Arabic) / English. Default: `Default language`.
- **Backlog language:** English / the report's language. Default: English.
- **Target market:** the country or countries of the first customers. Default: `Default market`.
  Global competitors and the global market are always researched as well.
- **Currency:** the target market's currency (default) or another ISO code.
- **Team:** how many developers; their total monthly cost if known (otherwise step 4 researches it
  and it becomes an Estimate); their velocity in points per two-week sprint if the team has one.
- **Prepared by:** the name or company shown on the report's cover. Default: `git config user.name`.

## config.md
Create it on the first run if it's missing, from this run's answers, and tell the user it prefills
the next run:

```
# nawah — machine config
Default language: <ar | en>
Default market: <country>
Default currency: <ISO code>
```

Then: existing project → step 2 (`Step: 2`); new project → step 3 (`Step: 3`).
