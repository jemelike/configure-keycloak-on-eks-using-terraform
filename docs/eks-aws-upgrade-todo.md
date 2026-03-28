# EKS 21.x and AWS 6.x Upgrade To-Do

Current path forward remains the conservative approach:

- Keep `terraform-aws-modules/eks/aws` on `18.31.2`
- Pin `hashicorp/aws` to `5.x`
- Defer the `21.x` / `6.x` migration to a separate upgrade effort

This checklist is for that later upgrade effort.

## To-Do

- Add explicit provider constraints first so the upgrade is controlled from source, not inferred from the lockfile. Put `aws`, `helm`, and `kubernetes` into a root `required_providers` block.
- Create a dedicated upgrade branch for the EKS/AWS jump. Do not mix it with the current Helm syntax fix or other functional changes.
- Fix the Helm provider syntax now in `terraform/modules/cluster-autoscaler/helm.tf` and `terraform/modules/cluster/main.tf` so the later module/provider upgrade is isolated from unrelated errors.
- Inventory everything tied to the EKS module in this repo before changing versions: cluster config, managed node groups, self-managed behavior, `aws-auth` handling, Helm releases, IRSA or service-account annotations, and `kubectl_manifest` resources.
- Read the EKS module upgrade guides in order, not just v21: v19, v20, then v21. This repo is on `18.31.2`, so the breaking changes stack.
- Pay special attention to the authentication model change in EKS module `21.x`: the module defaults to `authentication_mode = "API_AND_CONFIG_MAP"` and leans on EKS access entries instead of the older `aws-auth`-only model.
- Decide whether this project will keep managing `aws-auth` explicitly, move fully to access entries, or run in a mixed transition state. That decision affects both Terraform code and cluster access safety.
- Review whether `enable_cluster_creator_admin_permissions` should be enabled during migration to prevent accidental lockout while switching auth models.
- Compare current variable names and structures against the `21.x` module inputs. Expect renames and shape changes around node groups, launch template handling, cluster options, and newer EKS features.
- Update the EKS module source in `terraform/modules/cluster/main.tf` from `18.31.2` to a pinned `21.x` release. Prefer a specific minor, not a loose range, for the first migration pass.
- Upgrade the AWS provider only after the EKS module code is updated. The `elastic_gpu_specifications` and `elastic_inference_accelerator` errors came from old module-generated launch template code that is incompatible with AWS provider `6.x`.
- Do not target AWS provider `6.1.0`. That version was removed from the Registry on June 27, 2025. Use a later `6.x` release.
- Regenerate modules and providers with `terraform init -upgrade` after changing constraints, then inspect `.terraform/modules/...` to confirm the old launch-template blocks are gone.
- Run `terraform validate` and then a read-only `terraform plan` in a non-production workspace first. Expect diff noise from provider normalization and possible auth-related resource changes.
- Audit any stateful or one-time resources that may require manual intervention, especially EKS access, config-map ownership, launch templates, and security-group rules created inside the module.
- Check whether any `terraform state mv` or import steps are required based on the v19, v20, and v21 upgrade guides before the first apply.
- Verify cluster access out of band before apply: confirm at least one admin principal can access the cluster if `aws-auth` behavior changes.
- After the first successful plan, review all node-group and launch-template changes separately from cluster control plane changes. Apply only when those diffs are understood.
- After apply, verify cluster health explicitly: EKS API access, node registration, Helm releases, `kubectl_manifest` resources, ingress controller, metrics server, and cluster-autoscaler.
- Once the `21.x` / `6.x` upgrade is stable, remove any temporary compatibility settings left over from the conservative path.

## Recommended Order

1. Pin providers explicitly.
2. Fix Helm syntax.
3. Keep production on `aws 5.x` for now.
4. Do the EKS `18.31.2 -> 21.x` migration in its own branch.
5. Move `aws 5.x -> 6.x` only after the module upgrade is in place.

## References

- EKS module repo and upgrade guides: <https://github.com/terraform-aws-modules/terraform-aws-eks>
- EKS module releases: <https://github.com/terraform-aws-modules/terraform-aws-eks/releases>
- EKS module docs: <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>
- AWS provider releases: <https://github.com/hashicorp/terraform-provider-aws/releases>
- AWS provider 6.1.0 removal announcement: <https://github.com/hashicorp/terraform-provider-aws/issues/43213>
