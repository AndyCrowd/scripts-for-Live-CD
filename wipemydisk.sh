#!/bin/bash
#PathToDevice='/dev/sdX(Y)'
PathToDevice="$1"
RepeatWipes="0"
#
# TESTED ONLY IN ARCH LINUX
#
if [ "${PathToDevice}"'XX' != 'XX'  ];then
if [ -b ${PathToDevice} ];then

for (( count=0; count<=${RepeatWipes}; count++ ));do

CC='[0-9]+$';
DeviceName=$(echo ${PathToDevice} | sed 's/[0-9$]//m')
UsePhysBlockSize=$(cat /sys/block/${DeviceName##*/}/queue/physical_block_size)
UseLogicBlockSize=$(cat /sys/block/${DeviceName##*/}/queue/logical_block_size)
if [[ "${PathToDevice}" =~ $CC ]];then
#PartAlignmentOffset=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/alignment_offset)
PartAlignmentOffset=0
PartStart=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/start)
PartSectors=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/size)
PartInByteSize=$((UseLogicBlockSize * PartSectors))

echo The ${PathToDevice} Is partition of the': ' ${DeviceName} 
echo UseLogicBlockSize = ${UseLogicBlockSize} , PartStart = ${PartStart} \
, PartSectors = ${PartSectors} , PartInByteSize = ${PartInByteSize}

#openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero \
#| pv -bartpes ${PartInByteSize} |
#dd bs=${UseLogicBlockSize} count=${PartSectors} of=/dev/${DeviceName##*/} \ 
#seek=$((PartStart + PartAlignmentOffset)) oflag=direct iflag=nocache 

#dd if=/dev/urandom bs=${UseLogicBlockSize} count=${PartSectors} |
#pv -bartpes ${PartInByteSize} |
#dd of=/dev/${DeviceName##*/} bs=${UseLogicBlockSize} \
#seek=$((PartStart + PartAlignmentOffset)) oflag=direct iflag=nocache

#dd if=/dev/zero bs=${UseLogicBlockSize} count=${PartSectors} |
#pv -bartpes ${PartInByteSize} | 
#dd of=/dev/${DeviceName##*/} bs=${UseLogicBlockSize} \ 
#seek=${PartStart} oflag=direct iflag=nocache

else echo The ${PathToDevice} is a device'!';

partprobe ${PathToDevice}

DeviceLogicSectors=$(cat /sys/block/${DeviceName##*/}/size)
DeviceInByteSize=$((UseLogicBlockSize * DeviceLogicSectors))
DevicePhysSectors=$((DeviceInByteSize / UsePhysBlockSize))

echo UseLogicBlockSize = ${UseLogicBlockSize} , DeviceLogicSectors = ${DeviceLogicSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

echo UsePhysBlockSize = ${UsePhysBlockSize} , DevicePhysSectors = ${DevicePhysSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

#wipefs -a ${PathToDevice}

#
# Use Logical Block Size
#
#dd if=/dev/zero bs=${UseLogicBlockSize} count=${DeviceLogicSectors} | pv -bartpes ${DeviceInByteSize} | 
#dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UseLogicBlockSize}

#
# Use Physical Block Size & compressed randomized data.
# High CPU usage but might be good to use on SSD. 
#
#dd if=/dev/urandom bs=${UsePhysBlockSize} count=${DevicePhysSectors} \
#| gzip | bzip2 | xz -9 --format=raw | pv -bartpes ${DeviceInByteSize} \ 
#| dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UsePhysBlockSize}

#
# Use Physical Block Size & zeros
#
#dd if=/dev/zero bs=${UsePhysBlockSize} count=${DevicePhysSectors} | pv -bartpes ${DeviceInByteSize} |
#dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UsePhysBlockSize}

fi;
done;
#To verify after filled in disk with zeros
#hexdump "${PathToDevice}"
else echo 'Is not a block/storage device!'
fi;
else echo 'No block device is specified! Use something like /dev/sdX(Y)'
lsblk -o SIZE,NAME,FSTYPE,MODEL
echo chose one from above to destroy
fi;
