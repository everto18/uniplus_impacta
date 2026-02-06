# UniPlus - Arquitetura da Plataforma

![Diagrama de Arquitetura AWS](/home/evert/Projetos/bootcamp/docs/architecture-diagram.png)

## Visão Geral

```mermaid
graph TB
    subgraph "Internet"
        USER[👤 Usuários]
        ADMIN[👨‍💼 Admin]
    end

    subgraph "AWS Cloud - sa-east-1"
        subgraph "Edge"
            CF[CloudFront CDN]
            R53[Route 53 DNS]
        end

        subgraph "VPC 10.0.0.0/16"
            subgraph "Public Subnets"
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end

            subgraph "Private App Subnets"
                ECS[ECS Fargate Cluster]
                
                subgraph "Containers"
                    PA[Portal Aluno]
                    PP[Portal Professor]
                    SA[Sistema Acadêmico]
                    VA[Video API]
                end
            end

            subgraph "Private Data Subnets"
                RDS[(RDS MySQL)]
            end
        end

        subgraph "Serverless"
            S3_RAW[S3 Raw Videos]
            S3_PROC[S3 Processed Videos]
            S3_ASSETS[S3 Assets]
            
            EB[EventBridge]
            SQS[SQS Queue]
            SFN[Step Functions]
            LAMBDA[Lambda Processor]
            MC[MediaConvert]
        end
    end

    USER --> R53
    R53 --> CF
    CF --> ALB
    ALB --> ECS
    ECS --> PA & PP & SA & VA
    PA & PP & SA --> RDS
    VA --> S3_PROC
    
    S3_RAW --> EB
    EB --> SQS
    SQS --> SFN
    SFN --> LAMBDA
    LAMBDA --> MC
    MC --> S3_PROC
```

---

## Arquitetura de Rede (VPC)

```mermaid
graph TB
    subgraph "VPC - 10.0.0.0/16"
        subgraph "AZ-A (sa-east-1a)"
            PUB_A[Public Subnet<br/>10.0.1.0/24]
            APP_A[Private App<br/>10.0.11.0/24]
            DATA_A[Private Data<br/>10.0.21.0/24]
        end

        subgraph "AZ-B (sa-east-1b)"
            PUB_B[Public Subnet<br/>10.0.2.0/24]
            APP_B[Private App<br/>10.0.12.0/24]
            DATA_B[Private Data<br/>10.0.22.0/24]
        end

        subgraph "AZ-C (sa-east-1c)"
            PUB_C[Public Subnet<br/>10.0.3.0/24]
            APP_C[Private App<br/>10.0.13.0/24]
            DATA_C[Private Data<br/>10.0.23.0/24]
        end

        IGW[Internet Gateway]
        NAT_A[NAT Gateway A]
        NAT_B[NAT Gateway B]
    end

    IGW --> PUB_A & PUB_B & PUB_C
    PUB_A --> NAT_A
    PUB_B --> NAT_B
    NAT_A --> APP_A
    NAT_B --> APP_B
    APP_A & APP_B & APP_C --> DATA_A & DATA_B & DATA_C
```

---

## Pipeline de Processamento de Vídeo

```mermaid
sequenceDiagram
    participant User as 👤 Usuário
    participant App as Portal
    participant S3R as S3 Raw
    participant EB as EventBridge
    participant SQS as SQS Queue
    participant SFN as Step Functions
    participant L1 as Lambda 1
    participant L2 as Lambda 2
    participant L3 as Lambda 3
    participant L4 as Lambda 4
    participant L5 as Lambda 5
    participant MC as MediaConvert
    participant S3P as S3 Processed
    participant SNS as SNS

    User->>App: Upload vídeo
    App->>S3R: PUT video.mp4
    S3R->>EB: Object Created
    EB->>SQS: Send Message
    SQS->>SFN: Trigger Batch
    
    par Processamento Paralelo (max 5)
        SFN->>L1: Process Video 1
        SFN->>L2: Process Video 2
        SFN->>L3: Process Video 3
        SFN->>L4: Process Video 4
        SFN->>L5: Process Video 5
    end
    
    L1->>MC: Create Job
    L2->>MC: Create Job
    MC->>S3P: Output HLS
    MC->>SNS: Job Complete
    SNS->>App: Notify User
```

---

## Arquitetura do Container PHP

