#!/bin/bash

# Define a variable with a value
my_value="false"

# Check if the value is true (non-empty)
if [ true == "" ]; then
    echo "The value is true (non-empty)."
else
    echo "The value is false (empty)."
fi
