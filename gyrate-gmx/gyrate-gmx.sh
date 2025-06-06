#!/bin/bash
# Author: Emily M. Cameron
# Date Started: 06/05/2025
# Version: 1.0.0

# Trialling with same file (P1Ta) but with different trajectories

# Exit if any command fails
set -e

# === Static Input Files ===
GRO="P1Ta_ACN_start.gro"
INX="P1Ta_ACN.ndx"    # index file
GRP_INX="P1Ta"        # group from index to analyse

# === Check Required Files ===
if [[ ! -f "$GRO" ]]; then
    echo "GRO file $GRO not found!"
    exit 1
fi

# === Loop Over Trajectories ===
for TRAJ in P1Ta_ACN_R?_center_skip_10.xtc; do
    if [[ ! -f "$TRAJ" ]]; then
        echo "No matching trajectory files found."
        exit 1
    fi

    BASENAME="${TRAJ%%.xtc}"
    OUTFILE="${BASENAME}_gyrate.xvg"
    LOGFILE="${BASENAME}_gyrate.log"

    echo "Processing $TRAJ..."

    if [[ -f "$INX" ]]; then
        echo "$GRP_INX" | gmx gyrate -s "$GRO" -f "$TRAJ" -n "$INX" -o "$OUTFILE" > "$LOGFILE" 2>&1
    else
        echo "$GRP_INX" | gmx gyrate -s "$GRO" -f "$TRAJ" -o "$OUTFILE" > "$LOGFILE" 2>&1
    fi

    echo "Calculating average Rg from $OUTFILE..."

    AVG_RG=$(awk '!/^[@#]/ { sum += $2; count++ } END { if (count > 0) print sum/count; else print "NA"}' "$OUTFILE")

    echo "Done: $TRAJ Average Rg = $AVG_RG nm"
done
