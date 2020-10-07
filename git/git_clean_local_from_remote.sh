#!/bin/sh
#
# SCRIPT: git_clean_local_from_remote.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2020-10-07
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Remove local git branches which are deleted on repository.
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



CRED='\033[1;31m'
CGREEN='\033[1;32m'
CCYAN='\033[1;36m'
CNC='\033[0m' # No Color

echo " "
echo "Remove local git branches which are deleted on repository."
echo " "
echo $CNC
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options]"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo " "
} 

while getopts ":h" opt; do
  case ${opt} in
    h )
      display_usage
      exit 0
      ;;
    \? )
      echo $CRED
      echo "Invalid Option: -$OPTARG" 1>&2
      echo $CNC
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


# if less than two arguments supplied, display usage 
if [  $# -gt 0 ] 
then 
	echo "${CRED}Error : Too much arguments ($#)$CNC"
    
	display_usage
	exit 2
fi 


git remote prune origin
git branch -vv | grep origin | grep gone | awk '{print $1}'|xargs -L 1 git branch -d



echo " "
echo "Operation complete."
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."