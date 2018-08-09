# Modem keeper

For using 3G/4G modems on Raspberry Pi you should run `umtskeeper.service`:

```bash
cat <<EOF | sudo tee /lib/systemd/system/umtskeeper.service > /dev/null
[Unit]
Description=UMTS-Keeper

[Service]
ExecStart=/home/pi/autocopter/3g_modem/umtskeeper --sakisoperators "USBINTERFACE='0' OTHER='USBMODEM' USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='internet.beeline.ru' SIM_PIN='0000' APN_USER='beeline' APN_PASS='beeline'" --sakisswitches "--sudo --console" --devicename 'Huawei' --log --nat 'no'
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

## Other

* You can see usb devices using `lsusb`.
* Usualy you can see modems in `/dev/gsmmodem`.
* Tested on Huawei E352.
* For debug use `wvdial`
* Some OS doesn't consist driver, install `usb-modeswitch`
