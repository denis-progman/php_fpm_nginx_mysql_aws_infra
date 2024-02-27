<p align="center"><img width="250px" src="https://camo.githubusercontent.com/6d6ec94bb2909d75122df9cf17e1940b522a805587c890a2e37a57eba61f7eb1/68747470733a2f2f7777772e6461746f636d732d6173736574732e636f6d2f323838352f313632393934313234322d6c6f676f2d7465727261666f726d2d6d61696e2e737667"></p>


# Custom Terraform builder 

### The PHP-fpm, Nginx, Mysql for AWS cloud infrastructure for a web application

Aloud to create and terminate the infrastructure in AWS to test LAMP app. Saves expenses a lot by this way. 

#### Details
A terraform builder of the website infrastructure using AWS (VPS EC2 RDS S3). By 2 subnets(public/private) and 2 EC2 with NGINX as a proxy and PHP FPM as website engine. __Laravel framework supported!__

### Terminal commands to use
>#### Initialize
>>`terraform init`
>#### Validate
>>`terraform validate`
>#### Plan (pre checking)
>>`terraform plan`
>#### Terraform Apply
>>`terraform apply -auto-approve`
>#### Destroy (removing the built infra)
>>`terraform destroy -auto-approve`

Notice: Needs pre authorized AWS terminal tools for correct work.

