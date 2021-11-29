#!/bin/sh
#
# SCRIPT: jenkins_job_export.sh
# AUTHOR: Christophe MICHAUX <chris@cmxconsulting.fr>
# CREATION DATE : 2021-11-10
# WEBSITE : https://www.cmxconsulting.fr
#
# DESCRIPTION : Export Jobs from Jenkins
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

echo "Export all Jenkins jobs."
echo " "
display_usage() { 
    echo " "
    echo "Usage:"
    echo "    $CGREEN $0 [options] JENKINS_URL"
    echo $CNC
    echo "Arguments : "
    echo "  -h : display this message"
    echo "  JENKINS_URL : the Jenkins' URL" 
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

#JENKINS_URL=http://p0qt3c13.sie.caisse-epargne.fr:8585/
JENKINS_URL=$1


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

#JENKINS_AUTHENTICATION="--username **** --password ***"
JENKINS_AUTHENTICATION=""
TEMP_FILE=.jenkins_jobs.txt
TEMP_FOLDER=jenkins_jobs_output
ZIP_FILE=jenkins_jobs.zip

echo "List all jenkins jobs... "
JENKINS_LIST_JOBS="java -jar jenkins-cli.jar -s $JENKINS_URL list-jobs $JENKINS_AUTHENTICATION"

echo $JENKINS_LIST_JOBS
eval $JENKINS_LIST_JOBS > $TEMP_FILE

JOBS_FOUND=`wc -l $TEMP_FILE |awk '{print $1}'`
echo "$JOBS_FOUND jenkins jobs found"

#Clean old folders
rm -rf $TEMP_FOLDER
mkdir -p $TEMP_FOLDER
j=0



cat "$TEMP_FILE" | while read i
do

echo $i
  let j++
  # remove trailing character end of line 
  CURRENT_JOB=${i//$'\r'/ }
  # remove trailing whitespace characters
  CURRENT_JOB="${CURRENT_JOB%"${CURRENT_JOB##*[![:space:]]}"}" 
  printf -v JOB_NUMBER "%03d" $j

  #echo "Export JOB ($JOB_NUMBER / ${JOBS_FOUND}) -${CURRENT_JOB}-"
  echo "java -jar jenkins-cli.jar -s $JENKINS_URL $JENKINS_AUTHENTICATION get-job \"$CURRENT_JOB\" > \"$TEMP_FOLDER/$CURRENT_JOB.xml\"" >> commands.sh 

  #java -jar jenkins-cli.jar -s $JENKINS_URL  get-job "$CURRENT_JOB" > "$TEMP_FOLDER/$CURRENT_JOB.xml"

done

sh commands.sh
echo $j

if  [ j==0 ]; then 
	echo "No jobs found. No zip file generated."

else 
#	rm -f $TEMP_FILE
#	rm -f $ZIP_FILE
	zip -jr9q $ZIP_FILE $TEMP_FOLDER

	echo "----------------------"
	echo "File $ZIP_FILE generated with Jenkins jobs from ${JENKINS_URL}"
	echo "Each job is also available in local $TEMP_FOLDER folder"
	echo "----------------------"


fi

echo " "
echo "Operation complete."
echo " "
echo "If you are searching for other useful scripts, be free to go to https://github.com/cmxconsulting/"
echo " "
echo "End."


