############################# Stream Pool #############################
resource "oci_streaming_stream_pool" "oci_stream_pool" {
  name           = "oci_stream_pool"
  compartment_id = var.tenancy_ocid
  kafka_settings {
    auto_create_topics_enable = true
    log_retention_hours       = var.stream_retention_in_hours
    num_partitions            = var.stream_partitions
  }
  # this restricts stream to be used only internally
  # private_endpoint_settings {
  #   nsg_ids             = [oci_core_network_security_group.stream_nsg.id]
  #   private_endpoint_ip = "10.0.0.100"
  #   subnet_id           = oci_core_subnet.stream_subnet.id
  # }

  freeform_tags = var.tags
}

data "oci_identity_tenancy" "oci_tenancy" {
  tenancy_id = var.tenancy_ocid
}

output "stream_user_name" {
  # format :: tenancyName/username/streamPoolId
  value = "${data.oci_identity_tenancy.oci_tenancy.name}/${var.stream_user_name}/${oci_streaming_stream_pool.oci_stream_pool.id}"
}

output "bootstrap_servers" {
  value = join(",", oci_streaming_stream_pool.oci_stream_pool.kafka_settings.*.bootstrap_servers)
}

############################# Stream #############################
resource "oci_streaming_stream" "oci_stream" {
  name = "oci_stream"
  partitions         = var.stream_partitions
  retention_in_hours = var.stream_retention_in_hours
  stream_pool_id     = oci_streaming_stream_pool.oci_stream_pool.id

  freeform_tags = var.tags
}

output "topic_name" {
  value = oci_streaming_stream.oci_stream.name
}

############################# Connect Config #############################
resource "oci_streaming_connect_harness" "oci_connect_harness" {
  compartment_id = var.tenancy_ocid
  name           = "oci_connect_harness"

  freeform_tags = var.tags
}

output "kakfa_connect_topic_status" {
  value = "${oci_streaming_connect_harness.oci_connect_harness.id}-status"
}

output "kakfa_connect_topic_config" {
  value = "${oci_streaming_connect_harness.oci_connect_harness.id}-config"
}

output "kakfa_connect_topic_offset" {
  value = "${oci_streaming_connect_harness.oci_connect_harness.id}-offset"
}
