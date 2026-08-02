# DVC project layout & metafiles

## Directory map

```text
.dvc/
  config           # shared project config (remotes, core.*) — COMMIT
  config.local     # machine secrets/overrides — DO NOT COMMIT (gitignored)
  .gitignore       # ignores cache/tmp inside .dvc
  cache/           # content-addressed data (default) — DO NOT COMMIT
  tmp/             # ephemeral (experiments, locks)
  plots/           # internal plot templates cache (optional)
.dvcignore         # like gitignore for DVC tree walks — COMMIT
dvc.yaml           # stages + optional artifacts/metrics/params/plots — COMMIT
dvc.lock           # resolved hashes after repro/exp — COMMIT
params.yaml        # default hyperparameters file — COMMIT
*.dvc              # pointers from dvc add/import — COMMIT
metrics JSON/YAML  # if produced with -M / cache:false — usually COMMIT
data/, models/     # bulk files — gitignored; live in cache/remote
```

## What Git should contain

**Yes (meta + code):**

- Source code, notebooks (if small), configs
- `dvc.yaml`, `dvc.lock`, `params.yaml`
- All `*.dvc` pointer files
- `.dvc/config` (no secrets), `.dvc/.gitignore`, `.dvcignore`
- Metrics/plot **source files** when not cached (`-M`, `--plots-no-cache`)
- Empty-directory keepers / README under `data/` if useful

**No (bulk / secrets):**

- Dataset files, model weights, feature matrices
- `.dvc/cache/**`
- `.dvc/config.local`
- Cloud keys, service account JSON (use env or local config)

## `.dvc` pointer (from `dvc add`)

Human-readable YAML. Example shape:

```yaml
outs:
  - md5: 22a1a2931c8370d3aeedd7183606fd7f
    size: 14445097
    hash: md5
    path: data.xml
```

Directory targets use a `.dir` manifest in the cache (`nfiles`, cumulative size).

Agents **must not** invent `md5` values. Create/update via `dvc add`,
`dvc import*`, `dvc commit`.

## `dvc.yaml` stages

```yaml
stages:
  <name>:
    cmd: <str | [str, …]>     # required — what repro executes
    wdir: <path>              # optional, default .
    deps: [<paths>]
    outs:
      - <path>
      - <path>:
          cache: true|false
          persist: true|false
          remote: <remote-name>
          push: true|false
    params:
      - <key>
      - <file>:
          - <key>
      - <file>                # all keys
    metrics:
      - <path>:
          cache: false
    plots:
      - <path>
    frozen: true|false
    always_changed: true|false
    desc: <string>
    meta: <any>               # ignored by DVC machinery

artifacts:
  my-model:
    path: models/model.pkl
    type: model
    desc: Production classifier
    labels: [sklearn, v1]

metrics:
  - eval/metrics.json
params:
  - params.yaml
plots:
  - eval/loss.csv:
      x: step
      y: loss
```

Multiple `dvc.yaml` files are allowed (subdirs); targets can be
`path/to/dvc.yaml:stage_name`.

## `dvc.lock`

Written by DVC after successful runs. Records schema version, cmd, deps hashes,
params values, outs hashes. **Treat as generated** — commit it so others (and
CI) reproduce the same graph resolution; don’t hand-merge hashes.

## Cache link types

DVC may use reflinks, hardlinks, symlinks, or copies depending on filesystem
(`dvc config cache.type`). Workspace files may be read-only when linked to
cache — use `dvc unprotect` before in-place edits, then `dvc add` / `dvc commit`.

## `.dvcignore`

Same idea as `.gitignore`. Excluded paths are skipped when adding directories or
computing status. Use to ignore `raw/tmp`, `__pycache__`, etc. inside tracked
trees.

## Config keys agents touch most

```bash
dvc config core.autostage true     # auto git-add metafiles (optional)
dvc config cache.dir /fast/disk/dvc-cache
dvc remote add -d storage s3://…
```

List all: `dvc config -l` / docs for `core.*`, `cache.*`, `remote.*`.

## Relationship summary

```text
git checkout <rev>     →  metafiles change (which data version is desired)
dvc checkout / pull    →  workspace bulk files match those metafiles
dvc repro / exp run    →  recompute outs when deps/params/cmd changed; refresh lock
dvc push               →  ensure remote has cache objects for collaboration/CI
```
