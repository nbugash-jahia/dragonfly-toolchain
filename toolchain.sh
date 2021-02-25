#!/bin/bash

run_startup() {
    if [[ -z ${DRAGONFLY_SRC_CODE_LOC} ]]; then
        printf "Location of the dragonfly source code [Default: \$HOME/.dragonfly-src]: "
        read location
        if [[ -z ${location} ]]; then
            echo "Setting location to ${HOME}/.dragonfly-src"
            location="${HOME}/.dragonfly-src"
        fi
        intialize_aliases
        export DRAGONFLY_SRC_CODE_LOC="${location}"
    fi
}

## Installing the server via Docker
get_dragonfly_src() {
    if [[ $1 == "--help" ]]; then
        echo "*******************************************************************"
        echo "** Usage: $0 [folder name] [git repo account] [git repo name]   ***"
        echo "** Usage: $0 dragonflyoss  [Dragonfly] [dragonflyoss]           ***"
        echo "*******************************************************************"
        exit 1;
    else
        local git_repo_account=dragonflyoss
        local git_repo_name=dragonfly
        local name="${DRAGONFLY_SRC_CODE_LOC}"
        if [[ $# -eq 3 ]]; then
            name=$1
            git_repo_account=$2
            git_repo_name=$3
        fi
        [[ ! -z ${name} ]] \
        && git clone git@github.com:${git_repo_account}/${git_repo_name}.git ${name} \
        || echo "May need to re-source the toolchain script. Run the following command: source ./toolchain.sh"
    fi
}

build_supernode_image() {
    if [[ $1 == "--help" ]]; then
        echo "********************************"
        echo "** Usage: $0 [repo location] ***"
        echo "** Usage: $0 ./dragonfly     ***"
        echo "********************************"
        exit 1;
    else
        local repo_location=${DRAGONFLY_SRC_CODE_LOC}
        [[ $# -eq 1 ]] && repo_location=$1
        cd ${repo_location}
        make docker-build-supernode
        cd -
    fi
}

build_client() {
    if [[ $1 == "--help" ]]; then
        echo "********************************"
        echo "** Usage: $0 [repo location] ***"
        echo "** Usage: $0 ./dragonfly     ***"
        echo "********************************"
    else
        local repo_location=${DRAGONFLY_SRC_CODE_LOC}
        [[ $# -eq 1 ]] && repo_location=$1
        cd ${repo_location}
        make build-client
        GOOS=$(go env GOOS)
        GOARCH=$(go env GOARCH)
        export PATH="${PATH}:${repo_location}/bin/${GOOS}_${GOARCH}"
        export PATH="${PATH}:${repo_location}/bin/${GOOS}_${GOARCH}"
        cd -
    fi
}

install_client() {
    if [[ $1 == "--help" ]]; then
        echo "********************************"
        echo "** Usage: $0 [repo location] ***"
        echo "** Usage: $0 ./dragonfly     ***"
        echo "********************************"
    else
        local repo_location=${DRAGONFLY_SRC_CODE_LOC}
        [[ $# -eq 1 ]] && repo_location=$1
        cd ${repo_location}
        make install-client
        GOOS=$(go env GOOS)
        GOARCH=$(go env GOARCH)
        export PATH="${PATH}:${repo_location}/bin/${GOOS}_${GOARCH}"
        cd -
    fi
}

uninstall_client() {
    if [[ $1 == "--help" ]]; then
        echo "********************************"
        echo "** Usage: $0 [repo location] ***"
        echo "** Usage: $0 ./dragonfly     ***"
        echo "********************************"
    else
        local repo_location=${DRAGONFLY_SRC_CODE_LOC}
        [[ $# -eq 1 ]] && repo_location=$1
        cd ${repo_location}
        [[ -f "./hack/install.sh" ]] && ./hack/install.sh uninstall uninstall-dfclient
        DFDAEMON_BINARY_NAME=dfdaemon
        DFGET_BINARY_NAME=dfget
        GOOS=$(go env GOOS)
        GOARCH=$(go env GOARCH)
        bin_location="${repo_location}/bin/${GOOS}_${GOARCH}"
        [[ -d "/opt/dragonfly" ]] && rm -rf "/opt/dragonfly"
        [[ -f "${bin_location}/${DFDAEMON_BINARY_NAME}" ]] && rm -rf "${bin_location}/${DFDAEMON_BINARY_NAME}"
        [[ -f "${bin_location}/${DFGET_BINARY_NAME}" ]] && rm -rf "${bin_location}/${DFGET_BINARY_NAME}"
        cd -
    fi

}

get_supernode_docker_image_id() {
    echo "$(docker image ls|grep 'supernode' |awk '{print $3}' | head -n1)"
}

run_supernode_container() {
    if [[ $# -ne 1 ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 dragonfly-supernode        ***"
        echo "*******************************************"
        exit 1;
    fi
    if [[ $1 == "--help" ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 dragonfly-supernode        ***"
        echo "*******************************************"
    else
        local container_name=$1
        local supernodeDockerImageId=$(get_supernode_docker_image_id)
        docker run --name ${container_name} -d -p 8001:8001 -p 8002:8002 ${supernodeDockerImageId}
    fi
}

stop_supernode_container() {
    if [[ $# -ne 1 ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 dragonfly-supernode        ***"
        echo "*******************************************"
        exit 1;
    fi
    if [[ $1 == "--help" ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 dragonfly-supernode        ***"
        echo "*******************************************"
    else
        local container_name=$1
        docker container stop ${container_name}
    fi
}

remove_supernode_container() {
    if [[ $# -ne 1 ]]; then
        echo "*******************************************"
        echo "** Usage: $0 [container name]           ***"
        echo "** Usage: $0 dragonfly-supernode        ***"
        echo "*******************************************"
        exit 1;
    fi
    local container_name=$1
    docker container rm ${container_name}
}

nuke_dragonfly() {
    local container_name=supernode;
    local src_code_location=${DRAGONFLY_SRC_CODE_LOC};
    if [[ $# -eq 2 ]]; then
        echo "****************************************************"
        echo "** Usage: $0 [container_name] [src code location]***"
        echo "** Usage: $0                                     ***"
        echo "****************************************************"
        container_name=$1;
        src_code_location=$2;
    fi
    echo "Deleting client"
    uninstall_client ${src_code_location}
    echo "Client deleted"
    local supernode_container=supernode
    echo "Deleting dragonfly from local"
    echo "Stopping supernode container..."
    local stop_supernode_container ${supernode_container}
    echo "Supernode container stopped"
    echo "Removing supernode container"
    local remove_supernode_container ${supernode_container}
    echo "Supernode container removed"
    echo "Removing supernode image..."
    local supernode_image_id=$(get_supernode_docker_image_id)
    [[ ! -z ${supernode_image_id} ]] \
    && docker image rm --force $(get_supernode_docker_image_id) \
    && echo "Supernode removed" \
    || echo "Supernode image not created."
    echo "Deleting source code"
    [[ -d ${src_code_location} ]] \
    && rm -rf ${src_code_location} \
    echo "Source code removed. Unsetting env DRAGONFLY_SRC_CODE_LOC" \
    && unset DRAGONFLY_SRC_CODE_LOC \
    && echo "DRAGONFLY_SRC_CODE_LOC unsetted" \
    || echo "DRAGONFLY_SRC_CODE_LOC is not set" 
    echo "Deleting hidden files created by Dragonfly"
    [[ -d "${HOME}/.small-dragonfly" ]] \
    && rm -rf ${HOME}/.small-dragonfly
}

print_help() {
    echo "***************************** USAGE ********************************************"
    echo "Here are the list of aliases"
    echo "df:getsrc   = download the dragonfly source code"
    echo "df:nuke     = remove dragonfly from local workstation"
    echo "df:help     = print this help"
    echo "df:install  = download the dragonfly source code"
    echo "df:supernode:image:build = build the supernode docker image"
    echo "df:supernode:image:id    = retrieve the supernode image id"
    echo "df:supernode:image:run [args]    = run the supernode container. Requires a name"
    echo "df:supernode:image:stop [args]   = stop the supernode container. Requires a name"
    echo "df:supernode:image:remove [args] = remove the supernode container. Requires a name"
    echo "df:client:install   = Install the dragonfly client"
    echo "df:client:uninstall = Uninstall the dragonfly client"
    echo "********************************************************************************"
}

intialize_aliases() {
    echo "Creating aliases"
    alias df:getsrc="get_dragonfly_src"
    alias df:install="get_dragonfly_src"
    alias df:nuke="nuke_dragonfly"
    alias df:help="print_help"
    alias df:supernode:image:build="build_supernode_image"
    alias df:supernode:container:run="run_supernode_container"
    alias df:supernode:container:stop="stop_supernode_container"
    alias df:supernode:container:remove="remove_supernode_container"
    alias df:supernode:image:id="get_supernode_docker_image_id" 
    alias df:client:install="install_client"
    alias df:client:unintall="uninstall_client"
}

echo "Running startup script"
run_startup
echo "Startup script done"