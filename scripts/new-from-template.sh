#!/usr/bin/env bash
# Create a file from a schema template in modules/schemas.
# Usage: new-from-template.sh <schema-name> <output>   (e.g. test-case -> modules/schemas/test-case.md)
set -euo pipefail

modules_dir="$(cd "$(dirname "$0")/.." && pwd)/modules"
schemas_dir="$(cd "$(dirname "$0")/.." && pwd)/schemas"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <schema-name> <output>" >&2
  exit 1
fi

template="$schemas_dir/$1.md"
output="$modules_dir/$2.md"

[ -f "$template" ] || { echo "Schema not found: $template" >&2; exit 1; }
[ ! -e "$output" ] || { echo "Refusing to overwrite: $output" >&2; exit 1; }

mkdir -p "$(dirname "$output")"
cp "$template" "$output"

echo "Created $output from $template"
