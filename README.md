# Modem keeper

Modem keeper is package consists of umtskeeper, sakis3g, and wvdial. You can use their separatly.

* **umtskeeper** - utility works with sakis3g for **traffic accounting** and works as **connection keeper**.
* **sakis3g** - script for connecting modem to internet.
* **wvdial** - simple dialer.

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

Also you can create umtskeeper config and call umtskeeper with param-file:

```bash
./umtskeeper --conf umtskeeper.conf
```

### sakis3g

Running params of sakis3g for MTS & Beeline:

* `USBMODEM`: if Huawei E352 or E392 `12d1:1506`
* `CUSTOM_APN`: `internet.mts.ru` or `internet.beeline.ru`
* `SIM_PIN`: usualy `0000`
* `APN_USER`: `mts` or `beeline`
* `APN_PASS`: `mts` or `beeline`

Manual running:

```bash
# For re-connect to internet:
sudo ./sakis3g ignore disconnect connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'

# For connect to internet:
sudo ./sakis3g ignore connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'

# For disconnect from internet:
sudo ./sakis3g ignore disconnect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'
```

Creating service:

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

WORK_DIR="."
LOG_PATH="$WORK_DIR/sakis3g.log"

cat <<EOF | tee -a $LOG_PATH
--------------------------------------------------------------------------------------------
$(date) Internet connection and checker script
--------------------------------------------------------------------------------------------
EOF

USBMODEM='12d1:1506'
CUSTOM_APN='internet.mts.ru'
SIM_PIN='0000'
APN_USER='mts'
APN_PASS='mts'

check_modem_connection() {
  while true; do
    if [[ $(lsusb -d $1) ]]; then break;
    else
      sleep 1
      echo "USB modem not connected." | tee -a $LOG_PATH
    fi
  done
}

echo "$(date) try connect" | tee -a $LOG_PATH
sudo $WORK_DIR/sakis3g connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM=$USBMODEM APN='CUSTOM_APN' CUSTOM_APN=$CUSTOM_APN SIM_PIN=$SIM_PIN APN_USER=$APN_USER APN_PASS=$APN_PASS >> $LOG_PATH# 2>&1
#sleep 10

if ping 8.8.8.8 -n -q -i 0.2 -c 3 -W 1 > /dev/null 2>&1
then echo "$(date) connected" | tee -a $LOG_PATH
fi

while true; do
  if ping 8.8.8.8 -n -q -i 0.2 -c 3 -W 1 > /dev/null 2>&1
  then sleep 1
  else
    while true; do
      check_modem_connection $USBMODEM
      echo "$(date) no internet -> try reconnect" | tee -a $LOG_PATH
      sudo $WORK_DIR/sakis3g ignore disconnect connect --sudo --console USBINTERFACE='0' OTHER='USBMODEM' USBMODEM=$USBMODEM APN='CUSTOM_APN' CUSTOM_APN=$CUSTOM_APN SIM_PIN=$SIM_PIN APN_USER=$APN_USER APN_PASS=$APN_PASS >> $LOG_PATH
      if ping 8.8.8.8 -n -q -i 0.2 -c 3 -W 1 > /dev/null 2>&1; then
        echo $(date) "connected" | tee -a $LOG_PATH
        break
      fi
    done
  fi
done
```

### wvdial

For install:

```bash
sudo apt install wvdial
```

For run use (`PATH_TO_SPECIFIC_CONF` by default `/etc/wvdial.conf`):

```bash
sudo wvdial <PATH_TO_SPECIFIC_CONF>
```

`wvdial` will try to auto create `/etc/wvdial.conf` in the first running. It may doesn't work. For fix this use this config:

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

Also I created simple internet keeper:

```bash
#!/bin/bash

WORK_DIR="."
LOG_PATH="$WORK_DIR/wvdial.log"

cat <<EOF | tee -a $LOG_PATH
--------------------------------------------------------------------------------------------
$(date) Internet connection and checker script
--------------------------------------------------------------------------------------------
EOF

while true; do
  if ping 8.8.8.8 -n -q -i 0.2 -c 3 -W 1 > /dev/null 2>&1; then
    sleep 1
  else
    while true; do
      echo "$(date) no internet -> try reconnect" | tee -a $LOG_PATH
      sudo pkill wvdial >> $LOG_PATH
      sudo wvdial >> $LOG_PATH
      if ping 8.8.8.8 -n -q -i 0.2 -c 3 -W 1 > /dev/null 2>&1; then
        echo "$(date) connected" | tee -a $LOG_PATH
        break
      fi
    done
  fi
done
```

## Other

* You can see usb devices using `lsusb`.
* Usualy you can see modems in `/dev/gsmmodem`.
* Tested on Huawei E352.
* For debug use `wvdial`
* Some OS doesn't consist driver, install `usb-modeswitch`
