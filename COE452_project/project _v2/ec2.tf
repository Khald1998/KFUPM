resource "aws_instance" "main" {
    ami           = data.aws_ami.amazon-linux-2.id
    instance_type          = "t2.micro"
    subnet_id = module.vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.open_door.id]
    key_name = "main-key"

    tags = {
        Name: "connecter"
    }
}