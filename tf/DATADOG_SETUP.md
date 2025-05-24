# Integración AWS-Datadog con Terraform

Esta documentación explica la configuración completa de monitoreo usando Terraform para integrar AWS con Datadog.

## 📋 Resumen de la Implementación

### Componentes Configurados

1. **Integración AWS-Datadog**
   - Roles y políticas IAM para acceso de Datadog a AWS
   - Configuración automática de la integración en Datadog
   - Permisos para CloudWatch, EC2, S3, y otros servicios

2. **Agentes Datadog en EC2**
   - Instalación automática via user_data
   - Configuración de monitoreo de Docker
   - Habilitación de logs y métricas del sistema
   - Tagging automático por entorno y servicio

3. **Dashboard Personalizado**
   - Widgets para CPU, memoria, disco y red
   - Monitoreo de contenedores Docker
   - Métricas de carga del sistema
   - Estado de instancias

4. **Monitoreo y Alertas**
   - Alertas por alto uso de CPU (>80%)
   - Alertas por alto uso de memoria (>85%)
   - Alertas por instancias caídas
   - Notificaciones automáticas

## 🚀 Instrucciones de Despliegue

### Prerrequisitos

1. **Cuenta de Datadog activa**
2. **Claves API de Datadog:**
   - API Key: Ve a [Organization Settings > API Keys](https://app.datadoghq.com/organization-settings/api-keys)
   - APP Key: Ve a [Organization Settings > Application Keys](https://app.datadoghq.com/organization-settings/application-keys)

3. **AWS CLI configurado** con permisos adecuados
4. **Terraform >= 1.0** instalado

### Paso a Paso

1. **Configurar Variables:**
   ```bash
   cd tf/
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edita `terraform.tfvars` con tus valores reales:
   ```hcl
   datadog_api_key = "tu-api-key-real"
   datadog_app_key = "tu-app-key-real"
   datadog_site    = "datadoghq.com"  # o "datadoghq.eu" para EU
   environment     = "dev"
   project_name    = "lti-project"
   ```

2. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

3. **Planificar el Despliegue:**
   ```bash
   terraform plan
   ```

4. **Aplicar la Configuración:**
   ```bash
   terraform apply
   ```

5. **Verificar el Despliegue:**
   - Espera 5-10 minutos para que los agentes empiecen a reportar
   - Visita el dashboard creado (URL en los outputs)
   - Verifica las instancias en Datadog Infrastructure Map

## 📊 Funcionalidades de Monitoreo

### Métricas Recopiladas

#### AWS CloudWatch
- CPU utilization
- Network I/O
- Disk I/O
- Instance status checks

#### Datadog Agent
- System metrics (CPU, memory, disk, load)
- Process monitoring
- Docker container metrics
- Custom application metrics
- Log collection

#### CloudWatch Agent Personalizado
- Memory usage percentage
- Disk usage percentage
- Network statistics
- Swap usage

### Dashboard Widgets

1. **EC2 CPU Utilization** - Uso de CPU por instancia
2. **Memory Utilization** - Uso de memoria del sistema
3. **Disk Usage** - Uso de disco por dispositivo
4. **Network I/O** - Tráfico de red entrante y saliente
5. **Running Instances** - Contador de instancias activas
6. **Application Response Time** - Estado del agente Datadog
7. **System Load Average** - Carga promedio del sistema (1, 5, 15 min)
8. **Docker Containers** - Estado de contenedores Docker

### Alertas Configuradas

1. **High CPU Usage**
   - Warning: >70%
   - Critical: >80%
   - Evalúa últimos 5 minutos

2. **High Memory Usage**
   - Warning: <20% disponible
   - Critical: <15% disponible
   - Evalúa últimos 5 minutos

3. **Instance Down**
   - Critical: Instancia no responde
   - No data timeout: 10 minutos
   - Renotificación cada 30 minutos

## 🔧 Configuración Técnica

### Estructura de Archivos

```
tf/
├── provider.tf          # Configuración de proveedores
├── variables.tf         # Definición de variables
├── iam.tf              # Roles y políticas IAM
├── ec2.tf              # Configuración de instancias EC2
├── datadog.tf          # Integración y dashboard Datadog
├── outputs.tf          # Outputs informativos
├── scripts/
│   ├── backend_user_data.sh   # Script de inicialización backend
│   └── frontend_user_data.sh  # Script de inicialización frontend
└── terraform.tfvars.example   # Ejemplo de variables
```

### Permisos IAM para Datadog

La configuración incluye permisos para:
- CloudWatch metrics y logs
- EC2 describe operations
- S3 bucket notifications
- Lambda function information
- RDS metrics
- Auto Scaling groups
- Load Balancer metrics

### Tagging Strategy

Todas las recursos usan tags consistentes:
- `Environment`: dev/staging/prod
- `Project`: lti-project
- `Service`: backend/frontend
- `Terraform`: true

## 🛠️ Troubleshooting

### Problemas Comunes

1. **Agente Datadog no aparece:**
   ```bash
   sudo systemctl status datadog-agent
   sudo tail -f /var/log/datadog/agent.log
   ```

2. **Métricas de CloudWatch faltantes:**
   ```bash
   sudo systemctl status amazon-cloudwatch-agent
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a query-config
   ```

3. **Contenedores Docker no monitoreados:**
   ```bash
   sudo docker ps
   sudo systemctl restart datadog-agent
   ```

4. **Dashboard vacío:**
   - Verifica que las instancias tengan los tags correctos
   - Espera al menos 10 minutos para data population
   - Revisa los filtros en los widgets del dashboard

### Logs Importantes

- Datadog Agent: `/var/log/datadog/agent.log`
- CloudWatch Agent: `/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log`
- User Data: `/var/log/cloud-init-output.log`

## 🔄 Mantenimiento

### Actualizaciones

1. **Actualizar Datadog Agent:**
   ```bash
   sudo yum update datadog-agent
   sudo systemctl restart datadog-agent
   ```

2. **Modificar Configuración:**
   - Edita variables en `terraform.tfvars`
   - Ejecuta `terraform plan` y `terraform apply`

3. **Agregar Nuevas Métricas:**
   - Modifica `datadog.tf` para nuevos widgets
   - Actualiza configuración del agente si es necesario

### Monitoreo del Monitoreo

- Revisa regularmente los dashboards de Datadog
- Verifica que las alertas funcionen correctamente
- Mantén actualizados los umbrales según el rendimiento

## 📚 Referencias

- [Datadog AWS Integration Guide](https://docs.datadoghq.com/integrations/amazon_web_services/)
- [Terraform Datadog Provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [CloudWatch Agent Configuration](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [Datadog Agent Configuration](https://docs.datadoghq.com/agent/basic_agent_usage/) 