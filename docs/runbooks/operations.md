# Runbook: Deployment de Produção

## Pré-Deployment Checklist

- [ ] Backup do banco de dados criado
- [ ] Pipeline de CI passou em todos os testes
- [ ] Code review aprovado
- [ ] Estimativa de custo revisada (Infracost)
- [ ] Security scan sem vulnerabilidades críticas

## Processo de Deployment

### 1. Aprovar PR para main
```bash
# No GitHub, aprovar e mergear PR para branch main
```

### 2. Monitorar Pipeline
- Acessar GitHub Actions
- Aguardar jobs de security e plan
- Aprovar environment "production" quando solicitado

### 3. Verificar Apply
```bash
# Verificar outputs do Terraform
cd terraform/environments/prod
terraform output
```

### 4. Validação Pós-Deploy

```bash
# Verificar ECS tasks
aws ecs list-tasks --cluster uniplus-prod-cluster

# Verificar ALB health
aws elbv2 describe-target-health --target-group-arn <TG_ARN>

# Verificar RDS status
aws rds describe-db-instances --db-instance-identifier uniplus-prod-mysql
```

## Rollback

### Rollback via Terraform
```bash
# Reverter para versão anterior
git revert HEAD
git push origin main

# Ou aplicar state anterior
terraform state list
terraform state show <resource>
```

### Rollback via ECS
```bash
# Listar task definitions anteriores
aws ecs list-task-definitions --family uniplus-prod-app

# Atualizar service com versão anterior
aws ecs update-service \
  --cluster uniplus-prod-cluster \
  --service uniplus-prod-service \
  --task-definition uniplus-prod-app:PREVIOUS_VERSION
```

## Contatos de Emergência

- **DevOps Lead**: devops@uniplus.com
- **AWS Support**: Console → Support → Create Case
- **On-call**: [PagerDuty/Slack Channel]

---

# Runbook: Troubleshooting

## ECS Tasks Falhando

### Verificar logs
```bash
aws logs tail /ecs/uniplus-prod --follow
```

### Verificar task events
```bash
aws ecs describe-services \
  --cluster uniplus-prod-cluster \
  --services uniplus-prod-service \
  --query 'services[0].events[:10]'
```

## RDS Conexão Lenta

### Verificar métricas
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=uniplus-prod-mysql \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average
```

### Verificar connections
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=uniplus-prod-mysql \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Maximum
```

## Video Processing Falhando

### Verificar DLQ
```bash
aws sqs get-queue-attributes \
  --queue-url $(terraform output -raw video_processing_dlq_url) \
  --attribute-names ApproximateNumberOfMessages
```

### Ver mensagens de erro
```bash
aws sqs receive-message \
  --queue-url $(terraform output -raw video_processing_dlq_url) \
  --max-number-of-messages 10
```

### Ver logs do Lambda
```bash
aws logs tail /aws/lambda/uniplus-prod-video-processor --follow
```
