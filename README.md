# Guild DevOps

## Setting up the environment
1. Download the repository

    ```
    repo=dragonfly-guild-devops ;\
    git clone git@github.com:nbugash-jahia/dragonfly-guild-devops.git ${repo}
    ```

2. Export the functions from the `toolchain.sh` script

    ```
    repo=dragonfly-guild-devops ;\
    cd ${repo} ;\
    source ./toolchain.sh ;\
    cd -
    ```

    Optional: Add the toolchain.sh script to your `.bashrc`, `.bash_profile`, `.zshrc`, etc so that it'll be available everytime a new terminal gets created
    ```
    repo=dragonfly-guild-devops
    ln -s $(pwd)/${repo}/toolchain.sh ${HOME}/.${repo}.sh
    echo "source ${HOME}/.${repo}.sh" >> ${HOME}/.zshrc
    ```

3. Get the dragonfly src code
    ```
    get_dragonfly_src
    ```

### Supernode

#### Building the supernode image

```bash
repo=dragonfly-guild-devops ;\
build_supernode_image ${repo}
```

### Running the supernode container as a Standalone

```bash
container_name=supernode ;\
run_supernode_container ${container_name}
```

### Running the supernode container using Docker Compose
```bash
docker-compose up -d
```


## Tearing down environment
When done or when you want to remove dragonfly from your local workstation, simply using the `nuke_dragonfly` function
```bash
nuke_dragonfly
```