output "amplify_service_roles" {
  description = "Amplify service role ARN per app, keyed like local.amplify_apps."
  value = {
    for key, role in module.amplify_service_role : key => {
      app_id   = local.amplify_apps[key].app_id
      role_arn = role.role_arn
    }
  }
}
