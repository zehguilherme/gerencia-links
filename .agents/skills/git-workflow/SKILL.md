---
name: git-workflow
description: Apply this project's commit message rules and human confirmation requirements before state-changing Git operations and operations through integrations.
---

# Git Workflow

This skill applies only to this project.

## 1. Commit Messages

All commit messages must be written in English and follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Title format: `type(scope)!: description`. The scope and `!` are optional. The body and footers are also optional; when present, they must be written in English and separated by blank lines as required by the specification.

- Use `feat` for features and `fix` for bug fixes. Other types, such as `docs`, `chore`, `refactor`, and `test`, are allowed according to the nature of the change.
- Indicate breaking changes with `!` before `:` or a `BREAKING CHANGE:` footer, followed by a description in English.
- Example: `docs: define link management business rules`.

## 2. Read-Only Queries and Human Confirmation

- Read-only Git queries, including `git status`, `git diff`, and `git log`, may be run without separate human confirmation.
- State-changing Git operations require explicit human authorization before execution. A direct user request for a specific operation counts as authorization for that operation; it does not authorize unrelated state changes.
- Apply these rules to CLIs, graphical interfaces, APIs, MCPs, scripts, and other tools performing Git operations or their equivalents on the repository.
- Do not modify `.git` metadata directly.
