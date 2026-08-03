# DVC command cheat sheet

Companion to `SKILL.md`. Prefer official `dvc <cmd> --help` for full flags.

## Project

| Command | Purpose |
|---------|---------|
| `dvc init` | Create `.dvc/` in a Git repo |
| `dvc init --subdir` | Init inside a subfolder monorepo style |
| `dvc version` | CLI + environment info |
| `dvc config -l` | List config (project + local + global) |
| `dvc config core.autostage true` | Auto `git add` metafiles DVC rewrites |
| `dvc config cache.dir PATH` | External cache directory |
| `dvc destroy` | Remove DVC meta (destructive; confirm with user) |

## Data tracking

| Command | Purpose |
|---------|---------|
| `dvc add PATH` | Track file/dir; write `PATH.dvc` + gitignore |
| `dvc add -f FILE PATH` | Force / custom `.dvc` location |
| `dvc commit [PATH]` | Hash & cache current outs without re-running cmd |
| `dvc checkout [PATH]` | Materialize workspace from cache using metafiles |
| `dvc remove PATH.dvc` | Stop tracking; optional keep/remove workspace files |
| `dvc move SRC DST` | Rename tracked data + update meta |
| `dvc unprotect PATH` | Make cache-linked files writable before edit |
| `dvc gc` | Garbage-collect unused cache (careful; often needs `-w`/`-c` flags) |

## Import / get external

| Command | Purpose |
|---------|---------|
| `dvc import URL PATH` | Import from another DVC/Git project (tracked dependency) |
| `dvc import-url URL [PATH]` | Import from HTTP/S3/… URL |
| `dvc update PATH.dvc` | Refresh an import to newer upstream |
| `dvc get URL PATH` | One-shot download without adding to this project |

## Pipelines

| Command | Purpose |
|---------|---------|
| `dvc stage add -n NAME ...` | Append stage to `dvc.yaml` |
| `dvc stage list` | List stages |
| `dvc repro [TARGET]` | Run changed pipeline stages |
| `dvc repro -f` | Force re-run |
| `dvc repro --dry` | Show what would run |
| `dvc dag` | Print pipeline DAG |
| `dvc freeze STAGE` / `dvc unfreeze STAGE` | Pin / unpin stage |
| `dvc params diff` | Diff params vs last run / another rev |

Common `dvc stage add` flags:

```text
-n, --name       stage name
-d, --deps       dependency path (repeatable)
-o, --outs       cached output
-O, --outs-no-cache   output not in cache
-m, --metrics    cached metrics file
-M, --metrics-no-cache  metrics kept in Git (usual)
-p, --params     params file or file:key
-w, --wdir       working directory for cmd
--plots / --plots-no-cache
```

## Remotes & sync

| Command | Purpose |
|---------|---------|
| `dvc remote add [-d] NAME URL` | Add remote; `-d` = default |
| `dvc remote list` | Show remotes |
| `dvc remote modify [--local] NAME KEY VALUE` | Configure remote (use `--local` for secrets) |
| `dvc remote default NAME` | Set default remote |
| `dvc remote remove NAME` | Drop remote entry |
| `dvc push [TARGET]` | Upload cache objects for current meta |
| `dvc pull [TARGET]` | Download missing objects + checkout |
| `dvc fetch [TARGET]` | Download to cache without checkout |
| `dvc status -c` | Compare workspace/cache to remote |

Remote URL schemes (examples):

```text
s3://bucket/prefix
gs://bucket/prefix
azure://container/prefix
ssh://user@host/path
/absolute/local/path
```

## Metrics, plots, status

| Command | Purpose |
|---------|---------|
| `dvc status` | Changed deps/outs vs lock/cache |
| `dvc metrics show` | Print metrics |
| `dvc metrics diff [A [B]]` | Compare metrics across revs/exps |
| `dvc plots show` | Render plots |
| `dvc plots diff` | Compare plots across revs |

## Experiments

| Command | Purpose |
|---------|---------|
| `dvc exp run` | Run pipeline as experiment |
| `dvc exp run -S section.key=value` | Override param for this exp |
| `dvc exp show` | Table of experiments |
| `dvc exp list` | List exp refs |
| `dvc exp apply EXP` | Apply exp results to workspace |
| `dvc exp branch EXP BRANCH` | Promote exp to a Git branch |
| `dvc exp remove EXP` | Delete exp |
| `dvc exp push/pull REMOTE EXP` | Share experiments via Git remote |

## Diagnosis

```bash
dvc doctor          # if available in version
dvc version
dvc config -l
dvc remote list
dvc status -v
dvc repro --dry
ls -la .dvc/config .dvc/config.local 2>/dev/null
```
