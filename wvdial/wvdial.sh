#!/bin/bash

#18082017 smirart

echo
echo "--------------------------------------------------------------------------------------------"
echo $(date) "Internet connection and checker script"
echo "--------------------------------------------------------------------------------------------"
echo
echo >> /home/pi/autocopter/3g_modem/wvdial.log
echo "--------------------------------------------------------------------------------------------" >> /home/pi/autocopter/3g_modem/wvdial.log
echo $(date) "Internet connection checker and switcher script started" >> /home/pi/autocopter/3g_modem/wvdial.log
echo "--------------------------------------------------------------------------------------------" >> /home/pi/autocopter/3g_modem/wvdial.log
echo >> /home/pi/autocopter/3g_modem/wvdial.log

while true
do
 if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
 then
  sleep 1
 else
  while true
  do
   echo $(date) "no internet -> try reconnect"
   echo $(date) "no internet -> try reconnect" >> /home/pi/autocopter/3g_modem/wvdial.log
   sudo pkill wvdial >> /home/pi/autocopter/3g_modem/wvdial.log
   sudo wvdial >> /home/pi/autocopter/3g_modem/wvdial.log
   if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
   then
    echo $(date) "connected"
    echo $(date) "connected" >> /home/pi/autocopter/3g_modem/wvdial.log
    break
   fi
  done
 fi
done
fi
