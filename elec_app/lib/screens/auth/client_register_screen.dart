import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();
      final language = provider.language;
      final l10n = AppLocalizer.fromLanguage(language);
      
      final success = await provider.registerClient(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/client-home',
          (route) => false,
        );
      } else if (mounted) {
        final backendError = provider.authError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              backendError ??
                  l10n.tr(
                    'فشل إنشاء الحساب. تحقق من الاتصال أو أن رقم الهاتف غير مستعمل.',
                    'Echec de creation du compte. Verifiez la connexion ou que le numero n est pas deja utilise.',
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
        title: Text(l10n.tr('إنشاء حساب عميل', 'Creer un compte client')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                // Name
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.tr('الاسم الكامل', 'Nom complet'),
                    hintText: l10n.tr(
                      'أدخل اسمك الكامل',
                      'Entrez votre nom complet',
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.tr(
                        'الرجاء إدخال الاسم',
                        'Veuillez entrer le nom',
                      );
                    }
                    if (value.length < 3) {
                      return l10n.tr(
                        'الاسم يجب أن يكون 3 أحرف على الأقل',
                        'Le nom doit contenir au moins 3 caracteres',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.tr(
                      'تأكيد كلمة المرور',
                      'Confirmer le mot de passe',
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.tr(
                        'الرجاء تأكيد كلمة المرور',
                        'Veuillez confirmer le mot de passe',
                      );
                    }
                    if (value != _passwordController.text) {
                      return l10n.tr(
                        'كلمتا المرور غير متطابقتين',
                        'Les mots de passe ne correspondent pas',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Register Button
                ElevatedButton(
                  onPressed: isLoading ? null : _register,
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
                          : Text(l10n.tr('إنشاء الحساب', 'Creer le compte')),
                ),
                const SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.tr(
                        'لديك حساب بالفعل؟',
                        'Vous avez deja un compte ?',
                      ),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(l10n.tr('تسجيل الدخول', 'Se connecter')),
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
