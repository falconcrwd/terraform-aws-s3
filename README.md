## Step 1 - set up OIDC between Github and AWS
Go to IAM > Identity Providers and create an *OpenID Connect* provider with the following OIDC url

```
token.actions.githubusercontent.com
```
and the following audience

```
sts.amazonaws.com
```

## Step 2 - create an IAM role that allows Github actions to write tfstate to S3 and create the SG. Start with the trust policy on the IAM role

Get the Github ORG_ID and REPO_ID
```bash
gh api /orgs/<org-name> --jq .id

gh api /repos/<org-name>/<repo-name> --jq .id
```

Use the following trust policy
```yaml
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:<GITHUB_ORG>@<ORG_ID>/<GITHUB_REPOSITORY>@<REPO_ID>:ref:refs/heads/<GITHUB_BRANCH>"
        }
      }
    }
  ]
}
```

Assign relevant permissions for S3 bucket access (tfstate) and security group, then create the role. A sample permissions policy that allows access to the S3 bucket for tfstate operations and also Security Group operations is below

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TFStateBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::tfstate2508"
        },
        {
            "Sid": "TFStateObjects",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::tfstate2508/*"
        },
        {
            "Sid": "SecurityGroupMgmt",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeTags",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:ModifySecurityGroupRules",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2Read",
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "us-east-1"
                }
            }
        }
    ]
}
```


## Step 3 - get the role ARN in step 2 and create a repository level secret

Based on the workflow, the secret name to use is *TFDEMO_AWS_ROLE_ARN* 



