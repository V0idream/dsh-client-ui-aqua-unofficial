#!/usr/bin/env bash
# Publish dsh-client-ui-aqua-unofficial to npm (Linux counterpart of publish.ps1).
# The manifest already carries the final name, the dsh.bundle.patch layer, and
# the files list; staging only strips devDependencies (workspace links must
# never ship) and then publishes the pre-built lib/ bundle.
#
# Usage:
#   ./publish.sh             # publish
#   ./publish.sh --dry-run   # inspect the staged tarball without publishing
set -euo pipefail
cd "$(dirname "$0")"

DRY=0
if [ "${1:-}" = "--dry-run" ]; then DRY=1; fi

rm -rf .npm-stage
mkdir -p .npm-stage
cp -r lib .npm-stage/
cp cordis.patch.yml README.md README.zh.md LICENSE .npm-stage/

python3 - <<'PY'
import json
with open('package.json', encoding='utf-8') as f:
    manifest = json.load(f)
manifest.pop('devDependencies', None)  # workspace links must never ship
with open('.npm-stage/package.json', 'w', encoding='utf-8') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)
    f.write('\n')
PY

cd .npm-stage
if [ "$DRY" = 1 ]; then
  npm publish --dry-run
else
  npm publish
fi
