#!/bin/bash

echo
echo "--------------------------------------------------------------------------------------------"
echo $(date) "Internet connection checker and switcher script started"
echo "--------------------------------------------------------------------------------------------"
echo

main_interface="eth1"
main_ip="192.168.99.120"
main_gw="192.168.99.1"
second_interface="ppp0"
second_ip="192.168.88.1"
second_gw="192.168.88.2"

current_interface=""

function switch_to_interface {
        gw="$1"
        interface="$2"  
        echo $(date) "Switching to $interface"
        # we need this route to ping 8.8.8.8 only through main interface. It may dsappear for some reason,
	# so we add it again and again
        sudo ip route add 8.8.8.8/32 via $main_gw dev $main_interface src $main_ip 
        sudo ip route del default
        sudo ip route add default via $gw dev $interface
}

function send_connection_request {
	str=$(curl --header "Referer: http://192.168.99.1/index.html" http://192.168.99.1/goform/goform_set_cmd_process\?goformId\=CONNECT_NETWORK)
        if [ "$str" == '{"result":"success"}' ]
        then
                echo "$str"
                echo "Modem 4g connected to network! (or not - {result=success} from this modem means nothing)"
		return 1
        fi
	return 0	
}

while true
do
	# this "heavy" code is here because when system starts it changes network settings in many ways
	# and we need to know exactly that our code has been run
        sudo ip route del default dev wlan0 #hardcode
        # switching to second interface to get internet connection while preparing main interface and if it is not accessible
        switch_to_interface $second_gw $second_interface
        current_interface=$second_interface
        sleep 2

        while ping "$main_gw" -n -q -i 0.2 -c 3 > /dev/null # While we have an access to modem4g, we will stay into a nested cycle, switching channels
        do
                if ping 8.8.8.8 -n -q -i 0.2 -c 3 > /dev/null # send ping 3 times with 0.2 second interval
                then
                        if [ "$current_interface" != "$main_interface" ] # if we are not currently on main interface, switching
                        then
                                switch_to_interface $main_gw $main_interface
                                current_interface=$main_interface
                        fi
                else
			send_connection_request # sending connection string - maybe we just disconnected from network or not connected yet

                        if [ "$current_interface" != "$second_interface" ] # if we are not currently on second interface, switching
                        then
                                switch_to_interface $second_gw $second_interface
                                current_interface=$second_interface
                        fi
                fi

        done
done


