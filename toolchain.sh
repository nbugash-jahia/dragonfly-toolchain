#!/bin/bash

## Installing the server via Docker
get_dragonfly_src() {
    git_repo_account=dragonflyoss
    git_repo_name=dragonfly
    name=dragonfly-src
    if [[ $# -eq 3 ]]; then
        echo "*******************************************************************"
        echo "** Usage: $0 [folder name] [git repo account] [git repo name]   ***"
        echo "** Usage: $0 dragonflyoss  [Dragonfly] [dragonflyoss]           ***"
        echo "*******************************************************************"
        name=$1
        git_repo_account=$2
        git_repo_name=$3
    fi
    [[ ! -d ${name} ]] \
    && git clone git@github.com:${git_repo_account}/${git_repo_name}.git ${DRAGONFLY_SRC_CODE_LOC}/${name} \
    || echo "The folder ${name} already exists under ${DRAGONFLY_SRC_CODE_LOC}"
}

build_supernode_image() {
    if [[ $# -ne 1 ]]; then
        echo "********************************"
        echo "** Usage: $0 [repo location] ***"
        echo "** Usage: $0 ./dragonfly     ***"
        echo "********************************"
        exit 1;
    fi
    repo_location=$1
    cd ${repo_location}
    docker image prune
    make docker-build-supernode
    cd -
}

get_supernode_docker_image_id() {
    echo "$(docker image ls|grep 'supernode' |awk '{print $3}' | head -n1)"
}

run_supernode_container() {
    if [[ $# -ne 1 ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 ./dragonfly-supernode      ***"
        echo "*******************************************"
        exit 1;
    fi
    local container_name=$1
    local supernodeDockerImageId=get_supernode_docker_image_id
    docker run --name ${container_name} -d -p 8001:8001 -p 8002:8002 ${supernodeDockerImageId}
}

nuke_dragonfly() {
    local container_name=supernode;
    local src_code_location=${DRAGONFLY_SRC_CODE_LOC};
    if [[ $# -eq 2 ]]; then
        echo "******************************************************"
        echo "** Usage: $0 [container name] [src code location]  ***"
        echo "** Usage: $0 supernode dragonfly-src               ***"
        echo "******************************************************"
        container_name=$1;
        src_code_location=$2;
    fi
    echo "Deleting dragonfly from local"
    echo "Removing supernode image..."
    docker image rm --force $(get_supernode_docker_image_id)
    echo "Supernode removed"
    echo "Deleting source code"
    [[ -d ${src_code_location} ]] && rm -rf ${src_code_location} 
    echo "Source code removed"
}

if [[ -z ${DRAGONFLY_SRC_CODE_LOC} ]]; then
    printf "Location of the dragonfly source code: "
    read location
    if [[ -z ${location} ]]; then
        location=${HOME}/.dragonfly-src
    fi
    export DRAGONFLY_SRC_CODE_LOC="${location}"
fi