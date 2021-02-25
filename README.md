# Guild DevOps

## Setting up the environment
1. Download the repository

    ```
    repo=dragonfly-toolchain ;\
    git clone git@github.com:nbugash-jahia/dragonfly-toolchain.git ${repo}
    ```

2. Export the functions from the `toolchain.sh` script

    ```
    repo=dragonfly-toolchain ;\
    cd ${repo} ;\
    source ./toolchain.sh ;\
    cd -
    ```

    Optional: Add the toolchain.sh script to your `.bashrc`, `.bash_profile`, `.zshrc`, etc so that it'll be available everytime a new terminal gets created
    ```
    repo=dragonfly-toolchain
    ln -s ${repo}/toolchain.sh ${HOME}/.${repo}.sh
    echo "[[ -f ${HOME}/.${repo}.sh ]] && source ${HOME}/.${repo}.sh" >> ${HOME}/.zshrc
    ```

3. Get the dragonfly src code
    ```
    df:install
    ```

### Supernode

#### Building the supernode image

```bash
df:supernode:image:build
```

### Running the supernode container as a Standalone

```bash
container_name=supernode ;\
df:supernode:container:run ${container_name}
```

### Running the supernode container using Docker Compose
```bash
docker-compose up -d
```

### Client
#### Installing the client
```bash
df:client:install
```
#### Uninstall the client
```bash
df:client:uninstall
```

## Tearing down environment
When done or when you want to remove dragonfly from your local workstation, simply using the `nuke_dragonfly` function
```bash
df:nuke
```