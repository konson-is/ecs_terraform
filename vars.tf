variable "region" {
  type    = string
  default = "ap-northeast-1"

}

variable "egress-default-rule" {
  type = object({
    description      = string
    protocol         = string
    to_port          = string
    from_port        = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    security_groups  = list(string)
    self             = bool
  })

  default = {
    description      = "Allow all outbound traffic by default"
    protocol         = "-1"
    to_port          = "0"
    from_port        = "0"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}
