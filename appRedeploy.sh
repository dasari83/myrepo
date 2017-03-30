#!/bin/bash

# A shell script for redeploying ear files in Weblogic domain
#
# Usage:
# $ ./appRedeploy.sh ear_name
#
# Author: Vivek Dasari
# CreateDate: 06/04/2013

DMGR_DIR=/opt/infra/weblogic/apps/issoa/deploy
DEPLOY_DIR=/opt/infra/weblogic/domains/issoa-stage-domain/deploy

WL_T3_URL=t3://xxxx:10005
WL_USER=weblogic
WL_PASSWORD=xxx
WL_HOME=/opt/infra/weblogic/product/xxx-stage-wls10-64bit/wlserver_10.3

# Get input
if [[ -n "$1" ]]; then
  EAR_NAME=$1
else
  echo "You must define ear file.\n"
  echo "Usage: ./appRedeploy.sh ear_name [--nodeploy] \n"
  exit 1;
fi

DEPLOY="true"
if [ "$2" = "--nodeploy" ]; then
  DEPLOY="false"
fi

# Unpack ear file from dmgr to deploy folder
ear_path=${DMGR_DIR}/${EAR_NAME}
if [[ -f "${ear_path}" ]]; then # If ear is a file
	echo "Unpack ${ear_path} to ${DEPLOY_DIR}/${EAR_NAME}"
	rm -rf ${DEPLOY_DIR}/${EAR_NAME}/*
	unzip ${ear_path} -d ${DEPLOY_DIR}/${EAR_NAME}
elif [[ -d "${ear_path}" ]]; then # If ear is a directory
	echo "Copy directory ${ear_path} to ${DEPLOY_DIR}/${EAR_NAME}"
	rm -rf ${DEPLOY_DIR}/${EAR_NAME}/*
	cp -r ${ear_path}/* ${DEPLOY_DIR}/${EAR_NAME}/
else
	echo "No such file or directory: ${ear_path}"
	exit 1
fi

# Change context root and remove security block
${DEPLOY_DIR}/applicationChange.sh ${EAR_NAME}

# Redeploy in Weblogic domain
if [ "${DEPLOY}" = "true" ]; then
	APP_NAME=`basename ${EAR_NAME} .ear`
	. ${WL_HOME}/server/bin/setWLSEnv.sh
	java weblogic.Deployer -adminurl ${WL_T3_URL} -username ${WL_USER} -password ${WL_PASSWORD} -name ${APP_NAME} -timeout 60 -redeploy
fi
