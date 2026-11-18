# Project Instructions

This repository contains product and technical specifications plus the initial frontend scaffold. Treat `spec.md` and `tech-spec.md` as the source of truth for application behavior.

## Startup Workflow

1. Read `progress.md` and `feature_list.json` to identify the active work and verified state.
2. Read `spec.md` for product behavior and `tech-spec.md` for implementation constraints relevant to the task.
3. When application modules exist, read the module document beside the code before editing it.
4. Run `./init.sh` for the harness, frontend, and backend checks currently configured.

## Working Rules

- Work on one feature at a time and keep changes within its acceptance criteria.
- Preserve security, ownership, URL validation, code reservation, transaction, and session invalidation requirements in the specifications.
- Do not mark a feature passing without recorded verification evidence.
- Keep module-specific constraints beside their code; update that module's document when behavior or verification changes.
- Read-only Git queries (such as `git status`, `git diff`, and `git log`) may be run without separate confirmation. Get explicit user authorization before Git operations that modify repository state. Before Git operations or commit preparation, read and apply `.agents/skills/git-workflow/SKILL.md`.

## Module Index

| Module path | Document | Verification command |
| --- | --- | --- |
| `frontend/` | [`frontend/frontend.md`](frontend/frontend.md) | `cd frontend && npm run lint && npm run typecheck && npm run build` |

## Definition of Done

A feature is complete only when its acceptance criteria are implemented, the applicable checks pass, and `feature_list.json` records evidence. Update `progress.md` before ending the session.

## Verification

Run `./init.sh` for the harness baseline and configured frontend checks. Add backend checks when `backend/` is scaffolded.

## Instruction Language

- Always write `AGENTS.md` files and all skill files in English, including skill metadata and supporting instructions.

## Git

Before Git operations or commit preparation, read and apply the local [git-workflow](.agents/skills/git-workflow/SKILL.md) skill. It requires commit messages in English following Conventional Commits. Read-only Git queries may be run without separate confirmation; state-changing Git operations require explicit human authorization. This requirement also applies to integrations and other tools.
