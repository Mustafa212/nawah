# Tracker: file

*nawah adapter. Writes the backlog to a Markdown file instead of a tracker, for trying nawah out and
for tests. Project file: `Tracker: file`, `URL: <path of the Markdown file>`, `Connection: none`.*

## File format

```
# Tracker file

## FILE-<n> — <Epic | Feature | Story>: <title>
Parent: <FILE-n or none>
Release: <MVP | v1 | v2>
Priority: <Must | Should | Could | ->
Points: <n | ->
Tags: nawah, nawah:<slug>
Depends on: <FILE-n, … | none>
Body:
<the item's lines from backlog.md, from the line after its heading to the line before the next heading, without the Parent, Release, Priority, Points and Depends on lines>
```

Items are appended, never rewritten, except the `Depends on:` line by `link`. Numbers continue from the
highest `FILE-<n>` in the file.

## Operations

| Operation | How |
|---|---|
| connect | The file's folder exists. If the file doesn't, create it with the line `# Tracker file`. |
| detect | Nothing to detect. Write `Detected: file` in the project file. |
| read_backlog | Every `## FILE-<n> — <type>: <title>` heading with its `Parent:` line. |
| create | Append one item in the format above (a heredoc, `cat >> "<file>" <<'EOF'`, or the Edit tool at the end of the file). Its id is `FILE-<n>`; its URL is `<path>#FILE-<n>`. The parent is written at create. |
| link | Dependencies: replace the `Depends on:` line in the item's header (the line above `Body:`) with the tracker ids. |
| csv_format | The generic CSV (`references/backlog.md`). |
