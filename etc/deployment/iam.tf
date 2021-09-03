data "oci_identity_user" "current_user" {
  user_id = var.user_ocid
}

output "oci_identity_user_current_user" {
  value = data.oci_identity_user.current_user
}

############################# Group #############################
resource "oci_identity_group" "stream_group" {
  compartment_id = var.tenancy_ocid
  description    = "stream group"
  name           = "stream_group"

  freeform_tags = var.tags
}

resource "oci_identity_policy" "stream_group_policy" {
  compartment_id = var.tenancy_ocid
  description    = "stream group policy"
  name           = "stream_group_policy"
  # Allow group <group_name> to <verb> <resource-type> in compartment <compartment_name>
  # Allow group <group_name> to <verb> <resource-type> in tenancy
  statements = [
    "Allow group ${oci_identity_group.stream_group.name} to manage streams in tenancy",
    "Allow group ${oci_identity_group.stream_group.name} to use stream-push in tenancy",
    "Allow group ${oci_identity_group.stream_group.name} to use stream-pull in tenancy",
  ]

  freeform_tags = var.tags
}

output "oci_identity_policy" {
  value = oci_identity_policy.stream_group_policy
}

############################# User #############################
resource "oci_identity_user" "stream_user" {
  compartment_id = var.tenancy_ocid
  description    = "stream user"
  name           = var.stream_user_name
  email          = "${var.stream_user_name}@mail.com"

  freeform_tags = var.tags
}

############################# User Capabilities #############################
resource "oci_identity_user_capabilities_management" "stream_user_capabilities_management" {
  user_id = oci_identity_user.stream_user.id

  can_use_api_keys             = "true"
  can_use_auth_tokens          = "true"
  can_use_console_password     = "false"
  can_use_customer_secret_keys = "true"
  can_use_smtp_credentials     = "true"
}

############################# Group Membership #############################
resource "oci_identity_user_group_membership" "stream_user_group_membership" {
  group_id = oci_identity_group.stream_group.id
  user_id  = oci_identity_user.stream_user.id
}

############################# Auth Token #############################
resource "oci_identity_auth_token" "stream_user_auth_token" {
  description = "stream user auth token"
  user_id     = oci_identity_user.stream_user.id
}

output "stream_user_password" {
  value = oci_identity_auth_token.stream_user_auth_token.token
}

############################# TLS Key #############################
resource "tls_private_key" "stream_user_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

############################# API Key #############################
resource "oci_identity_api_key" "stream_user_api_key" {
  key_value = tls_private_key.stream_user_private_key.public_key_pem
  user_id   = oci_identity_user.stream_user.id
}

output "stream_user_api_key_fingerprint" {
  value = oci_identity_api_key.stream_user_api_key.fingerprint
}

output "stream_user_api_key_value" {
  value = oci_identity_api_key.stream_user_api_key.key_value
}
