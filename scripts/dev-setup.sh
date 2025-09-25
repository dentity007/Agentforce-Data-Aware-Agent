#!/usr/bin/env bash
set -euo pipefail
aliasorg="${1:-agent-data-aware}"
sf org create scratch --definition-file config/project-scratch-def.json --alias "$aliasorg" --set-default --duration-days 7 --wait 10
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission -o "$aliasorg" || true
echo "Done. Open org: sf org open -o $aliasorg"
