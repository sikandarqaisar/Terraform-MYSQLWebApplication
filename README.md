
# Terraform-MYSQL Web Application

This template is for a VPC containing 2 Subnets(1 for Private Database, 1 for Public WebServer's). Each subnet has an instance. Private instance can only be accessed through the public subnets. It deploys an Internet Gateway, with a default route on the public subnets. It deploys a pair of NAT Gateways, and default routes for them in the private subnets.

## [](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#table-of-contents)Table of contents

-   [What is Terraform?](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#what-is-Terraform)
-   [Terraform module's](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#terraform-module)
-   [How to create the infrastructure](https://github.com/sikandarqaisar/Jenkins-CICD#create-it)
## [](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#what-is-jenkins)What is Terraform


Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.
**What are we creating:**

-   VPC with a /16 ip address range and an internet gateway
-   We are creating an availability zones. For high-availability we need at least two
-   In every availability zone we are creating a subnet with a /24 ip address range
    -   Public subnet convention is 10.x.0.x and Private subnet convention is 10.x.1.x etc..
-   In the public subnet we place a NAT gateway and the LoadBalancer
-   The public subnets are also used in the autoscale group which places instances in them
-  Private subnet contains DataBase Instance and only be access through Public Instance's

## [](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#terraform-module)Terraform module

To be able to create the stated infrastructure we are using Terraform. To allow everyone to use the infrastructure code, this repository contains the code as Terraform modules so it can be easily used by others.

Creating one big module does not really give a benefit of modules. Therefore it consists of different modules. This way it is easier for others to make changes, swap modules or use pieces from this repository even if not setting up EC2 Instances.

Details regarding how a module works or why it is setup is described in the module itself if needed.

Modules need to be used to create infrastructure. For an example on how to use the modules to create a working Infrastructure see  **main.tf** in  **VPCModule**

**Note:**  You need to use Terraform version 0.9.5 and above

### [](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#list-of-modules)List of modules

-   **VPC**
    -   **Template**
    -   **data**
-   **LB-ASG**
    -   **Template**
    -   **data**


### [](https://github.com/sikandarqaisar/Terraform-MYSQLWebApplication#conventions)Conventions

These are the conventions we have in every module

-   Contains  **main.tf**  where all the terraform code is
-   Contains  **outputs.tf**  with the output parameters
-   Contains  **variables.tf**  which sets required attributes
-   For grouping in AWS we set the tag "Environment" everywhere where possible



## Create it

To create a working Infrastructure from this repository see  **prod_var.tfvars**  in main module.
Quick way to create this from the repository as is:

`terraform apply -var-file=dev.tfvarsz`

Actual way for creating everything using the default terraform flow:

```
 terraform init
 terraform plan  -var-file=dev.tfvars
 terraform apply -var-file=dev.tfvars 
```
