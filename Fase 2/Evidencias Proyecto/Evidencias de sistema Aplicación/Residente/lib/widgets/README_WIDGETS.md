# 🎨 Widgets Comunes Optimizados

Este archivo contiene widgets reutilizables y optimizados para toda la aplicación.

## 📦 Widgets Disponibles

### 1. SectionHeader
Header optimizado para secciones con gradiente

```dart
SectionHeader(
  icon: Icons.people,
  title: 'Gestión de Familia',
  subtitle: 'Agrega y gestiona los miembros de tu familia',
  gradientColors: [Colors.green.shade600, Colors.green.shade800],
)
```

### 2. ActionButton
Botón de acción con icono y color personalizable

```dart
ActionButton(
  onPressed: () => _showAddDialog(),
  label: 'Agregar nueva persona',
  icon: Icons.add,
  backgroundColor: Colors.green.shade600,
)
```

### 3. InfoCard
Tarjeta de información simple

```dart
InfoCard(
  title: 'Dirección',
  value: 'Calle Ejemplo 123, Santiago',
)
```

### 4. DetailRow
Fila de detalles con etiqueta y valor

```dart
DetailRow(
  label: 'Email:',
  value: 'usuario@ejemplo.com',
  labelWidth: 100,
)
```

### 5. EmptyStateWidget
Estado vacío para listas sin contenido

```dart
EmptyStateWidget(
  icon: Icons.pets_outlined,
  message: 'No hay mascotas registradas',
)
```

### 6. ShadowContainer
Contenedor con sombra personalizable

```dart
ShadowContainer(
  child: Text('Contenido'),
  padding: EdgeInsets.all(16),
)
```

## 🎯 Ventajas de Usar Estos Widgets

✅ **Optimizados** - Menos rebuilds innecesarios
✅ **Consistentes** - Mismo diseño en toda la app
✅ **Reutilizables** - Código más limpio
✅ **Mantenibles** - Cambios en un solo lugar

## 📝 Cómo Usar

1. Importa el archivo:
```dart
import '../widgets/common_widgets.dart';
```

2. Usa el widget directamente:
```dart
SectionHeader(
  icon: Icons.home,
  title: 'Mi Título',
  subtitle: 'Subtítulo',
  gradientColors: [Colors.blue, Colors.blueAccent],
)
```

## 💡 Tips

- Todos los widgets usan `const` donde es posible
- Los colores se pasan como parámetros para flexibilidad
- Usa `gradientColors` con colores que combinen bien

