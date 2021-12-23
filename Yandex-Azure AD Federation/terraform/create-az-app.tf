resource "azuread_application" "az-app" {
  display_name              = var.app_name
  # owners                    = [data.azuread_client_config.current.object_id]
  sign_in_audience          = "AzureADMyOrg"
  template_id               = "8adf8e6e-67b2-4cf2-a259-e3dc5476c621"

  app_role {
    allowed_member_types    = ["User"]
    description             = "User"
    display_name            = "User"
    enabled                 = true
    id                      = "18d14569-c3bd-439b-9a66-3a2aee01d14f"
  }

  app_role {
    allowed_member_types    = ["User"]
    description             = "msiam_access"
    display_name            = "msiam_access"
    enabled                 = true
    id                      = "b9632174-c057-4f7e-951b-be3adc52bfe6"
  }

  api {
      oauth2_permission_scope {
        admin_consent_description  = "Allow the application to access ${var.app_name} on behalf of the signed-in user."
        admin_consent_display_name = "Access ${var.app_name}"
        enabled                    = true
        id                         = "8b4bae5e-11c9-4a8d-b3df-16886e1e03ff"
        type                       = "User"
        user_consent_description   = "Allow the application to access ${var.app_name} on your behalf."
        user_consent_display_name  = "Access ${var.app_name}"
        value                      = "user_impersonation"
      }
  }

  feature_tags {
    custom_single_sign_on   = true
    enterprise              = true
    gallery                 = true
  }
}