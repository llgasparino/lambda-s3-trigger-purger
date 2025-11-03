variable "aws_region" {
  description = "Região da AWS para provisionar os recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome base para os recursos (ex: 's3-cache-purger')."
  type        = string
  default     = "s3-cache-purger"
}

variable "s3_bucket_name" {
  description = "Nome exato do bucket S3 que disparará a Lambda."
  type        = string
}

variable "cloudflare_domain_name" {
  description = "Domínio base para montar a URL de purge (ex: 'meusite.com')."
  type        = string
}

# --- Configuração de Rede (VPC) ---
# Em vez de uma lista, usamos uma string separada por vírgula
# Isso é MUITO mais fácil de passar via GitHub Secrets

variable "vpc_subnet_ids" {
  description = "IDs das subnets PRIVADAS, separadas por vírgula (ex: 'subnet-abc,subnet-xyz')."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "IDs dos Security Groups, separados por vírgula (ex: 'sg-123')."
  type        = string
}

# --- Segredos Injetados pela Pipeline ---

variable "cloudflare_api_token" {
  description = "Token da API do Cloudflare."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "ID da Zona do Cloudflare."
  type        = string
  sensitive   = true
}