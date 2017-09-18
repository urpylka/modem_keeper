#! /bin/bash
sudo chmod +x /home/pi/autocopter/3g_modem/sakis3g
sudo chmod +x /home/pi/autocopter/3g_modem/umtskeeper
sudo ln -fs /home/pi/autocopter/3g_modem/e352.service /etc/systemd/system/
sudo systemctl enable /home/pi/autocopter/3g_modem/e352.service
