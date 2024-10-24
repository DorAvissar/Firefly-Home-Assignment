
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-06b21ccaeff8cd686"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "Firefly-EC2"
}


#------------------
# Key Pair Variables
#------------------
variable "key_pair_name" {
  description = "Key Pair for ssh access to instance"
  type        = string
  default     = "my-key-pair" # Replace with your desired key pair name
}

variable "file_name" {
  description = "Name of the key pair file"
  type        = string
  default     = "my-key-pair.pem" # Replace with your desired private key file name
}

