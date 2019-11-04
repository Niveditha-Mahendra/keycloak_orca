#!/bin/bash -le

########################################################################################################################
# Initialization                                                                                                       #
########################################################################################################################

if [ -z "$1" ]
then
  echo "Usage: ./deploy.sh <environment>"
  exit 1
fi

if [ -f "config/$1" ]
then
  . "config/$1"
  echo "Deploying to environment: $1"
else
  if [ "$1" == "package" ] && [ -f "../config" ]
  then
    echo "Deploying using packaged release"
    . "../config"
  else
    echo "Unsupported environment: $1"
    exit 1
  fi
fi

########################################################################################################################
# Default Parameters                                                                                                   #
########################################################################################################################

function registerParam {
  name=$1
  default=$2
  value="${!name}"

  if [[ -z "$value" ]];
  then
    export "$name=$default"
  else
    export "$name=$value"
  fi
}

if [[ "$1" == "package" ]];
then
  registerParam "NGINX_DOCKER_IMAGE"                   "${REGISTRY_PREFIX}/ngix:${RELEASE_NAME}"
  registerParam "KEYCLOAK_DOCKER_IMAGE"                "${REGISTRY_PREFIX}/keycloak:${RELEASE_NAME}"
  
 

else
  registerParam "NGINX_DOCKER_IMAGE"                    "nginx:latest"
  registerParam "KEYCLOAK_DOCKER_IMAGE"                 "jboss/keycloak:5.0.0"
fi

########################################################################################################################
# Logic                                                                                                                #
########################################################################################################################

function logMsg() {
  echo $(date +"%T"): $1
}

function logSection() {
  echo
  echo
  logMsg "--------------------------------------------------------------"
  logMsg "--------- $1"
  logMsg "--------------------------------------------------------------"
  echo
}

logSection "Using Docker images:"
echo "keycloak:                $KEYCLOAK_DOCKER_IMAGE"
echo "nginx:                   $NGINX_DOCKER_IMAGE"

logSection "Creating Docker network (unless it already exists)..."

if [ "$ENCRYPT_NETWORK" = "1" ]
then
  echo "------ Turning on encryption for the Docker overlay network"
  ENCRYPTION_FLAG="--opt encrypted=true"
else
  ENCRYPTION_FLAG=""
fi

docker network create --driver=overlay $ENCRYPTION_FLAG --attachable fidor 2>/dev/null || true

if [ "$DEPLOYMENT_TYPE" == "single_node" ]
then
  logSection "Configuring Node Labels ..."

  node=$(docker node ls | head -n2 | tail -n1 | awk '{ print $3 }')

  apps=(ngix keycloak)

  for app in ${apps[@]}
  do
    label="com.fidor.apps.$app=true"

    echo "Adding $label"
    docker node update $node --label-add $label > /dev/null
  done
fi

  echo "Creating folders for volumes ..."

  mkdir -p "${NGINX_VOLUME}"

  echo "copy nginx configuration file"

  cp -a ../nginx/default.conf ${NGINX_VOLUME}/



  echo "Deploying Keycloak..."
  docker stack deploy -c application_stack/docker-stack-keycloak.yml fidor-keycloak


  echo "Deploying NGINX..."
  docker stack deploy -c application_stack/docker-stack-ngix.yml fidor-ngix

echo "Deployment complete"
