#! /bin/bash

#18082017 smirart
#базовая установка
#21082017 smirart
#копирование из директории

WORK_DIRECTORY="/home/pi/modem_keeper"

sudo rsync -av --progress $WORK_DIRECTORY/sakis/* $WORK_DIRECTORY/run/ --exclude $WORK_DIRECTORY/sakis/sakis_install.sh
#sudo cp -r $WORK_DIRECTORY/sakis/* $WORK_DIRECTORY/ -i $WORK_DIRECTORY/sakis/sakis_install.sh

sudo chmod +x $WORK_DIRECTORY/run/sakis.sh
sudo chmod +x $WORK_DIRECTORY/run/sakis3g
sudo ln -fs $WORK_DIRECTORY/run/sakis.service /etc/systemd/system/
sudo systemctl enable $WORK_DIRECTORY/run/sakis.service
sudo systemctl try-restart sakis.service