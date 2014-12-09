#!/bin/bash

#
# Creates rar with random password, file names, size, split name
# It removes files when carshes due disk full error and removes all created files
#
openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 \
count=1 2>/dev/null | base64)" -nosalt </dev/zero | pv | 
rar a -sistdin -p${RANDOM}"$(dd if=/dev/urandom bs=4086 count=1)" -v${RANDOM}m test.wipe.${RANDOM}.file
