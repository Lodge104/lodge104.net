# -----------------------------------------------------------------------------
# Amplify Hosting service role
#
# Assumed by Amplify Hosting during builds so `npx ampx pipeline-deploy` can
# deploy the Amplify Gen2 backend (CloudFormation/CDK) for the app.
# https://docs.aws.amazon.com/amplify/latest/userguide/amplify-service-role.html
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  app_arn = "arn:${data.aws_partition.current.partition}:amplify:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:apps/${var.app_id}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AmplifyAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }

    # Confused-deputy protection: only this account's specific Amplify app
    # (and its branches) may assume the role.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [local.app_arn, "${local.app_arn}/*"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = "Amplify Hosting service role for app ${var.app_id} (${var.app_name})"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "backend_deploy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmplifyBackendDeployFullAccess"
}
