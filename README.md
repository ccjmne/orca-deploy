# orca-deploy

Packager project for NCLS Development's [Orca](https://www.orca-solution.com/) solution.

## Usage

1. Build and publish a [Docker](https://www.docker.com/) image of the Web server using the instructions found under `docker-bundle`.
2. Deploy the environment either using [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) (see [related section](#elastic-beanstalk)) or directly onto a simple [EC2 instance](https://aws.amazon.com/ec2/) (see [related section](#ec2-ubuntu)). The main difference between these two approaches is the SSL setup.

## docker-bundle

This section is used to create and publish a new version of Orca's Web application as a [Docker](https://www.docker.com/) image.

### Requirements

You'll need to have both the [AWS CLI](https://aws.amazon.com/cli/) and the [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/) installed  and available.  
The image will be published to our [AWS ECS](https://aws.amazon.com/ecs/) registry (`424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca`).

You will need to be logged in using:
```shell-script
aws ecr get-login | bash
```

### Usage

- Make sure to have the webapp available under the `webapps/` directory
- Execute `compose.bat <version>`.

## elastic-beanstalk

This section creates a application bundle for [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) to run a [Multi-Container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html) with a ready-to-use Orca Web server.

Using Elastic Beanstalk, the SSL certificates are managed via [AWS Certificate Manager (ACM)](https://aws.amazon.com/certificate-manager/) and installed on a front-facing [Elastic Load Balancer (ELB)](https://aws.amazon.com/elasticloadbalancing/). The distributed certificate is a wildcard, whose renewal is automatically handled by ACM.

> - **Pro:** Easiest setup possible.
> - **Con:** Uses an ELB (per environment), which is somewhat pricy and downright overkill, considering our current needs.

### Usage

- Create an [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment configured as follows:
  1. Use an Elastic Load Balancer and listen for both HTTP and HTTPS
  2. Select [Multi-Container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html)
  3. Set up the [required environment variables](#environment-variables)
- Create a `zip` archive from the `Dockerrun.aws.json` and the `nginx-config` directory.
- Upload to the desired [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment.

## ec2-ubuntu

This section guides you through setting up client configuration and building tools to deploy Orca directly onto an [EC2 instance]([EC2](https://aws.amazon.com/ec2/)).

Managing your own EC2 instance "manually" will use certificates issued by [Let's Encrypt](https://letsencrypt.org/). It might end up somewhat more painful to manage, although their [Certbot](https://certbot.eff.org/) client is very solid when working with NGINX on Ubuntu. The distributed certificates can **not** use wildcards, and thus are issued dynamically for each instance, in turn requiring the corresponding DNS records to have properly propagated before being able to resolve the challenge.

> - **Pro:** No additional costs, other than the EC2 instance and data transfer.
> - **Con:** More complex setup.

### Usage

- Launch an EC2 instance configured as follows:
  1. Choose an instance of type _Ubuntu Server_ (e.g.: `ami-a8d2d7ce`).
  2. Set its `clientid` tag appropriately.
  3. Pick a preconfigured [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) that opens HTTP (:80/tcp), HTTPS (:443/tcp) and SSH (:22/tcp).
- Create the DNS record for `<client id>.orca-solution.com` pointing to the right instance (use an [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)).
- Set the [expected environment variables](#environment-variables):
  1. Edit the `/ec2-ubuntu/orca.conf.tmpl`
  2. Upload it as `<client id>.conf` in the `orca-clients` S3 bucket (`arn:aws:s3:::orca-clients`).
- Upload the setup code to the EC2 instance **OR use the [alternative](#alternatively)**:
```shell-script
tar -zcvf setup.tar.gz *.{conf,sh}
scp -i /path/to/pem setup.tar.gz ubuntu@<ip>:/home/ubuntu
```
- Connect onto the instance via SSH for the last step **OR use the [alternative](#alternatively)**

> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
tar -zxvf setup.tar.gz
./setup.sh
```

### Alternatively

> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
curl -s https://raw.githubusercontent.com/ccjmne/orca-deploy/master/ec2-ubuntu/utils/deploy.sh | bash
```

## Environment variables

| Name | Description |
| --- | --- |
| `AWS_ACCESS_KEY_ID`* | Access Key ID of user with full access to arn:aws:s3:::orca-resources |
| `AWS_SECRET_KEY`* | Secret Key of user with full access to arn:aws:s3:::orca-resources |
| `ORCA_DB_HOST`* | [RDS](https://aws.amazon.com/rds/) hostname |
| `ORCA_DB_NAME`* | [RDS](https://aws.amazon.com/rds/) database name |
| `ORCA_DB_USER`* | Database user name |
| `ORCA_DB_PASS`* | Database user password |
| `ORCA_DEMO_ENABLED` | `true` iff the demo mode should be enabled |
| `ORCA_INIT_SECRET` | Used to trigger a (re)initialisation of the database or a demo data reset |

> **\*** - Required
