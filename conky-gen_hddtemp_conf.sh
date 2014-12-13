#!/bin/bash
Gsm=($(lsblk | grep -v -e '─' -e 'NAME' | awk '{print $1}'))

Titems=${#Gsm[@]}

Count=0
echo '$hr'
printf '${color grey}HDD temp'"\n"
while [ $Count -lt $Titems ];do
IFS="
"
CSmrt=($(smartctl --info '/dev/'${Gsm[Count]} |
grep -e 'SMART support' -e 'Device Model' -e 'User Capacity' |
cut -d: -f2 |
sed  -e 's/^ //m;s/^    //m;s/^   //m' |
cut -d "[" -f2 |
sed 's/\]//m'))

Dtmp=${CSmrt[3]}

if [ "$Dtmp" == "Enabled"  ] ; then
if [ 'XX'"$(smartctl -A '/dev/'${Gsm[Count]} | grep ' Temperature_Celsius')" != 'XX'  ];then

printf  ${Gsm[Count]}': ${hddtemp /dev/'${Gsm[Count]}'}C - Size: '${CSmrt[1]}"\n"
else
printf  ${Gsm[Count]}': Not supported - Size: '${CSmrt[1]}"\n"
fi;
fi;

Count=$((Count+1))
unset CSmrt
done;
