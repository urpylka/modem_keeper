#!/bin/bash

#18082017 smirart

#02102017 urpylka
#sleep 15
#sudo ifconfig wwx582c80139263 down
#sudo ifconfig wwan0 down

#19092017
WORK_DIRECTORY="/home/pi/modem_keeper"

if [[ -z $1 ]]
then
 echo
 echo "--------------------------------------------------------------------------------------------"
 echo $(date) "Internet connection and checker script"
 echo "Конфигурационный файл не задан"
 echo "--------------------------------------------------------------------------------------------"
 echo
 echo >> $WORK_DIRECTORY/run/sakis.log
 echo "--------------------------------------------------------------------------------------------" >> $WORK_DIRECTORY/run/sakis.log
 echo $(date) "Internet connection checker and switcher script started" >> $WORK_DIRECTORY/run/sakis.log
 echo "Конфигурационный файл не задан" >> $WORK_DIRECTORY/run/sakis.log
 echo "--------------------------------------------------------------------------------------------" >> $WORK_DIRECTORY/run/sakis.log
 echo >> $WORK_DIRECTORY/run/sakis.log
else
 source $1
echo
echo "--------------------------------------------------------------------------------------------"
echo $(date) "Internet connection and checker script"
echo $modem_name", "$operator_name
echo "--------------------------------------------------------------------------------------------"
echo
echo >> $WORK_DIRECTORY/run/sakis.log
echo "--------------------------------------------------------------------------------------------" >> $WORK_DIRECTORY/run/sakis.log
echo $(date) "Internet connection checker and switcher script started" >> $WORK_DIRECTORY/run/sakis.log
echo $modem_name", "$operator_name >> $WORK_DIRECTORY/run/sakis.log
echo "--------------------------------------------------------------------------------------------" >> $WORK_DIRECTORY/run/sakis.log
echo >> $WORK_DIRECTORY/run/sakis.log

#20092017
source ../other/check_modem.sh
check_modem_connection_log $WORK_DIRECTORY/run/sakis.log

echo $(date) "try connect"
echo $(date) "try connect" >> $WORK_DIRECTORY/run/sakis.log
sudo $WORK_DIRECTORY/run/sakis3g connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM=$USBMODEM APN='CUSTOM_APN' CUSTOM_APN=$CUSTOM_APN SIM_PIN=$SIM_PIN APN_USER=$APN_USER APN_PASS=$APN_PASS >> $WORK_DIRECTORY/run/sakis.log# 2>&1
#sleep 10
if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
 then
  echo $(date) "connected"
  echo $(date) "connected" >> $WORK_DIRECTORY/run/sakis.log
fi

while true
do
 if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
 then
  sleep 1
 else
  while true
  do
   check_modem_connection_log $WORK_DIRECTORY/run/sakis.log
   echo $(date) "no internet -> try reconnect"
   echo $(date) "no internet -> try reconnect" >> $WORK_DIRECTORY/run/sakis.log
   sudo $WORK_DIRECTORY/run/sakis3g ignore disconnect connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM=$USBMODEM APN='CUSTOM_APN' CUSTOM_APN=$CUSTOM_APN SIM_PIN=$SIM_PIN APN_USER=$APN_USER APN_PASS=$APN_PASS >> $WORK_DIRECTORY/run/sakis.log
   if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
   then
    echo $(date) "connected"
    echo $(date) "connected" >> $WORK_DIRECTORY/run/sakis.log
    break
   fi
  done
 fi
done
fi
