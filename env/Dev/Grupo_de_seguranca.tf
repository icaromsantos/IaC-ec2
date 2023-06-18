resource "aws_security_group" "acesso_geral" {
  name        = "acesso_geral"
  description = "grupo do Dev"
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
    Name = "acesso_geral"
  }
}
