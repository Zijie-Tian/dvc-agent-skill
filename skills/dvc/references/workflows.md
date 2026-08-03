# DVC end-to-end workflows

Concrete sequences agents can follow. Adapt paths and remotes to the project.

---

## 1. Greenfield: init + track data + remote

**Goal:** New or existing Git repo; version a dataset without putting bytes in Git.

```bash
# 0. Ensure Git
git status

# 1. Init DVC (once)
dvc init
git add .dvc .dvcignore 2>/dev/null || git add .dvc
git commit -m "Initialize DVC"

# 2. Place bulk data (example)
mkdir -p data/raw
# ... user copies files into data/raw ...

# 3. Track
dvc add data/raw
git add data/raw.dvc data/.gitignore
git commit -m "Track raw data with DVC"

# 4. Remote (example: local shared path or S3)
dvc remote add -d storage s3://my-bucket/dvc-store
# credentials only local:
# dvc remote modify --local storage credentialpath ~/.aws/credentials

dvc push
git push   # metafiles to Git remote
```

**Done when:** `*.dvc` committed; bulk path gitignored; `dvc status -c` clean after push.

---

## 2. Clone on a new machine

```bash
git clone <repo-url> && cd <repo>
# install dvc + remote extras
dvc pull          # fetch + checkout bulk data
# if only cache wanted without workspace write: dvc fetch && dvc checkout
```

**Failure modes:** missing remote credentials; incomplete `dvc push` from author; wrong DVC extras for S3/GCS.

---

## 3. Simple ETL + train pipeline

**Layout:**

```text
src/prepare.py
src/train.py
params.yaml          # train: { lr, epochs, seed }
data/raw/            # dvc-tracked input (or stage dep only)
data/prepared/       # stage out
models/model.pkl     # stage out
metrics/eval.json    # metrics-no-cache
```

```bash
# params.yaml example
# train:
#   lr: 0.001
#   epochs: 10
#   seed: 42

dvc stage add -n prepare \
  -d src/prepare.py -d data/raw \
  -o data/prepared \
  python src/prepare.py

dvc stage add -n train \
  -d src/train.py -d data/prepared \
  -p train \
  -o models/model.pkl \
  -M metrics/eval.json \
  python src/train.py

dvc repro
dvc metrics show
dvc dag

git add dvc.yaml dvc.lock params.yaml metrics/eval.json data/.gitignore models/.gitignore
git commit -m "Add prepare→train DVC pipeline"
dvc push
```

**Change code or params:** edit → `dvc repro` → commit updated `dvc.lock` + metrics → `dvc push` if outs changed.

---

## 4. Experiment sweep (single param)

```bash
dvc exp run -S train.lr=0.01
dvc exp run -S train.lr=0.001
dvc exp run -S train.lr=0.0001
dvc exp show

# Pick best
dvc exp apply <exp_id>
git add dvc.lock params.yaml metrics models/.gitignore 2>/dev/null
git status   # review
git commit -m "Promote experiment lr=..."
dvc push
```

---

## 5. Update a tracked dataset in place

```bash
# If files are hardlinked/read-only from cache:
dvc unprotect data/raw

# Edit / replace files under data/raw
dvc add data/raw
git add data/raw.dvc
git commit -m "Update raw dataset"
dvc push
```

If `data/raw` is only a **pipeline dependency** and never `dvc add`'d, update via whatever produced it + `dvc repro` on downstream stages (or re-`dvc add` the external input).

---

## 6. Switch Git revision and match data

```bash
git checkout main~3
dvc checkout          # or dvc pull if objects missing locally
dvc status
```

Bulk workspace now matches metafiles at that commit (if cache/remote has objects).

---

## 7. Import versioned data from another DVC project

```bash
dvc import https://github.com/org/data-repo.git data/dataset --rev v1.2.0
git add dataset.dvc .gitignore
git commit -m "Import dataset v1.2.0 from data-repo"
dvc push   # if project remote should hold a copy
```

Later: `dvc update dataset.dvc` when upstream moves.

---

## 8. CI sketch

```yaml
# Conceptual — adapt to runner
# 1. checkout git
# 2. install dvc + cloud extra
# 3. configure remote credentials from CI secrets (env or dvc remote modify --local)
# 4. dvc pull
# 5. dvc repro
# 6. dvc metrics show / upload artifacts
# 7. optional: dvc push (if CI writes new outs)
```

Never bake cloud keys into committed `.dvc/config`.

---

## Decision: `dvc add` vs pipeline `outs`

| Situation | Use |
|-----------|-----|
| External/raw data not produced by repo code | `dvc add` |
| Output of a script you own | stage `outs` in `dvc.yaml` |
| Both (raw + derived) | `dvc add` raw; stage deps on raw; stage outs for derived |
| Metrics for Git diffs / PRs | `-M` / `metrics: cache: false` |
| Large intermediate you don't need in remote | `outs` with `push: false` or no-cache where appropriate |

---

## Recovery snippets

```bash
# Workspace out of sync with lock
dvc checkout
dvc status

# Missing data after clone
dvc pull

# Accidentally edited cached file in place without unprotect
dvc unprotect PATH
# fix content
dvc add PATH   # or dvc commit if pipeline out

# Lock conflict after merge
# prefer: pick one side of dvc.yaml, then dvc repro, commit new dvc.lock
```
