---
name: git-workflow
description: Apply this project's commit message rules and human confirmation requirements before any Git operation, including read-only queries and operations through integrations.
---

# Git Workflow

This skill applies only to this project.

## 1. Commit Messages

All commit messages must be written in English and follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Title format: `type(scope)!: description`. The scope and `!` are optional. The body and footers are also optional; when present, they must be written in English and separated by blank lines as required by the specification.

- Use `feat` for features and `fix` for bug fixes. Other types, such as `docs`, `chore`, `refactor`, and `test`, are allowed according to the nature of the change.
- Indicate breaking changes with `!` before `:` or a `BREAKING CHANGE:` footer, followed by a description in English.
- Example: `docs: define link management business rules`.

## 2. Mandatory Human Confirmation

- AI agents must not initiate Git operations on their own. Before each operation, present the concrete action and wait for explicit human confirmation to execute it.
- This requirement includes queries such as `git status`, `git diff`, and `git log`, as well as local and remote operations that modify files, the index, history, branches, or configuration.
- Apply the same rule to CLIs, graphical interfaces, APIs, MCPs, scripts, and other tools performing Git operations or their equivalents on the repository. Do not bypass the requirement through another mechanism.
- A general request to implement, review, or fix something does not authorize Git operations. Confirmation must identify the authorized operation or concrete sequence; it does not extend to additional actions.
- A direct user request for a specific operation counts as human confirmation for that operation. Supporting queries and further operations are not implicitly authorized.
- Without confirmation, limit work to reading or editing files authorized for the task, preparing suggested commands or messages, and reporting which Git operations await confirmation. Do not modify metadata in `.git` directly.
