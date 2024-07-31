# iac-final-project

O projeto consiste em configurar uma infraestrutura na Azure para uma aplicacao utilizando o Terraform para provisionamento.
Tudo está centralizado no `main.tf`, a pedido da atividade.

## Ferramentas utilizadas:

- **Infraestrutura como código (Iac)**
  - [Terraform](https://www.terraform.io/)
  - [Ansible](https://www.ansible.com/)

- **Cloud**
  - [Azure](https://azure.microsoft.com/pt-br/)

- **Pipeline**
  - [Github Actions](https://docs.github.com/pt/actions)
 

## Configurações Terraform:

- Grupo de Recursos
- Rede Virtual
- Subnet
- IP Público
- Grupo de Segurança de Rede (NSG)
- Regras de Segurança
- Interface de Rede (NIC)
- Máquina Virtual

## Configurações Ansible:
- Update apt cache
- Install Nginx
- Start Nginx
