# LTI - Sistema de Seguimiento de Talento

Este proyecto es una aplicación full-stack con un frontend en React y un backend en Express usando Prisma como un ORM. El frontend se inicia con Create React App y el backend está escrito en TypeScript.

## Explicación de Directorios y Archivos

- `backend/`: Contiene el código del lado del servidor escrito en Node.js.
  - `src/`: Contiene el código fuente para el backend.
    - `index.ts`: El punto de entrada para el servidor backend.
    - `application/`: Contiene la lógica de aplicación.
    - `domain/`: Contiene la lógica de negocio.
    - `infrastructure/`: Contiene código que se comunica con la base de datos.
    - `presentation/`: Contiene código relacionado con la capa de presentación (como controladores).
    - `routes/`: Contiene las definiciones de rutas para la API.
    - `tests/`: Contiene archivos de prueba.
  - `prisma/`: Contiene el archivo de esquema de Prisma para ORM.
  - `tsconfig.json`: Archivo de configuración de TypeScript.
- `frontend/`: Contiene el código del lado del cliente escrito en React.
  - `src/`: Contiene el código fuente para el frontend.
  - `public/`: Contiene archivos estáticos como el archivo HTML e imágenes.
  - `build/`: Contiene la construcción lista para producción del frontend.
- `.env`: Contiene las variables de entorno.
- `docker-compose.yml`: Contiene la configuración de Docker Compose para gestionar los servicios de tu aplicación.
- `README.md`: Este archivo, contiene información sobre el proyecto e instrucciones sobre cómo ejecutarlo.

## Estructura del Proyecto

El proyecto está dividido en dos directorios principales: `frontend` y `backend`.

### Frontend

El frontend es una aplicación React y sus archivos principales están ubicados en el directorio `src`. El directorio `public` contiene activos estáticos y el directorio `build` contiene la construcción de producción de la aplicación.

### Backend

El backend es una aplicación Express escrita en TypeScript. El directorio `src` contiene el código fuente, dividido en varios subdirectorios:

- `application`: Contiene la lógica de aplicación.
- `domain`: Contiene los modelos de dominio.
- `infrastructure`: Contiene código relacionado con la infraestructura.
- `presentation`: Contiene código relacionado con la capa de presentación.
- `routes`: Contiene las rutas de la aplicación.
- `tests`: Contiene las pruebas de la aplicación.

El directorio `prisma` contiene el esquema de Prisma.

Tienes más información sobre buenas prácticas utilizadas en la [guía de buenas prácticas](./backend/ManifestoBuenasPracticas.md).

Las especificaciones de todos los endpoints de API los tienes en [api-spec.yaml](./backend/api-spec.yaml).

La descripción y diagrama del modelo de datos los tienes en [ModeloDatos.md](./backend/ModeloDatos.md).


## Primeros Pasos

Para comenzar con este proyecto, sigue estos pasos:

1. Clona el repositorio.
2. Instala las dependencias para el frontend y el backend:
```sh
cd frontend
npm install

cd ../backend
npm install
```
3. Construye el servidor backend:
```
cd backend
npm run build
```
4. Inicia el servidor backend:
```
cd backend
npm start
```
5. En una nueva ventana de terminal, construye el servidor frontend:
```
cd frontend
npm run build
```
6. Inicia el servidor frontend:
```
cd frontend
npm start
```

El servidor backend estará corriendo en http://localhost:3010 y el frontend estará disponible en http://localhost:3000.

## Docker y PostgreSQL

Este proyecto usa Docker para ejecutar una base de datos PostgreSQL. Así es cómo ponerlo en marcha:

Instala Docker en tu máquina si aún no lo has hecho. Puedes descargarlo desde aquí.
Navega al directorio raíz del proyecto en tu terminal.
Ejecuta el siguiente comando para iniciar el contenedor Docker:
```
docker-compose up -d
```
Esto iniciará una base de datos PostgreSQL en un contenedor Docker. La bandera -d corre el contenedor en modo separado, lo que significa que se ejecuta en segundo plano.

Para acceder a la base de datos PostgreSQL, puedes usar cualquier cliente PostgreSQL con los siguientes detalles de conexión:
 - Host: localhost
 - Port: 5432
 - User: postgres
 - Password: password
 - Database: mydatabase

Por favor, reemplaza User, Password y Database con el usuario, la contraseña y el nombre de la base de datos reales especificados en tu archivo .env.

Para detener el contenedor Docker, ejecuta el siguiente comando:
```
docker-compose down
```

