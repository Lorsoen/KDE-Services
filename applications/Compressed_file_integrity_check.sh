#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2014-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
FILE=$@
EXIT=""
PB_PIDFILE="$(mktemp)"

###################################
############# Functions ###########
###################################

progressbar-start() {
	kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]  ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]   ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]   ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}h"
	fi
}

exit-check() {
	if [ "$EXIT" = "1" ]; then
		kdialog --icon=ks-error --title="Compressed File Integrity Check" \
			--passivepopup="[Error]  ${file##*/}   Archive parsing failed! (Data is corrupted.)"
		exit 1
	fi
	while [ "$EXIT" = "2" ] || [ "$EXIT" = "1" ]; do
		PWD=$(kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--password="The ${file##*/} archive is encrypted, requires a password for integrity check")
		lsar -t $file -p $PWD > /dev/null 2>&1
		EXIT=$?
	done
}

###################################
############### Main ##############
###################################

progressbar-start

for file in $FILE; do
	cd "${file%/*}"

	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|\
		sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")" "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")" "$(dirname "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")" "$(dirname "$(dirname "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname \
		"$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"|\
		sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null
	cd ./

	for i in *; do
		mv "$i" "${i// /_}" 2> /dev/null
	done

	DIR="$(pwd)"

	BEGIN_TIME=$(date +%s)
	lsar -t $file > /dev/null 2>&1
	EXIT=$?
	exit-check
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
done
progressbar-stop
exit 0
