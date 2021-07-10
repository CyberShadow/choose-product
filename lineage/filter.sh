#!/bin/bash
set -eEuo pipefail

script=$(cat script.jq)
cd lineage_wiki/_data/devices
yq -r -s "$script" ./* | column -ts $'\t'
