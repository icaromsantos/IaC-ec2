module "aws-dev" {
  source          = "../../infra"
  instancia       = "t2.micro"
  regiao_aws      = "us-west-2"
  chave           = "IaC-DEV"
  grupo_seguranca = "acesso_geral"
  minimo          = 0
  maximo          = 1
  nomeGrupo       = "DEV"
  producao        = false
}

# obtendo o IP publico da máquina
#output "IP" {
#  value = module.aws-dev.IP_publico
#}
