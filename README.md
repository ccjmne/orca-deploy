# orca-docker
Docker project for NCLS Development's Orca solution.

# How to use
Make sure [Docker](https://docs.docker.com/#components) and [Docker Compose](https://docs.docker.com/compose/install/#/install-docker-compose) are installed.

1. Create a `docker-compose.yml` (see the [docker-compose section](//github.com/ccjmne/orca-docker/blob/master/README.md#docker-compose))
2. Include the **keystore** to our signed SSL certificate (see the [keystore section](//github.com/ccjmne/orca-docker/blob/master/README.md#keystore))
3. Build (and push) images for each client with docker-compose:  
   ```
   docker-compose build && docker-compose push
   ```
4. Install and run the environments' images using **docker**:
   ```
   docker run -it -d -p=80:8080 -p=443:8443 -v <local-webapps>:/usr/local/tomcat/webapps --name=webserver nclsdevelopment/orca:<version>-<client-name>
   ```
   Where `<local-webapps>` is a directory that will be used to drop in our web apps.
5. *Hot-deploy* the API ([ccjmne/orca-api](//github.com/ccjmne/first-aid-officers-maintenance-api)) and the front-end ([ccjmne/orca-ui](//github.com/ccjmne/first-aid-officers-maintenance-ui)) by uploading them to `<local-webapps>`:  
   `scp -i <identity> <api-war>.war <user>@<host>:<local-webapps>`  
   `scp -i <identity> -R <font-end-dir> <user>@<host>:<local-webapps>/ROOT`

### docker-compose
The `docker-compose.yml` file should use the `version: "2"` notation, in order to use the `args` feature.  
Create one service per client; each built from the unique `Dockerfile` present (translates into `context: .`) with the following `args`:

- `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`: self-explanatory
- `AWS_ACCESS`, `AWS_SECRET`: identity of an IAM user that needs full access access to `arn:aws:s3:::orca-resources/*`
- \*`DEMO`: 'true' activates the demonstration mode, taking control of all the data
- \*`DEMO-CRONWIPE`: [cron expression](http://www.quartz-scheduler.org/documentation/quartz-2.2.x/tutorials/crontrigger.html#format) used to trigger the demo data wiping and resetting
- \*`MEMORY`: additional memory options passed to the JVM

\*: optional argument.

A `docker-compose.yml` configured for *one client* plus *the demo version* could be as follows:

```dockerfile
version: "2"
services:
  webserver-demo:
    image: 'nclsdevelopment/orca:<version>-demo'
    build:
      context: .
      args:
        DB_HOST: <db-host>.eu-west-1.rds.amazonaws.com
        DB_NAME: demo
        DB_USER: <db-user>
        DB_PASS: <db-password>

        AWS_ACCESS: <access-key>
        AWS_SECRET: <secret-key>

        DEMO: 'true'
  webserver-<client-name>:
    image: 'nclsdevelopment/orca:<version>-<client-name>'
    build:
      context: .
      args:
        DB_HOST: <db-host>.eu-west-1.rds.amazonaws.com
        DB_NAME: <client-name>
        DB_USER: <db-user>
        DB_PASS: <db-password>

        AWS_ACCESS: <access-key>
        AWS_SECRET: <secret-key>

        MEMORY: -Xms2048m -Xmx3072m
```

### keystore
The expected keystore file name is `star_formationssecurite_fr.jks`. It should be found in the **working directory**.  
In case this needs to be changed, these expectations are referenced at the [line 21 in the Dockerfile](//github.com/ccjmne/orca-docker/blob/master/docker-compose/Dockerfile#L21).
