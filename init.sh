#!/usr/bin/env bash
set -e

echo "=== Harness baseline ==="
test -s AGENTS.md
test -s spec.md
test -s tech-spec.md
test -s progress.md
test -s session-handoff.md
test -s frontend/package-lock.json
test -d frontend/node_modules
test ! -d node_modules
node -e "const f = require('./feature_list.json'); if (f.project_type !== 'fullstack' || !Array.isArray(f.features) || f.features.length === 0) process.exit(1); for (const x of f.features) { if (x.type === 'api' && !['not_started','in_progress','blocked','passing'].includes(x.status)) process.exit(1); if (x.type === 'ui' && typeof x.passes !== 'boolean') process.exit(1); if (!['api','ui'].includes(x.type)) process.exit(1); }"
echo "Harness files and feature tracker are valid."
(cd frontend && npm run lint && npm run typecheck && npm run build)
