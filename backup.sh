#!/bin/bash
STACK_NAME=$1
BACKUP_DIR=${2:-/backup}

backup()
{
    echo  "ARGS " $@
    local STACK_NAME_FROM=$1
    local BACKUP_DIR=$2
    local VOLUME_TARGET=$3
    local BACKUP_NAME=$4
    local TASK_ID=($(get_containers_from_stack ${STACK_NAME_FROM}))
    local CONTAINER_ID=$(get_container_id_from_task_id $TASK_ID)
    docker run --rm --volumes-from ${CONTAINER_ID} -v ${BACKUP_DIR}:/backup:rw ubuntu tar cf /backup/${BACKUP_NAME}_backup.tar ${VOLUME_TARGET}
}

get_volumes_list()
{
    docker service inspect $1 -f '{{range .Spec.TaskTemplate.ContainerSpec.Mounts}}{{println .Target .Source}}{{end}}'
}

get_containers_id()
{
    docker service inspect $1 -f '{{ .ID }}'
}

get_containers_from_stack()
{
    local STACK_NAME=$1
    docker service ps $STACK_NAME --no-trunc --filter "desired-state=Running" -q
}

get_container_id_from_task_id()
{
    local TASK_ID=$1
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" $TASK_ID
}

export -f backup
export -f get_containers_from_stack
export -f get_container_id_from_task_id
export STACK_NAME_ID=$(get_containers_id $STACK_NAME)
export STACK_NAME
export BACKUP_DIR

get_volumes_list $STACK_NAME | xargs -l bash -c 'backup ${STACK_NAME} ${BACKUP_DIR} $0 $1'


