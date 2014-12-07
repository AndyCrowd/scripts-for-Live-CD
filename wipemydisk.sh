#!/bin/bash

#PathToDevice='/dev/sdX(Y)'
PathToDevice="$1"
RepeatWipes="0"

if [ -b ${PathToDevice} ];then

for (( count=0; count<=${RepeatWipes}; count++ ));do

CC='[0-9]+$';
DeviceName=$(echo ${PathToDevice} | sed 's/[0-9$]//m')
PhysicalBlockSize=$(cat /sys/block/${DeviceName##*/}/queue/physical_block_size)
if [[ "${PathToDevice}" =~ $CC ]];then

PartStart=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/start)
PartSectors=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/size)
PartInByteSize=$((PhysicalBlockSize * PartSectors))

echo The ${PathToDevice} Is partition of the': ' ${DeviceName} 
echo PhysicalBlockSize = ${PhysicalBlockSize} , PartStart = ${PartStart} \
, PartSectors = ${PartSectors} , PartInByteSize = ${PartInByteSize}

#openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero \
#| pv -bartpes ${PartInByteSize} |
#dd bs=${PhysicalBlockSize} count=${PartSectors} of=/dev/${DeviceName##*/} seek=${PartStart} oflag=direct iflag=nocache 

#dd if=/dev/urandom |
#pv -bartpes ${PartInByteSize} |
#dd of=/dev/${DeviceName##*/} bs=${PhysicalBlockSize} count=${PartSectors} \
#seek=${PartStart} oflag=direct iflag=nocache

#dd if=/dev/zero |
#pv -bartpes ${PartInByteSize} | 
#dd of=/dev/${DeviceName##*/} bs=${PhysicalBlockSize} count=${PartSectors} \ 
#seek=${PartStart} oflag=direct iflag=nocache

else echo The ${PathToDevice} is a device'!';

partprobe ${PathToDevice}

DeviceSectors=$(cat /sys/block/${DeviceName##*/}/size)
DeviceInByteSize=$((PhysicalBlockSize * DeviceSectors))
echo PhysicalBlockSize = ${PhysicalBlockSize} , DeviceSectors = ${DeviceSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

#wipefs -a ${PathToDevice}
#dd if=/dev/zero bs=${PhysicalBlockSize} count=${DeviceSectors} | pv -bartpes ${DeviceInByteSize} | 
#dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache 

fi;
done;
#To verify 
#hexdump "${PathToDevice}"
else echo Is not a block'/'storage device'!'
fi;
