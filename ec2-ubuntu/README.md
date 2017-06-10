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
- Upload the setup code to the EC2 instance:
```shell-script
tar -zcvf setup.tar.gz *.{conf,sh}
scp -i /path/to/pem setup.tar.gz ubuntu@<ip>:/home/ubuntu
```
- Connect onto the instance via SSH for the last step

> **IMPORTANT:** Ensure the DNS records have properly propagated before continuing.
```shell-script
tar -zxvf setup.tar.gz
./setup.sh
```
