## app

This section is used to create and publish a new version of Orca's Web application as a [Docker](https://www.docker.com/) image.

### Requirements

You'll need to have both the [AWS CLI](https://aws.amazon.com/cli/) and the [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/) installed and available.  
The image will be published to our [AWS ECS](https://aws.amazon.com/ecs/) registry (`424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca`).

> [!TIP]  
> You will need to have configured a CLI profile named `ncls` that has **write** access to [ECR](https://aws.amazon.com/ecr/) on the `424880512736` account.
> This profile should provide the *region* as well as the credentials to access the account.

### Usage

- Make sure to have the webapp available under the `webapps/` directory
- Execute `compose.sh <version>`.
