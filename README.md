# Dockerize-Custom-Odoo-Application
Create odoo and PostgreSQL docker image for your custom modules

# Docker-Compose.yml

This `docker-compose.yml` file defines a multi-container setup for running an Odoo application with a PostgreSQL database using Docker. Here's an explanation of the services, configuration, and how the file structure fits into this:

## 1. Service: `web`
- Purpose: This is the Odoo service, responsible for running the Odoo instance.
- Key configurations:
  - Build Context:
    - `context: ./`: The Docker build context is set to the current directory.
    - `dockerfile`: dockerfile: Specifies that the Dockerfile used to build this service is located in the root directory and is named `dockerfile`.
    - 
  - Depends On:
    - `db`: The Odoo container depends on the PostgreSQL container (`db`) to ensure the database service is started before Odoo.
  - Ports:
    - `8099:8069`: Exposes Odoo's default web interface on port `8099` of your local machine, mapped to Odoo’s internal port `8069`.
    - `8070:8070`: Maps the local port `8070` to Odoo's XML-RPC port for external integrations.
    -  `8072:8072`: Maps the longpolling port, typically used for live updates or chat.
  - Volumes:
    - `odoo-web-data:/var/lib/odoo`: Stores Odoo's persistent data (database filestore, logs, etc.) in a Docker-managed volume.
    - `./odoo.config:/etc/odoo/odoo.conf`: Maps a local configuration file `(odoo.config)` into the container at Odoo's configuration file path `(/etc/odoo/odoo.conf)`.
    - `./custom_addons:/mnt/extra-addons`: Maps your local `custom_addons` directory to `/mnt/extra-addons` in the container, which is Odoo's directory for external/custom modules.
  - Environment Variables:
    - `ODOO_RC=/etc/odoo/odoo.conf`: Tells Odoo to use the configuration file located at `/etc/odoo/odoo.conf` (which is mapped from `odoo.config`).
  - Networks:
    - `webnet`: Connects the `web` service to a network shared with other services (in this case, the `db` service).

## 2. Service: `db`
- Purpose: This is the PostgreSQL service, which acts as the database for the Odoo instance.
- Key configurations:
  - Image:
    - `postgres:12`: Specifies that this service uses the official PostgreSQL version 12 Docker image.
  - Ports:
    - `6432:5432`: Maps the database's internal port `5432` to port `6432` on your local machine, allowing you to connect to PostgreSQL outside of the container.
  - Environment Variables:
    - `POSTGRES_DB=your_db_name`: Defines the initial database name to be created as `your_db_name`.
    -  `POSTGRES_PASSWORD=your_db_passwd`: Sets the password for the `your_passwd` PostgreSQL user.
    -  `POSTGRES_USER=your_db_user`: Defines the PostgreSQL superuser as `your_db_user`.
    -  `PGDATA=/var/lib/postgresql/data/pgdata`: Sets the location for PostgreSQL data storage.
  - Volumes:
    - `odoo-db-data:/var/lib/postgresql/data`: Stores the PostgreSQL data in a Docker-managed volume to persist data between container restarts.
  - Networks:
    - `webnet`: Connects the `db` service to the same network as `web` so Odoo can communicate with PostgreSQL.

## 3. Volumes
- `odoo-web-data`: A named volume to persist Odoo’s data, including the filestore, logs, etc.
- `odoo-db-data`: A named volume to persist PostgreSQL's data, ensuring the database is retained even if the container is destroyed.

## 4. Networks
- `webnet`: A custom Docker network that allows containers to communicate with each other. Both the web (Odoo) and db (PostgreSQL) services are part of this network.

## Explanation of Key Files:
- `odoo.config`: Your Odoo configuration file, containing settings like the database name, user, and ports.
- `custom_addons/`: A directory where you place your custom Odoo modules.
- `dockerfile`: The Dockerfile that builds the Odoo container.
- `docker-compose.yml`: The file that orchestrates the Docker containers for Odoo and PostgreSQL.

This setup ensures that Odoo can run with custom modules and persistent data, connected to a PostgreSQL database.

## * Docker compose file end *


# Dockerfile

This Dockerfile defines the steps to create a custom Odoo 15 Docker image that includes additional dependencies and custom modules. Here's an explanation of each section:

## 1. Base Image 
```sh
FROM odoo:15
```
- Purpose: This line sets the base image for your Docker build. In this case, it uses the official Odoo 15 Docker image, which includes everything needed to run Odoo.

## 2. Copy `requirements.txt` and Install Python Dependencies
```sh
# Copy requirements.txt file into the container
COPY ./requirements.txt ./requirements.txt
```
- Purpose: This command copies the `requirements.txt` file from your local project directory into the container. This file usually lists all the Python dependencies that need to be installed for your custom modules or the Odoo instance to function properly.

```sh
RUN pip install -r ./requirements.txt
```
- Purpose: This line runs `pip` inside the container to install all the Python packages listed in `requirements.txt`.

```sh
RUN pip install psycopg2-binary
```  
- Purpose: This command installs `psycopg2-binary`, a PostgreSQL adapter for Python, required for connecting Odoo to the PostgreSQL database.

## 3. Set the Custom Addons Directory
```sh
ENV ADDONS_PATH=/mnt/extra-addons
```
- Purpose: This sets the environment variable `ADDONS_PATH` to `/mnt/extra-addons`, where custom Odoo modules will be stored and searched by Odoo when starting up.

## 4. Copy Custom Addons
```sh
# Copy your custom module to the specified addons directory
COPY ./custom_addons ./mnt/extra-addons
```
- Purpose: This command copies the `custom_addons` directory from your local machine into the container at the `/mnt/extra-addons` path. This is where your custom Odoo modules will be placed, making them available to Odoo during runtime.

## 5. Set Permissions for Custom Addons
```sh
RUN chmod -R 777 ./mnt/extra-addons
```
- Purpose: This sets read, write, and execute permissions (777) on the /mnt/extra-addons directory and its contents. This ensures that Odoo has the necessary access to the custom modules during runtime.

## 6. Start Odoo
```sh
CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
```
