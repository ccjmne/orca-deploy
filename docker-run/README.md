## docker-run

This section creates a application bundle for [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) to run a [multi-container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html) with a ready-to-use Orca Web server.

### Usage
- Create a `zip` archive from the `Dockerrun.aws.json` and the `nginx-config` directory.
- Upload to the desired [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment.
