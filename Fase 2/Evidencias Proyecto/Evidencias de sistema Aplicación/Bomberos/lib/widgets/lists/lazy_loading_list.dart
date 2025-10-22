import 'package:flutter/material.dart';
import '../../utils/responsive_constants.dart';
import '../../constants/grifo_colors.dart';

/// Componente de lista lazy loading reutilizable
/// Aplicando principios SOLID y Clean Code
class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  const LazyLoadingList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.padding,
    this.scrollController,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
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
      if (widget.hasMore && !widget.isLoading && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? _buildEmptyWidget();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return widget.loadingWidget ?? _buildLoadingWidget();
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: ResponsiveConstants.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(32),
          tablet: const EdgeInsets.all(48),
          desktop: const EdgeInsets.all(64),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: IconSize.large(context),
              color: GrifoColors.textTertiary,
            ),
            SizedBox(height: Spacing.medium(context)),
            Text(
              'No hay elementos para mostrar',
              style: TextStyle(
                fontSize: FontSize.large(context),
                color: GrifoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Componente de lista de grifos con lazy loading
class LazyGrifosList extends StatefulWidget {
  final List<dynamic> grifos;
  final Map<int, dynamic> infoGrifos;
  final Map<int, String> nombresComunas;
  final Function(int, String) onCambiarEstado;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;

  const LazyGrifosList({
    super.key,
    required this.grifos,
    required this.infoGrifos,
    required this.nombresComunas,
    required this.onCambiarEstado,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
  });

  @override
  State<LazyGrifosList> createState() => _LazyGrifosListState();
}

class _LazyGrifosListState extends State<LazyGrifosList> {
  @override
  Widget build(BuildContext context) {
    return LazyLoadingList(
      items: widget.grifos,
      onLoadMore: widget.onLoadMore,
      hasMore: widget.hasMore,
      isLoading: widget.isLoading,
      padding: ResponsiveConstants.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      itemBuilder: (context, grifo, index) {
        return _buildGrifoCard(grifo, index);
      },
      emptyWidget: _buildEmptyGrifosWidget(),
    );
  }

  Widget _buildGrifoCard(dynamic grifo, int index) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.medium(context),
        vertical: Spacing.small(context),
      ),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveConstants.getResponsiveBorderRadius(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveConstants.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGrifoHeader(grifo),
            SizedBox(height: Spacing.medium(context)),
            _buildGrifoInfo(grifo),
            SizedBox(height: Spacing.medium(context)),
            _buildGrifoActions(grifo),
          ],
        ),
      ),
    );
  }

  Widget _buildGrifoHeader(dynamic grifo) {
    final estadoColor = _getEstadoColor(grifo);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: estadoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: estadoColor, width: 1),
          ),
          child: Text(
            'Grifo ${grifo.idGrifo}',
            style: TextStyle(
              color: estadoColor,
              fontWeight: FontWeight.bold,
              fontSize: FontSize.small(context),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GrifoColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            grifo.cutCom.toString(),
            style: TextStyle(
              color: GrifoColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: FontSize.small(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrifoInfo(dynamic grifo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grifo ${grifo.idGrifo}',
          style: TextStyle(
            fontSize: FontSize.large(context),
            fontWeight: FontWeight.bold,
            color: GrifoColors.textPrimary,
          ),
        ),
        SizedBox(height: Spacing.small(context)),
        Text(
          'Comuna: ${widget.nombresComunas[grifo.cutCom] ?? 'Comuna ${grifo.cutCom}'}',
          style: TextStyle(
            fontSize: FontSize.medium(context),
            color: GrifoColors.textSecondary,
          ),
        ),
        SizedBox(height: Spacing.small(context)),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: IconSize.small(context),
              color: GrifoColors.textTertiary,
            ),
            SizedBox(width: Spacing.small(context)),
            Text(
              'Coordenadas: ${grifo.lat.toStringAsFixed(4)}, ${grifo.lon.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: FontSize.small(context),
                color: GrifoColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrifoActions(dynamic grifo) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEstadoDialog(grifo),
            icon: Icon(
              Icons.edit,
              size: IconSize.small(context),
            ),
            label: const Text('Cambiar Estado'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GrifoColors.primary,
              side: BorderSide(color: GrifoColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: Spacing.medium(context)),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDetallesDialog(grifo),
            icon: Icon(
              Icons.info_outline,
              size: IconSize.small(context),
            ),
            label: const Text('Ver Detalles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GrifoColors.secondary,
              side: BorderSide(color: GrifoColors.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGrifosWidget() {
    return Center(
      child: Padding(
        padding: ResponsiveConstants.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(32),
          tablet: const EdgeInsets.all(48),
          desktop: const EdgeInsets.all(64),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: IconSize.large(context),
              color: GrifoColors.textTertiary,
            ),
            SizedBox(height: Spacing.medium(context)),
            Text(
              'No hay grifos registrados',
              style: TextStyle(
                fontSize: FontSize.large(context),
                color: GrifoColors.textSecondary,
              ),
            ),
            SizedBox(height: Spacing.small(context)),
            Text(
              'Registra el primer grifo para comenzar',
              style: TextStyle(
                fontSize: FontSize.medium(context),
                color: GrifoColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(dynamic grifo) {
    final infoGrifo = widget.infoGrifos[grifo.idGrifo];
    if (infoGrifo == null) return GrifoColors.textTertiary;
    
    switch (infoGrifo.estado.toLowerCase()) {
      case 'operativo':
        return Colors.green;
      case 'dañado':
        return Colors.red;
      case 'mantenimiento':
        return Colors.orange;
      case 'sin verificar':
        return Colors.grey;
      default:
        return GrifoColors.textTertiary;
    }
  }

  void _showEstadoDialog(dynamic grifo) {
    final estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((estado) => ListTile(
            title: Text(estado),
            onTap: () {
              Navigator.pop(context);
              widget.onCambiarEstado(grifo.idGrifo, estado);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDetallesDialog(dynamic grifo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grifo ${grifo.idGrifo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID:', grifo.idGrifo.toString()),
            _buildDetailRow('Comuna:', widget.nombresComunas[grifo.cutCom] ?? 'Comuna ${grifo.cutCom}'),
            _buildDetailRow('Latitud:', grifo.lat.toStringAsFixed(6)),
            _buildDetailRow('Longitud:', grifo.lon.toStringAsFixed(6)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSize.medium(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSize.medium(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
