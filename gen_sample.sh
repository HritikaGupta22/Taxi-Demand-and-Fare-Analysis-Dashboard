#!/bin/bash

# Last amended: Dec 17th, 2024

# Usage:
# ./gen_sample.sh /path/to/rev_sample.json [batch_size] [delay_in_ms] | kafkacat -b localhost:9092 -t mytest -K: -P

cd ~

if [ -z "$1" ]; then
    echo " "
    echo "No input JSON file specified."
    echo "Usage:"
    echo "./gen_sample.sh filenameWithPath [batch_size] [delay_in_ms] | kafkacat -b localhost:9092 -t mytest -K: -P"
    echo " "
    exit
fi

# File to read
INPUT_FILE="$1"

# Batch size (default: 100 rows per batch)
BATCH_SIZE=${2:-100}

# Optional delay in milliseconds (default: 0 for no delay)
DELAY_MS=${3:-0}

# Initialize a buffer
buffer=""

# Counter to track batch size
counter=0

# Read file line by line and send in batches
while read -r line; do
    buffer+="$line"$'\n'
    counter=$((counter + 1))

    if [ "$counter" -ge "$BATCH_SIZE" ]; then
        echo -n "$buffer"
        buffer=""
        counter=0
        if [ "$DELAY_MS" -gt 0 ]; then
            sleep $(bc <<< "scale=3; $DELAY_MS/1000")
        fi
    fi
done < "$INPUT_FILE"

# Send remaining lines in buffer
if [ -n "$buffer" ]; then
    echo -n "$buffer"
fi

