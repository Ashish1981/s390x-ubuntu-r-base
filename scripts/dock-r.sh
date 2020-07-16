#!/bin/bash
# @author Ashish Sahoo (ashissah@in.ibm.com)
#
echo "Docker Push Images"
docker push "$DOCKER_USERNAME"/$git_repo:$TRAVIS_BRANCH-$DEPLOY_TIMESTAMP-$TRAVIS_BUILD_NUMBER
docker push "$DOCKER_USERNAME"/$git_repo:latest