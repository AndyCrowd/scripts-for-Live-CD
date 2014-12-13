#!/bin/bash
echo '${color grey}Networking:'
Excl="-v -e ^$ -e lo"
ifconfig |grep $Excl -e ^" "  | 
cut -d: -f1 | 
sed "s/^/Up:$color \$\{upspeed\ /m" | 
sed "s/$/ \} \$\{color grey\} - Down:$color \$\{downspeed/m" |
awk '{
printf $1 $2" "$3 $4" "$5" "$6" "$7" "$8 $9" "$3 "}\n"
}'
