#!/usr/bin/env bash
# Copyright (C) 2023 Benjamin Thomas Schwertfeger
# E-Mail: development@b-schwertfeger.de
# Github: https://github.com/btschwertfeger


INPUT_DIR="input_data"
BiasAdjustCXX="BiasAdjustCXX/build/BiasAdjustCXX"

mkdir -p bc_output performance_results

# get files
OBSH_FILES=($INPUT_DIR/obsh*)
SIMH_FILES=($INPUT_DIR/simh*)
SIMP_FILES=($INPUT_DIR/simp*)

TABLE_HEADER="resolution,jobs,time (seconds)"

for method in "delta_method" "linear_scaling" "variance_scaling" "quantile_mapping" "quantile_delta_mapping"; do
    echo $TABLE_HEADER >> performance_results/performance_BiasAdjustCXX_method-${method}.csv
done

variable="dummy"
kind="+"

# iterate over the scaling-based methods
for method in  "delta_method" "linear_scaling" "variance_scaling"; do
    # execute the program with 1..4 parallel jobs
    perf_fname="performance_results/performance_BiasAdjustCXX_method-${method}.csv"

    for i in `seq 1 10`; do
        for jobs in {1..4}; do
            # for every resoulution
            for resolution in ${!OBSH_FILES[*]}; do
                START=$(date +%s)
                $BiasAdjustCXX                          \
                    --ref "${OBSH_FILES[resolution]}"   \
                    --contr "${SIMH_FILES[resolution]}" \
                    --scen "${SIMP_FILES[resolution]}"  \
                    -o "bc_output/${variable}_${method}_kind${kind}${resolution}.nc" \
                    -v "dummy"                          \
                    -k "+"                              \
                    -m $method                          \
                    -p $jobs

                END=$(date +%s)
                DIFF=$(echo "$END - $START" | bc)
                resolution=`echo "${OBSH_FILES[resolution]}" | sed 's/input_data\/obsh-//' | sed 's/.nc//'`
                echo "$resolution,$jobs,$DIFF" >> $perf_fname
                rm bc_output/*
            done
        done
    done
done

# iterate over the distribution-based methods
for method in "quantile_mapping" "quantile_delta_mapping"; do

    # execute the program with 1..4 parallel jobs
    perf_fname="performance_results/performance_BiasAdjustCXX_method-${method}.csv"

    for i in `seq 1 10`; do
        for jobs in {1..4}; do
            # for every resoulution
            for resolution in ${!OBSH_FILES[*]}; do
                START=$(date +%s)
                $BiasAdjustCXX                          \
                    --ref "${OBSH_FILES[resolution]}"   \
                    --contr "${SIMH_FILES[resolution]}" \
                    --scen "${SIMP_FILES[resolution]}"  \
                    -o "bc_output/${variable}_${method}_kind${kind}${resolution}.nc" \
                    -v "dummy"                          \
                    -k "+"                              \
                    -m $method                          \
                    -q 250                              \
                    -p $jobs

                END=$(date +%s)
                DIFF=$(echo "$END - $START" | bc)
                resolution=`echo "${OBSH_FILES[resolution]}" | sed 's/input_data\/obsh-//' | sed 's/.nc//'`
                echo "$resolution,$jobs,$DIFF" >> $perf_fname
                rm bc_output/*
            done
        done
    done
done

rm -rf bc_output

exit 0
