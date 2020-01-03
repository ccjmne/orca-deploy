# orca-deploy

Packager project for NCLS Development's [Orca](https://www.orca-solution.com/) solution.

## Usage

1. Build and publish a [Docker](https://www.docker.com/) image of the Web server using the instructions found under `docker-bundle`.
2. Deploy the environment either using [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) (see [related section](#elastic-beanstalk)) or directly onto a simple [EC2 instance](https://aws.amazon.com/ec2/) (see [related section](#ec2-ubuntu)). The main difference between these two approaches is the SSL setup.

## Release note

Don't forget to compile and publish `setup.tag.gz` with each release:
```shell-script
cd ec2-ubuntu/
tar -zcvf setup.tar.gz *.{conf,sh} motd
```

---

## docker-bundle

This section is used to create and publish a new version of Orca's Web application as a [Docker](https://www.docker.com/) image.

### Requirements

You'll need to have both the [AWS CLI](https://aws.amazon.com/cli/) and the [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/) installed  and available.  
The image will be published to our [AWS ECS](https://aws.amazon.com/ecs/) registry (`424880512736.dkr.ecr.eu-west-1.amazonaws.com/orca`).

You will need to be logged in using:
```shell-script
aws ecr get-login --no-include-email | bash
```

### Usage

- Make sure to have the web app available under the `webapps/` directory
- Execute `compose.bat <version>`.

---

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

---

## ec2-ubuntu

This section guides you through setting up client configuration and building tools to deploy Orca directly onto an [EC2 instance]([EC2](https://aws.amazon.com/ec2/)).

Managing your own EC2 instance "manually" will use certificates issued by [Let's Encrypt](https://letsencrypt.org/). It might end up somewhat more painful to manage, although their [Certbot](https://certbot.eff.org/) client is very solid when working with NGINX on Ubuntu. The distributed certificates can **not** use wildcards, and thus are issued dynamically for each instance, in turn requiring the corresponding DNS records to have properly propagated before being able to resolve the challenge.

> - **Pro:** No additional costs, other than the EC2 instance and data transfer.
> - **Con:** More complex setup.

### Usage

1. Launch an EC2 instance configured as follows:
  - Choose an instance of type _Ubuntu Server_ (e.g.: `ami-a8d2d7ce`).
  - Set its `clientid` tag appropriately.
  - Pick a preconfigured [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) that opens `HTTP` (`:80/tcp`), `HTTPS` (`:443/tcp`) and `SSH` (`:22/tcp`).
  - Grant it the `ec2-orca-install` [IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) that allows:

| Policy                               | Service                           | Reason                            |
| ------------------------------------ | --------------------------------- | --------------------------------- |
| `AmazonEC2ReadOnlyAccess`            | [EC2](https://aws.amazon.com/ec2) | List instance tags                |
| `AmazonS3ReadOnlyAccess`             | [S3](https://aws.amazon.com/s3)   | Get client-specific configuration |
| `AmazonEC2ContainerRegistryReadOnly` | [ECR](https://aws.amazon.com/ecr) | Access Orca's docker container    |

2. Create the DNS record for `<client id>.orca-solution.com` pointing to the right instance (use an [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)).
3. Set the [expected environment variables](#environment-variables):
  - Edit the [configuration template](/ec2-ubuntu/utils/orca.conf.tpl)
  - Upload it as `<client id>.conf` in the `orca-clients` S3 bucket (`arn:aws:s3:::orca-clients`).
4. Connect onto the machine and install the latest release via the setup script on `master` branch:
> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
ssh -i /path/to/key.pem ubuntu@<client-id>.orca-solution.com
curl -s https://raw.githubusercontent.com/ccjmne/orca-deploy/master/ec2-ubuntu/utils/deploy.sh | bash
```

### Update

Use the `update.sh` script installed during the deployment in your home directory (`/home/ubuntu`) as follows:

```shell-script
./update.sh <version>
```

Where `<version>` corresponds to a tag for our web app's Docker container and defaults to `latest`.

---

## Environment variables

| Name | Description |
| --- | --- |
| `AWS_ACCESS_KEY_ID`* | Access Key ID of user with full access to `arn:aws:s3:::orca-resources` |
| `AWS_SECRET_KEY`* | Secret Key of user with full access to `arn:aws:s3:::orca-resources` |
| `ORCA_DB_HOST`* | [RDS](https://aws.amazon.com/rds/) hostname |
| `ORCA_DB_NAME`* | [RDS](https://aws.amazon.com/rds/) database name |
| `ORCA_DB_USER`* | Database user name |
| `ORCA_DB_PASS`* | Database user password |
| `ORCA_DEMO_ENABLED` | `true` iff the demo mode should be enabled |
| `ORCA_INIT_SECRET` | Used to trigger a (re)initialisation of the database or a demo data reset |
| `CORS_ORIGIN` | Used to set the `Access-Control-Allow-Origin` header |

> **\*** - Required
