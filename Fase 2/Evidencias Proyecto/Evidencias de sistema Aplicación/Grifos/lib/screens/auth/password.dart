import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/white_card_container.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await SupabaseConfig.client.auth.resetPasswordForEmail(
          _emailController.text.trim(),
        );

        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.msgRecuperacionSuccess),
              backgroundColor: AppColors.success,
              duration: AppConstants.snackbarDuration,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradientColors: [Colors.orange.shade400, Colors.orange.shade700],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthHeader(
              icon: _emailSent ? Icons.check_circle_outline : Icons.lock_reset,
              iconColor: AppColors.warning,
              title: _emailSent ? '¡Email Enviado!' : 'Recuperar Contraseña',
              subtitle: _emailSent
                  ? 'Revisa tu email para restablecer tu contraseña'
                  : 'Ingresa tu email para recibir el codigo',
            ),
            const SizedBox(height: 40),
            if (!_emailSent) _buildEmailForm() else _buildSuccessMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return WhiteCardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'correo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Enviar Email',
            backgroundColor: AppColors.warning,
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return WhiteCardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: AppStyles.iconXLarge,
            color: Color(0xFF43A047),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hemos enviado un enlace de recuperación a tu email.',
            textAlign: TextAlign.center,
            style: AppStyles.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            _emailController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.info,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sigue las instrucciones del email para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 20),
          CustomOutlinedButton(
            text: 'Enviar otro email',
            borderColor: AppColors.warning,
            onPressed: () {
              setState(() {
                _emailSent = false;
                _emailController.clear();
              });
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Volver al Login',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
