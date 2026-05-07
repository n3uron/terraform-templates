# N3uron AWS Templates

Deploy [N3uron](https://n3uron.com) on AWS in minutes with
[OpenTofu](https://opentofu.org) (or [Terraform](https://www.terraform.io/)).
Six ready-to-use templates cover standalone and high-availability setups, with
optional managed database integration (MongoDB Atlas or Tiger Data).

## What is N3uron?

[N3uron](https://n3uron.com) is an Industrial Edge Platform for DataOps that streamlines the flow of
data between industrial devices and business applications, either on-premise or
in the cloud. N3uron provides an out-of-the-box solution for data
standardization, normalization and contextualization, seamless integration with
industrial and IT systems, efficient information management, and unparalleled
scalability and security.

## Templates overview

Choose the template that matches your deployment needs:

| Template | Database | Use case |
|-------|----------|----------|
| `standalone` | None | Simplest deployment — single N3uron instance |
| `standalone-atlas` | MongoDB Atlas | Single instance with MongoDB Atlas as Historian database |
| `standalone-tigerdata` | Tiger Data | Single instance with Tiger Data as Historian database |
| `redundant` | None | High availability — primary + backup in separate AZs |
| `redundant-atlas` | MongoDB Atlas | HA pair with MongoDB Atlas |
| `redundant-tigerdata` | Tiger Data | HA pair with Tiger Data |

**Standalone** stacks deploy a single EC2 instance in one availability zone.

**Redundant** stacks deploy two EC2 instances (primary and backup) in separate
availability zones for high availability.

## Prerequisites

Before you begin, make sure the following are in place. This guide does not cover
how to set up these prerequisites — follow the linked documentation for each one.

- **AWS account** with permissions to create VPCs, subnets, EC2 instances,
  Elastic IPs, security groups, IAM roles, and CloudWatch alarms.
- **IAM access key and secret key**. Create them in the AWS Console → IAM →
  IAM Users → *select your user* → Security credentials → Create access key
  ([Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)),
  **or** use an **AWS CLI** profile already configured
  ([Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) ·
  [Configure a profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)).
- **OpenTofu** (>= 1.6.0) installed
  ([Install guide](https://opentofu.org/docs/intro/install/)).
  Alternatively, you can use **Terraform** (>= 1.6.0) — all commands are the same,
  just replace `tofu` with `terraform`.
- **N3uron AMI subscription** from the AWS Marketplace
  ([Subscribe here](https://aws.amazon.com/marketplace/pp/prodview-ts5qknzpiy2nw)).

> **Important:** An active Marketplace subscription is required for AWS to
> authorize the usage of the AMI. No charges are incurred for the subscription
> itself and it only needs to be done once.

**Additional prerequisites for MongoDB Atlas:**

- **MongoDB Atlas account** with a project already created
  ([Sign up](https://www.mongodb.com/cloud/atlas/register)).
- **Atlas Service Account** with credentials (client ID and client secret). Create
  one in Atlas → Organization → Access Manager → Service Accounts
  ([Documentation](https://www.mongodb.com/docs/atlas/api/service-accounts/)).

**Additional prerequisites for Tiger Data:**

- **Tiger Data account** with a project already created
  ([Sign up](https://console.cloud.timescale.com/signup)).
- **Client credentials** (access key and secret key). Create them in the Tiger Data
  console → Project settings
  ([Documentation](https://docs.timescale.com/use-timescale/latest/security/client-credentials/)).

> **Important:** Make sure billing is enabled in your Tiger Data project before
> deploying, otherwise the deployment will fail.
> Configure it in **Project settings → Billing**.

## Quick start

These steps apply to **any** template. The example below uses `standalone`, but the
process is identical for all six stacks — just replace the folder name.

### 1. Download the templates

Clone the repository:

```bash
git clone https://github.com/N3uron/n3uron-terraform-templates.git
cd n3uron-terraform-templates
```

Alternatively, click **Code → Download ZIP** from the repository page and extract
the archive.

### 2. Select a template

```bash
cd standalone
```

Replace `standalone` with the template you want to deploy (e.g., `standalone-atlas`,
`redundant-tigerdata`, etc.).

### 3. Create a configuration file

Each template includes a `terraform.tfvars.example` file with all available variables
and sensible defaults. Copy it to create your own configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

The `terraform.tfvars` file is where you set your deployment parameters.

### 4. Edit the configuration

Open `terraform.tfvars` in your editor and fill in the required values. At a
minimum, you need to configure:

- **AWS region** — the region where resources will be deployed.
- **AWS authentication** — either an AWS CLI profile name or IAM access keys.
- **Name prefix** — a short identifier used to name all created resources.

The `terraform.tfvars.example` file documents every available option with comments
and default values.

> **Atlas and Tiger Data templates** require additional configuration for their
> respective database services. See [MongoDB Atlas stacks](#mongodb-atlas-stacks)
> or [Tiger Data stacks](#tiger-data-stacks) for details.

### 5. Initialize

Run this command to initialize the template and download the necessary dependencies:

```bash
tofu init
```

### 6. Preview the changes

Before creating any resources, preview what will be created:

```bash
tofu plan
```

This command shows a detailed list of every resource that will be created, modified,
or destroyed — **without actually making any infrastructure changes**.

### 7. Deploy

Apply the configuration to create the infrastructure:

```bash
tofu apply
```

You will be asked for confirmation. Type `yes` to proceed.

> **Note:** This will create real resources in your AWS account which may incur
> costs. Review the [AWS pricing page](https://aws.amazon.com/ec2/pricing/) to
> understand the charges associated with the instance type and resources you
> configured.

Once complete, the **outputs** are printed with the information you need to access
your deployment (WebUI address, initial N3uron password, database connection
address, etc.). See the next section for how to use them.

## Accessing your deployment

After a successful deploy, the outputs are displayed. You can view them
again at any time by running:

```bash
tofu output
```

### N3uron WebUI

Open the `n3uron_web_url` output in your browser to access the N3uron WebUI.

The **initial password** is the EC2 instance ID, shown in the `instance_id` output.
It looks like `i-0abc1234def567890`. You will be prompted to change it on first
login.

> **Redundant stacks** provide two URLs and two instance IDs — one for the primary
> instance (`n3uron_web_url_primary`, `instance_id_primary`) and one for the backup
> (`n3uron_web_url_backup`, `instance_id_backup`).

### SSH access

If you configured a `key_name` and `ssh_cidr_blocks` in your configuration, connect
via SSH:

```bash
ssh -i /path/to/your-key.pem ubuntu@<public_ip>
```

If you did not configure SSH, you can still connect using
[EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html)
from the AWS Console. The `connect_via_console` output provides a direct link.

> **Redundant stacks:** after deploying, follow the
> [N3uron Redundancy configuration guide](https://docs.n3uron.com/docs/redundancy-configuration)
> to set up failover between the primary and backup instances.

## MongoDB Atlas stacks

This section covers the additional configuration required when using an Atlas template
(`standalone-atlas` or `redundant-atlas`). The general deployment steps
([Quick start](#quick-start)) remain the same.

### Atlas configuration

In your `terraform.tfvars`, fill in the **MongoDB Atlas** section:

**Authentication** — credentials for the Atlas API:

- `atlas_client_id` — Service Account client ID.
- `atlas_client_secret` — Service Account client secret.
- `atlas_project_id` — the Atlas project where the cluster will be created.

**Cluster** — instance size and region:

- `atlas_instance_size` — cluster tier. `M0` (free) is the default for testing.
  Use `M10` or higher for production workloads.
- `atlas_cluster_name` — optional custom name (defaults to `<name_prefix>-cluster`).
- `atlas_region_name` — optional region override. By default, the Atlas cluster is
  created in the same region configured for AWS.

**Database** — credentials for the database user:

- `atlas_db_username` — username for the N3uron Historian connection.
- `atlas_db_password` — password for the database user.

### Atlas connection string

After deploying, retrieve the MongoDB connection string:

```bash
tofu output atlas_connection_string_srv
```

This is the URI you will use to configure the N3uron Historian module to connect to
your Atlas cluster. The format looks like:

```
mongodb+srv://<cluster-name>.xxxxx.mongodb.net
```

### Atlas VPC peering

By default, the N3uron instance connects to Atlas over the public internet. To route
traffic over a private network link instead, enable VPC peering
([Atlas VPC peering documentation](https://www.mongodb.com/docs/atlas/security-vpc-peering/)):

```hcl
atlas_vpc_peering = true
atlas_vpc_cidr    = "172.16.0.0/21"   # must not overlap vpc_cidr
```

> **VPC peering requires an M10+ tier.** It is not available on the free (M0) tier.

## Tiger Data stacks

This section covers the additional configuration required when using a Tiger Data
template (`standalone-tigerdata` or `redundant-tigerdata`). The general deployment
steps ([Quick start](#quick-start)) remain the same.

### Tiger Data configuration

In your `terraform.tfvars`, fill in the **Tiger Data** section:

**Authentication** — credentials for the Tiger Data API:

- `ts_project_id` — your Tiger Data project ID.
- `ts_access_key` — public key of the client credentials.
- `ts_secret_key` — secret key of the client credentials.

**Service** — instance sizing:

- `ts_milli_cpu` — CPU allocation in milli-CPU (1000 = 1 vCPU). Default: `500`.
- `ts_memory_gb` — RAM allocation in GB. Default: `2`.
- `ts_service_name` — optional custom name (defaults to `<name_prefix>-tigerdata`).
- `ts_region_code` — optional region override (defaults to `aws_region`).
- `ts_ha_replicas` — number of HA replicas. `0` = none, `1` = high availability,
  `2` = highest availability. Default: `0`.

### Tiger Data connection URI

After deploying, retrieve the connection URI with:

```bash
tofu output tigerdata_uri
```

This output is marked as **sensitive** because it contains the database credentials.
Sensitive outputs are not displayed by default, you must use the command above
to reveal it. The format looks like:

```
postgresql://<user>:<password>@<host>:<port>/tsdb?sslmode=require
```

Use this URI to configure the N3uron Historian module to connect to your Tiger Data
instance.

### Tiger Data VPC peering

By default, the N3uron instance connects to Tiger Data over the public internet. To
route traffic over a private network link instead, enable VPC peering
([Tiger Data VPC peering documentation](https://docs.timescale.com/use-timescale/latest/vpc-peering/)):

```hcl
ts_vpc_peering = true
ts_vpc_cidr    = "10.1.0.0/21"   # must not overlap vpc_cidr
```

## Using an existing VPC

By default, each template creates its own VPC, subnet, internet gateway, and route
table. To deploy into an existing VPC instead, set the following variables:

**Standalone stacks:**

```hcl
existing_vpc_id    = "vpc-xxxxxxxxxxxxxxxxx"
existing_subnet_id = "subnet-xxxxxxxxxxxxxxxxx"
```

**Redundant stacks:**

```hcl
existing_vpc_id            = "vpc-xxxxxxxxxxxxxxxxx"
existing_subnet_id_primary = "subnet-xxxxxxxxxxxxxxxxx"
existing_subnet_id_backup  = "subnet-xxxxxxxxxxxxxxxxx"
```

The two subnets must be in **different availability zones**. When using an existing
VPC, the `vpc_cidr` and `public_subnet_cidr` variables are ignored.

> **Important:** the existing subnet must be a public subnet with an internet gateway
> and a route table that routes `0.0.0.0/0` to the internet gateway. The EC2
> instances need internet access to activate the N3uron license and for AMI updates.

## Updating and redeploying

To change your deployment after the initial deploy:

1. Edit the variables in your `terraform.tfvars` file.
2. Preview the changes:

   ```bash
   tofu plan
   ```

3. Apply the changes:

   ```bash
   tofu apply
   ```

The current state of your infrastructure is tracked automatically. When you run `tofu plan`,
it compares your configuration against the current state and shows exactly what will
change. Some changes (like updating tags) are applied in-place, while others (like
changing the instance type) may require the resource to be replaced.

> **Always review the plan output before applying**, especially when resources are
> marked for replacement — this means they will be destroyed and recreated.

## Destroying the infrastructure

To delete all resources created by a template:

```bash
tofu destroy
```

Every resource that will be destroyed is shown and you will be asked for confirmation.
Type `yes` to proceed.

> **This action is irreversible.** All resources — EC2 instances, VPCs, security
> groups, database clusters, and VPC peering connections — will be permanently
> deleted. Make sure you have backed up any data you need before destroying.
