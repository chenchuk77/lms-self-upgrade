#!/bin/bash

# printing to stdout for 10 minutes
#
for i in {1..600}; do
  echo "$(date) [$i/600]"
  sleep 1s
done

