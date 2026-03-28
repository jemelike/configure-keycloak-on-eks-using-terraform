# Terraform Execution Role Permissions

Least-privilege permission set for the IAM principal that runs `terraform plan` and `terraform apply` in this repository.

## Read and discovery

- `sts:GetCallerIdentity`
- `ec2:DescribeAvailabilityZones`
- `ec2:DescribeAccountAttributes`
- `ec2:DescribeVpcs`
- `ec2:DescribeSubnets`
- `ec2:DescribeRouteTables`
- `ec2:DescribeInternetGateways`
- `ec2:DescribeNatGateways`
- `ec2:DescribeAddresses`
- `ec2:DescribeSecurityGroups`
- `ec2:DescribeNetworkInterfaces`
- `ec2:DescribeInstances`
- `ec2:DescribeTags`
- `ec2:DescribeLaunchTemplateVersions`
- `autoscaling:DescribeAutoScalingGroups`
- `autoscaling:DescribeAutoScalingInstances`
- `autoscaling:DescribeLaunchConfigurations`
- `autoscaling:DescribeTags`
- `eks:DescribeCluster`
- `eks:ListClusters`
- `iam:GetRole`
- `iam:ListRoles`
- `iam:GetPolicy`
- `iam:ListPolicies`
- `iam:GetPolicyVersion`
- `iam:ListAttachedRolePolicies`
- `iam:ListInstanceProfilesForRole`
- `kms:DescribeKey`
- `kms:ListAliases`
- `logs:DescribeLogGroups`
- `logs:DescribeLogStreams`
- `rds:DescribeDBClusters`
- `rds:DescribeDBSubnetGroups`
- `rds:DescribeDBParameterGroups`
- `rds:DescribeDBClusterParameterGroups`
- `route53:GetHostedZone`
- `route53:ListHostedZones`
- `route53:ListResourceRecordSets`
- `acm:DescribeCertificate`

## VPC and networking

- `ec2:CreateVpc`
- `ec2:DeleteVpc`
- `ec2:ModifyVpcAttribute`
- `ec2:CreateSubnet`
- `ec2:DeleteSubnet`
- `ec2:ModifySubnetAttribute`
- `ec2:CreateRouteTable`
- `ec2:DeleteRouteTable`
- `ec2:CreateRoute`
- `ec2:ReplaceRoute`
- `ec2:DeleteRoute`
- `ec2:AssociateRouteTable`
- `ec2:DisassociateRouteTable`
- `ec2:CreateInternetGateway`
- `ec2:AttachInternetGateway`
- `ec2:DetachInternetGateway`
- `ec2:DeleteInternetGateway`
- `ec2:AllocateAddress`
- `ec2:ReleaseAddress`
- `ec2:CreateNatGateway`
- `ec2:DeleteNatGateway`
- `ec2:CreateSecurityGroup`
- `ec2:DeleteSecurityGroup`
- `ec2:AuthorizeSecurityGroupIngress`
- `ec2:RevokeSecurityGroupIngress`
- `ec2:AuthorizeSecurityGroupEgress`
- `ec2:RevokeSecurityGroupEgress`
- `ec2:CreateTags`
- `ec2:DeleteTags`

## EKS

- `eks:CreateCluster`
- `eks:DeleteCluster`
- `eks:UpdateClusterConfig`
- `eks:UpdateClusterVersion`
- `eks:CreateNodegroup`
- `eks:UpdateNodegroupConfig`
- `eks:UpdateNodegroupVersion`
- `eks:DeleteNodegroup`
- `eks:TagResource`
- `eks:UntagResource`
- `eks:DescribeNodegroup`

## IAM

- `iam:CreateRole`
- `iam:DeleteRole`
- `iam:UpdateAssumeRolePolicy`
- `iam:CreatePolicy`
- `iam:DeletePolicy`
- `iam:CreatePolicyVersion`
- `iam:DeletePolicyVersion`
- `iam:SetDefaultPolicyVersion`
- `iam:AttachRolePolicy`
- `iam:DetachRolePolicy`
- `iam:PutRolePolicy`
- `iam:DeleteRolePolicy`
- `iam:CreateServiceLinkedRole`
- `iam:PassRole`

## KMS

- `kms:CreateKey`
- `kms:ScheduleKeyDeletion`
- `kms:CancelKeyDeletion`
- `kms:CreateAlias`
- `kms:DeleteAlias`
- `kms:UpdateAlias`
- `kms:PutKeyPolicy`
- `kms:TagResource`
- `kms:UntagResource`

## CloudWatch Logs

- `logs:CreateLogGroup`
- `logs:DeleteLogGroup`
- `logs:PutRetentionPolicy`
- `logs:AssociateKmsKey`
- `logs:DisassociateKmsKey`
- `logs:TagResource`
- `logs:UntagResource`

## RDS Aurora

- `rds:CreateDBSubnetGroup`
- `rds:DeleteDBSubnetGroup`
- `rds:CreateDBParameterGroup`
- `rds:DeleteDBParameterGroup`
- `rds:CreateDBClusterParameterGroup`
- `rds:DeleteDBClusterParameterGroup`
- `rds:ModifyDBParameterGroup`
- `rds:ModifyDBClusterParameterGroup`
- `rds:CreateDBCluster`
- `rds:ModifyDBCluster`
- `rds:DeleteDBCluster`
- `rds:CreateDBInstance`
- `rds:ModifyDBInstance`
- `rds:DeleteDBInstance`
- `rds:AddTagsToResource`
- `rds:RemoveTagsFromResource`

## Route53

- `route53:ChangeResourceRecordSets`

## Kubernetes access during apply

- AWS-side: `eks:DescribeCluster`
- Kubernetes-side: cluster-admin access in the target EKS cluster

## Notes

- Scope `iam:PassRole` to the EKS cluster role and managed node group roles created by Terraform.
- Scope resource-level permissions where possible, but expect `ec2` permissions to remain broad because the VPC and EKS modules create multiple dependent resources.
