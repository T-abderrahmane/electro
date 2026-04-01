import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class ElectricianLoginScreen extends StatefulWidget {
  const ElectricianLoginScreen({super.key});

  @override
  State<ElectricianLoginScreen> createState() =>
      _ElectricianLoginScreenState();
}

class _ElectricianLoginScreenState extends State<ElectricianLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      final language = provider.language;
      final l10n = AppLocalizer.fromLanguage(language);
      
      final success = await provider.loginAsElectrician(
        _phoneController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/electrician-home',
          (route) => false,
        );
      } else if (mounted) {
        final backendError = provider.authError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              backendError ??
                  l10n.tr(
                    'فشل تسجيل الدخول. تحقق من البيانات وحاول مجددا.',
                    'Echec de la connexion. Verifiez vos donnees et reessayez.',
                  ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppProvider>().isLoading;
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('تسجيل دخول الكهربائي', 'Connexion electricien')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction,
                    size: 40,
                    color: AppColors.secondary,
                  ),
                ),
                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.tr('رقم الهاتف', 'Numero de telephone'),
                    hintText: '0555123456',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.tr(
                        'الرجاء إدخال رقم الهاتف',
                        'Veuillez entrer le numero de telephone',
                      );
                    }
                    if (value.length < 10) {
                      return l10n.tr(
                        'رقم الهاتف غير صحيح',
                        'Numero de telephone invalide',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.tr('كلمة المرور', 'Mot de passe'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.tr(
                        'الرجاء إدخال كلمة المرور',
                        'Veuillez entrer le mot de passe',
                      );
                    }
                    if (value.length < 6) {
                      return l10n.tr(
                        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                        'Le mot de passe doit contenir au moins 6 caracteres',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  onPressed: isLoading ? null : _login,
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(l10n.tr('تسجيل الدخول', 'Se connecter')),
                ),
                const SizedBox(height: 16),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.tr('ليس لديك حساب؟', 'Vous n avez pas de compte ?'),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/electrician-register');
                      },
                      child: Text(l10n.tr('سجل الآن', 'Inscrivez-vous')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
