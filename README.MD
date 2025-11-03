# AWS Lambda S3 Cloudflare Purger

[![Terraform](https://img.shields.io/badge/Terraform-~>5.0-blue?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-~>5.0-orange?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)](https://www.python.org)
Este projeto provisiona uma função Lambda na AWS que limpa automaticamente o cache de arquivos no Cloudflare sempre que um objeto é criado ou modificado em um bucket S3.

A Lambda é configurada para rodar dentro de uma VPC, garantindo que todas as requisições de API para o Cloudflare saiam de um IP estático (via NAT Gateway).

## 🚀 Funcionalidades

* **Gatilho:** Eventos S3 (`s3:ObjectCreated:*`, `s3:ObjectRemoved:*`).
* **Ação:** Limpa o cache (purge) do arquivo específico no Cloudflare.
* **Rede:** Executa em subnets privadas e usa um NAT Gateway para IP de saída fixo.

## 📦 Deploy (via GitHub Actions)

Este repositório está configurado para deploy automático usando GitHub Actions.

### 1. Pré-requisitos

Antes de rodar, você deve configurar os seguintes **Segredos** no seu repositório GitHub (em `Settings > Secrets and variables > Actions`):

* `AWS_ACCESS_KEY_ID`: Chave de acesso AWS.
* `AWS_SECRET_ACCESS_KEY`: Chave secreta AWS.
* `CLOUDFLARE_API_TOKEN`: Token da API do Cloudflare.
* `CLOUDFLARE_ZONE_ID`: ID da Zona do Cloudflare.
* `S3_BUCKET_NAME`: Nome do bucket S3 (ex: `meusite.com`).
* `CLOUDFLARE_DOMAIN_NAME`: Domínio no Cloudflare (ex: `meusite.com`).
* `VPC_SUBNET_IDS`: IDs das subnets privadas, separadas por vírgula (ex: `subnet-abc,subnet-xyz`).
* `VPC_SECURITY_GROUP_IDS`: IDs dos SGs, separados por vírgula (ex: `sg-123`).

### 2. `main.tf`

* Você também deve atualizar o arquivo `main.tf` para apontar para o seu próprio bucket S3 de armazenamento de estado (terraform state backend).

### 3. Executando o Deploy

Faça um push (ou merge) para o branch `main`. A Action será disparada automaticamente, executando `terraform init`, `plan` e `apply`.