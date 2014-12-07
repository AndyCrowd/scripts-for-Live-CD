#!/bin/bash
#PathToDevice='/dev/sdX(Y)'
PathToDevice="$1"
RepeatWipes="0"

if [ ${PathToDevice}'XX' != 'XX'  ];then
if [ -b ${PathToDevice} ];then

for (( count=0; count<=${RepeatWipes}; count++ ));do

CC='[0-9]+$';
DeviceName=$(echo ${PathToDevice} | sed 's/[0-9$]//m')
#UseBlockSize=$(cat /sys/block/${DeviceName##*/}/queue/physical_block_size)
UseBlockSize=$(cat /sys/block/${DeviceName##*/}/queue/logical_block_size)
if [[ "${PathToDevice}" =~ $CC ]];then
PartAlignmentOffset=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/alignment_offset)
PartStart=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/start)
PartSectors=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/size)
PartInByteSize=$((UseBlockSize * PartSectors))

echo The ${PathToDevice} Is partition of the': ' ${DeviceName} 
echo UseBlockSize = ${UseBlockSize} , PartStart = ${PartStart} \
, PartSectors = ${PartSectors} , PartInByteSize = ${PartInByteSize}

#openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero \
#| pv -bartpes ${PartInByteSize} |
#dd bs=${UseBlockSize} count=${PartSectors} of=/dev/${DeviceName##*/} \ 
#seek=$((PartStart + PartAlignmentOffset)) oflag=direct iflag=nocache 

#dd if=/dev/urandom |
#pv -bartpes ${PartInByteSize} |
#dd of=/dev/${DeviceName##*/} bs=${UseBlockSize} count=${PartSectors} \
#seek=$((PartStart + PartAlignmentOffset)) oflag=direct iflag=nocache

#dd if=/dev/zero |
#pv -bartpes ${PartInByteSize} | 
#dd of=/dev/${DeviceName##*/} bs=${UseBlockSize} count=${PartSectors} \ 
#seek=${PartStart} oflag=direct iflag=nocache

else echo The ${PathToDevice} is a device'!';

partprobe ${PathToDevice}

DeviceSectors=$(cat /sys/block/${DeviceName##*/}/size)
DeviceInByteSize=$((UseBlockSize * DeviceSectors))
echo UseBlockSize = ${UseBlockSize} , DeviceSectors = ${DeviceSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

#wipefs -a ${PathToDevice}
#dd if=/dev/zero bs=${UseBlockSize} count=${DeviceSectors} | pv -bartpes ${DeviceInByteSize} | 
#dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache 

fi;
done;
#To verify 
#hexdump "${PathToDevice}"
else echo 'Is not a block/storage device!'
fi;
else echo 'No block device is specified! Use something like /dev/sdX(Y)'
lsblk -o SIZE,NAME,FSTYPE,MODEL
echo chose one from above to destroy
fi;
