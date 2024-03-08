## app

This section is used to create and publish a new version of Orca's Web application as a [Docker](https://www.docker.com/) image.

### Requirements

You'll need to have both the [AWS CLI](https://aws.amazon.com/cli/) and the [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/) installed  and available.  
The image will be published to our [AWS ECS](https://aws.amazon.com/ecs/) registry (`424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca`).

You will need to be logged in using:
```shell-script
aws ecr get-login-password | docker login --username AWS --password-stdin 424880512736.dkr.ecr.eu-west-1.amazonaws.com
```

### Usage

- Make sure to have the webapp available under the `webapps/` directory
- Execute `compose.bat <version>`.
