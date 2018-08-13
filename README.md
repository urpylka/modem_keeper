# Modem keeper

Modem keeper consists of umtskeeper, sakis3g, and wvdial. You can use their separatly.
* `umtskeeper` - utility works with sakis3g for traffic accounting.
* `sakis3g` - script for connection modem to internet.
* `wvdial` - dialer.

## Install
### umtskeeper
For using 3G/4G modems on Raspberry Pi you should run `umtskeeper.service`:

```bash
git clone https://github.com/urpylka/modem_keeper.git

cat <<EOF | sudo tee /lib/systemd/system/umtskeeper.service > /dev/null
[Unit]
Description=UMTS-Keeper

[Service]
ExecStart=$(pwd)/modem_keeper/umtskeeper --sakisoperators "USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'" --sakisswitches "--sudo --console" --devicename 'Huawei' --log --nat 'no'
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable umtskeeper
sudo systemctl start umtskeeper
```

For stop service use:

```bash
sudo systemctl stop umtskeeper
```

For disable service use:

```bash
sudo systemctl disable umtskeeper
```

### sakis3g

Running params of sakis3g for MTS & Beeline:
* `USBMODEM`: if Huawei E352 or E392 `12d1:1506`
* `CUSTOM_APN`: `internet.mts.ru` or `internet.beeline.ru`
* `SIM_PIN`: usualy `0000`
* `APN_USER`: `mts` or `beeline`
* `APN_PASS`: `mts` or `beeline`

```bash
USBMODEM='12d1:1506'
CUSTOM_APN='internet.mts.ru'
SIM_PIN='0000'
APN_USER='mts'
APN_PASS='mts'
```

For manual running:
```bash
sudo ./sakis3g ignore disconnect connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'

sudo ./sakis3g ignore connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'

sudo ./sakis3g ignore disconnect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'
```

Create service
```bash
git clone https://github.com/urpylka/modem_keeper.git

cat <<EOF | sudo tee /lib/systemd/system/umtskeeper.service > /dev/null
[Unit]
Description=Sakis modem connector

[Service]
ExecStart=$(pwd)/modem_keeper/sakis3g
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
```

Simple internet keeper for sakis3g:
```bash
#!/bin/bash
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
```

### wvdial

For install
```bash
sudo apt install wvdial
```

For run use, `PATH_TO_SPECIFIC_CONF` by default `/etc/wvdial.conf`:
```bash
sudo wvdial <PATH_TO_SPECIFIC_CONF>
```

`wvdial` will try to auto create `/etc/wvdial.conf` in the first running. It may doesn't work.

Create config
```bash
cat <<EOF | sudo tee /etc/wvdial.conf > /dev/null
[Dialer Defaults]
Init1 = ATZ
Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Stupid Mode = yes
Modem Type = Analog Modem
ISDN = 0
Phone = *99#
New PPPD = yes
Modem = /dev/gsmmodem
Username = default
Password = default
Baud = 57600
EOF
```

And also I create simple internet keeper:
```bash
#!/bin/bash

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
```

## Other

* You can see usb devices using `lsusb`.
* Usualy you can see modems in `/dev/gsmmodem`.
* Tested on Huawei E352.
* For debug use `wvdial`
* Some OS doesn't consist driver, install `usb-modeswitch`
