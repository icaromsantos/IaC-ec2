module "aws-prod" {
  source          = "../../infra"
  instancia       = "t2.micro"
  regiao_aws      = "us-west-2"
  chave           = "IaC-Prod"
  grupo_seguranca = "seguranca_prod"
  minimo          = 1
  maximo          = 10
  nomeGrupo       = "Prod"
  producao        = true
}

# obtendo o IP publico da máquina
#output "IP" {
#  value = module.aws-prod.IP_publico
#}
