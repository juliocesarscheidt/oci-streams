provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = "${path.module}/private_key.pem"
  fingerprint      = var.user_key_fingerprint
}
