#!/bin/bash
# Builds preconfigured Sandbox X-Road images

cd $(dirname -- "$0")

REGISTRY=
PUSH=false
TAG=
VARIANTS=(ss1 ss2 ss3)
SWAP_JARS=false
XROAD_PROJECT_PATH=

while getopts "r:t:px:" opt; do
  case "${opt}" in
  r)
    REGISTRY="${OPTARG}"
    ;;
  p)
    PUSH=true
    ;;
  t)
    TAG="${OPTARG}"
    ;;
  x)
    XROAD_PROJECT_PATH="${OPTARG}"
    ;;
  *)
    echo "Usage: $0 -r <registry base url> [-t tag] [-p] [-x <xroad project path>]"
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

set -eo pipefail

if [[ -z $REGISTRY ]]; then
  REPO=im/x-road
else
  REPO=${REGISTRY}/im/x-road
fi

if [[ -z $XROAD_PROJECT_PATH ]]; then
  SWAP_JARS=false
else
  SWAP_JARS=true
  echo "Building security server admin ui jar"
  (cd $XROAD_PROJECT_PATH/src && ./gradlew :proxy-ui-api:build -x test -x intTest -x integTest --stacktrace --info)
  cp $XROAD_PROJECT_PATH/src/proxy-ui-api/build/libs/proxy-ui-api-1.0.jar sandbox-xroad-ss/files/proxy-ui-api-1.0.jar
fi

TAG=${TAG:-latest}

echo "Building Central Server image $REPO/central-server:$TAG"
docker build -t $REPO/central-server:$TAG sandbox-xroad-cs
if [[ -n $REGISTRY && $PUSH = true ]]; then
  echo -e "\nPushing central server image to $REGISTRY..."
  docker push $REPO/central-server:$TAG
fi

echo "Building Central Server preconfigured image with PAM authentication $REPO/central-server:$TAG-cs"
docker build -t $REPO/central-server:$TAG-cs \
  --build-arg IMAGE=$REPO/central-server:$TAG \
  -f sandbox-xroad-cs/Dockerfile.preconf \
  sandbox-xroad-cs
if [[ -n $REGISTRY && $PUSH = true ]]; then
  echo -e "\nPushing central server preconfigured image to $REGISTRY..."
  docker push $REPO/central-server:$TAG-cs
fi

echo -e "\nBuilding Security Server image $REPO/security-server:$TAG"
docker build -t $REPO/security-server:$TAG sandbox-xroad-ss
if [[ -n $REGISTRY && $PUSH = true ]]; then
  echo -e "\nPushing security server image to $REGISTRY..."
  docker push $REPO/security-server:$TAG
fi

for s in "${VARIANTS[@]}"; do
  if [[ $SWAP_JARS == true ]]; then
    echo -e "\nBuilding Security Server preconfigured images with IAM authentication $REPO/security-server:$TAG-$s"
    docker build \
      -t $REPO/security-server:$TAG-$s \
      --build-arg IMAGE=$REPO/security-server:$TAG \
      --build-arg CONFIG="${s}_conf_backup.tar" \
      -f sandbox-xroad-ss/Dockerfile.preconf.iam \
      sandbox-xroad-ss
  else
    echo -e "\nBuilding Security Server preconfigured images with PAM authentication $REPO/security-server:$TAG-$s"
    docker build \
      -t $REPO/security-server:$TAG-$s \
      --build-arg IMAGE=$REPO/security-server:$TAG \
      --build-arg CONFIG="${s}_conf_backup.tar" \
      -f sandbox-xroad-ss/Dockerfile.preconf \
      sandbox-xroad-ss
  fi
done

if [[ -n $REGISTRY && $PUSH = true ]]; then
  echo -e "\nPushing security server preconfigured images to $REGISTRY..."
  for s in "${VARIANTS[@]}"; do
    echo -e "\nPushing security server $REPO/security-server:$TAG-$s to $REGISTRY..."
    docker push $REPO/security-server:$TAG-$s
  done
fi
