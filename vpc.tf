### VPC Creating ###

resource "aws_vpc" "main" {
  cidr_block = var.cidr_blocks
  instance_tenancy = "default"
  enable_dns_hostnames = var.dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,{
        Name = local.resource_name
    }
  )
}

### IGW Creating ###
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.vpc_tags,{
        Name = local.resource_name
    }
  )
}

### SUbnets #######################################################################################
### public subnet ###
resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnet_cidrs)
    availability_zone = local.azs_names[count.index]
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]

    tags = merge(
        var.common_tags,
        var.public_subnet_cidr_tags,{
            Name = "${local.resource_name}-public-${local.azs_names[count.index]}"
        }
    )
}

### private subnet ###
resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
    availability_zone = local.azs_names[count.index]
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]

    tags = merge(
        var.common_tags,
        var.private_subnet_cidr_tags,{
            Name = "${local.resource_name}-private-${local.azs_names[count.index]}"
        }
    )
}

### database subnet ###
resource "aws_subnet" "main" {
    count = length(var.database_subnet_cidrs)
    availability_zone = local.azs_names[count.index]
    vpc_id     = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]

    tags = merge(
        var.common_tags,
        var.database_subnet_cidr_tags,{
            Name = "${local.resource_name}-database-${local.azs_names[count.index]}"
        }
    )
}

## database subnets groups ###
resource "aws_db_subnet_group" "database_subnet_groups" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.main[*].id

  tags = merge(
      var.common_tags,
      var.database_subnet_group_tags,{
          Name = "${local.resource_name}"
      }
    )
}
# resource "aws_db_subnet_group" "default" {
#   name       = "${local.resource_name}"
#   subnet_ids = aws_subnet.main[*].id

#   tags = merge(
#     var.common_tags,
#     var.database_subnet_group_tags,
#     {
#         Name = "${local.resource_name}"
#     }
#   )
# }



### Elastic ip this is need for nat gateway ###
resource "aws_eip" "nat" {
  domain   = "vpc"
}

### NAt gateway to give the net access to private subnets ###
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
        var.common_tags,
        var.nat_gateway_tags,{
            Name = "${local.resource_name}"
        }
    )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

### Route tables #######################################################################################
### public route table ###
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(
        var.common_tags,
        var.public_route_table_tags,{
            Name = "${local.resource_name}-public"
        }
    )
}

### Private route table ###
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(
        var.common_tags,
        var.private_route_table_tags,{
            Name = "${local.resource_name}-private"
        }
    )
}

### database route table ###
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(
        var.common_tags,
        var.database_route_table_tags,{
            Name = "${local.resource_name}-database"
        }
    )
}

### Assigning routes ###################################################################################
### public route ###
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

### private route ###
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

### database route ###
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

### Subnet Associations ####################################################################################################
### Public subnet Association ###
resource "aws_route_table_association" "public_association" {
    count = length(var.public_subnet_cidrs)
    subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = aws_route_table.public_route_table.id
}

### Private subnet Association ### 
resource "aws_route_table_association" "private_association" {
    count = length(var.private_subnet_cidrs)
    subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = aws_route_table.private_route_table.id
}

### Database subnet association ###
resource "aws_route_table_association" "database_association" {
    count = length(var.database_subnet_cidrs)
    subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
    route_table_id = aws_route_table.database_route_table.id
}