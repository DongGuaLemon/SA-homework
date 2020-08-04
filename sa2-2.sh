#!/bin/sh
main (){
	choice=$(dialog --menu "SYS INFO" 15 60 4 1 "CPU INFO" 2 "MEMORY INFO" 3 "NETWORK INFO" 4 "FILE BROWSER" 2>&1 >/dev/tty);
		case $choice in
			1)
				cpu;;
			2)
				mem;;
			3)
				net;;
			4)	
				file;;
			*)
				echo "no such choice";;
		esac
}
cpu (){
	cpumachine=$(sysctl -a hw.machine | awk '{$1= "";print}')
	cpumodel=$(sysctl -a | egrep -i 'hw.model' | awk '{$1= "";print}')
	cpucore=$(sysctl -a hw.ncpu | awk '{$1= "";print}')
	dialog --title "CPU INFO" --clear --msgbox \
		"CPU Model: ${cpumodel}\n\nCPU Machine: ${cpumachine}\n\nCPU Core: ${cpucore}" 20 60
}
mem (){
	memreal=$(sysctl -a hw.realmem | awk '{print $2/1024/1024/1024}')
	memfree=$(sysctl -a hw.usermem | awk '{print $2/1024/1024/1024}')
	memused=$(echo $memreal $memfree | awk '{print $1-$2}')
	usegauge=$(echo $memused $memreal | awk '{print int($1/$2*100)}')	
	dialog --title "Memory Info and Usage" --clear --gauge \
		"Total: ${memreal} GB\nUsed: ${memused} GB\nFree: ${memfree} GB" 20 60 ${usegauge}
	
}
net (){
	allnet=$(ifconfig -a | sed -E 's/[[:space:]:].*//;/^$/d'| awk '{print $0 " \"*\""}')
	choice=$(dialog --menu "test" 20 50 2 ${allnet} 2>&1 >/dev/tty)
	if [ -z $choice ]; then
		echo $(clear)
	else
		netinfo
	fi	
}

netinfo (){
	ipinfo=$(ifconfig $choice | awk '$0 ~ /inet /{print $2}')
	maskinfo=$(ifconfig $choice | awk '$0 ~ /netmask /{print $4}')
	macinfo=$(ifconfig $choice | awk '$0 ~ /ether /{print $2}')
	dialog --title "Interface Name:${choice}" --msgbox \
		"IPv4___: ${ipinfo}\nNetmask: ${maskinfo}\nMac____: ${macinfo}" 20 60

}
file (){
	file=$(ls -f|awk '{print $0}')
	echo $(file $file)
}
main

