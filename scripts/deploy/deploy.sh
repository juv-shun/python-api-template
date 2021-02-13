#!/bin/bash -e
set -e

### Please set the following environment variables.
# export AWS_ACCOUNT_ID=
# export APPLICATION_NAME=
# export IMAGE_TAG=
# export CPU_SIZE=
# export MEMORY_SIZE=
# export TASK_ROLE_ARN=
# export TASK_EXE_ROLE_ARN=
# export ECS_DESIRED_COUNT=
# export DB_HOST=
# export DB_USER=
# export DB_PASSWORD=
# export DB_NAME=
# export APP_LOG_LEVEL=
# export APPLICATION_LOG_BUCKET=

current_dir=$(cd $(dirname $0); pwd)

# Register Task Definition
envsubst < $current_dir/taskdef_template.json > $current_dir/taskdef.json
aws ecs register-task-definition --cli-input-json file://$current_dir/taskdef.json
export TASK_DEF_ARN=`aws ecs describe-task-definition --task-definition ${APPLICATION_NAME} | jq '.taskDefinition.taskDefinitionArn' -r`
echo "*** Task Definition Successfully registered. ${TASK_DEF_ARN}"

# Deploy with CodeDeploy
envsubst < $current_dir/appspec_template.yaml > $current_dir/appspec.yaml
aws deploy create-deployment \
    --application-name ${APPLICATION_NAME}\
    --deployment-group-name ${APPLICATION_NAME}\
    --revision revisionType=AppSpecContent,appSpecContent={content=\'"`cat $current_dir/appspec.yaml`"\'}
echo "*** CodeDeploy Successfully started."
aws ecs update-service --cluster ${APPLICATION_NAME} --service ${APPLICATION_NAME} --desired-count ${ECS_DESIRED_COUNT}
echo "*** Desired count of ECS tasks successfully updated to ${ECS_DESIRED_COUNT}."

# Delete temporary file
rm -f $current_dir/taskdef.json
rm -f $current_dir/appspec.yaml
