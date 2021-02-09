#!/bin/bash -e
set -e

source $(cd $(dirname $0); pwd)/env.sh

aws ecr get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${IMAGE_TAG} ../..
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${IMAGE_TAG}
