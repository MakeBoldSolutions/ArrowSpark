#!/usr/bin/env bash
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
set -euo pipefail

SCRIPT_DIR=$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

repo_root=""
output=""
generated_at=""
stdout=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo-root) repo_root="$2"; shift 2 ;;
        --output) output="$2"; shift 2 ;;
        --generated-at) generated_at="$2"; shift 2 ;;
        --stdout) stdout=true; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[[ -n "$repo_root" ]] || repo_root=$(get_repo_root)

arguments=("$SCRIPT_DIR/../build_knowledge_index.py" --repo-root "$repo_root")
[[ -z "$output" ]] || arguments+=(--output "$output")
[[ -z "$generated_at" ]] || arguments+=(--generated-at "$generated_at")
[[ "$stdout" == false ]] || arguments+=(--stdout)
python3 "${arguments[@]}"
