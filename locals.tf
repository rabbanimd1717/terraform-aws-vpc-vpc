locals {
    resource_name = "${var.project_name}-${var.environment}"
    azs_names = slice(data.aws_availability_zones.zones.names, 0, 2)
}