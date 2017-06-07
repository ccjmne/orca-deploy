# orca-docker
Packaging project for NCLS Development's Orca solution.

## How to use

- Build and publish a [Docker](https://www.docker.com/) image of the Web server using the instructions found under `docker-compose`.
- Bundle and deploy the [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) application with AWS, following the instructions under `docker-run`.

## docker-compose

This section is used to create and publish a new version of Orca's Web application as a [Docker](https://www.docker.com/) image.

### Requirements

You'll need to have both the [AWS CLI](https://aws.amazon.com/cli/) and the [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/) installed  and available.  
The image will be published to our [AWS ECS](https://aws.amazon.com/ecs/) registry (424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca).

You will need to be logged in using:
```
aws ecr get-login
```

### Usage

- Make sure to have the webapp available under the `webapps/` directory
- Execute `compose.bat <version>`.

## docker-run

This section creates a application bundle for [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) to run a [multi-container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html) with a ready-to-use Orca Web server.

### Usage
- Create a `zip` archive from the `Dockerrun.aws.json` and the `nginx-config` directory.
- Upload to the desired [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment.
