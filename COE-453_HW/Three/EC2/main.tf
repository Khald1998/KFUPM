resource "aws_instance" "EC2_Instance" {
    ami = "ami-09d3b3274b6c5d4aa"
    instance_type = "${var.instance_type}"

    tags = {
        Name = "${var.instance_name}"
    }
}
