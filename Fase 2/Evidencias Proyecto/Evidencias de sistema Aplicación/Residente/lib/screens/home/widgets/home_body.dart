import 'package:flutter/material.dart';
import '../controllers/family_controller.dart';

/// Widget que maneja el cuerpo principal de la pantalla de residente
/// Sigue el principio de Single Responsibility (SRP)
class HomeBody extends StatelessWidget {
  final int currentIndex;
  final bool isLoading;
  final String? errorMessage;
  final FamilyController familyController;
  final VoidCallback onRetry;

  const HomeBody({
    super.key,
    required this.currentIndex,
    required this.isLoading,
    required this.errorMessage,
    required this.familyController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga
    if (isLoading) {
      return const _LoadingState();
    }
    
    // Mostrar error si hubo problemas
    if (errorMessage != null) {
      return _ErrorState(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    
    // Mostrar contenido principal
    return _ContentState(
      currentIndex: currentIndex,
      familyController: familyController,
    );
  }
}

/// Estado de carga
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando información del usuario...'),
        ],
      ),
    );
  }
}

/// Estado de error
class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Estado de contenido principal
class _ContentState extends StatelessWidget {
  final int currentIndex;
  final FamilyController familyController;

  const _ContentState({
    required this.currentIndex,
    required this.familyController,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentIndex,
      children: [
        // Tab de familia
        Center(
          child: Text(
            'Tab de Familia',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        // Tab de mascotas
        Center(
          child: Text(
            'Tab de Mascotas',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        // Tab de residencia
        Center(
          child: Text(
            'Tab de Residencia',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        // Tab de configuración
        Center(
          child: Text(
            'Tab de Configuración',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
