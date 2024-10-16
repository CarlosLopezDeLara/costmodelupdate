#!/bin/bash

# For extra precaution we are going to put the cost model parameters in the order determined by `ParamName.hs`,
# the authoritative source for the order and names of the cost model parameters.

OUTDIR="outputs"
mkdir -p "$OUTDIR"

PARAM_FILE="$OUTDIR/ParamName.hs"
MERGED_FILE="$OUTDIR/pv3-297-params-not-in-order.json"
OUTPUT_FILE="$OUTDIR/pv3-297-params-ordered.json"

wget https://raw.githubusercontent.com/IntersectMBO/plutus/refs/tags/1.36.0.0/plutus-ledger-api/src/PlutusLedgerApi/V3/ParamName.hs -O "$PARAM_FILE"


# Build the `pv3-297-params-ordered.json` file by reading and transforming `ParamName.hs`
# without changing the order of the parameters.

echo "{" > "$OUTPUT_FILE"

awk '
    function toLowerFirst(str) {                      # Function to lowercase the first letter
        return tolower(substr(str, 1, 1)) substr(str, 2)
    }
    found_block {                                     # If inside the block
        if (/^\s*$/) exit                             # Stop at the first empty line
        if (/^\s*--/) next                            # Skip comment lines
        if (/^\s*\|/) sub(/^\s*\|/, "")               # Remove leading "|"
        gsub(/^[[:space:]]+/, "")                     # Remove leading spaces
        param = toLowerFirst($0)                      # Convert the first letter to lowercase
        gsub(/'\''/, "-", param)                      # Replace single quotes with hyphens
        print param                                   # Print cleaned parameter name for next step
    }
    /data ParamName =/ {                              # Start when "data ParamName =" is found
        found_block = 1                               # Mark start of the block
        next                                          # Skip the line with "data ParamName ="
    }
' "$PARAM_FILE" | while read -r param; do
    value=$(jq -r --arg key "$param" '.[$key] // "null"' "$MERGED_FILE")

    echo "  \"$param\": $value," >> "$OUTPUT_FILE"
done

# Remove the last comma to ensure valid JSON
sed -i '$ s/,$//' "$OUTPUT_FILE"

# Close the JSON structure
echo "}" >> "$OUTPUT_FILE"

# Confirm completion
if [[ -s "$OUTPUT_FILE" ]]; then
    echo "Ordered JSON saved to $OUTPUT_FILE"
else
    echo "Failed to generate the ordered JSON. Please verify the input files."
fi
