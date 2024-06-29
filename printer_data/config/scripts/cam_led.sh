#!/bin/sh
if [ "$1" -eq "0" ];
then
  echo "Camera LED OFF";
else
   echo "Camera LED ON: ${1}";
fi
curl -s "http://192.168.1.27/control?var=led_intensity&val=${1}"
