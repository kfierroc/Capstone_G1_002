import 'package:flutter/material.dart';
import 'package:firedata_admin/web_admin/services/admin_metrics_service.dart';

/// Página principal del panel con tarjetas de resumen alimentadas desde Supabase.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 12.0 : 24.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: FutureBuilder<AdminMetrics>(
        future: AdminMetricsService.instance.loadMetrics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
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
                      'No fue posible cargar los indicadores',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final metrics = snapshot.data ??
              const AdminMetrics(
                residents: 0,
                firefighters: 0,
                houses: 0,
                hydrants: 0,
              );

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

              final cards = [
                _DashboardCard(
                  title: 'Residentes',
                  value: metrics.residents.toString(),
                  icon: Icons.groups_2,
                  color: const Color(0xFF43A047),
                ),
                _DashboardCard(
                  title: 'Bomberos',
                  value: metrics.firefighters.toString(),
                  icon: Icons.fire_extinguisher,
                  color: const Color(0xFFD84315),
                ),
                _DashboardCard(
                  title: 'Viviendas',
                  value: metrics.houses.toString(),
                  icon: Icons.house,
                  color: const Color(0xFF1E88E5),
                ),
                _DashboardCard(
                  title: 'Grifos',
                  value: metrics.hydrants.toString(),
                  icon: Icons.water_drop,
                  color: const Color(0xFF00897B),
                ),
              ];

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(padding),
                    sliver: SliverGrid.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isMobile ? 1.8 : 1.5,
                      children: cards,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.08),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



