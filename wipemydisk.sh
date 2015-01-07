#/bin/bash
#PathToDevice='/dev/sdX(Y)'
PathToDevice="$1"
RepeatWipes="0"
ASK_confirm="1"

#
# TESTED ONLY IN ARCH LINUX
#

# Use on:
# Partition = Logical sectors only
# Disk = Physical sectors or Logical sectors

DeviceName=$(echo ${PathToDevice} | sed 's/[0-9$]//m')

if [ "${PathToDevice}"'XX' != 'XX'  ];then
if [ -b "${DeviceName}" ] ;then

CC='[0-9]+$';

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

if [ "$ASK_confirm" == "1"  ];then
read -r -p "Continue to run patterns to Destroy PARTITION /dev/${PathToDevice##*/}? [y/N] " answer
answer=${answer,,}
if [[ $answer =~ ^(yes|y)$ ]];then
ASK_confirm="0"
else
echo Canceled !!!
fi
fi

if [ ${ASK_confirm} == "0"  ];then
echo Starting at:
date

for (( count=0; count<=${RepeatWipes}; count++ ));do
echo Destroying with enabled patterns has begun !!!

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

done

echo Finished at:
date

fi

else echo The ${PathToDevice} is a device'!';

partprobe ${PathToDevice}

DeviceLogicSectors=$(cat /sys/block/${DeviceName##*/}/size)
DeviceInByteSize=$((UseLogicBlockSize * DeviceLogicSectors))
DevicePhysSectors=$((DeviceInByteSize / UsePhysBlockSize))

echo UseLogicBlockSize = ${UseLogicBlockSize} , DeviceLogicSectors = ${DeviceLogicSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

echo UsePhysBlockSize = ${UsePhysBlockSize} , DevicePhysSectors = ${DevicePhysSectors} \
, DeviceInByteSize = ${DeviceInByteSize}

if [ "$ASK_confirm" == "1"  ];then
read -r -p "Continue to run patterns to WIPE DEVICE /dev/${DeviceName##*/}? [y/N] " answer
answer=${answer,,}
if [[ $answer =~ ^(yes|y)$ ]];then
ASK_confirm="0"
else
echo Canceled !!!
fi
fi

if [ ${ASK_confirm} == "0"  ];then
echo Starting at:
date

for (( count=0; count<=${RepeatWipes}; count++ ));do
echo Wiping of the disk with enabled patterns is started
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
#dd if=/dev/urandom bs=${UsePhysBlockSize} \
#| gzip | bzip2 | xz -9 --format=raw | pv -bartpes ${DeviceInByteSize} \ 
#| dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UsePhysBlockSize} \
#count=${DevicePhysSectors}

#
# Use Physical Block Size & compressed AES-ssl data.
# High CPU usage but might be good to use on SSD. 
#
#openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/random bs=128 \
#count=1 2>/dev/null | base64)" -nosalt </dev/zero | xz -9 --format=raw | pv -bartpes ${DeviceInByteSize} \ 
#| dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UsePhysBlockSize} \ 
#count=${DevicePhysSectors}

#
# Use Physical Block Size & zeros
#
#dd if=/dev/zero bs=${UsePhysBlockSize} | pv -bartpes ${DeviceInByteSize} |
#dd of=/dev/${DeviceName##*/} seek=0 oflag=direct iflag=nocache bs=${UsePhysBlockSize} \ 
#count=${DevicePhysSectors}

done
echo Finished at:
date

fi;
fi;

#To verify after filled in disk with zeros
#hexdump "${PathToDevice}"
else echo 'Is not a block/storage device!'
fi;
else echo 'No block device is specified! Use something like /dev/sdX(Y)'
lsblk -o SIZE,NAME,FSTYPE,MODEL
echo chose one from above to destroy
fi;
