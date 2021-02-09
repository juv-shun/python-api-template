#!/bin/bash -e
set -e

### Please set the following environment variables.
# export AWS_ACCOUNT_ID=
# export APPLICATION_NAME=
# export IMAGE_TAG=

aws ecr get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${IMAGE_TAG} $(cd $(dirname $(dirname $(dirname $0))); pwd)
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:${IMAGE_TAG}
