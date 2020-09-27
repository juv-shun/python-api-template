#!/bin/bash -e
SCRIPT_DIR=$(cd $(dirname $0); pwd)
source ${SCRIPT_DIR}/env.sh

aws ecr get-login --no-include-email | sh
docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG} .
echo "docker image successfully built."
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}
echo "docker image successfully pushed."
