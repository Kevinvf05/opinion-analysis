# Guía de Actualización para Ubuntu

Esta guía te ayudará a actualizar tu despliegue existente con las últimas imágenes Docker que incluyen todas las correcciones.

## Para Usuarios en Ubuntu/macOS

Si ya tienes el sistema corriendo y necesitas actualizar a la última versión con todos los cambios (7 pestañas de navegación, etc.), sigue estos pasos:

### Paso 1: Detener los contenedores actuales

```bash
cd ~/uaem-sistema  # O la carpeta donde tengas tu docker-compose.prod.yml
docker compose -f docker-compose.prod.yml down
```

### Paso 2: Limpiar imágenes antiguas (opcional pero recomendado)

```bash
# Ver imágenes actuales
docker images | grep uaem

# Eliminar las imágenes antiguas para forzar descarga nueva
docker rmi axldm09/uaem-frontend:latest
docker rmi axldm09/uaem-backend:latest
docker rmi axldm09/uaem-database:latest
```

### Paso 3: Descargar las últimas imágenes

```bash
docker compose -f docker-compose.prod.yml pull
```

Verás algo como:
```
[+] Pulling 3/3
 ✔ frontend Pulled
 ✔ backend Pulled  
 ✔ db Pulled
```

### Paso 4: Iniciar con las nuevas imágenes

```bash
docker compose -f docker-compose.prod.yml up -d
```

### Paso 5: Verificar que todo esté corriendo

```bash
docker compose -f docker-compose.prod.yml ps
```

Deberías ver 3 servicios en estado "running".

### Paso 6: Verificar la actualización

1. Abre tu navegador en: http://localhost:8080
2. Inicia sesión como admin: `admin@uaem.mx` / `admin123`
3. **Verifica que veas las 7 pestañas de navegación:**
   - Dashboard
   - Gestionar Usuarios
   - Profesores
   - Materias
   - Crear Usuario
   - Crear Materia
   - Crear Grupo

## Solución Rápida (Un Solo Comando)

Si quieres hacer todo en un solo comando:

```bash
cd ~/uaem-sistema && \
docker compose -f docker-compose.prod.yml down && \
docker rmi -f axldm09/uaem-frontend:latest axldm09/uaem-backend:latest axldm09/uaem-database:latest 2>/dev/null; \
docker compose -f docker-compose.prod.yml pull && \
docker compose -f docker-compose.prod.yml up -d && \
echo "✅ Actualización completada. Accede a http://localhost:8080"
```

## Verificar la Versión de las Imágenes

Para confirmar que tienes las últimas imágenes:

```bash
docker images | grep uaem
```

Busca la columna "CREATED" - debería mostrar "Less than a second ago" o "X minutes ago" si acabas de descargarlas.

## Si los Datos no Aparecen

Si después de actualizar no ves datos o usuarios:

```bash
# La base de datos persiste los datos. Si necesitas reiniciar desde cero:
docker compose -f docker-compose.prod.yml down -v  # ⚠️ CUIDADO: Esto borra TODOS los datos
docker compose -f docker-compose.prod.yml up -d
```

Esto recreará la base de datos con los datos de demostración iniciales.

## Logs para Debugging

Si algo no funciona después de actualizar:

```bash
# Ver logs de todos los servicios
docker compose -f docker-compose.prod.yml logs -f

# Ver logs solo del frontend
docker compose -f docker-compose.prod.yml logs -f frontend

# Ver logs solo del backend
docker compose -f docker-compose.prod.yml logs -f backend
```

## Notas Importantes

- ✅ Las imágenes actualizadas ya están en Docker Hub
- ✅ Tus datos se mantienen después de la actualización (a menos que uses `-v`)
- ✅ La actualización incluye:
  - 7 pestañas de navegación en el admin
  - Todas las correcciones de hash de contraseñas
  - Inicialización automática de la base de datos
  - Todos los archivos HTML actualizados

## Verificación Final

Después de actualizar, verifica:

1. ✅ Login funciona: `admin@uaem.mx` / `admin123`
2. ✅ Se ven las 7 pestañas en el panel admin
3. ✅ Puedes crear usuarios, materias y grupos
4. ✅ Los profesores pueden ver sus materias
5. ✅ Los estudiantes pueden completar encuestas

---

**¿Problemas?** Ejecuta `docker compose logs -f` para ver qué está pasando.
