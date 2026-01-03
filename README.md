# orca-deploy

Packager project for NCLS Development's [Orca](https://www.orca-solution.com/) solution.

## Usage

1. Build and publish a [Docker](https://www.docker.com/) image of the Web server using the instructions found under [`app/`](./app).
2. Deploy the environment either using either:

   - [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) (see [`eb/`](./eb)), or
   - directly onto a simple [EC2 instance](https://aws.amazon.com/ec2/) (see [`ec2/`](./ec2)).

   The main difference between these two approaches is the SSL setup.

> [!TIP]  
> Don't forget to compile and publish `setup.tag.gz` with each release:
>
> ```shell
> tar --directory ec2/setup -czvf setup.tar.gz .
> ```
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
## eb

> [!WARNING]  
> This method doesn't deploy puppeteer-html2pdf, which is required for PDF generation.

This section creates a application bundle for [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) to run a [Multi-Container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html) with a ready-to-use Orca Web server.

Using Elastic Beanstalk, the SSL certificates are managed via [AWS Certificate Manager (ACM)](https://aws.amazon.com/certificate-manager/) and installed on a front-facing [Elastic Load Balancer (ELB)](https://aws.amazon.com/elasticloadbalancing/). The distributed certificate is a wildcard, whose renewal is automatically handled by ACM.

> [!NOTE]
>
> - **Pro:** Easiest setup possible.
> - **Con:** Uses an ELB (per environment), which is somewhat pricy and downright overkill, considering our current needs.

### Usage

- Create an [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment configured as follows:
  1. Use an Elastic Load Balancer and listen for both HTTP and HTTPS
  2. Select [Multi-Container Docker environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html)
  3. Set up the [required environment variables](#environment-variables)
- Create a `zip` archive from the `Dockerrun.aws.json` and the `nginx-config` directory.
- Upload to the desired [Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/) environment.
## ec2

This section guides you through setting up client configuration and building tools to deploy Orca directly onto an [EC2 instance](https://aws.amazon.com/ec2/).

Managing your own EC2 instance "manually" will use certificates issued by [Let's Encrypt](https://letsencrypt.org/).

> [!NOTE]
>
> - **Pro:** No additional costs, other than the EC2 instance and data transfer.
> - **Con:** More complex setup.

### Usage

1. Launch an EC2 instance configured as follows:

- Choose an instance of type _Amazon Linux 2023 AMI_ (e.g.: `ami-0fc3317b37c1269d3`).
- Pick a preconfigured [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) that opens `HTTP` (`:80/tcp`), `HTTPS` (`:443/tcp`) and `SSH` (`:22/tcp`).

  - Also ensure that `[::]:80`, `[::]:443` and `[::]:22` are open, for IPv6 support.

- Grant it the `ec2-orca-install` [IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) that allows:

  | Policy                               | Service                           | Reason                            |
  | ------------------------------------ | --------------------------------- | --------------------------------- |
  | `AmazonEC2ReadOnlyAccess`            | [EC2](https://aws.amazon.com/ec2) | List instance tags                |
  | `AmazonS3ReadOnlyAccess`             | [S3](https://aws.amazon.com/s3)   | Get client-specific configuration |
  | `AmazonEC2ContainerRegistryReadOnly` | [ECR](https://aws.amazon.com/ecr) | Access Orca's docker container    |

2. Create the DNS record for `<client-id>.orca-solution.com` pointing to the right instance (use an [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)).
3. Set the [expected environment variables](#environment-variables):

   - Edit the [configuration template](/ec2/utils/orca.conf.tpl)
   - Upload it as `<client-id>.conf` in the `orca-clients` S3 bucket (`arn:aws:s3:::orca-clients`).

4. Connect onto the machine and install the latest release via the setup script on `master` branch:

   ```shell
   ssh -i /path/to/key.pem ec2-user@<client-id>.orca-solution.com
   bash <(curl -s https://raw.githubusercontent.com/ccjmne/orca-deploy/master/ec2/utils/deploy.sh)
   ```

> [!TIP]  
> Ensure the DNS records have properly propagated before proceeding to step 4.

### Update Orca

Use the `update.sh` script installed during the deployment in your home directory (`/home/ec2-user`) as follows:

```shell
./update.sh <version>
```

Where `<version>` corresponds to a tag for our web app's Docker container and defaults to `latest`.

### Create new versions of the setup script

Create a new release on GitHub and upload the `setup.tar.gz` archive as an asset, generated as follows:

```shell
tar --directory setup -czvf setup.tar.gz .
```
## Environment variables

| Name                  | Description                                                               |
| --------------------- | ------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`\* | Access Key ID of user with full access to `arn:aws:s3:::orca-resources`   |
| `AWS_SECRET_KEY`\*    | Secret Key of user with full access to `arn:aws:s3:::orca-resources`      |
| `ORCA_DB_HOST`\*      | [RDS](https://aws.amazon.com/rds/) hostname                               |
| `ORCA_DB_NAME`\*      | [RDS](https://aws.amazon.com/rds/) database name                          |
| `ORCA_DB_USER`\*      | Database user name                                                        |
| `ORCA_DB_PASS`\*      | Database user password                                                    |
| `ORCA_DEMO_ENABLED`   | `true` iff the demo mode should be enabled                                |
| `ORCA_INIT_SECRET`    | Used to trigger a (re)initialisation of the database or a demo data reset |
| `CORS_ORIGIN`         | Used to set the `Access-Control-Allow-Origin` header                      |

> **\*** - Required
