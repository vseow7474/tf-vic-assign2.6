variable "name_prefix" {
  description = "Name prefix for table"
  type        = string
  default     = "victor"
}

variable "instance_type" {
  description = "Instance type of ec2"
  type        = string
  default     = "t2.micro"
}

# variable "vpc_id" {
#   description = "Virtual private cloud id"
#   type        = string
#   
# }

variable "public_subnet" {
  description = "Choice of deploying to public or private subnet"
  type        = bool
  default     = true
}