
CONTAINER_NAME=""
SOURCE_DIRECTORY=""
IMAGE_NAME="easykivy"
CACHE_DIRECTORY="$(pwd)/.cache"


# Parse parameters
while getopts "hn:s:i:" opt
do
    case $opt in
        n)
            CONTAINER_NAME=$OPTARG
            ;;
        s)
            SOURCE_DIRECTORY=$OPTARG
            ;;
        i)
            IMAGE_NAME=$OPTARG
            ;;
        *)
            echo "Usage: $0 -n NAME -s SOURCE_DIRECTORY [-i IMAGE_NAME]"
            echo "Create a docker container and bind it to the source directory"
            echo
            echo "    -n CONTIANER NAME    The name to use for the docker container."
            echo "    -s SOURCE DIRECTORY  The source directory of the project."
            echo "    -i IMAGE NAME        The name for the docker built image."
            echo
            echo "Notes:"
            echo "    The buildozer.spec and requirements.txt files need to be in the root of the project"
            echo
            echo "Example Usage:"
            echo "    $0 -n my_project_container -s /home/user/projects/my_project"
            exit
            ;;
    esac
done


# Ensure required parameters are passed
if [ -z "$CONTAINER_NAME" ]
then
    echo "Name not specified. Use the -n option"
    exit
fi

if [ -z "$SOURCE_DIRECTORY" ]
then
    echo "Source directory not specified. Use the -s option"
    exit

else

    SOURCE_DIRECTORY=$(realpath $SOURCE_DIRECTORY)

fi

# Ensure cache directory exists
if [ ! -d "$CACHE_DIRECTORY" ]
then

    mkdir "$CACHE_DIRECTORY"
    mkdir "$CACHE_DIRECTORY/home.buildozer"
    chmod 777 -R "$CACHE_DIRECTORY"

fi

# Ensure image exists in the docker
IMAGE_EXISTS=0
IMAGE_GREP=$(docker images --format "{{.Repository}}" | grep "^${IMAGE_NAME}$")
if [ -n "$IMAGE_GREP" ]
then
    IMAGE_EXISTS=1
fi


if [ $IMAGE_EXISTS -eq 0 ]
then

    echo "Image doesn't exist. Building image..."
    cd image
    docker build -t $IMAGE_NAME .
    cd ..
    echo "Image successfully built."

else

    echo "Image already exists"

fi


# Ensure container exists in the docker
CONTAINER_EXISTS=0
CONTAINER_GREP=$(docker ps -a --format "{{.Names}}" | grep "^${CONTAINER_NAME}$")
if [ -n "$CONTAINER_GREP" ]
then
    CONTAINER_EXISTS=1
fi

if [ $CONTAINER_EXISTS -eq 0 ]
then

    echo "Container doesn't exist. Building container..."
    docker create \
        --name $CONTAINER_NAME \
        --volume "$CACHE_DIRECTORY/home.buildozer:/home/builder/.buildozer" \
        -it \
        $IMAGE_NAME
    echo "Container successfully built."

else

    echo "Container already exists."

fi

# Create environment script
echo "Writing environment script"
cat > $SOURCE_DIRECTORY/${CONTAINER_NAME}.env <<EOF
#!/usr/bin/bash

export IMAGE_NAME="${IMAGE_NAME}"
export CONTAINER_NAME="${CONTAINER_NAME}"
export SOURCE_DIRECTORY="${SOURCE_DIRECTORY}"
export EASYKIVY_DIRECTORY="$(pwd)"

easykivy_sync() {
    \$EASYKIVY_DIRECTORY/bin/sync.sh
}

easykivy_build() {
    \$EASYKIVY_DIRECTORY/bin/build.sh
}

easykivy_update_container_scripts() {
    \$EASYKIVY_DIRECTORY/update_container_scripts.sh
}

easykivy_deactivate() {
    unset IMAGE_NAME
    unset CONTAINER_NAME
    unset SOURCE_DIRECTORY
    unset EASYKIVY_DIRECTORY

    unset easykivy_sync
    unset easykivy_build
    unset easykivy_update_container_scripts
    unset easykivy_deactivate
}
EOF



