#!/bin/sh
#
# SCRIPT: unlock_device.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-07
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Unlock the android device with pincode
#
# Copyright 2020 CMX Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/
#


DEFAULT_PINCODE="0000"
SCREEN_CAPTURE=0
CAPTURE_COUNT=1

CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color

echo "Unlock the android device with pincode"
echo " "

screen_capture() {

	if [[ $SCREEN_CAPTURE -eq "1" ]]; then
		CAPTURE_NAME="screen_capture_$(date +"%Y-%m-%d-%H-%H-%S")_${CAPTURE_COUNT}.png"
		echo "Capturing device to $CAPTURE_NAME"
		$ADB exec-out screencap -p > $CAPTURE_NAME
		CAPTURE_COUNT=$((CAPTURE_COUNT+1))

	fi
}
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options] video_file output_directory"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo " "
} 
while getopts ":v:g:h" option; do
    case "${option}" in
        v)
            v=${OPTARG}
            ((v == 15 || v == 75)) || usage
            ;;
        h)
            display_usage
            exit 0
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))



# if less than two arguments supplied, display usage 
if [  $# -gt 2 ] 
then 
  echo "${CRED}Error : Too much arguments ($#)$CNC"
    
  display_usage
  exit 2
fi 

if [ -z "${v}" ] || [ -z "${g}" ]; then
    display_usage
fi



devices=(`adb devices -l | sed "s/:/ /g" | awk 'NF {printf "%s(%s)\n", $1,$8}' | tail -n +2`)
echo "Please select an android device connected in the list below :"

select device in "${devices[@]}" "quit";
do

    # leave the loop if the user says 'stop'
    if [[ "$device" == "quit" ]]; then exit 0; fi

    DEVICE_SELECTED="$device"

    DEVICE_ID=`echo $DEVICE_SELECTED | cut -d "(" -f1 `
    DEVICE_MODEL=`echo $DEVICE_SELECTED | cut -d "(" -f2 | tr -d ")" `
    break

done


echo "Device Chosen : $DEVICE_MODEL ($DEVICE_ID)"
read -s -p "Please specify the pin code. Leave empty for [${DEFAULT_PINCODE}]:" PINCODE
PINCODE="${PINCODE:-$DEFAULT_PINCODE}"


ADB="adb -s ${DEVICE_ID}"
echo " "
echo "Unlock device"
$ADB shell input keyevent 26
$ADB shell input touchscreen swipe 930 880 930 380
screen_capture

echo "Enter pincode"
$ADB shell input text ${PINCODE}

screen_capture
$ADB shell input keyevent 66
sleep 1
screen_capture



echo "${CGREEN}The device should be unlocked. If needed you can add -s option to do screen captures at each steps $CNC"
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."
