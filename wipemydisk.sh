#/bin/bash
#
#Script: License: GPL
#Patterns: are from forums and wiki
#
#Author: Andy Crowd
#PathToDevice='/dev/sdX(Y)'
PathToDevice="$1"
RepeatWipes="0"
ASK_confirm="1"
echo 'You must edit the script:
 1) Uncomment or add own wiping patterns.
 2) Adjust settings in variables:
   RepeatWipes="0"
   ASK_confirm="1"'
   echo 'Press any key to continue!'
keywait
#
# TESTED ONLY IN ARCH LINUX
#

# Use on:
# Partition = Logical sectors only
# Disk = Physical sectors or Logical sectors

DeviceName="$(echo ${PathToDevice} | sed 's/[0-9$]//m')"

if [ ! -z "${PathToDevice}"  ];then
if [ -b "${DeviceName}" ] ;then
CC='[0-9]+$';

UsePhysBlockSize=$(cat /sys/block/"${DeviceName##*/}"/queue/physical_block_size)
UseLogicBlockSize=$(cat /sys/block/"${DeviceName##*/}"/queue/logical_block_size)
if [[ "${PathToDevice}" =~ $CC ]];then
#PartAlignmentOffset=$(cat /sys/block/${DeviceName##*/}/${PathToDevice##*/}/alignment_offset)
#PartAlignmentOffset=0
PartStart=$(cat /sys/block/"${DeviceName##*/}/${PathToDevice##*/}"/start)
PartSectors=$(cat /sys/block/"${DeviceName##*/}/${PathToDevice##*/}"/size)
PartInByteSize=$((UseLogicBlockSize * PartSectors))

echo "The ${PathToDevice} Is partition of the: ${DeviceName} 
UseLogicBlockSize = ${UseLogicBlockSize}
PartStart = ${PartStart} 
PartSectors = ${PartSectors}  
PartInByteSize = ${PartInByteSize}"

ISMounted="$(lsblk /dev/${PathToDevice##*/} -o "NAME,MOUNTPOINT" | grep /)"
if [[ ! -z "$ISMounted"  ]];then
echo '!!! Not allowed to wipe mounted partition! Unmount and try again:'
echo "$ISMounted"
echo 'Unmount and try again!'
exit 1
fi

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
echo "The single partition wipe - round: ${RepeatWipes}"

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

else 

partprobe "${PathToDevice}"

DeviceLogicSectors=$(cat /sys/block/${DeviceName##*/}/size)
DeviceInByteSize=$((UseLogicBlockSize * DeviceLogicSectors))
DevicePhysSectors=$((DeviceInByteSize / UsePhysBlockSize))

echo "The ${PathToDevice} is a device'!'
UseLogicBlockSize = ${UseLogicBlockSize}
DeviceLogicSectors = ${DeviceLogicSectors}
DeviceInByteSize = ${DeviceInByteSize}
_
UsePhysBlockSize = ${UsePhysBlockSize}
DevicePhysSectors = ${DevicePhysSectors}
DeviceInByteSize = ${DeviceInByteSize}"

ISMounted="$(lsblk /dev/${PathToDevice##*/}  -o "NAME,MOUNTPOINT" | grep /)"
if [[ ! -z "$ISMounted"  ]];then
echo '!!! Not allowed to wipe! At least one partition is mounted:'
echo "$ISMounted"
echo 'Unmount and try again!'
exit 1
fi

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
echo "The whole devce wipe - round: ${RepeatWipes}"
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
