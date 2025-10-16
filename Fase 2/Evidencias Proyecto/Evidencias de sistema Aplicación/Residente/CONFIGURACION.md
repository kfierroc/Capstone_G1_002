# 🔧 Configuración de Residente

## ⚠️ Estado Actual
La app está configurada para funcionar sin archivo `.env`, pero para usar todas las funcionalidades de Supabase necesitas configurar las credenciales.

## 🚀 Configuración Rápida

### 1. Crear archivo de configuración
```bash
# Copia el archivo de plantilla
cp env_template.txt .env
```

### 2. Configurar Supabase
1. Ve a [https://supabase.com](https://supabase.com) y crea un proyecto
2. En **Settings > API** encontrarás:
   - **Project URL** (SUPABASE_URL)
   - **anon public** key (SUPABASE_ANON_KEY)
3. Edita el archivo `.env` y reemplaza los valores:
   ```
   SUPABASE_URL=https://tuproyecto.supabase.co
   SUPABASE_ANON_KEY=tu_clave_anonima_aqui
   ```

### 3. Configurar Base de Datos
1. Ve al **SQL Editor** en tu proyecto Supabase
2. Ejecuta el script `supabase_schema.sql` que está en la raíz del proyecto
3. Esto creará todas las tablas necesarias

### 4. Ejecutar la app
```bash
flutter run
```

## 📱 Funcionalidades

### ✅ Sin configuración (Modo Demo)
- La app se ejecuta sin errores
- Interfaz funcional
- Datos de prueba/mock
- Formularios de registro funcionales

### 🏠 Con Supabase configurado
- Autenticación real
- Base de datos en la nube
- Registro de residentes completo
- Gestión de grupos familiares
- Gestión de mascotas
- Sincronización de datos

## 🛠️ Solución de Problemas

### App aparece en rojo
- ✅ **SOLUCIONADO**: La app ya no falla al iniciar
- Se muestran advertencias en consola sobre configuración faltante
- La app funciona en modo demo

### Error de credenciales
- Verifica que el archivo `.env` existe
- Confirma que las credenciales son correctas
- Revisa que no hay espacios extra en el archivo `.env`

### Error de base de datos
- Asegúrate de ejecutar el script `supabase_schema.sql`
- Verifica que las tablas se crearon correctamente
- Revisa los permisos RLS (Row Level Security)

## 📞 Soporte
Si tienes problemas, revisa los logs en la consola para mensajes de ayuda.
