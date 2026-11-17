# Project Instructions

This repository currently contains product and technical specifications; application code has not been scaffolded yet. Treat `spec.md` and `tech-spec.md` as the source of truth until implementation begins.

## Startup Workflow

1. Read `progress.md` and `feature_list.json` to identify the active work and verified state.
2. Read `spec.md` for product behavior and `tech-spec.md` for implementation constraints relevant to the task.
3. When application modules exist, read the module document beside the code before editing it. The module index below is intentionally empty until code is added.
4. Run `./init.sh`. At the planning stage it checks harness state; add actual frontend and backend checks when those projects are scaffolded.

## Working Rules

- Work on one feature at a time and keep changes within its acceptance criteria.
- Preserve security, ownership, URL validation, code reservation, transaction, and session invalidation requirements in the specifications.
- Do not mark a feature passing without recorded verification evidence.
- Keep module-specific constraints beside their code; update that module's document when behavior or verification changes.
- Read-only Git queries (such as `git status`, `git diff`, and `git log`) may be run without separate confirmation. Get explicit user authorization before Git operations that modify repository state. Before Git operations or commit preparation, read and apply `.agents/skills/git-workflow/SKILL.md`.

## Module Index

No application modules are present yet. When code is scaffolded, add one `<module-name>.md` beside each detected module and list its path, document, and verification command here.

## Definition of Done

A feature is complete only when its acceptance criteria are implemented, the applicable checks pass, and `feature_list.json` records evidence. Update `progress.md` before ending the session.

## Verification

Run `./init.sh` for the current harness baseline. Once `frontend/` and `backend/` exist, replace or extend this baseline with their real lint, typecheck, test, and build commands.

## Instruction Language

- Always write `AGENTS.md` files and all skill files in English, including skill metadata and supporting instructions.

## Git

Before Git operations or commit preparation, read and apply the local [git-workflow](.agents/skills/git-workflow/SKILL.md) skill. It requires commit messages in English following Conventional Commits. Read-only Git queries may be run without separate confirmation; state-changing Git operations require explicit human authorization. This requirement also applies to integrations and other tools.
