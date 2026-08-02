# DVC Agent Skill

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-open%20standard-blue)](https://agentskills.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An **[Agent Skills](https://agentskills.io/)** package that teaches coding agents how to use **[DVC](https://dvc.org/)** (Data Version Control) correctly:

- Version large datasets & models without bloating Git  
- Build reproducible pipelines (`dvc.yaml` / `dvc repro`)  
- Configure remotes (`push` / `pull`)  
- Run and compare experiments (`dvc exp`)  

Compatible with the open `SKILL.md` standard used by **Claude Code**, **OpenAI Codex**, **OpenCode**, **Cursor**, **Gemini CLI**, **GitHub Copilot**, **Windsurf**, and others that speak Agent Skills / [`npx skills`](https://skills.sh/).

Official DVC docs: [doc.dvc.org](https://doc.dvc.org/)

---

## Quick install (recommended)

Install into every Agent Skills–compatible tool the CLI detects:

```bash
# Install from this GitHub repo:
npx skills add Zijie-Tian/dvc-agent-skill

# Or from a local checkout:
npx skills add ./dvc-agent-skill
npx skills add /absolute/path/to/dvc-agent-skill
```

Target specific agents:

```bash
npx skills add Zijie-Tian/dvc-agent-skill --agent claude-code
npx skills add Zijie-Tian/dvc-agent-skill --agent codex
npx skills add Zijie-Tian/dvc-agent-skill --agent opencode
npx skills add Zijie-Tian/dvc-agent-skill --agent cursor
npx skills add Zijie-Tian/dvc-agent-skill --agent gemini-cli

# Global (user-level) install
npx skills add Zijie-Tian/dvc-agent-skill -g
```

Browse / discover skills: [skills.sh](https://skills.sh/)

---

## Manual install by platform

Copy the skill folder so the agent’s skill root contains `dvc/SKILL.md`.

| Agent | Project-local | User-global |
|-------|---------------|-------------|
| **Claude Code** | `.claude/skills/dvc/` | `~/.claude/skills/dvc/` |
| **OpenAI Codex** | `.agents/skills/dvc/` | `~/.agents/skills/dvc/` |
| **OpenCode** | `.opencode/skills/dvc/` or via `npx skills` | via `npx skills -g` |
| **Cursor** | via `npx skills` / `.cursor/` skills dir | via `npx skills -g` |
| **Gemini CLI** | via `npx skills` | via `npx skills -g` |
| **Grok / other SKILL.md hosts** | `.grok/skills/dvc/` (or host-specific root) | host-specific |

```bash
# From this repository root:

# Claude Code (project)
mkdir -p .claude/skills
cp -R skills/dvc .claude/skills/dvc

# Codex (project)
mkdir -p .agents/skills
cp -R skills/dvc .agents/skills/dvc

# Claude Code (user)
mkdir -p ~/.claude/skills
cp -R skills/dvc ~/.claude/skills/dvc

# Codex (user)
mkdir -p ~/.agents/skills
cp -R skills/dvc ~/.agents/skills/dvc
```

Restart or start a new agent session after installing.

### Claude Code plugin marketplace

```text
/plugin marketplace add Zijie-Tian/dvc-agent-skill
/plugin install dvc@dvc-agent-skills
```

(Requires the repo to be on GitHub; see [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).)

---

## Repository layout

```text
dvc-agent-skill/
├── README.md
├── LICENSE
├── skills.sh.json              # optional skills.sh grouping
├── .claude-plugin/
│   └── marketplace.json        # Claude Code marketplace entry
└── skills/
    └── dvc/                    # ← the installable skill (name == frontmatter name)
        ├── SKILL.md            # required (agentskills.io)
        ├── agents/
        │   └── openai.yaml     # Codex / OpenAI UI metadata
        └── references/         # progressive disclosure (load on demand)
            ├── commands.md
            ├── workflows.md
            └── project-layout.md
```

Format: [Agent Skills specification](https://agentskills.io/specification)

---

## What the skill teaches agents

| Topic | Behavior |
|-------|----------|
| Mental model | Git for metafiles; DVC cache/remote for bulk data |
| Data tracking | `dvc add`, `.dvc` pointers, gitignore rules |
| Pipelines | `dvc stage add`, `dvc.yaml`, `dvc repro`, DAG |
| Remotes | S3/GCS/Azure/SSH/local; secrets in `config.local` |
| Experiments | `dvc exp run/show/apply`, params & metrics |
| Pitfalls | No forged hashes, no `dvc add` on pipeline outs, etc. |

---

## Prerequisites on the machine the agent drives

```bash
# Git required
git --version

# DVC (pick one)
pipx install "dvc[s3]"          # example with S3
# uv tool install "dvc[all]"
# pip install "dvc[gs,azure,ssh]"

dvc version
```

Cloud remotes need the matching extra (`dvc[s3]`, `dvc[gs]`, `dvc[azure]`, …).

---

## Install

```bash
npx skills add Zijie-Tian/dvc-agent-skill
```

Optional: list on [skills.sh](https://skills.sh/) once the repo is public.

---

## Validate (optional)

If you have the reference validator:

```bash
# https://github.com/agentskills / skills-ref tooling
skills-ref validate ./skills/dvc
```

Checklist:

- [ ] `skills/dvc/SKILL.md` frontmatter has `name` + `description`
- [ ] Directory name is `dvc` (matches `name:`)
- [ ] Relative links to `references/` resolve
- [ ] No secrets in the skill tree

---

## License

MIT — see [LICENSE](LICENSE).

DVC itself is a separate project ([treeverse/dvc](https://github.com/treeverse/dvc)); this repository only ships agent instructions.
