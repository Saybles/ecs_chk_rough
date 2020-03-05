variable "profile" {
  description = "AWS IAM profile to use"
  default     = "terra"
}

variable "region" {
  description = "AWS region to use"
  default     = "us-east-2"
}

variable "key_name" {
  default = "UzkyDevOpsAWS"
}


# [{from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "lol"},]
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    self        = bool
  }))

  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow incoming http from anywhere"
      self        = false
    },
  ]
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    self        = bool
  }))

  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outcoming http from anywhere"
      self        = false
    },
  ]
}