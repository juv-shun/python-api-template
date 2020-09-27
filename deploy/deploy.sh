#!/bin/bash -e
SCRIPT_DIR=$(cd $(dirname $0); pwd)
source ${SCRIPT_DIR}/env.sh

ecs-cli compose \
    -p ${SYSTEM_NAME} \
    -f ${SCRIPT_DIR}/docker-compose.yml \
    --ecs-params ${SCRIPT_DIR}/ecs-params.yml \
    service up \
        --target-group-arn ${TARGET_GROUP_ARN} \
        --container-name app \
        --container-port 80 \
        --cluster ${CLUSTER_NAME} \
        --deployment-max-percent 100 \
        --deployment-min-healthy-percent 50 \
        --create-log-groups

echo "service up finished."

ecs-cli compose \
    -p ${SYSTEM_NAME} \
    -f ${SCRIPT_DIR}/docker-compose.yml \
    --ecs-params ${SCRIPT_DIR}/ecs-params.yml \
    service scale \
        --cluster ${CLUSTER_NAME} \
        --deployment-max-percent 200 \
        --deployment-min-healthy-percent 100 \
    2

echo "service scale finished."
