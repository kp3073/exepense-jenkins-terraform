env                        = "prod"
vpc_cidr                   = "10.255.0.0/16"
public_subnet = ["10.255.0.0/24", "10.255.1.0/24"]
private_subnet = ["10.255.2.0/24", "10.255.3.0/24"]
azs = ["us-east-1a", "us-east-1b"]
account_no                 = "471112727668"
default_vpc_id             = "vpc-01c37a20026cef1d0"
default_vpc_cidr           = "172.31.0.0/16"
default_vpc_route_table_id = "rtb-02b9362c64fce6d6f"
bastion_node_cidr = ["172.31.30.152/32"]
max_size                   = 5
min_size                   = 2
desired_capacity           = 2
kms_key_id                 = "arn:aws:kms:us-east-1:471112727668:key/619416f9-8535-4dfd-b4d4-9d429aada3e7"
project_name = "expense"

#eks

size = 2 #this is node size
instance_type = ["t3.small"]