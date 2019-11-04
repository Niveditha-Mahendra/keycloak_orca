#!/bin/bash

set -e

if [ -z "$1" ]
then
  echo "Usage: ./release.sh <environment>"
  exit 1
fi

function gnu_sed {
  if [[ "$(uname)" == "Darwin" ]];
  then
    gsed "$@"
  else
    sed "$@"
  fi
}

cat << "EOF"
  ______________________________________
 / Looks like you are trying to package \
 \ community. Can I help you?           /
  --------------------------------------
    \
     \
      \
                 '-.
       .---._     \ .--'
     /       `-..__)  ,-'
    |    0           /
     --.__,   .__.,`
      `-.___'._\_.'

EOF

mkdir delivery/images

# Pull and save docker images

docker pull nginx:latest
docker save nginx:latest | gzip > delivery/images/nginx.tar.gz

docker pull jboss/keycloak:5.0.0
docker save jboss/keycloak:5.0.0 | gzip > delivery/images/keycloak.tar.gz


# Create the delivery/config file

mv delivery/config{.template,}
gnu_sed -e "/# {DYNAMIC_CONTENT}/ {" -e "r config/$1" -e "d" -e "}" -i delivery/config

# Create mini-orca version just including what we want to ship to the customer

mkdir -p delivery/orca/config
mkdir -p delivery/nginx

cp deploy.sh delivery/orca/deploy.sh
cp -a nginx delivery
cp -a application_stack delivery/orca


# Package everything (no compression since we already have it for the images)

cd delivery
zip -0 -r ../package.zip .
cd ..

exit 0
