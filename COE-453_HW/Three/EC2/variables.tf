// Variables the module expects as inputs

variable "instance_name" {
    type = string
    description = "Name of EC2 instance"
    default = "EC2 Instance"
}

variable "instance_type" {
    type = string
    description = "Type of EC2 Instance"
    default = "t2.micro"
}