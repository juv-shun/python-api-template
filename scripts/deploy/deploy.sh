#!/bin/bash -e
set -e

# Set environment variables
source $(cd $(dirname $0); pwd)/env.sh

# Register Task Definition
envsubst < taskdef_template.json > taskdef.json
aws ecs register-task-definition --cli-input-json file://taskdef.json
export TASK_DEF_ARN=`aws ecs describe-task-definition --task-definition ${APPLICATION_NAME} | jq '.taskDefinition.taskDefinitionArn' -r`
echo "*** Task Definition Successfully registered. ${TASK_DEF_ARN}"

# Deploy with CodeDeploy
envsubst < appspec_template.yaml > appspec.yaml
aws deploy create-deployment \
    --application-name ${APPLICATION_NAME}\
    --deployment-group-name ${APPLICATION_NAME}\
    --revision revisionType=AppSpecContent,appSpecContent={content=\'"`cat appspec.yaml`"\'}
echo "*** CodeDeploy Successfully started."
aws ecs update-service --cluster ${APPLICATION_NAME} --service ${APPLICATION_NAME} --desired-count ${ECS_DESIRED_COUNT}
echo "*** Desired count of ECS tasks successfully updated to ${ECS_DESIRED_COUNT}."

# Delete temporary file
rm -f taskdef.json
rm -f appspec.yaml
