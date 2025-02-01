#!/bin/bash
set -eEuo pipefail

script=$(cat script.jq)
cd lineage_wiki/_data/devices
NIX_PATH=nixpkgs=$(~/libexec/nixpkgs-at-date 2023-07-01) nix-shell -p yq --run "$(printf '%q ' yq -r -s "$script" ./*)" | column -ts $'\t'
