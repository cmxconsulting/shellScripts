#!/bin/sh
#
# SCRIPT: video_thumbs.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-09
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Generate thumbnails from videos
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



MAX_WIDTH=853
MAX_HEIGHT=480
THUMBNAILS_NUMBER=3

CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color


VERBOSE=0

echo $CCYAN
echo " ██████ ███    ███ ██   ██      ██████  ██████  ███    ██ ███████ ██    ██ ██   ████████ ██ ███    ██  ██████  ";
echo "██      ████  ████  ██ ██      ██      ██    ██ ████   ██ ██      ██    ██ ██      ██    ██ ████   ██ ██       ";
echo "██      ██ ████ ██   ███       ██      ██    ██ ██ ██  ██ ███████ ██    ██ ██      ██    ██ ██ ██  ██ ██   ███ ";
echo "██      ██  ██  ██  ██ ██      ██      ██    ██ ██  ██ ██      ██ ██    ██ ██      ██    ██ ██  ██ ██ ██    ██ ";
echo " ██████ ██      ██ ██   ██      ██████  ██████  ██   ████ ███████  ██████  ███████ ██    ██ ██   ████  ██████  ";
echo "                                                                                                               ";
echo "                                                                                                               ";

echo "Generate thumbnails from videos"
echo $CNC
echo "Author : Christophe MICHAUX <chris@cmxconsulting.fr>"
echo "Copyright 2020 CMX Consulting"


# Check if a program exists
check_if_program_exists(){
    if ! command -v $1 &> /dev/null
    then
        echo $CRED
        echo "$1 could not be found. Please install it before using apt-get/rpm/brew install $2$CNC"
        exit 4
    fi
}

display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options] video_file output_directory"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo "  -v : verbose"
    echo "  -n X : number of thumbnails to generate (3 by default)"
    echo " "
} 

while getopts ":vn:h" option; do
    case "${option}" in
        v)
            VERBOSE=1
            ;;
        n)
            THUMBNAILS_NUMBER=${OPTARG}
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

if [ -z "$1" ] || [ -z "$2" ]; then
    display_usage
    exit 3
fi



VID_NAME=${1%.*}
VID_NAME=${VID_NAME##*/}
DEST_DIR=$(dirname $2)
filesize=`stat -f "%z" $1`

check_if_program_exists mediainfo "mediainfo"
check_if_program_exists avconv "libav"

echo "Reading video $1"
src_info=`mediainfo --Inform="Video;src_width=%Width%,src_height=%Height%,src_frames=%Duration%,src_rotate=%Rotation%" $1 | tr "," "\n"`
for x in ${src_info}
do
    eval ${src_info}
done

# Calculate rotation and transposition if video is not in the good rotation
src_rotate=${src_rotate/.*}
src_transpose=0
case ${src_rotate} in
  90) src_transpose=1;;
  180) src_transpose=3;;
  270) src_transpose=2;;
  *) src_transpose=0;;
esac

if ((${src_transpose} > 0))
then
    src_transpose="transpose=${src_transpose},"
else
    src_transpose=

fi

# Store if video is HD or not
if ((${src_height} >= 720))
then
    HD=1
else
    HD=0
fi


echo "Input video height : ${src_height} - width : ${src_width} - frames : ${src_frames}"
if [ -z "${src_frames}" ]; then
    src_frames=`mediainfo --inform="General;%Duration%" $1`
fi

DURATION=$[${src_frames}/1000]
FRAME_COMPUTE=$[${src_frames}/1000/$((THUMBNAILS_NUMBER+1))]

TIMECMD=
LOGLEVEL="warning"
if [[ $VERBOSE -eq "1" ]]; then

    TIMECMD=time
    LOGLEVEL="info"
fi

for i in `seq 1 $THUMBNAILS_NUMBER`;
do
    IMAGE_FRAME=$[${FRAME_COMPUTE}*$i]
    echo "Generate header from video at : ${IMAGE_FRAME}s to ${DEST_DIR}/${VID_NAME}_$i.jpg"
    $TIMECMD avconv -i $1  -an -ss ${IMAGE_FRAME} \
    -vframes 1 \
    -vf "${src_transpose}scale=-1:480" \
    -y -f image2 ${DEST_DIR}/${VID_NAME}_$i.jpg \
    -loglevel $LOGLEVEL
done    


echo " "
echo "Operation complete."
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."


