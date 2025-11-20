# Docker Data Persistence Guide

## Your Database is Already Set Up for Persistence!

Your `docker-compose.yml` already has a volume configured for PostgreSQL data:
```yaml
volumes:
  postgres_data:/var/lib/postgresql/data
```

This means your database data **is persistent** and survives container restarts.

## Important Commands

### ✅ Safe Commands (Keep Your Data)
```powershell
# Stop containers but keep data
docker-compose stop

# Start existing containers
docker-compose start

# Restart containers (keeps data)
docker-compose restart

# Stop and remove containers (but KEEPS volumes/data)
docker-compose down

# Rebuild and restart (keeps data)
docker-compose up -d --build
```

### ❌ Dangerous Commands (Delete Your Data)
```powershell
# This DELETES all volumes including your database!
docker-compose down -v

# This also deletes the volume
docker volume rm proyecto_postgres_data
```

## Current Workflow

### First Time Setup
1. Start containers:
   ```powershell
   docker-compose up -d --build
   ```

2. Initialize database (only needed once):
   ```powershell
   # Create schema
   docker exec -i uaem_db psql -U admin -d uaem < database/schema.sql
   
   # Load seed data
   docker exec -i uaem_db psql -U admin -d uaem < database/seed_data.sql
   ```

### Daily Development

**To update code and restart:**
```powershell
# Option 1: Just restart (if only code changed)
docker-compose restart backend

# Option 2: Rebuild and restart (if dependencies changed)
docker-compose up -d --build

# Your data is safe! ✅
```

**To stop working:**
```powershell
docker-compose stop
# or
docker-compose down  # (still keeps data)
```

**To start working again:**
```powershell
docker-compose up -d
# Your data is still there! ✅
```

## Checking Your Data Volume

To verify your volume exists and has data:
```powershell
# List all volumes
docker volume ls

# Inspect the postgres volume
docker volume inspect proyecto_postgres_data

# Check database size
docker exec uaem_db psql -U admin -d uaem -c "SELECT pg_size_pretty(pg_database_size('uaem'));"

# List tables
docker exec uaem_db psql -U admin -d uaem -c "\dt"

# Count records
docker exec uaem_db psql -U admin -d uaem -c "SELECT 'users', COUNT(*) FROM users UNION ALL SELECT 'professors', COUNT(*) FROM professors UNION ALL SELECT 'subjects', COUNT(*) FROM subjects;"
```

## Backup Your Database

To create a backup of your current data:
```powershell
# Create backup file
docker exec uaem_db pg_dump -U admin uaem > database/backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Restore from backup
docker exec -i uaem_db psql -U admin -d uaem < database/backup_20241118_120000.sql
```

## Troubleshooting

### "My data is gone!"
- Check if you accidentally ran `docker-compose down -v`
- Check if the volume still exists: `docker volume ls | Select-String postgres_data`
- If volume exists but data seems empty, you may need to restore from a backup

### "I want a fresh start but keep a backup"
```powershell
# 1. Backup current data
docker exec uaem_db pg_dump -U admin uaem > database/backup.sql

# 2. Remove everything including volume
docker-compose down -v

# 3. Start fresh
docker-compose up -d --build

# 4. If you want your data back
docker exec -i uaem_db psql -U admin -d uaem < database/backup.sql
```

## Summary

**✅ Your setup already preserves data!**
- Use `docker-compose up -d --build` to rebuild - **data is safe**
- Use `docker-compose down` to stop - **data is safe**
- Use `docker-compose restart` to restart - **data is safe**

**❌ Only loses data if you:**
- Explicitly use `docker-compose down -v`
- Manually delete the volume with `docker volume rm`

**Your database data is stored in:** Named volume `proyecto_postgres_data`
