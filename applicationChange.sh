#!/bin/bash

# A shell script for changing context root under a war file before the deployment to APP Server.
#
# Usage:
# $ ./applicationChange.sh war_name
#
# Author: Vivek Dasari

JENKINS_HOME=/opt/bitnami/apps/jenkins/jenkins_home
APP_DIR=/opt/bitnami/apps/jenkins/deploy/demo
WAR_NAME=sample.war
CONTEXT_ROOT=/demo

echo "Changing context root for $WAR_NAME"

cd $APP_DIR

cp -rp "$JENKINS_HOME/jobs/$JOB_NAME/workspace/apps/web/target/sample.war" $APP_DIR

mkdir tmpDir
cd tmpDir
jar -xvf ../$WAR_NAME
#sed -i "s:\(context-root>\).*<:\1$CONTEXT_ROOT<:" WEB-INF/weblogic.xml
sed -i "s:context-root\/>:context-root>$CONTEXT_ROOT<\/context-root>:" WEB-INF/weblogic.xml

jar -cvf $WAR_NAME *
cd ..
cp tmpDir/$WAR_NAME .
rm -rf tmpDir

