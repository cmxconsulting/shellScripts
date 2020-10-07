#!/bin/sh
#
# SCRIPT: video_convert.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-09
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Encode video to different formats for web purposes with optimizations for Youtube...
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
# Before use, please launch installation.
# 
# On MacOS : 
#     brew install x264 mediainfo libav



MAX_WIDTH=853
MAX_HEIGHT=480
THUMBNAILS_NUMBER=3
RES_NAME="240 360 720 1080"

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

echo "Encode video to different formats for web purposes with optimizations."
echo "This program will encode your video to these resolutions : ${RES_NAME}"
echo $CNC
echo "Author : Christophe MICHAUX <chris@cmxconsulting.fr>"
echo "Copyright 2020 CMX Consulting\n"


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
    echo "  --help/-h : display this message"
    echo "  -v : verbose"
    echo "  --h264/-h264 : Encode video in h264 format (default) with aac audio codec"
    echo "  --webm/-webm : Encode video in webm format (default) with ogg vorbis audio codec"
    echo " "
} 

VIDEO_CODEC="libx264"
AUDIO_CODEC="libfaac"
OUTPUT_EXTENSION="mp4"
ENCODING_TYPE="h264"


while [ $# -gt 2 ]; do
  case "$1" in
    --url*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      URL="${1#*=}"
      ;;
    --file*|-f*)
      if [[ "$1" != *=* ]]; then shift; fi
      FILE="${1#*=}"
      ;;
    --h264|-h264)
      # H264 Encoding
      # Parameters already set above
      ;;
    --webm|-webm)
      # WebM Encoding
      VIDEO_CODEC="libvpx"
      AUDIO_CODEC="libvorbis"
      OUTPUT_EXTENSION="webm"
      ENCODING_TYPE="webm"
      ;;
    --help|-h)
      display_usage
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      display_usage
      exit 1
      ;;
  esac
  shift
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
echo "Processing file $1"
echo "Encoding to ${ENCODING_TYPE} format\n"



declare WIDTH
declare BITRATE

VID_NAME=${1%.*}
VID_NAME=${VID_NAME##*/}

DEST_DIR=$(dirname $2)

src_info=`mediainfo --Inform="Video;src_width=%Width%,src_height=%Height%,src_rotate=%Rotation%" $1 | tr "," "\n"`
for x in ${src_info}
do
	eval ${src_info}
done

# Compute if we need to rotate the video
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
	src_transpose="transpose=${src_transpose}"
else
	src_transpose=

fi

# Define each width for specific height
WIDTH[1080]=1920
WIDTH[720]=1280
WIDTH[480]=854
WIDTH[360]=640
WIDTH[240]=426

#Youtube's recommandations
BITRATE[1080]=8000
BITRATE[720]=5000
BITRATE[480]=2500
BITRATE[360]=1000
BITRATE[240]=500


TIMECMD=
LOGLEVEL="warning"
if [[ $VERBOSE -eq "1" ]]; then

    TIMECMD=time
    LOGLEVEL="info"
fi

COUNT_RES=0
for res in ${RES_NAME}
do
   wxh=${WIDTH[$res]}x${res}

   if (($res <= $src_height)) || ((${WIDTH[$res]} <= $src_width))
   then
	COUNT_RES=$[$COUNT_RES +2]
   fi
done

for res in ${RES_NAME}
do
   wxh=${WIDTH[$res]}x${res}

   if (($res <= $src_height)) || ((${WIDTH[$res]} <= $src_width))
   then

      if [ -z "$src_transpose" ]; then
	       #not transposed
         scale="-vf scale=${WIDTH[$res]}:trunc(ow/a/2)*2"
      else
         scale="-vf ${src_transpose},scale=trunc(oh*a/2)*2:$res"
      fi

      echo  "Encoding $1 ($wxh) as ${VID_NAME}_${res}.mp4 @ ${BITRATE[$res]}kbps"
      echo "Please wait..."
      $TIMECMD avconv 	-i $1 -vcodec ${VIDEO_CODEC} $scale -acodec ${AUDIO_CODEC}  -b:v ${BITRATE[$res]}k -ac 2 \
			-b:a 128k -threads 8 -metadata:s:v:0 rotate=0 -y ${DEST_DIR}/${VID_NAME}_${res}p.${OUTPUT_EXTENSION} \
      -loglevel $LOGLEVEL

	
   else
       echo  "Skipping $wxh as source is smaller"
   fi

done


echo " "
echo "${CGREEN}Operation complete.$CNC"
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."

