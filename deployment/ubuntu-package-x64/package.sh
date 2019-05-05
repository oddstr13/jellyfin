#!/usr/bin/env bash

source ../common.build.sh

WORKDIR="$( pwd )"

package_temporary_dir="${WORKDIR}/pkg-dist-tmp"
output_dir="${WORKDIR}/pkg-dist"
current_user="$( whoami )"
image_name="jellyfin-ubuntu-build"

# Determine if sudo should be used for Docker
if [[ ! -z $(id -Gn | grep -q 'docker') ]] \
  && [[ ! ${EUID:-1000} -eq 0 ]] \
  && [[ ! ${USER} == "root" ]] \
  && [[ ! -z $( echo "${OSTYPE}" | grep -q "darwin" ) ]]; then
    docker_sudo="sudo"
else
    docker_sudo=""
fi

# Prepare temporary package dir
mkdir -p "${package_temporary_dir}"
# Set up the build environment Docker image
${docker_sudo} docker build ../.. -t "${image_name}" -f ./Dockerfile --build-arg APT_PROXY="${APT_PROXY:-}"
# Build the DEBs and copy out to ${package_temporary_dir}
${docker_sudo} docker run --rm -v "${package_temporary_dir}:/dist" "${image_name}"
# Move the DEBs to the output directory
mkdir -p "${output_dir}"
mv "${package_temporary_dir}"/deb/* "${output_dir}"
