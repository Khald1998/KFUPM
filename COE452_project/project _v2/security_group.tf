# # Security Group
# resource "aws_security_group" "ssh_allowed" {
#     vpc_id = aws_vpc.main.id
    
#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = -1
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     ingress {
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         // Do not use this in production, should be limited to your own IP
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     ingress {
#         from_port = 80
#         to_port = 80
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     tags = {
#         Name = "ssh allowed"
#     }
# }

resource "aws_security_group" "open_door" {
    vpc_id = module.vpc.vpc_id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "open door"
    }
}