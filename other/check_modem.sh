#!/bin/bash

#20092017 urpylka

check_modem_connection() {
	while true; do
		if [[ $(lsusb -d 12d1:1506) ]]; then break; else sleep 1; fi
	done
}
check_modem_connection_log() {
	while true; do
		if [[ $(lsusb -d 12d1:1506) ]]; then break; else sleep 1; fi
		echo $(date) "Modem not connected";
		echo $(date) "Modem not connected" >> $1;
	done
}

#check_modem_connection