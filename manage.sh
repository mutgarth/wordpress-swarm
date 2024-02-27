#!/bin/bash

subcommand=$1; shift 
SERVICE_NAME="dummy"

CONTAINER_DB_NAME=$(docker ps --format '{{.Names}}' --filter "name=stack-${SERVICE_NAME}_db")
CONTAINER_WP_NAME=$(docker ps --format '{{.Names}}' --filter "name=stack-${SERVICE_NAME}_wordpress")


case "$subcommand" in
    down)
        service_ids=$(docker service ls -qf "name=stack-$SERVICE_NAME")

        # check for any services with SERVICE_NAME
        if [ -z "$service_ids" ]; then
            echo "No Docker Swarm services found with name 'stack-$SERVICE_NAME'."
            exit 0
        fi

        # remove services if exists
        for service_id in $service_ids; do
            docker service rm "$service_id"
        done

        echo "Removed 'stack-$SERVICE_NAME' from Docker Swarm."
        ;;

    remove-volumes)
        echo "Removing volumes with name 'stack-$SERVICE_NAME'..."
        docker volume rm $(docker volume ls -qf "name=stack-$SERVICE_NAME*")
        echo "Volumes with name 'stack-$SERVICE_NAME' were removed."
        ;;

    load-backup)

        cd $(pwd)/backups && tar -xzvf wp-backup-$SERVICE_NAME.tar.gz

        if [ $# -ne 2 ]; then
            echo "Use: $0 load-backup PASSWORD"
            exit 1
        fi

        USERNAME=$1
        PASSWORD=$2

        if [ -z "$CONTAINER_DB_NAME" ]; then
            echo "No containers with name 'stack-${SERVICE_NAME}_db' were found."
            exit 1
        fi

        echo $(pwd)
        echo "Loading DB backup into ${CONTAINER_DB_NAME}"
        cat backup.sql | docker exec -i $CONTAINER_DB_NAME mysql -u $USERNAME --password=$PASSWORD wordpress

        echo "Loading wp-contant into ${CONTAINER_WP_NAME}"
        cp -r $(pwd)/wp-content $CONTAINER_WP_NAME:/var/www/html/

        ;;

    backup)
        PASSWORD=$1

        [ -d "$(cd ../../ && pwd)/docker-services/ms-${SERVICE_NAME}/backups" ] || mkdir -p "$(pwd)/backups"

        docker exec $CONTAINER_DB_NAME mysqldump -u root -p$PASSWORD wordpress > $(pwd)/backups/backup.sql

        docker cp $CONTAINER_WP_NAME:/var/www/html/wp-content $(pwd)/backups/

        cd $(pwd)/backups/ && tar -czvf $(pwd)/wp-backup-$SERVICE_NAME.tar.gz  .
        ;;
    *)
        echo "Subcomand not found: $subcommand"
        exit 1
        ;;

esac