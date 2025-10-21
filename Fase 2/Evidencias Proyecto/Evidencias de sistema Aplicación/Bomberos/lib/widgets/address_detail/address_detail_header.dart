import 'package:flutter/material.dart';
import '../../constants/address_detail_styles.dart';

/// Widget reutilizable para el header de la pantalla de detalles
/// Aplicando principio de responsabilidad única (SRP)
class AddressDetailHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onClose;

  const AddressDetailHeader({
    super.key,
    required this.userName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AddressDetailStyles.redGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AddressDetailStyles.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sistema de Emergencias',
                          style: TextStyle(
                            color: AddressDetailStyles.white,
                            fontSize: AddressDetailStyles.fontSizeTitle,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bienvenido, Voluntario $userName',
                          style: const TextStyle(
                            color: AddressDetailStyles.white,
                            fontSize: AddressDetailStyles.fontSizeLarge,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close,
                      color: AddressDetailStyles.white,
                      size: AddressDetailStyles.iconSizeMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
