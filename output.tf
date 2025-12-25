output "azs" {
    value = data.aws_availability_zones.zones.names
}

### output of vpc id ###
output "vpc_id" {
    value = aws_vpc.main.id
}

### output of public subnet id ###
output "public_subnet_ids" {
    value = aws_subnet.public_subnet[*].id
}

### output of private subnet ids ###
output "private_subnet_ids" {
    value = aws_subnet.private_subnet[*].id
}

### output of database subnet ids ###
output "database_subnet_ids" {
    value = aws_subnet.main[*].id
}

output "database_subnet_groups_ids" {
    value = aws_db_subnet_group.database_subnet_groups.id
}

# output "database_subnet_groups_name" {
#     value = aws_db_subnet_group.database_subnet_groups.name
# }

output "database_subnet_group_name" {
  value = aws_db_subnet_group.default.name
}

