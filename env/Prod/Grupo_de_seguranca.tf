resource "aws_security_group" "seguranca_prod" {
  name        = "seguranca_prod"
  description = "grupo do Prod"
  # entrada
  ingress {
    # IPv4
    cidr_blocks = ["0.0.0.0/0"]
    # IPv6
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    to_port          = 0
    # "-1" libera todos os protocolos
    protocol = "-1"
  }
  # saída
  egress {
    # IPv4
    cidr_blocks = ["0.0.0.0/0"]
    # IPv6
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    to_port          = 0
    # "-1" libera todos os protocolos
    protocol = "-1"
  }
  tags = {
    Name = "seguranca_prod"
  }
}
