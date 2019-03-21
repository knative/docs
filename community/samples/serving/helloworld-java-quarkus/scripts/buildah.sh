#!/bin/bash 

# WORK_DIR  the directory where the application binaries are built
# DESTINATION_NAME  - the fully qualified destination image name where the 
# MVN_CMD_ARGS - the maven command arguments e.g. clean install
# build image will deployed e.g. quay.io/myrepo/app:1.0

set -eu

PUSH=${PUSH:-'true'}

cd $WORK_DIR

ARTIFACT_NAME=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.build.finalName -q -DforceStdout)
ARTIFACT_NAME_PKG=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.packaging -q -DforceStdout)

APP_NAME="$ARTIFACT_NAME-runner"

# build the java project 
mvn ${MVN_CMD_ARGS:-clean -DskipTests install -Pnative}

# define the container base image
containerID=$(buildah from registry.fedoraproject.org/fedora-minimal)

# mount the container root FS
appFS=$(buildah mount $containerID)

# make the native app directory
mkdir -p $appFS/deployment

cp target/$APP_NAME  $appFS/deployment/application

chmod +x $appFS/deployment/application

# Add entry  point for the application
buildah config --entrypoint '["/deployment/application"]'  $containerID
buildah config --cmd "\-Dquarkus.http.host=0.0.0.0" $containerID

buildah config --author "devx@redhat.com" --created-by "devx@redhat.com" --label Built-By=buildah $containerID

IMAGEID=$(buildah commit $containerID $DESTINATION_NAME)

echo "Succesfully committed $DESTINATION_NAME with image id $IMAGEID"

# Push the image to regisry 
echo "To push ? $PUSH"

if [ "$PUSH" = "false" ];
then
  echo "Pushing $DESTINATION_NAME to local storage"
  buildah push $IMAGEID oci:/var/lib/containers/storage:$DESTINATION_NAME
else  
  echo "Pushing $DESTINATION_NAME to remote container repository"
  buildah push --tls-verify=false $IMAGEID $DESTINATION_NAME
fi 
