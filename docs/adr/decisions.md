# ADR 001: Escolha de Banco de Dados

## Status
Aceito

## Contexto
A aplicação existente utiliza MySQL como banco de dados. Na migração para AWS, precisávamos decidir entre:
1. Aurora PostgreSQL (mais moderno, melhor performance)
2. RDS MySQL (compatibilidade com aplicação existente)

## Decisão
Escolhemos **RDS MySQL Multi-AZ** para manter compatibilidade com o Laravel e simplificar a migração.

## Consequências

### Positivo
- Zero mudanças no código da aplicação
- Migração simplificada via mysqldump
- Equipe já conhece MySQL
- Multi-AZ garante alta disponibilidade

### Negativo
- Perde benefícios de performance do Aurora
- Menos escalabilidade horizontal que Aurora

## Alternativas Consideradas
- Aurora PostgreSQL: Rejeitado devido à necessidade de alterar queries
- Aurora MySQL: Considerado para fase futura

---

# ADR 002: Pipeline de Vídeo Event-Driven

## Status
Aceito

## Contexto
O processamento de vídeo atual usa FFmpeg em cron jobs na EC2, consumindo recursos da aplicação e sem escalabilidade.

## Decisão
Implementar pipeline event-driven:
```
S3 → EventBridge → SQS → Lambda → MediaConvert
```

## Consequências

### Positivo
- Processamento desacoplado da aplicação
- Escalabilidade automática
- Custo pay-per-use (só paga pelos vídeos processados)
- Qualidade profissional com MediaConvert

### Negativo
- Complexidade adicional na arquitetura
- Dependência de múltiplos serviços AWS

---

# ADR 003: Uso de ECS Fargate

## Status
Aceito

## Contexto
Precisávamos decidir a plataforma de execução dos containers:
1. EC2 com ECS
2. ECS Fargate (serverless)
3. EKS (Kubernetes)

## Decisão
**ECS Fargate** - serverless, menor overhead operacional.

## Consequências

### Positivo
- Zero gerenciamento de servidores
- Auto scaling automático
- Custo otimizado (pay-per-task)
- Integração nativa com AWS

### Negativo
- Custo unitário maior que EC2
- Menos flexibilidade que EKS
- Cold starts em alguns casos
