#!/bin/bash

SERVICE_NAME='dummy'

# check if network is active
if ! docker network inspect network-${SERVICE_NAME} >/dev/null 2>&1; then
	docker network create \
	  --driver overlay \
	  --subnet 10.0.9.0/24 \
	  --gateway 10.0.9.99 \
	  network-${SERVICE_NAME}
else
	echo "The network network-${SERVICE_NAME} already exists"
fi

# verify if services exists
if docker service ls --filter "name=stack-${SERVICE_NAME}_db" | grep -q "stack-${SERVICE_NAME}_db"; then
    echo "The service stack-${SERVICE_NAME}_db will be removed."
	docker service rm stack-${SERVICE_NAME}_db
else
    echo "No service stack-${SERVICE_NAME}_db is running."
fi

if docker service ls --filter "name=stack-${SERVICE_NAME}_wordpress" | grep -q "stack-${SERVICE_NAME}_wordpress"; then
    echo "The service stack-${SERVICE_NAME}_wordpress will be removed."
	docker service rm stack-${SERVICE_NAME}_wordpress
else
    echo "No service stack-${SERVICE_NAME}_wordpress is running."
fi

# create volume if not exist
if ! docker volume inspect stack-${SERVICE_NAME}_wordpress >/dev/null 2>&1; then
	docker volume create --driver local --name stack-${SERVICE_NAME}_wordpress
else
	echo "Volume stack-"${SERVICE_NAME}"_wordpress already exists"
fi

if ! docker volume inspect stack-${SERVICE_NAME}_db-data >/dev/null 2>&1; then
	docker volume create --driver local --name stack-${SERVICE_NAME}_db-data
else
	echo "Volume stack-"${SERVICE_NAME}"_db-data already exists"
fi

docker build $(pwd) -t my_wordpress

# deploy the stack-file-mng stack
docker stack deploy --with-registry-auth --compose-file docker-compose.yml stack-${SERVICE_NAME}

