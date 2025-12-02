# Guía de Despliegue para macOS

Esta guía te ayudará a descargar y ejecutar el Sistema de Análisis de Opinión Docente UAEM en tu MacBook.

## Requisitos Previos

### 1. Instalar Docker Desktop para Mac

1. **Descargar Docker Desktop:**
   - Visita: https://www.docker.com/products/docker-desktop
   - Haz clic en "Download for Mac"
   - Selecciona la versión correcta:
     - **Apple Silicon (M1/M2/M3):** Chip Apple
     - **Intel:** Chip Intel
   
2. **Instalar Docker Desktop:**
   - Abre el archivo `.dmg` descargado
   - Arrastra Docker a la carpeta Aplicaciones
   - Abre Docker desde Aplicaciones
   - Sigue el asistente de instalación
   - Acepta los permisos cuando se soliciten

3. **Verificar la instalación:**
   ```bash
   docker --version
   docker compose version
   ```
   
   Deberías ver algo como:
   ```
   Docker version 24.0.x
   Docker Compose version v2.x.x
   ```

### 2. Configurar Docker Desktop

1. Abre Docker Desktop
2. Ve a **Configuración** (ícono de engranaje)
3. En **Resources → Advanced**, asigna:
   - **CPUs:** Mínimo 2 (recomendado 4)
   - **Memory:** Mínimo 4 GB (recomendado 8 GB)
   - **Disk:** Mínimo 10 GB de espacio libre
4. Haz clic en **Apply & Restart**

## Instalación del Sistema

### Paso 1: Descargar el archivo de configuración

1. **Crear un directorio para el proyecto:**
   ```bash
   mkdir -p ~/uaem-sistema
   cd ~/uaem-sistema
   ```

2. **Descargar el archivo docker-compose.prod.yml:**
   
   **Opción A - Usando curl:**
   ```bash
   curl -o docker-compose.prod.yml https://raw.githubusercontent.com/kao-05/opinion-analysis/main/docker-compose.prod.yml
   ```
   
   **Opción B - Descarga manual:**
   - Descarga el archivo `docker-compose.prod.yml` del repositorio
   - Muévelo a la carpeta `~/uaem-sistema/`
   - Mantén el nombre como `docker-compose.prod.yml`

### Paso 2: Iniciar el sistema

1. **Navega al directorio del proyecto:**
   ```bash
   cd ~/uaem-sistema
   ```

2. **Descarga e inicia todos los servicios:**
   ```bash
   docker compose -f docker-compose.prod.yml up -d
   ```
   
   Este comando:
   - Descargará las imágenes Docker desde Docker Hub (puede tardar 5-15 minutos en la primera vez)
   - Creará y configurará la base de datos automáticamente con datos de demostración
   - Iniciará los servicios backend y frontend
   - El flag `-d` ejecuta los contenedores en segundo plano

3. **Verificar que todo esté corriendo:**
   ```bash
   docker compose -f docker-compose.prod.yml ps
   ```
   
   Deberías ver 3 servicios en estado "running":
   - `db` (PostgreSQL)
   - `backend` (Flask API)
   - `frontend` (Nginx)

### Paso 3: Acceder al sistema

1. **Abre tu navegador** (Safari, Chrome, Firefox)

2. **Accede a la aplicación:**
   ```
   http://localhost:8080
   ```

3. **Credenciales de prueba:**

   **Administrador:**
   - Email: `admin@uaem.mx`
   - Contraseña: `admin123`

   **Profesor:**
   - Email: `alberto.garcia@uaem.mx`
   - Contraseña: `profesor123`

   **Estudiante:**
   - Matrícula: `A01700001`
   - Contraseña: `estudiante123`

## Comandos Útiles

### Ver logs en tiempo real
```bash
# Ver todos los logs
docker compose -f docker-compose.prod.yml logs -f

# Ver logs de un servicio específico
docker compose -f docker-compose.prod.yml logs -f backend
docker compose -f docker-compose.prod.yml logs -f frontend
docker compose -f docker-compose.prod.yml logs -f db
```

### Detener el sistema
```bash
# Detener sin eliminar datos
docker compose -f docker-compose.prod.yml stop

# Detener y eliminar contenedores (los datos persisten)
docker compose -f docker-compose.prod.yml down
```

### Reiniciar el sistema
```bash
# Reiniciar todos los servicios
docker compose -f docker-compose.prod.yml restart

# Reiniciar un servicio específico
docker compose -f docker-compose.prod.yml restart backend
```

### Ver estado de los contenedores
```bash
docker compose -f docker-compose.prod.yml ps
```

### Actualizar a la última versión
```bash
# Detener el sistema
docker compose -f docker-compose.prod.yml down

# Descargar las últimas imágenes
docker compose -f docker-compose.prod.yml pull

# Iniciar con las nuevas imágenes
docker compose -f docker-compose.prod.yml up -d
```

