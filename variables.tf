### Project name ###
variable "project_name" {
    default = ""
    type = string
}

variable "environment" {
    default = "dev"
    type = string
}

variable "common_tags" {
    default = {}
    type = map
}

### VPC variables ###
variable "cidr_blocks" {
    type = string 
    default = "100.0.0.0/16"
}

variable "dns_hostnames" {
    type = bool 
    default = true
}

variable "vpc_tags" {
    type = map 
    default = {}
}

### IGW Variables ###
variable "igw_tags" {
    type = map 
    default = {}
}

### Public subnet variables ###
variable "public_subnet_cidrs" {
    type        = list
    validation {
        condition     = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid public subnet cidr"
    }
}

variable "public_subnet_cidr_tags" {
    type = map 
    default = {}
}

### private subnet variable ###
variable "private_subnet_cidrs" {
    type        = list
    validation {
        condition     = length(var.private_subnet_cidrs) == 2
        error_message = "please provide 2 valid private subnet cidr"
    }
}

variable "private_subnet_cidr_tags" {
    type = map 
    default = {}
}

### database subnet ###
variable "database_subnet_cidrs" {
    type        = list
    validation {
        condition     = length(var.database_subnet_cidrs) == 2
        error_message = "please provide 2 valid database subnet cidr"
    }
}

variable "database_subnet_cidr_tags" {
    default = {}
    type = map
}

### nat gateway ###
variable "nat_gateway_tags" {
    default = {}
    type = map 
}

### Route tables ###
### public route table variables ###
variable "public_route_table_tags" {
    default = {}
    type = map
}

### private route table variables ###
variable "private_route_table_tags" {
    default = {}
    type = map
}

### database  route table variables ###
variable "database_route_table_tags" {
    default = {}
    type = map
}

### database  subnet groups variables ###
variable "database_subnet_group_tags" {
    default = {}
    type = map
}