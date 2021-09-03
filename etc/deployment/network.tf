# ############################# Virtual Cloud Network #############################
# resource "oci_core_vcn" "stream_vcn" {
#   cidr_block     = "10.0.0.0/16"
#   compartment_id = var.tenancy_ocid
#   display_name   = "stream_vcn"
#   dns_label      = "vcn"

#   freeform_tags = var.tags
# }

# ############################# Subnet #############################
# resource "oci_core_subnet" "stream_subnet" {
#   cidr_block     = "10.0.0.0/24"
#   compartment_id = var.tenancy_ocid
#   vcn_id         = oci_core_vcn.stream_vcn.id
#   display_name   = "stream_subnet"
#   dns_label      = "subnet"

#   prohibit_internet_ingress  = false
#   prohibit_public_ip_on_vnic = false
#   route_table_id             = oci_core_route_table.stream_route_table.id

#   freeform_tags = var.tags
# }

# ############################# Network Security Group #############################
# resource "oci_core_network_security_group" "stream_nsg" {
#   compartment_id = var.tenancy_ocid
#   vcn_id         = oci_core_vcn.stream_vcn.id
#   display_name   = "stream_nsg"

#   freeform_tags = var.tags
# }

# ############################# Security Rules #############################
# resource "oci_core_network_security_group_security_rule" "stream_network_security_group_ingress" {
#   network_security_group_id = oci_core_network_security_group.stream_nsg.id
#   description = "stream_network_security_group_ingress"
#   direction = "INGRESS"
#   # see: https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
#   protocol = "6" # 6 = TCP
#   stateless = false
#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"
#   tcp_options {
#     destination_port_range {
#       min = 9092
#       max = 9092
#     }
#     source_port_range {
#       min = 9092
#       max = 9092
#     }
#   }
# }

# resource "oci_core_network_security_group_security_rule" "stream_network_security_group_egress" {
#   network_security_group_id = oci_core_network_security_group.stream_nsg.id
#   description = "stream_network_security_group_egress"
#   direction = "EGRESS"
#   # see: https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
#   protocol = "6" # 6 = TCP
#   stateless = false
#   destination = "0.0.0.0/0"
#   destination_type = "CIDR_BLOCK"
#   tcp_options {}
# }

# ############################# Internet Gateway #############################
# resource "oci_core_internet_gateway" "stream_internet_gateway" {
#   compartment_id = var.tenancy_ocid
#   vcn_id         = oci_core_vcn.stream_vcn.id
#   display_name   = "stream_internet_gateway"
#   enabled        = true

#   freeform_tags = var.tags
# }

# ############################# Route Table #############################
# resource "oci_core_route_table" "stream_route_table" {
#   compartment_id = var.tenancy_ocid
#   vcn_id         = oci_core_vcn.stream_vcn.id
#   display_name   = "stream_route_table"
#   route_rules {
#     network_entity_id = oci_core_internet_gateway.stream_internet_gateway.id
#     cidr_block = "0.0.0.0/0"
#   }

#   freeform_tags = var.tags
# }
