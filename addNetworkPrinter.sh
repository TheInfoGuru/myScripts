#!/bin/bash
clear

CUPSTATUS=$(/etc/init.d/cups status | grep '(running)')

read -p "Enter a name for the printer (NO SPACES): " PRINTERNAME
echo
read -p "Enter the IP address of the printer (e.g. 10.1.10.150): " PRINTERIP

ping -q -c 1 -w 2 $PRINTERIP > /dev/null
if [ $? -ne 0 ]; then
	echo
	echo "COULD NOT REACH PRINTER OVER NETWORK."
	echo "PLEASE CHECK CONNECTION AND RUN SCRIPT AGAIN."
	sleep 3
	exit
fi

echo
read -p "Would you like to set this printer as default (y/N): " SETDEFAULT
echo

echo "Making sure CUPS service is running."
if [ -z "$CUPSTATUS" ]; then
	echo
	sudo /etc/init.d/cups start
fi

echo "Adding printer at selected IP."
lpadmin -p $PRINTERNAME -E -v socket://$PRINTERIP

PRINTERSTATUS=$(lpstat -p -d | grep "$PRINTERNAME")

if [ -z "$PRINTERSTATUS" ]; then
	echo
	echo "ERROR OCCURED! PRINTER NOT ADDED!"
	sleep 3
	exit
fi

if [ "$SETDEFAULT" == "y" -o "$SETDEFAULT" == "Y" ] ; then
	echo "Making chosen printer as default."
	lpadmin -d "$PRINTERNAME"

	PRINTERDEFAULT=$(lpstat -p -d | grep 'system default' | grep "$PRINTERNAME")

	if [ ! "$PRINTERDEFAULT" ]; then
		echo
		echo "COULD NOT SET PRINTER AS DEFAULT."
		echo
		sleep 4
	fi
fi

echo "Printing test page."
lpr -P $PRINTERNAME /usr/share/cups/data/testprint
echo "Printing can take up to 60 seconds."
echo
echo "CONGRATULATIONS. PRINTER SETUP COMPLETE!"
sleep 5
exit
