# wordpress-swarm

This file structure helps noobs like me to fast deploy locally a wordpress container within docker swarm.

## What do you need:

1. A unix like system to run the magic stuff (bash script)
2. Docker installed on your system ([just follow the docker documentation](https://docs.docker.com/engine/install/ubuntu/)) 
3. Docker compose
4. Docker swarm activated to use docker secret

## How to use - fresh wordpress installation
1. Change the SERVICE_NAME in files deploy.sh and manage.sh for wathever you want.
2. Create a docker secret password. Run on terminal:
   
   ```
   printf "password" | docker secret create wp_db_password
   ```
3. Create a docker secret username. Run on terminal:
    ```
   printf "username" | docker secret create wp_db_username
   ```
> **Hint:**
> Save your credentials. I am already forgot them and needed to redo everything...

4. Change "db ports", "wordpress ports" and "adminer ports" on docker-compose.yml for whathever you want.
5. Inside the project folder run on terminal:
   ```
   ./deploy.sh
   ```
  > **Attention**
  > The depends_on is not working anymore within docker swarm. Sometimes the db services takes time to up properly and therefore the wordpress page shows "Database error connection" message. You can either wait until db container is online or restart the wordpress container.

## If you need to move your stuffs between servers

### On the old server:
The script creates a .tar.gz file with your wp-content folder and MySQL wordpress database. Just run:
```
./manage.sh backup password
```
Where the password is the password you set with docker secret.

The script creates a backup folder inside the project folder with **your-service-name.tar.gz** compressed file.

### On the new server:
1. Clone the repo on your new server and create a folder **backups** inside it.
2. Transfer the **your-service-name.tar.gz** file from the old server to the folder you just created on the new server.
3. Create a docker secret password. **It must be the same you set on the old server**:
   
   ```
   printf "password" | docker secret create wp_db_password
   ```
4. Create a docker secret username. **It must be the same you set on the old server**::
    ```
   printf "username" | docker secret create wp_db_username
   ```
5. Load the backup files into wordpress and db services:
   ```
   ./manager.sh username password
   ```
Where username and password are the same you set on docker secret (they must be the same since you are using the same project)

You should be able to access your wordpress page with all customizations and posts.

## If you want to delete everything related to the service.
Just run:
```
./manage.sh down
./manage.sh remove-volumes
```
You can run **./manage.sh down remove-volumes** but I recommend to wait a bit before run ./manage.sh remove-volumes since ./manage.sh down takes times to properly remove services. If you face any error related to the volumes being used by services run the ./manage.sh remove-volumes again.

## Things to fix/improve

- Auto backup folder creation.
- Trigger wordpress service on docker-compose after db service healthcheck
- Implement a rountine to check if ./manage.sh down is completed before rurn ./manage.sh remove-volumes
