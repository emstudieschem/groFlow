#!/bin/bashAdd commentMore actions
# Author: Emily M. Cameron
# Date Started: 06/05/2025
# Version: 1.0.0

# Trialling with same file (P1Ta) but with different trajectories
# Date Started: 06/06/2025
# Version: 1.1.0

# Exit if any command fails
set -e

# === Static Input Files ===
GRO="P1Ta_ACN_start.gro"
INX="P1Ta_ACN.ndx"    # index file
GRP_INX="P1Ta"        # group from index to analyse
# === Loop Over Files ===
for TRAJ in P?T?_???_R?_cen*.xtc; do  # using wildcards to make sure all xtc filenames will work
    if [[ ! -f "$TRAJ" ]]; then
        echo "No matching trajectory files found!"
        exit 1
    fi

    # Parameter expansion syntax to remove a pattern from the end of a string
    # `${variable%%pattern}` removes the longest match of 'pattern' from the end of value in 'variable'
    FILENAME="${TRAJ%%.xtc}"    # example FILENAME = P1Ta_ACN_R1_center_skip_10
    echo "Filename: $FILENAME"

# === Check Required Files ===
if [[ ! -f "$GRO" ]]; then
    echo "GRO file $GRO not found!"
    exit 1
fi
    BASENAME="${FILENAME%%_cen*}"  # example BASENAME = P1Ta_ACN_R1
    echo "Basename: $BASENAME"

# === Loop Over Trajectories ===
for TRAJ in P1Ta_ACN_R?_center_skip_10.xtc; do
    if [[ ! -f "$TRAJ" ]]; then
        echo "No matching trajectory files found."

    GRO="${BASENAME}.gro"   # looks for e.g. P1Ta_ACN_R1.gro
    NDX="${BASENAME}.ndx"
    # Find matching group name from NDX
     GRPNAME="${TRAJ%%_*}"
     echo "Index group name: $GRPNAME"

    # === Check Required Files ===
    if [[ ! -f "$GRO" ]]; then
        echo "GRO file $GRO not found!"
        exit 1
    fi

    BASENAME="${TRAJ%%.xtc}"
    if [[ ! -f "$NDX" ]]; then
        echo "NDX file $NDX not found!"
        exit 1
    fi

    
    # Output files
    OUTFILE="${BASENAME}_gyrate.xvg"
    LOGFILE="${BASENAME}_gyrate.log"

    echo "Processing $TRAJ..."

    if [[ -f "$INX" ]]; then
        echo "$GRP_INX" | gmx gyrate -s "$GRO" -f "$TRAJ" -n "$INX" -o "$OUTFILE" > "$LOGFILE" 2>&1
    if [[ -f "$NDX" ]]; then
        echo "$GRPNAME" | gmx gyrate -s "$GRO" -f "$TRAJ" -n "$NDX" -o "$OUTFILE" > "$LOGFILE" 2>&1
    else
        echo "$GRP_INX" | gmx gyrate -s "$GRO" -f "$TRAJ" -o "$OUTFILE" > "$LOGFILE" 2>&1
        echo "$GRPNAME" | gmx gyrate -s "$GRO" -f "$TRAJ" -o "$OUTFILE" > "$LOGFILE" 2>&1
    fi

    echo "Calculating average Rg from $OUTFILE..."

    # Parse average Rg from the output
    # `awk` is a utility command used for pattern scanning and processing

    # !/^[@#]/ is a pattern condition in awk, which only applies to the command inside {...}, or in this case doesn't match (from `!`)
    # `^` anchors the pattern to the start of the line (e.g. `^@` means "line that starts with @")
    # `/^[@#]/` matches any line beginning with @ or #. Adding `!` to start means "lines that do not start with @ or #"
    # 
    # `$2` refers to the second column, where the Rg is
    # `sum += $2` will add each value to the running sum, `count` keeps track of how many lines
    # `END { if ...}` this block of code only runs after the previous has processed

    AVG_RG=$(awk '!/^[@#]/ { sum += $2; count++ } END { if (count > 0) print sum/count; else print "NA"}' "$OUTFILE")

    echo "Done: $TRAJ Average Rg = $AVG_RG nm"
    # Calculate the standard deviation of the Rg
    STDDEV=$(awk '!/^[@#]/ {sum += $2; sumsq += ($2)^2; count++} END {if (count > 0) mean = sum/count; print stddev = sqrt((sumsq/count) - (mean^2))}' "$OUTFILE")
    Add commentMore actions

    echo "Done: $TRAJ Average Rg = $AVG_RG ± $STDDEV nm"
done

# to initiate in terminal
# chmod +x automatic_radius_gyration_v2.sh

# to run
# ./automatic_radius_gyration_v2.sh
