## eb

> [!WARNING]  
> This method doesn't deploy puppeteer-html2pdf, which is required for PDF generation.

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
