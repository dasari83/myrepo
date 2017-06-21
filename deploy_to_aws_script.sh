#!/bin/bash\
array=()\
if [ $DEPLOY_QA = "true" ]; then\
	echo $\{DEPLOY_QA\}\
	array+=('qa')\
fi\
if [ $DEPLOY_PREPROD = "true" ]; then\
	echo $\{DEPLOY_PREPROD\}\
	array+=('preprod')\
fi\
if [ $DEPLOY_PERFORMANCE = "true" ]; then\
	echo $\{DEPLOY_PERFORMANCE\}\
	array+=('performance')\
fi\
for item in $\{array[*]\}\
do\
	echo "starting the $\{item\} deployment with action as $\{Action\}"\
	echo "environment variables:"\
    \
    echo "Build Number to be deployed: $\{BUILD_NUMBER\}"\
    export AWS_DEFAULT_REGION=us-west-1\
    echo "AWS Default region: $\{AWS_DEFAULT_REGION\}"\
    \
	Environment=$\{item\}\
    \
    case "$Environment" in\
    'qa')\
    echo "Environment is qa"\
    deploymentPropertyFile=xxx-xxx\
    stackName=<PlatformName>-xxxx-xxx-QA\
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY\
	export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY\
    ;;\
    'preprod')\
    echo "Environment is preprod"\
    deploymentPropertyFile=xxx-xxx\
    stackName=<PlatformName>-xxxx-xxx-PreProduction\
    export AWS_ACCESS_KEY_ID=$AWS_PP_ACCESS\
	export AWS_SECRET_ACCESS_KEY=$AWS_PP_SECRET\
    ETag=`aws s3api head-object --bucket xxx-artifacts-qa --key application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz |jq -r '.ETag'`\
    aws s3api copy-object --copy-source xxx-artifacts-qa/application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz --copy-source-if-match $\{ETag\} --bucket xxx-artifacts-preproduction --key application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz\
    ;;\
    'performance')\
    echo "Environment is performance"\
    deploymentPropertyFile=xxx-xxx\
    stackName=<PlatformName>-xxxx-xxx-Performance\
    export AWS_ACCESS_KEY_ID=$AWS_PP_ACCESS\
	export AWS_SECRET_ACCESS_KEY=$AWS_PP_SECRET\
    ETag=`aws s3api head-object --bucket xxx-artifacts-qa --key application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz |jq -r '.ETag'`\
    aws s3api copy-object --copy-source xxx-artifacts-qa/application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz --copy-source-if-match $\{ETag\} --bucket xxx-artifacts-preproduction --key application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz\
    ;;\
    esac\
\
    echo "Deployment Property file is $\{deploymentPropertyFile\}.properties"\
    echo "Deployment Stack Name is $\{stackName\}"\
    \
    eval $(cat src/main/components/deployment/environments/$\{Environment\}/$\{deploymentPropertyFile\}.properties | sed 's/^/export /')\
    echo "AMI ID used: $\{AmiId\}"\
    \
    \
    bundlePath="application/services/deploy/$\{BUILD_NUMBER\}/xxx-deploy.1.0.tar.gz"\
    \
    git branch -d temp\
    git branch temp\
    git checkout temp\
    \
    sed -i "s/BundlePath.*/BundlePath=$\{bundlePath\}/" src/main/components/deployment/environments/$\{Environment\}/$\{deploymentPropertyFile\}.properties\
    echo "Replaced old bundle path with New BundlePath $\{bundlePath\}"\
    \
    git add src/main/components/deployment/environments/$\{Environment\}/$\{deploymentPropertyFile\}.properties\
    git commit -m "Updating deploymentPropertyFile with new BundlePath"\
    git checkout master\
    git pull\
    git merge temp\
    git push\
    	    \
   \
    src/main/components/deployment/scripts/merged/deployService-jenkins.sh --action $\{Action\} --environment $\{Environment\} --service $\{deploymentPropertyFile\} --stack $\{stackName\}\
\
    echo "Deployment completed in $\{Environment\}"\
    echo\
    echo "##### Summary of the $\{Environment\} deployment #####"\
    echo\
    echo "Environment deployed: $\{Environment\}"\
    echo "Build Number deployed: $\{BUILD_NUMBER\}"\
    echo "AMI ID used: $\{AmiId\}"\
    echo "Stack Name: $\{stackName\}"\
    echo\
    echo "-----------------------------------------------------------------"\
    echo\
done\
\
}
