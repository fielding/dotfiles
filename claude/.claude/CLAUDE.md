# Task Tracking with tix

Use `tix` for issue tracking in any repo. Stores live in `.tix/` directories.
Check `tix ready` before starting work to see what's unblocked.

## Quick Reference

```
tix init [--prefix name]                    # create .tix/ in current dir
tix add "title" [-p 1-5] [-a who] [-t tag]  # create issue (1=highest pri)
tix list [--status open] [--assignee x]      # list issues
tix ready [--assignee x]                     # unblocked issues only
tix show <id>                                # full details + comments
tix status <id> open|in_progress|closed      # change status
tix edit <id> [--title/--body/--priority/--assignee/--add-tag/--rm-tag]
tix comment <id> -m "text" [--author x]      # add comment
tix dep add <id> blocks <target>             # id blocks target
tix search "query"                           # full-text search
```

All list commands support `--json`. Use `-q` to get just the ID back.

## Workflow

- Set issues to `in_progress` when starting, `closed` when done
- Use `dep add` to model blocking relationships between tasks
- Use comments to log decisions or progress
- Use tags for categorization (`bug`, `enhancement`, etc.)
- JSONL is the source of truth and is git-friendly — commit `.tix/issues.jsonl`
