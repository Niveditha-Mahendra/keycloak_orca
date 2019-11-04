#!/bin/bash

set -e

if [[ "$DEBUG" == "true" ]];
then
  set -x
fi

echo "Loading all images and pushing them to the configured docker registry."

for image in $IMAGE_LIST;
do
  echo "Loading image $image for release $RELEASE_NAME"

  output="$(gunzip < $root/images/${image}.tar.gz | docker load)"

  if [[ $output == *"Loaded image:"* ]];
  then
    loaded_image_name=$(echo "$output" | head -n1 | cut -d" " -f3)
    new_image_name="${REGISTRY_PREFIX}/${image}:${RELEASE_NAME}"

    docker tag $loaded_image_name $new_image_name
    docker rmi $loaded_image_name
    docker push $new_image_name
  else
    echo "ERROR: Could not detect loaded image."
    exit 1
  fi
done

exit 0
