#!/bin/bash

# This script downloads the builtins and CEK machine cost model JSON files from the Plutus repository
# and merges them into a single JSON file, nested under the "PlutusV3" key.

OUTDIR="outputs"
mkdir -p "$OUTDIR"

BUILTINS_FILE="$OUTDIR/builtins.json"
CEK_FILE="$OUTDIR/cek.json"
OUTPUT_FILE="$OUTDIR/pv3-297-params-not-in-order.json"

wget https://raw.githubusercontent.com/IntersectMBO/plutus/refs/tags/1.36.0.0/plutus-core/cost-model/data/builtinCostModelC.json -O "$OUTDIR/builtinCostModelC.json"
wget https://raw.githubusercontent.com/IntersectMBO/plutus/refs/tags/1.36.0.0/plutus-core/cost-model/data/cekMachineCostsC.json -O "$OUTDIR/cekMachineCostsC.json"

# Process and flatten the JSON files
# shellcheck disable=SC2002
cat "$OUTDIR/builtinCostModelC.json" | jq 'walk(if type == "object" then del(.type) else . end)' \
    | jq '[paths(scalars) as $p | {key: ($p | join("-")), value: getpath($p)}] | from_entries' > "$BUILTINS_FILE"

# shellcheck disable=SC2002
cat "$OUTDIR/cekMachineCostsC.json" | jq 'walk(if type == "object" then del(.type) else . end)' \
    | jq '[paths(scalars) as $p | {key: ($p | join("-")), value: getpath($p)}] | from_entries' > "$CEK_FILE"

# Merge the JSON files and nest under "PlutusV3"
jq -s 'add | {PlutusV3: .}' "$BUILTINS_FILE" "$CEK_FILE" > "$OUTPUT_FILE"

# Confirm it is merged successfully
if [[ -s "$OUTPUT_FILE" ]]; then
    echo "Files merged successfully into $OUTPUT_FILE"
else
    echo "Failed to merge files. Please verify the input format."
fi

rm "$BUILTINS_FILE" "$CEK_FILE" "$OUTDIR/builtinCostModelC.json" "$OUTDIR/cekMachineCostsC.json"
