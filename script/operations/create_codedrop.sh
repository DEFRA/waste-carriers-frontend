#!/bin/bash
#set -x

## This script is designed to be run by the jenkins user after a successful build.
## It will create a deployable tarball tagged with the jenkins build number and a timestamp.
## It will deploy the build to ea-dev.

## This script should only be started by the user jenkins
USER=`/usr/bin/whoami`
if [ "$USER" != "jenkins" ]; then
    echo "ERROR: This script should only be run by the user jenkins."
    exit 1
fi

build_dir="/caci/jenkins/jobs/waste-exemplar-frontend/builds"
datestamp=`date +%Y.%m.%d-%H.%M`
baseline_dir="/caci/baselines/wcrs-frontend"
remote_codedrop_dir="/caci/deploys/wcrs-frontend/codedrop"
workspace_dir="/caci/jenkins/jobs/waste-exemplar-frontend/workspace"

echo ""
## Make a record of the jenkins build number.
jenkins_build_number=`ls -l $build_dir | grep ^d | grep -v last | awk '{print $9}' | sort -n | tail -1`
echo "j$jenkins_build_number" > $workspace_dir/jenkins_build_number
echo "jenkins_build_number = $jenkins_build_number"

## Tar up a deployable codedrop.
tarball_name="codedrop-wcrs-frontend-j${jenkins_build_number}-${datestamp}.tgz"
echo "Tarring up this codedrop for deploys to other servers. You can find it here:"
echo "    $baseline_dir/$tarball_name"
cd $workspace_dir
tar -zc --exclude='.git' --exclude='.gitignore' -f "$baseline_dir/$tarball_name" .simplecov *

## Deploy to ea-dev.
echo "Deploying $tarball_name to ea-dev."
ssh wcrs-frontend@ea-dev "rm -fr /caci/deploys/wcrs-frontend/codedrop/*"
scp $baseline_dir/$tarball_name wcrs-frontend@ea-dev:$remote_codedrop_dir/
ssh wcrs-frontend@ea-dev "source /home/wcrs-frontend/.bash_wcrs-frontend_config; \
                          cd /caci/deploys/wcrs-frontend/codedrop; \
                          tar zxf *.tgz; \
                          rm *tgz; \
                          script/operations/deploy.sh"

echo ""
exit 0
