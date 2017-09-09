## ec2-ubuntu

This section guides you through setting up client configuration and building tools to deploy Orca directly onto an [EC2 instance]([EC2](https://aws.amazon.com/ec2/)).

Managing your own EC2 instance "manually" will use certificates issued by [Let's Encrypt](https://letsencrypt.org/). It might end up somewhat more painful to manage, although their [Certbot](https://certbot.eff.org/) client is very solid when working with NGINX on Ubuntu. The distributed certificates can **not** use wildcards, and thus are issued dynamically for each instance, in turn requiring the corresponding DNS records to have properly propagated before being able to resolve the challenge.

> - **Pro:** No additional costs, other than the EC2 instance and data transfer.
> - **Con:** More complex setup.

### Usage

1. Launch an EC2 instance configured as follows:
  - Choose an instance of type _Ubuntu Server_ (e.g.: `ami-a8d2d7ce`).
  - Set its `clientid` tag appropriately.
  - Pick a preconfigured [Security Group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) that opens HTTP (:80/tcp), HTTPS (:443/tcp) and SSH (:22/tcp).
2. Create the DNS record for `<client id>.orca-solution.com` pointing to the right instance (use an [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)).
3. Set the [expected environment variables](#environment-variables):
  - Edit the `/ec2-ubuntu/orca.conf.tmpl`
  - Upload it as `<client id>.conf` in the `orca-clients` S3 bucket (`arn:aws:s3:::orca-clients`).
4. Upload the setup code to the EC2 instance **or use the alternative** and **skip to step 6**
```shell-script
tar -zcvf setup.tar.gz *.{conf,sh}
scp -i /path/to/pem setup.tar.gz ubuntu@<ip>:/home/ubuntu
```
5. Connect onto the instance via SSH for the last step **or use the alternative** and **skip to step 6**
> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
tar -zxvf setup.tar.gz
./setup.sh
```
6. **Alternatively** (and _preferably_), if and only if you have skipped steps 4 and 5, download and run the deployment script on the fly:
> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
curl -s https://raw.githubusercontent.com/ccjmne/orca-deploy/master/ec2-ubuntu/utils/deploy.sh | bash
```

### Update

Use the `update.sh` script installed during the deployment in your home directory (`/home/ubuntu`) as follows:

```shell-script
./update.sh <version>
```

Where `<version>` corresponds to a tag for our web app's Docker container and defaults to `latest`.
