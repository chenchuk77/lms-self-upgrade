#!/bin/bash

# printing to stdout for 10 minutes
#
for i in {1..600}; do
  echo "$(date) seq:[$i/600], args: [$@]"
  sleep 1s
done