### Eliminar todo (incluyendo datos)
```bash
# ⚠️ CUIDADO: Esto eliminará TODOS los datos
docker compose -f docker-compose.prod.yml down -v
```

## Solución de Problemas

### El puerto 8080 ya está en uso
Si ves un error sobre el puerto 8080:

1. **Encuentra qué proceso está usando el puerto:**
   ```bash
   lsof -i :8080
   ```

2. **Detén ese proceso o cambia el puerto:**
   
   Edita `docker-compose.yml` y cambia:
   ```yaml
   frontend:
     ports:
       - "8080:80"  # Cambia 8080 por otro puerto, ej: 3000:80
   ```

### Los contenedores no inician
```bash
# Ver logs detallados
docker compose -f docker-compose.prod.yml logs

# Verificar recursos de Docker Desktop
# Ve a Docker Desktop → Settings → Resources
```

### Error "Cannot connect to Docker daemon"
1. Asegúrate de que Docker Desktop esté corriendo
2. Abre Docker Desktop desde Aplicaciones
3. Espera a que el ícono de Docker en la barra de menú muestre "Docker Desktop is running"

### Limpiar espacio en disco
```bash
# Eliminar imágenes no usadas
docker image prune -a

# Eliminar todo lo no usado (contenedores, redes, volúmenes)
docker system prune -a --volumes
```

### Problemas de conexión a la base de datos
```bash
# Reiniciar la base de datos
docker compose -f docker-compose.prod.yml restart db

# Ver logs de la base de datos
docker compose -f docker-compose.prod.yml logs db
```

### La aplicación no carga en el navegador
1. Verifica que todos los servicios estén corriendo:
   ```bash
   docker compose -f docker-compose.prod.yml ps
   ```

2. Verifica los logs del frontend:
   ```bash
   docker compose -f docker-compose.prod.yml logs frontend
   ```

3. Prueba acceder a:
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:5000/api/health

## Copias de Seguridad

### Hacer backup de la base de datos
```bash
# Crear backup
docker compose -f docker-compose.prod.yml exec db pg_dump -U uaem_user uaem_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker compose -f docker-compose.prod.yml exec -T db psql -U uaem_user uaem_db < backup_20241202_120000.sql
```

## Desinstalación Completa

Si deseas eliminar completamente el sistema:

```bash
# 1. Detener y eliminar contenedores
cd ~/uaem-sistema
docker compose -f docker-compose.prod.yml down -v

# 2. Eliminar imágenes
docker rmi axldm09/uaem-frontend:latest
docker rmi axldm09/uaem-backend:latest
docker rmi axldm09/uaem-database:latest

# 3. Eliminar archivos del proyecto
cd ~
rm -rf ~/uaem-sistema

# 4. (Opcional) Desinstalar Docker Desktop
# Arrastra Docker desde Aplicaciones a la Papelera
```

## Arquitectura del Sistema

El sistema consta de 3 servicios Docker:

- **Frontend (Puerto 8080):** Interfaz web HTML/JavaScript con Nginx
- **Backend (Puerto 5000):** API REST en Python Flask
- **Database (Puerto 5432):** PostgreSQL con datos iniciales

Todos los servicios se comunican a través de una red Docker interna.

## Datos de Demostración

El sistema viene preconfigurado con:
- 2 Administradores
- 2 Profesores
- 2 Estudiantes
- 15 Comentarios de ejemplo en español
- 3 Materias de prueba

## Soporte

Para problemas o preguntas:
1. Revisa los logs: `docker compose -f docker-compose.prod.yml logs -f`
2. Verifica el estado: `docker compose -f docker-compose.prod.yml ps`
3. Reinicia el sistema: `docker compose -f docker-compose.prod.yml restart`

## Rendimiento en Apple Silicon (M1/M2/M3)

Las imágenes Docker están optimizadas para arquitectura ARM64, por lo que funcionarán de manera nativa en chips Apple Silicon sin emulación x86, proporcionando:
- ✅ Mejor rendimiento
- ✅ Menor consumo de batería
- ✅ Menor uso de memoria

## Notas Importantes

- **Primera ejecución:** La descarga de imágenes puede tardar 10-15 minutos dependiendo de tu conexión (Total: ~9.5 GB)
- **Datos persistentes:** Los datos de la base de datos se mantienen incluso después de `docker compose -f docker-compose.prod.yml down`
- **Actualizaciones:** Ejecuta `docker compose -f docker-compose.prod.yml pull` para obtener las últimas versiones
- **Seguridad:** Las credenciales de prueba son solo para desarrollo. Cámbialas en producción.
- **Archivo único:** Solo necesitas el archivo `docker-compose.prod.yml` - no se requiere código fuente

---

**¡Listo!** Tu Sistema de Análisis de Opinión Docente UAEM debería estar funcionando en http://localhost:8080
