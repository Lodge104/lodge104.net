# lodge104.net

Infrastructure as Code for Account-Wide Services

## Terraform

All Terraform lives in [`terraform/`](terraform/). State is stored in the account-wide
`lodge104-terraform-state` S3 bucket (key `lodge104.net/terraform.tfstate`) with S3-native
locking.

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Requirements: Terraform >= 1.10 and AWS credentials for account `423971488961` (`us-east-1`).

### Layout

| Path | Purpose |
| ---- | ------- |
| `terraform/backend.tf` | S3 remote state configuration |
| `terraform/main.tf` | Provider and default tags |
| `terraform/amplify.tf` | Amplify Hosting service roles (one per app) |
| `terraform/modules/amplify-service-role/` | IAM role assumable by Amplify, scoped to one app, with `AmplifyBackendDeployFullAccess` |

### Amplify service roles

Amplify Gen2 apps need a service role so `npx ampx pipeline-deploy` can deploy the backend.
The trust policy only allows `amplify.amazonaws.com` to assume the role on behalf of the specific
app (`aws:SourceArn` / `aws:SourceAccount` conditions).

| App | App ID | Role |
| --- | ------ | ---- |
| registration.lodge104.net | `d1c2x4zpjcxv7w` | `AmplifyServiceRole-registration-lodge104-net` |

**Adding an app:**

1. Add an entry to `local.amplify_apps` in `terraform/amplify.tf` and apply.
2. Attach the role to the app (the Amplify app itself is not managed here):

   ```bash
   aws amplify update-app --app-id <APP_ID> \
     --iam-service-role-arn "$(terraform output -json amplify_service_roles | jq -r '.["<key>"].role_arn')"
   ```
