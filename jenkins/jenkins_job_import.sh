#!/bin/sh
#
# SCRIPT: jenkins_job_import.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2021-11-10
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Import Jobs to Jenkins from XML files
#
# Copyright 2021 CMX Consulting
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

echo "Import Jenkins jobs from XML files."
echo " "
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options] JENKINS_URL"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo "  -u : user name"
    echo "  -j : job prefix"
    echo "  JENKINS_URL : the Jenkins' URL" 
    echo " "
} 
USERNAME=""
JOB_PREFIX="TNRA/"

while getopts ":h:u:j:" opt; do
  case ${opt} in
    h )
      display_usage
      exit 0
      ;;
    u )
      USERNAME=$OPTARG
      echo "Username : $USERNAME"
      ;;
    j )
      JOB_PREFIX=$OPTARG
      echo "Job prefix : $JOB_PREFIX"
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

#JENKINS_URL=http://picjkm011.dom101.mapres:8080/
JENKINS_URL=$1

if [ -n "$USERNAME" ]; then
	# Prompt for password
	read -s -p "Please set username $USERNAME password : " ACCOUNT_PASSWORD
	
	if [ -z "$ACCOUNT_PASSWORD" ]; then

		echo "${CRED}Error : Password not set$CNC"
		exit 4
	fi
fi


# if less than two arguments supplied, display usage 
if [  $# -gt 1 ]
then 
	echo "${CRED}Error : Too much arguments ($#)$CNC"
    
	display_usage
	exit 2
fi 


# Checks if file exists
if [ -z "$JENKINS_URL" ]; then
    echo $CRED
    echo "Jenkins URL not specified. Please pass the JENKINS url as argument."
    echo $CNC
    display_usage
    exit 3
fi


JENKINS_AUTHENTICATION=""
if [ -n "$USERNAME" ]; then

	JENKINS_AUTHENTICATION="-auth $USERNAME:$ACCOUNT_PASSWORD"
fi
JOBS_FOLDER=jenkins_jobs_output

CURRENT_FOLDER=$(pwd)


cd $JOBS_FOLDER
JOBS_COUNT=`ls *.xml | wc -l | xargs`
j = 0
echo "$JOBS_COUNT jobs found to import in Jenkins $JENKINS_URL"

for f in *.xml;
do
	let j++
	printf -v JOB_NUMBER "%03d" $j
	echo "Importing (${CCYAN}$JOB_NUMBER${CNC} / $JOBS_COUNT) ${CCYAN}${f%.*}${CNC} jenkins job...";
	java -jar $CURRENT_FOLDER/jenkins-cli.jar  -s ${JENKINS_URL} ${JENKINS_AUTHENTICATION}   create-job "${JOB_PREFIX}${f%.*}" < "$f"

done

cd $CURRENT_FOLDER


echo " "
echo "Operation complete."
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."

