# 🧪 Guía Rápida de Testing - Bomberos

## Inicio Rápido

### 1. Instalar Dependencias

```bash
cd Bomberos
flutter pub get
```

### 2. Ejecutar Pruebas Unitarias

```bash
# Todas las pruebas
flutter test

# Prueba específica
flutter test test/models/bombero_test.dart

# Con cobertura
flutter test --coverage
```

### 3. Ejecutar Pruebas de Integración

```bash
# En dispositivo/emulador
flutter test integration_test/app_test.dart

# En Chrome (web)
flutter test integration_test/app_test.dart -d chrome
```

### 4. Ver Cobertura de Código

```bash
# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
# Windows: start coverage/html/index.html
# macOS: open coverage/html/index.html
# Linux: xdg-open coverage/html/index.html
```

## Estructura de Pruebas

```
Bomberos/
├── test/
│   ├── models/
│   │   └── bombero_test.dart          # Pruebas de modelos
│   ├── utils/
│   │   └── validation_test.dart       # Pruebas de validación
│   └── widget_test.dart               # Pruebas básicas de widgets
│
├── integration_test/
│   └── app_test.dart                  # Pruebas de integración
│
└── tests/
    └── load/
        └── auth_load_test.js          # Pruebas de carga (k6)
```

## Comandos Útiles

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar con verbose
flutter test --verbose

# Ejecutar pruebas que contengan "bombero"
flutter test --name bombero

# Limpiar y ejecutar
flutter clean && flutter pub get && flutter test
```

## Próximos Pasos

1. ✅ Ejecutar `flutter test` para verificar que las pruebas básicas funcionan
2. ✅ Revisar `GUIA_PRUEBAS_FIREDATA.md` para guía completa
3. ✅ Agregar más pruebas según tus necesidades
4. ✅ Configurar CI/CD con GitHub Actions

## Recursos

- [Guía Completa de Pruebas](../GUIA_PRUEBAS_FIREDATA.md)
- [Documentación de Flutter Testing](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

