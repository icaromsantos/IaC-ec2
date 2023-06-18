terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region = var.regiao_aws
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave
  public_key = file("${var.chave}.pub")
}



###########################################
# ARQUITETURA DE UMA MÁQUINA APENAS       #
###########################################
# Criação de uma instância ec2
#resource "aws_instance" "app_server" {
#  ami             = "ami-00712dae9a53f8c15"
#  instance_type   = var.instancia
#  key_name        = var.chave
#  security_groups = [var.grupo_seguranca]
#  tags = {
#    Name = "terraform Ansible Python"
#  }
#}

# obter o ip publico da máquina criada quando estiver trabalhando com instancia
#output "IP_publico" {
#  value = aws_instance.app_server.public_ip
#}


######################################################
# ARQUITETURA ELÁSTICA                               #
######################################################

#Criação de um template de máquina para criação de novas no autoscalling
resource "aws_launch_template" "maquina" {
  image_id             = "ami-00712dae9a53f8c15"
  instance_type        = var.instancia
  key_name             = var.chave
  security_group_names = [var.grupo_seguranca]
  user_data            = var.producao ? filebase64("ansible.sh") : ""
  tags = {
    Name = "terraform Ansible Python"
  }
}
# criando gupo autoscalling
resource "aws_autoscaling_group" "grupo" {
  # informando os datacenters disponíveis
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"]
  name               = var.nomeGrupo
  max_size           = var.maximo
  min_size           = var.minimo
  launch_template {
    id      = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = var.producao ? [aws_lb_target_group.alvoLoadBalancer[0].arn] : []
}

# Agendamento para ligar máquinas
resource "aws_autoscaling_schedule" "liga" {
  scheduled_action_name = "liga"
  min_size              = 0
  max_size              = 1
  desired_capacity      = 1
  start_time            = timeadd(timestamp(), "10m")
  # Ligar a máquina todo dia as 07 horas, de segunda a sexta
  recurrence             = "0 10 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
}

# Agendamento para desliga máquinas
resource "aws_autoscaling_schedule" "desliga" {
  scheduled_action_name = "desliga"
  min_size              = 0
  max_size              = 1
  desired_capacity      = 1
  start_time            = timeadd(timestamp(), "11m")
  # Ligar a máquina todo dia as 18 horas, de segunda a sexta
  recurrence             = "0 21 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.grupo.name
}

resource "aws_autoscaling_policy" "escala-producao" {
  name                   = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  # especificção da quantidade de recurso a ser utilizado, e é obrigado utiliza [index_recurso]
  count = var.producao ? 1 : 0
}


# criando um load balancer
resource "aws_lb" "loadBalancer" {
  internal = false
  subnets  = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
  # especificção da quantidade de recurso a ser utilizado, e é obrigado utiliza [index_recurso]
  count = var.producao ? 1 : 0
}

# criando uma subnet para uma availability zone
resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
}
# criando uma subnet para uma availability zone
resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
}


#criando o grupo alvo do load balancer
resource "aws_lb_target_group" "alvoLoadBalancer" {
  name     = "maquinasAlvo"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
  # especificção da quantidade de recurso a ser utilizado, e é obrigado utiliza [index_recurso]
  count = var.producao ? 1 : 0
}

# criando um VPC para o nosso grupo alvo
resource "aws_default_vpc" "default" {

}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    # passar a requisição para as máquinas
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer[0].arn
  }
  # especificção da quantidade de recurso a ser utilizado, e é obrigado utiliza [index_recurso]
  count = var.producao ? 1 : 0
}




