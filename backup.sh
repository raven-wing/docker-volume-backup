#!/bin/bash
STACK_NAME=$1
BACKUP_DIR=${2:-${HOME}/backup}

help()
{
    echo "dockup is script which purpose is to backup docker swarm volumes"
    echo "This script takes up to 2 arguments:"
    echo "dockup STACK_NAME [BACKUP_DIR]"
    echo "STACK_NAME - name of docker swarm stack - all volumes from this stack will be taken and put into BACKUP_DIR"
    echo "BACKUP_DIR - absolute path to directory where backups should be stored"
    echo "backup file format is \$\(STACK_NAME\)_backup.tar"
    echo "-m MACHINE_NAME - will take it from docker-machine"    
}


tar_volume()
{
    CONTAINER_ID=$1
    DIR_TO_BACKUP=$2
    BACKUP_NAME=$3
    docker run --rm --volumes-from ${CONTAINER_ID} -v ${BACKUP_DIR}:/backup:rw ubuntu tar cf /backup/${BACKUP_NAME}_backup.tar ${DIR_TO_BACKUP}
}


backup()
{
    for TASK_ID in $(get_tasks_from_stack ${STACK_NAME} ) ; do
	echo "TASK_ID: ${TASK_ID}"
	DIR_VOLUMES=$(get_volumes_from_task ${TASK_ID})
	for (( i=0; i<${#DIR_VOLUMES[@]} ; i+=2 )); do
	    DIR_TO_BACKUP="${DIR_VOLUMES[i]}"
	    VOLUME_ID="${DIR_VOLUMES[i+1]}"
	    local CONTAINER_ID=$(get_container_id_from_task_id ${TASK_ID})
	    tar_volume $CONTAINER_ID $DIR_TO_BACKUP $VOLUME_NAME
	done
    done
}


get_volumes_from_task()
{
    docker inspect $1 -f '{{range .Spec.ContainerSpec.Mounts}}{{println .Target .Source}}{{end}}'
}

get_tasks_from_stack()
{
    local STACK_NAME=$1
    docker stack ps $STACK_NAME --no-trunc --filter "desired-state=Running" -q
}

get_container_id_from_task_id()
{
    local TASK_ID=$1
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" $TASK_ID
}


backup

#export STACK_NAME_ID=$(get_containers_id $STACK_NAME)
#get_volumes_list $STACK_NAME | xargs -l bash -c 'backup ${STACK_NAME} ${BACKUP_DIR} $0 $1' >  ${BACKUP_DIR}/${BACKUP_NAME}_backup.tar

# get_volumes_list()
# {
#     docker service inspect $1 -f '{{range .Spec.TaskTemplate.ContainerSpec.Mounts}}{{println .Target .Source}}{{end}}'
# }


# get_containers_id()
# {
#     docker service inspect $1 -f '{{ .ID }}'
# }
