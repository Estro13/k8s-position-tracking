#!/bin/bash

# Infinite loop
while true
do
    # Increment the request counter
        ((counter++))

    # Send a curl request to the target URL
    curl -s -o /dev/null http://localhost:31001/ >/dev/null 2>&1
#     curl http://localhost:31001/

    echo "Request count: $counter"
    # Sleep for 0.001 seconds (1 millisecond)
#    sleep 0.001
done