Para generar la base de datos utilizando Prisma, sigue estos pasos:

1. Asegúrate de que el archivo `.env` en el directorio raíz del backend contenga la variable `DATABASE_URL` con la cadena de conexión correcta a tu base de datos PostgreSQL. Si no te funciona, prueba a reemplazar la URL completa directamente en `schema.prisma`, en la variable `url`.

2. Abre una terminal y navega al directorio del backend donde se encuentra el archivo `schema.prisma` y `seed.ts`.

3. Ejecuta los siguientes comandos para generar la estructura de prisma, las migraciones a tu base de datos y poblarla con datos de ejemplo:
```
npx prisma generate
npx prisma migrate dev
ts-node seed.ts
```

Una vez has dado todos los pasos, deberías poder guardar nuevos candidatos, tanto via web, como via API, verlos en la base de datos y obtenerlos mediante GET por id. 

```
POST http://localhost:3010/candidates
{
    "firstName": "Albert",
    "lastName": "Saelices",
    "email": "albert.saelices@gmail.com",
    "phone": "656874937",
    "address": "Calle Sant Dalmir 2, 5ºB. Barcelona",
    "educations": [
        {
            "institution": "UC3M",
            "title": "Computer Science",
            "startDate": "2006-12-31",
            "endDate": "2010-12-26"
        }
    ],
    "workExperiences": [
        {
            "company": "Coca Cola",
            "position": "SWE",
            "description": "",
            "startDate": "2011-01-13",
            "endDate": "2013-01-17"
        }
    ],
    "cv": {
        "filePath": "uploads/1715760936750-cv.pdf",
        "fileType": "application/pdf"
    }
}
```

## 🏗️ Infraestructura y Monitoreo

Este proyecto incluye una configuración completa de infraestructura como código (IaC) usando Terraform, con integración de monitoreo avanzado mediante Datadog.

### Características de Infraestructura

- **Despliegue automatizado en AWS** usando Terraform
- **Integración completa con Datadog** para monitoreo en tiempo real
- **Agentes Datadog** instalados automáticamente en instancias EC2
- **Dashboard personalizado** con métricas clave de infraestructura
- **Alertas automatizadas** para problemas de rendimiento
- **Monitoreo de contenedores Docker** y aplicaciones

### Configuración de Infraestructura

El directorio `tf/` contiene toda la configuración de Terraform:

```
tf/
├── provider.tf              # Configuración de proveedores AWS y Datadog
├── variables.tf             # Variables de configuración
├── iam.tf                   # Roles y políticas IAM
├── ec2.tf                   # Instancias EC2 con user data
├── datadog.tf               # Integración Datadog y dashboard
├── outputs.tf               # Outputs con URLs y información útil
├── scripts/                 # Scripts de inicialización
│   ├── backend_user_data.sh # Setup backend con Datadog agent
│   └── frontend_user_data.sh# Setup frontend con Datadog agent
├── terraform.tfvars.example # Ejemplo de configuración
└── DATADOG_SETUP.md         # Documentación detallada
```

### Despliegue de Infraestructura

1. **Prerrequisitos:**
   - Cuenta AWS configurada
   - Cuenta Datadog activa
   - Terraform instalado (>= 1.0)

2. **Configuración:**
   ```bash
   cd tf/
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus claves API de Datadog
   ```

3. **Despliegue:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Acceso al Monitoreo:**
   - Dashboard Datadog: Disponible en outputs después del despliegue
   - Métricas de infraestructura: CPU, memoria, disco, red
   - Alertas automáticas: Alto uso de recursos, instancias caídas

### Tecnologías y Patrones Utilizados

#### Infraestructura
- **Terraform** - Infrastructure as Code
- **AWS EC2** - Instancias de aplicación
- **AWS IAM** - Gestión de permisos y roles
- **AWS CloudWatch** - Métricas básicas de AWS
- **Amazon Linux 2** - Sistema operativo base

#### Monitoreo
- **Datadog** - Plataforma de monitoreo y observabilidad
- **Datadog Agent** - Recolección de métricas del sistema
- **CloudWatch Agent** - Métricas detalladas del sistema
- **Docker Integration** - Monitoreo de contenedores

#### Arquitectura
- **Microservicios** - Frontend y backend separados
- **Containerización** - Docker para aplicaciones
- **Auto-scaling** - Preparado para escalado automático
- **Tag-based Organization** - Gestión mediante tags

Para información detallada sobre la configuración de monitoreo, consulta [`tf/DATADOG_SETUP.md`](./tf/DATADOG_SETUP.md).

