# AWS SSO Configuration

## Overview

This project is configured to use AWS SSO (Single Sign-On) for authentication with the ocscouts AWS organization.

## SSO Configuration Details

- **SSO Start URL**: `https://ocscouts.awsapps.com/start`
- **SSO Region**: `us-east-1`
- **Account ID**: `423971488961`
- **Role**: `AdministratorAccess`
- **Profile Name**: `AdministratorAccess-423971488961`

## Quick Start

### 1. Initial SSO Setup (One-time)

```bash
# Configure AWS SSO
aws configure sso
# Follow prompts with the values above
```

### 2. Daily Usage

```bash
# Use the helper script (recommended)
./scripts/aws-sso-login.sh

# Or manually export credentials
source <(aws configure export-credentials --profile AdministratorAccess-423971488961 --format env)
```

### 3. Run Terraform

```bash
cd environments/dev  # or prod
terraform plan
terraform apply
```

## Important Notes

### Credential Expiration

- SSO credentials expire after **1 hour**
- You'll need to re-run the login script when they expire
- Terraform will show authentication errors when credentials expire

### Backend Configuration

- The Terraform S3 backend uses **environment variables** for authentication
- No profile is configured in `backend.tf` - this is intentional
- Environment variables take precedence over AWS config files

### Team Usage

- Each team member needs to run `aws configure sso` once
- Daily workflow: run `./scripts/aws-sso-login.sh` before Terraform commands
- The helper script automatically handles login and credential export

## Troubleshooting

### "Profile not found" errors

```bash
aws configure sso  # Reconfigure SSO
```

### "Session expired" errors

```bash
./scripts/aws-sso-login.sh  # Re-login and export credentials
```

### "Access denied" errors

- Verify you have the correct role permissions in AWS SSO
- Check that your SSO session is active in the AWS console

### Backend initialization errors

```bash
# Ensure credentials are exported
source <(aws configure export-credentials --profile AdministratorAccess-423971488961 --format env)
terraform init
```
