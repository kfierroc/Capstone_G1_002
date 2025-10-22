import 'package:flutter/material.dart';

/// Sistema de lazy loading para pantallas siguiendo principios SOLID
/// 
/// Responsabilidades:
/// - Cargar pantallas bajo demanda
/// - Manejar estados de carga
/// - Optimizar memoria y rendimiento
/// - Proporcionar fallbacks apropiados
class LazyScreenBuilder {
  static final Map<String, Widget Function()> _screenFactories = {};
  static final Map<String, Widget> _loadedScreens = {};

  /// Registra una factory para una pantalla
  static void registerScreen(String routeName, Widget Function() factory) {
    _screenFactories[routeName] = factory;
  }

  /// Construye una pantalla con lazy loading
  static Widget buildLazyScreen(String routeName) {
    return LazyScreenWidget(routeName: routeName);
  }

  /// Precarga una pantalla específica
  static Future<void> preloadScreen(String routeName) async {
    if (_loadedScreens.containsKey(routeName)) {
      return; // Ya está cargada
    }

    final factory = _screenFactories[routeName];
    if (factory != null) {
      _loadedScreens[routeName] = factory();
    }
  }

  /// Limpia pantallas cargadas para liberar memoria
  static void clearCache() {
    _loadedScreens.clear();
  }

  /// Limpia una pantalla específica
  static void clearScreen(String routeName) {
    _loadedScreens.remove(routeName);
  }
}

/// Widget que maneja la carga lazy de pantallas
class LazyScreenWidget extends StatefulWidget {
  final String routeName;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration? timeout;

  const LazyScreenWidget({
    super.key,
    required this.routeName,
    this.loadingWidget,
    this.errorWidget,
    this.timeout,
  });

  @override
  State<LazyScreenWidget> createState() => _LazyScreenWidgetState();
}

class _LazyScreenWidgetState extends State<LazyScreenWidget> {
  Widget? _screen;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    try {
      // Verificar si ya está cargada
      if (LazyScreenBuilder._loadedScreens.containsKey(widget.routeName)) {
        setState(() {
          _screen = LazyScreenBuilder._loadedScreens[widget.routeName];
          _isLoading = false;
        });
        return;
      }

      // Obtener factory
      final factory = LazyScreenBuilder._screenFactories[widget.routeName];
      if (factory == null) {
        throw Exception('Screen factory not found for route: ${widget.routeName}');
      }

      // Cargar con timeout si está especificado
      if (widget.timeout != null) {
        _screen = await Future.any([
          Future(() => factory()),
          Future.delayed(widget.timeout!, () => throw Exception('Screen loading timeout')),
        ]);
      } else {
        _screen = await Future(() => factory());
      }

      // Cachear la pantalla
      LazyScreenBuilder._loadedScreens[widget.routeName] = _screen!;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading screen ${widget.routeName}: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? const DefaultLoadingWidget();
    }

    if (_hasError) {
      return widget.errorWidget ?? DefaultErrorWidget(
        error: _errorMessage ?? 'Error desconocido',
        onRetry: _loadScreen,
      );
    }

    return _screen ?? DefaultErrorWidget(
      error: 'Pantalla no encontrada',
      onRetry: _loadScreen,
    );
  }
}

/// Widget de carga por defecto
class DefaultLoadingWidget extends StatelessWidget {
  const DefaultLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando...'),
        ],
      ),
    );
  }
}

/// Widget de error por defecto
class DefaultErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
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
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sistema de lazy loading para datos
class LazyDataLoader<T> {
  final Future<List<T>> Function(int page, int limit) _loader;
  final int _pageSize;
  final int _preloadThreshold;

  List<T> _data = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  LazyDataLoader({
    required Future<List<T>> Function(int page, int limit) loader,
    int pageSize = 20,
    int preloadThreshold = 5,
  }) : _loader = loader,
       _pageSize = pageSize,
       _preloadThreshold = preloadThreshold;

  /// Obtiene los datos actuales
  List<T> get data => List.unmodifiable(_data);

  /// Indica si está cargando
  bool get isLoading => _isLoading;

  /// Indica si hay más datos disponibles
  bool get hasMore => _hasMore;

  /// Obtiene el error actual
  String? get error => _error;

  /// Carga la primera página de datos
  Future<void> loadFirstPage() async {
    _currentPage = 1;
    _data.clear();
    _hasMore = true;
    _error = null;
    await _loadPage(_currentPage);
  }

  /// Carga la siguiente página
  Future<void> loadNextPage() async {
    if (!_isLoading && _hasMore) {
      await _loadPage(_currentPage + 1);
    }
  }

  /// Recarga todos los datos
  Future<void> reload() async {
    await loadFirstPage();
  }

  /// Carga una página específica
  Future<void> _loadPage(int page) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;

      final newData = await _loader(page, _pageSize);
      
      if (page == 1) {
        _data = newData;
      } else {
        _data.addAll(newData);
      }

      _currentPage = page;
      _hasMore = newData.length == _pageSize;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading page $page: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Verifica si necesita precargar más datos
  bool shouldPreload(int currentIndex) {
    return currentIndex >= _data.length - _preloadThreshold && 
           !_isLoading && 
           _hasMore;
  }

  /// Obtiene un elemento por índice con precarga automática
  T? getItem(int index) {
    if (index < 0 || index >= _data.length) {
      return null;
    }

    // Precargar si es necesario
    if (shouldPreload(index)) {
      loadNextPage();
    }

    return _data[index];
  }

  /// Agrega un elemento al inicio de la lista
  void prependItem(T item) {
    _data.insert(0, item);
  }

  /// Agrega un elemento al final de la lista
  void appendItem(T item) {
    _data.add(item);
  }

  /// Actualiza un elemento en la lista
  void updateItem(int index, T item) {
    if (index >= 0 && index < _data.length) {
      _data[index] = item;
    }
  }

  /// Elimina un elemento de la lista
  void removeItem(int index) {
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
    }
  }

  /// Limpia todos los datos
  void clear() {
    _data.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
  }
}

/// Widget que maneja lazy loading de datos en una lista
class LazyListView<T> extends StatefulWidget {
  final LazyDataLoader<T> dataLoader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;

  const LazyListView({
    super.key,
    required this.dataLoader,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.scrollController,
  });

  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    widget.dataLoader.loadFirstPage();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      widget.dataLoader.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        final data = widget.dataLoader.data;
        final isLoading = widget.dataLoader.isLoading;
        final hasMore = widget.dataLoader.hasMore;
        final error = widget.dataLoader.error;

        if (error != null) {
          return widget.errorWidget ?? DefaultErrorWidget(
            error: error,
            onRetry: widget.dataLoader.reload,
          );
        }

        if (data.isEmpty && isLoading) {
          return widget.loadingWidget ?? const DefaultLoadingWidget();
        }

        if (data.isEmpty) {
          return widget.emptyWidget ?? const Center(
            child: Text('No hay datos disponibles'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: data.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= data.length) {
              return widget.loadingWidget ?? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return widget.itemBuilder(context, data[index], index);
          },
        );
      },
    );
  }
}
