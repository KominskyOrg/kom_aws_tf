# # VPN Configuration

# # Step 1: Create a security group for the VPN
# resource "aws_security_group" "client_vpn_sg" {
#   name   = "${local.org}-${local.env}-vpn-sg"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow VPN traffic on port 443"
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/8"]  # Change to your VPN CIDR range
#     description = "Allow SSH from VPN clients"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = local.tags
# }

# # Step 2: Create Client VPN Endpoint
# resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
#   description      = "Client VPN Endpoint"
#   server_certificate_arn = var.server_certificate_arn  # Needs an ACM SSL certificate ARN
#   authentication_options {
#     type                       = "certificate-authentication"
#     root_certificate_chain_arn  = var.client_certificate_arn
#   }
#   client_cidr_block          = "10.0.0.0/16"  # Change this to the appropriate CIDR block
#   connection_log_options {
#     enabled = false
#   }
#   dns_servers                = ["8.8.8.8", "8.8.4.4"]  # Optional DNS
#   security_group_ids         = [aws_security_group.client_vpn_sg.id]
#   split_tunnel               = true
#   transport_protocol         = "udp"

#   tags = local.tags
# }

# # Step 3: Associate VPN with VPC Subnets
# resource "aws_ec2_client_vpn_network_association" "vpn_association" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
#   subnet_id              = module.vpc.private_subnets[0]  # Use one of your private subnets
# }

# # Step 4: VPN Authorization Rule
# resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
#   target_network_cidr    = local.vpc_cidr  # Allowing access to your VPC CIDR
#   authorize_all_groups   = true
# }

# # Step 5: Route VPN traffic to VPC subnets
# resource "aws_route" "vpn_route" {
#   route_table_id         = module.vpc.private_route_table_ids[0]  # Use the private route table
#   destination_cidr_block = "10.0.0.0/16"  # Change this to match your VPN CIDR
#   gateway_id             = aws_ec2_client_vpn_endpoint.client_vpn.id
# }
