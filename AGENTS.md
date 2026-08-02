# Notes for agents working in this repository

This repo **is** an Agent Skill package (not an application).

- Canonical skill path: `skills/dvc/`
- Keep `SKILL.md` under ~500 lines; put depth in `references/`
- `name` in frontmatter must stay `dvc` and match the folder name
- Do not put secrets, cloud keys, or personal remotes in the skill
- After substantive edits, update `metadata.version` in `SKILL.md` and the marketplace version if needed
- Prefer progressive disclosure: link to references instead of inlining long command tables
