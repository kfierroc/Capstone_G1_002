import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../screens/grifos/grifo_map_screen.dart';

class GrifoMapPlaceholder extends StatelessWidget {
  final int itemCount;

  const GrifoMapPlaceholder({
    super.key,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GrifoMapScreen(),
              ),
            );
          },
          icon: const Icon(Icons.map_rounded, size: 20),
          label: const Text(
            'Ver mapa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
