# Terraform GCP Subnet

[![Latest Release](https://img.shields.io/github/release/terraform-gcloud-modules/terraform-gcp-subnet.svg)](https://github.com/terraform-gcloud-modules/terraform-gcp-subnet/releases/latest)
[![tfsec](https://github.com/terraform-gcloud-modules/terraform-gcp-subnet/actions/workflows/security-tfsec.yml/badge.svg)](https://github.com/terraform-gcloud-modules/terraform-gcp-subnet/actions/workflows/security-tfsec.yml)
[![License](https://img.shields.io/badge/License-APACHE-blue.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/Changelog-blue)](CHANGELOG.md)

Terraform module for creating and managing Google Cloud VPC Subnetworks.

This module creates one or more subnets inside a VPC network with full support for custom CIDR ranges, secondary IP ranges (alias IPs for GKE), private Google access, VPC flow logs, IPv6 configuration, subnet purpose and role, and per-resource timeout overrides.

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.14, < 2.0` |
| Google provider | `>= 4.64, < 8` |

---

## Resources

This module creates:

- `google_compute_subnetwork` — one or more VPC subnetworks

---

## Usage

### Basic — single subnet

```hcl
module "subnet" {
  source = "github.com/terraform-gcloud-modules/terraform-gcp-subnet"

  name        = "basic"
  environment = "test"
  label_order = ["environment", "name"]

  project_id = "your-gcp-project-id"
  network    = "your-vpc-network-name"
  gcp_region = "asia-south1"

  subnets = [
    {
      name                     = "main"
      ip_cidr_range            = "10.10.0.0/24"
      region                   = "asia-south1"
      description              = "Basic subnet"
      private_ip_google_access = true
      stack_type               = "IPV4_ONLY"
      secondary_ip_ranges      = []
      log_config               = null
    }
  ]
}
```

See [`examples/basic`](examples/basic) and [`examples/complete`](examples/complete) for full runnable examples.

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name prefix applied to all resources | `string` | `"vpc-test"` | no |t
| `environment` | Environment name e.g. prod, dev, staging | `string` | `"dev"` | no |
| `label_order` | Label order for resource naming | `list(any)` | `[]` | no |
| `project_id` | GCP project ID where resources are created | `string` | — | yes |
| `network` | Self link or name of the parent VPC network | `string` | `""` | yes |
| `gcp_region` | Default region when subnet does not specify one | `string` | — | yes |
| `subnets` | List of subnet objects to create | `list(object)` | `[]` | yes |
| `module_enabled` | Master switch — set `false` to disable all resource creation | `bool` | `true` | no |
| `google_compute_subnetwork_enabled` | Set `false` to skip creating subnetwork resources | `bool` | `true` | no |
| `module_timeouts` | Custom timeout overrides for `google_compute_subnetwork` | `any` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `subnet_ids` | Map of subnet name → subnet ID. Usage: `module.subnet.subnet_ids["web"]` |
| `subnet_names` | Map of subnet name → full GCP resource name |
| `subnet_self_links` | Map of subnet name → self link URI. Pass to GKE node pools, VMs, or other modules |
| `subnet_gateway_addresses` | Map of subnet name → default gateway IP address |
| `subnet_ip_cidr_ranges` | Map of subnet name → primary CIDR range |
| `subnet_regions` | Map of subnet name → GCP region |
| `subnet_projects` | Map of subnet name → GCP project ID |
| `subnet_secondary_ip_ranges` | Map of subnet name → list of secondary IP ranges. Useful when passing GKE ranges to other modules |



---

## Module Dependencies

This module has dependencies on:

- [Labels Module](https://github.com/terraform-gcloud-modules/terraform-gcp-labels) — provides name and label generation

---

## Examples

| Example | Description |
|---------|-------------|
| [`examples/basic`](examples/basic) | Single subnet with default settings |
| [`examples/complete`](examples/complete) | Multiple subnets with secondary ranges, flow logs, and IPv6 |

---

## License

Apache 2.0 — see [LICENSE](LICENSE) for full details.


## 📑 Changelog

Refer [here](CHANGELOG.md).




## ✨ Contributors

Big thanks to our contributors for elevating our project with their dedication and expertise! But, we do not wish to stop there, would like to invite contributions from the community in improving these projects and making them more versatile for better reach. Remember, every bit of contribution is immensely valuable, as, together, we are moving in only 1 direction, i.e. forward. 

<a href="https://github.com/clouddrove/terraform-module-template/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=clouddrove/terraform-module-template&max" />
</a>
<br>
<br>

 If you're considering contributing to our project, here are a few quick guidelines that we have been following (Got a suggestion? We are all ears!):

- **Fork the Repository:** Create a new branch for your feature or bug fix.
- **Coding Standards:** You know the drill.
- **Clear Commit Messages:** Write clear and concise commit messages to facilitate understanding.
- **Thorough Testing:** Test your changes thoroughly before submitting a pull request.
- **Documentation Updates:** Include relevant documentation updates if your changes impact it.


## Feedback 
Spot a bug or have thoughts to share with us? Let's squash it together! Log it in our [issue tracker](https://github.com/clouddrove/terraform-module-template/issues), feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

Show some love with a ★ on [our GitHub](https://github.com/clouddrove/terraform-module-template)!  if our work has brightened your day! – your feedback fuels our journey!


## :rocket: Our Accomplishment

We have [*100+ Terraform modules*][terraform_modules] 🙌. You could consider them finished, but, with enthusiasts like yourself, we are able to ever improve them, so we call our status - improvement in progress.

- [Terraform Module Registry:](https://registry.terraform.io/namespaces/clouddrove) Discover our Terraform modules here.

- [Terraform Modules for AWS/Azure Modules:](https://github.com/clouddrove/toc) Explore our comprehensive Table of Contents for easy navigation through our documentation for modules pertaining to AWS, Azure & GCP. 

- [Terraform Modules for Digital Ocean:](https://github.com/terraform-do-modules/toc) Check out our specialized Terraform modules for Digital Ocean.




## Join Our Slack Community

Join our vibrant open-source slack community and embark on an ever-evolving journey with CloudDrove; helping you in moving upwards in your career path.
Join our vibrant Open Source Slack Community and embark on a learning journey with CloudDrove. Grow with us in the world of DevOps and set your career on a path of consistency.

🌐💬What you'll get after joining this Slack community:

- 🚀 Encouragement to upgrade your best version.
- 🌈 Learning companionship with our DevOps squad.
- 🌱 Relentless growth with daily updates on new advancements in technologies.

Join our tech elites [Join Now][slack] 🚀


## Explore Our Blogs

 Click [here][blog] :books: :star2:

## Tap into our capabilities
We provide a platform for organizations to engage with experienced top-tier DevOps & Cloud services. Tap into our pool of certified engineers and architects to elevate your DevOps and Cloud Solutions. 

At [CloudDrove][website], has extensive experience in designing, building & migrating environments, securing, consulting, monitoring, optimizing, automating, and maintaining complex and large modern systems. With remarkable client footprints in American & European corridors, our certified architects & engineers are ready to serve you as per your requirements & schedule. Write to us at [business@clouddrove.com](mailto:business@clouddrove.com).

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://registry.terraform.io/namespaces/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [blog]: https://blog.clouddrove.com
  [slack]: https://www.launchpass.com/devops-talks
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
