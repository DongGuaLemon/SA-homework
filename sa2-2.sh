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
				echo '4';;
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
	allnet=$(ifconfig -a | sed -E 's/[[:space:]:].*//;/^$/d'| awk '$0=NR": "$0')
	echo $allnet
	choice=$(dialog --menu "test" 20 50 2 ${allnet} 2>&1 >/dev/tty)
}
file (){
}
main

