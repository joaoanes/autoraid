## raid.network infra

The [terraform](https://www.terraform.io/) infra files for raid.network
It basically just provisions a ec2 instance with caddy proxying requests to the app server (assumed to be at localhost:4000)

# Prerequisites
Terraform infers AWS information from the aws cli credentials file. You can setup and login to your AWS account [by following these instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

You also require initting terraform. `terraform init` should do the trick.

# Running

`terraform plan` creates a terraform plan to update infra nodes and state

`terraform apply` should plan and apply the plan, in order to update the infra to the currently logged in AWS account

`terraform destroy` brings the infra down
