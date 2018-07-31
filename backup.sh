#!/bin/bash
CONTAINER=$1

#mkdir -p backup

VOLUME_MOUNT=$(docker service inspect $1 -f '{{ .Spec.TaskTemplate.ContainerSpec.Mounts }}' | awk '{print $2 " " $3}')

docker service inspect $1 -f '{{range .Spec.TaskTemplate.ContainerSpec.Mounts}}{{println .Source .Target}}{{end}}'
    #| awk '{print $2 " " $3}'

#docker run --rm --volumes-from $CONTAINER -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar $2



