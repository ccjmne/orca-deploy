## ec2-ubuntu

This section guides you through setting up client configuration and building tools to deploy Orca directly onto an [EC2 instance](https://aws.amazon.com/ec2/).

Managing your own EC2 instance "manually" will use certificates issued by [Let's Encrypt](https://letsencrypt.org/).

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

2. Create the DNS record for `<client id>.orca-solution.com` pointing to the right instance (use an [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)).
3. Set the [expected environment variables](#environment-variables):

   - Edit the [configuration template](/ec2-ubuntu/utils/orca.conf.tpl)
   - Upload it as `<client id>.conf` in the `orca-clients` S3 bucket (`arn:aws:s3:::orca-clients`).

4. Connect onto the machine and install the latest release via the setup script on `master` branch:

   > **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.

   ```shell
   ssh -i /path/to/key.pem ec2-user@<client-id>.orca-solution.com
   bash <(curl -s https://raw.githubusercontent.com/ccjmne/orca-deploy/pre-revamp/ec2-ubuntu/utils/deploy.sh)
   ```

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