```mermaid
graph TB
    subgraph "Docker Container"
        subgraph "Supervisor (PID 1)"
            SUP[supervisord]
        end

        subgraph "Processos Gerenciados"
            NGINX[NGINX<br/>:80]
            PHP[PHP-FPM<br/>:9000]
        end

        subgraph "Aplicação"
            LARAVEL[Laravel App<br/>/var/www/html]
        end

        subgraph "Configurações"
            CONF1[nginx.conf]
            CONF2[php.ini]
            CONF3[supervisord.conf]
        end
    end

    REQ[HTTP Request :80] --> NGINX
    NGINX -->|FastCGI| PHP
    PHP --> LARAVEL
    LARAVEL --> RESP[Response]

    SUP -.->|gerencia| NGINX
    SUP -.->|gerencia| PHP
    CONF1 -.->|configura| NGINX
    CONF2 -.->|configura| PHP
    CONF3 -.->|configura| SUP
```

### Arquivos de Configuração

| Arquivo | Responsabilidade |
|---------|------------------|
| `Dockerfile` | Receita para construir a imagem |
| `nginx.conf` | Configuração do web server (proxy, static files) |
| `php.ini` | Configuração do PHP (memory, upload, opcache) |
| `supervisord.conf` | Gerenciador de processos (nginx + php-fpm) |

---

## Fluxo de CI/CD

```mermaid
graph LR
    subgraph "GitHub"
        DEV[develop branch]
        MAIN[main branch]
    end

    subgraph "GitHub Actions"
        subgraph "Dev Pipeline"
            SEC_D[Security Scan]
            PLAN_D[Terraform Plan]
            APPLY_D[Terraform Apply]
            TEST_D[Infrastructure Tests]
        end

        subgraph "Prod Pipeline"
            SEC_P[Security Scan]
            COST[Cost Estimation]
            PLAN_P[Terraform Plan]
            APPROVE[Manual Approval]
            APPLY_P[Terraform Apply]
            TEST_P[Infrastructure Tests]
        end
    end

    subgraph "AWS"
        DEV_ENV[Dev Environment]
        PROD_ENV[Prod Environment]
    end

    DEV --> SEC_D --> PLAN_D --> APPLY_D --> TEST_D --> DEV_ENV
    MAIN --> SEC_P --> COST --> PLAN_P --> APPROVE --> APPLY_P --> TEST_P --> PROD_ENV
```

---

## Security Groups

```mermaid
graph TB
    subgraph "Internet"
        USERS[Users]
    end

    subgraph "Security Groups"
        ALB_SG[ALB SG<br/>Inbound: 80, 443]
        ECS_SG[ECS SG<br/>Inbound: from ALB only]
        RDS_SG[RDS SG<br/>Inbound: 3306 from ECS only]
        LAMBDA_SG[Lambda SG<br/>Outbound: all]
    end

    USERS -->|HTTPS| ALB_SG
    ALB_SG -->|:80| ECS_SG
    ECS_SG -->|:3306| RDS_SG
    ECS_SG -->|:443| S3[S3 VPC Endpoint]
```

---

## Step Functions - State Machine

```mermaid
stateDiagram-v2
    [*] --> ValidateInput
    
    ValidateInput --> ProcessSingleVideo: $.videos não existe
    ValidateInput --> ProcessVideosInParallel: $.videos existe
    
    state ProcessVideosInParallel {
        [*] --> Video1
        [*] --> Video2
        [*] --> Video3
        [*] --> Video4
        [*] --> Video5
        
        Video1 --> [*]
        Video2 --> [*]
        Video3 --> [*]
        Video4 --> [*]
        Video5 --> [*]
    }
    
    ProcessSingleVideo --> [*]: Success
    ProcessSingleVideo --> HandleError: Error
    
    ProcessVideosInParallel --> ProcessingComplete: All Success
    ProcessVideosInParallel --> HandleError: Any Error
    
    ProcessingComplete --> [*]
    HandleError --> [*]
```

---

## Custos Estimados

| Recurso | Dev (mensal) | Prod (mensal) |
|---------|-------------|---------------|
| ECS Fargate | ~$30 | ~$150 |
| RDS MySQL | ~$15 | ~$200 |
| ALB | ~$20 | ~$50 |
| S3 + CloudFront | ~$5 | ~$50 |
| NAT Gateway | ~$35 | ~$100 |
| Lambda + Step Functions | ~$1 | ~$10 |
| **Total** | **~$106** | **~$560** |

---

## Tecnologias Utilizadas

| Camada | Tecnologia |
|--------|------------|
| **IaC** | Terraform 1.10+ |
| **CI/CD** | GitHub Actions |
| **Container** | Docker + ECS Fargate |
| **Database** | MySQL 8.0 (RDS) |
| **CDN** | CloudFront |
| **Video** | MediaConvert + HLS |
| **Orquestração** | Step Functions |
| **Monitoramento** | CloudWatch |
| **Segurança** | Checkov, TFLint, Trivy |
