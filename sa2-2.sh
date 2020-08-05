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
				files;;
			*)
				echo "no such choice";;
		esac
}
cpu (){
	cpumachine=$(sysctl -a hw.machine | awk '{$1= "";print}')
	cpumodel=$(sysctl -a | egrep -i 'hw.model' | awk '{$1= "";print}')
	cpucore=$(sysctl -a hw.ncpu | awk '{$1= "";print}')
	dialog --stdout --title "CPU INFO" --clear --msgbox \
		"CPU Model: ${cpumodel}\n\nCPU Machine: ${cpumachine}\n\nCPU Core: ${cpucore}" 20 60
	if [ $?==0 ];then
		main
	fi	
}
mem (){
	memreal=$(sysctl -a hw.realmem | awk '{print $2/1024/1024/1024}')
	memfree=$(sysctl -a hw.usermem | awk '{print $2/1024/1024/1024}')
	memused=$(echo $memreal $memfree | awk '{print $1-$2}')
	usegauge=$(echo $memused $memreal | awk '{print int($1/$2*100)}')	
	while true; do
		dialog --title "Memory Info and Usage" --mixedgauge "Total: ${memreal} GB\nUsed: ${memused} GB\nFree: ${memfree} GB" 20 50 ${usegauge} 2>&1 >/dev/tty
		read -r input 
		if [ "$input" == "" ]; then 
		      exit 0           
		fi
	done
}
net (){
	allnet=$(ifconfig -a | sed -E 's/[[:space:]:].*//;/^$/d'| awk '{print $0 " \"*\""}')
	indexnet=$(ifconfig -a | sed -E 's/[[:space:]:].*//;/^$/d' | awk '$0{dir++}END{print dir}')
	choice=$(dialog --menu "Net" 20 50 ${indexnet} ${allnet} 2>&1 >/dev/tty)
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
	dialog --stdout --title "Interface Name:${choice}" --msgbox \
		"IPv4___: ${ipinfo}\nNetmask: ${maskinfo}\nMac____: ${macinfo}" 20 60
	if [ $?==0 ];then
		net
	fi	
}
files (){
	pwd=$(pwd)
	files=$(ls -a $pwd | xargs file -i | awk '{print $1 " " $2}' | sed 's/\://g')
	fileindex=$(ls -a $pwd | xargs file -i | awk '$0{dir++}END{print dir}')
	choice=$(dialog --menu "File browser ${pwd}" 20 50 ${fileindex} ${files} 2>&1 >/dev/tty)
	if [ -z $choice ];then
		echo $(clear)
	else
		fileinfo
	fi	
}
fileinfo (){
	pwd=$(pwd)
	#fileinfo= echo $pwd/$choice | xargs file | awk '{print $1 = "";print}'
	fileinfo=`file $pwd/$choice -b`
	filesize=$(ls -lah $choice | awk '{ print $5}')
	if [ "$fileinfo" != "directory" ]; then
		#vim ${choice}
		#echo finish && exit 0
		select=$(dialog --stdout --extra-button --extra-label "edit" --ok-label "ok" --msgbox \
			"File Name: ${choice}\n\nFile Info: ${fileinfo}\n\nFile Size: ${filesize}" 20 40 2>&1 >/dev/tty)
		if [ $? == 3 ];then
			vim $choice
		fi	
		files
	else
		cd $choice
		files
	fi	
}

#fileinfo
main
