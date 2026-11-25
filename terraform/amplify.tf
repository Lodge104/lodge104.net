# -----------------------------------------------------------------------------
# Amplify Hosting service roles
#
# One role per Amplify app. To add an app, add an entry to `amplify_apps`,
# apply, then attach the role to the app (see README).
# -----------------------------------------------------------------------------

locals {
  amplify_apps = {
    "registration-lodge104-net" = {
      app_id = "d1c2x4zpjcxv7w"
      name   = "registration.lodge104.net"
      repo   = "Lodge104/registration.lodge104.net"
    }
  }
}

module "amplify_service_role" {
  source   = "./modules/amplify-service-role"
  for_each = local.amplify_apps

  app_id    = each.value.app_id
  app_name  = each.value.name
  role_name = "AmplifyServiceRole-${each.key}"

  tags = {
    AmplifyApp = each.value.name
    AppRepo    = each.value.repo
  }
}
