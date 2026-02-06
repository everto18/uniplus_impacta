# UniPlus Platform - AWS Infrastructure

Infraestrutura AWS moderna, escalável e segura para a plataforma educacional UniPlus.

## 📁 Estrutura do Projeto

```
terraform/
├── environments/           # Configurações por ambiente
│   ├── dev/               # Ambiente de desenvolvimento
│   └── prod/              # Ambiente de produção
├── modules/               # Módulos reutilizáveis
│   ├── networking/        # VPC, Subnets, NAT Gateway
│   ├── security/          # Security Groups, IAM Roles
│   ├── database/          # RDS MySQL Multi-AZ
│   ├── storage/           # S3 Buckets
│   ├── compute/           # ECS Fargate, ALB
│   ├── cdn/               # CloudFront
│   └── video-processing/  # EventBridge, SQS, Lambda, MediaConvert
└── shared/                # Configurações compartilhadas
```

## 🚀 Quick Start

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Credenciais AWS com permissões adequadas

### Deploy do Ambiente Dev

```bash
cd terraform/environments/dev

# Inicializar Terraform
terraform init

# Ver o plano de execução
terraform plan

# Aplicar as mudanças
terraform apply
```

### Deploy do Ambiente Prod

```bash
cd terraform/environments/prod

# Copiar e editar tfvars
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com seus valores

# Inicializar e aplicar
terraform init
terraform plan
terraform apply
```

## 🏗️ Arquitetura

```
                                    ┌─────────────┐
                                    │   Route 53  │
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │ CloudFront  │
                                    │    (CDN)    │
                                    └──────┬──────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
             ┌──────▼──────┐        ┌──────▼──────┐       ┌──────▼──────┐
             │  S3 Assets  │        │     ALB     │       │  S3 Videos  │
             └─────────────┘        └──────┬──────┘       └─────────────┘
                                           │
                                    ┌──────▼──────┐
                                    │ ECS Fargate │
                                    │  (Multi-AZ) │
                                    └──────┬──────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
             ┌──────▼──────┐        ┌──────▼──────┐       ┌──────▼──────┐
             │ RDS MySQL   │        │ ElastiCache │       │     S3      │
             │  (Multi-AZ) │        │   (Redis)   │       │  (Storage)  │
             └─────────────┘        └─────────────┘       └─────────────┘
```

## 🎬 Pipeline de Vídeo

```
Professor → API → S3 Raw → EventBridge → SQS → Lambda → MediaConvert → S3 Processed → CloudFront → Aluno
```

### Outputs do MediaConvert:
- **HLS**: 1080p, 720p, 480p, 360p (adaptive streaming)
- **MP4**: 720p (download)
- **Thumbnails**: 5 frames por vídeo

## 🔐 Segurança

- VPC isolada com subnets públicas/privadas
- Security Groups com least privilege
- Secrets Manager para credenciais
- IAM Roles com permissões mínimas
- Encryption at rest (S3, RDS, EBS)
- VPC Flow Logs habilitado
- CloudFront Origin Access Control

## 💰 Custos Estimados

| Ambiente | Mensal (USD) |
|----------|-------------|
| Dev      | ~$515       |
| Prod     | ~$2,150     |

## 📊 Monitoramento

- CloudWatch Logs
- CloudWatch Metrics & Alarms
- Container Insights (prod)
- Enhanced Monitoring do RDS (prod)

## 📝 Tags (FinOps)

Todas as resources são taggeadas com:
- `Project`: Nome do projeto
- `Environment`: dev/prod
- `ManagedBy`: terraform
- `Team`: Time responsável
- `CostCenter`: Centro de custo
- `Owner`: Email do responsável

## 📚 Documentação Adicional

- [Decisões de Arquitetura](docs/architecture/)
- [Runbooks Operacionais](docs/runbooks/)
- [ADRs](docs/adr/)
