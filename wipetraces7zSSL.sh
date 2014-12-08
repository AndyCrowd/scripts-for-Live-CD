#!/bin/bash

####
#
# Creates a random encrypted files with a random password of the random predefined size 
# Meant to be used to destroy all on free space on SSD by overwriting it.
#                         ANTI SSD traces
#  
####

openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 \
count=1 2>/dev/null | base64)" -nosalt </dev/zero \
| 7z a -si -t7z -v${RANDOM}m -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on \
-p${RANDOM}"$(dd if=/dev/urandom bs=512 count=1)" test.wipe.${RANDOM}.file
