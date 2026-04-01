import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  File? _newProfileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _experienceController = TextEditingController(
      text: user?.yearsExperience?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final language = provider.language;
    final l10n = AppLocalizer.fromLanguage(language);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final success = await provider.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      yearsExperience:
          _experienceController.text.isNotEmpty
              ? int.tryParse(_experienceController.text)
              : null,
      profileImage: _newProfileImage?.path,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tr(
              'تم تحديث الملف الشخصي بنجاح',
              'Profil mis a jour avec succes',
            ),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final isElectrician = user?.role == UserRole.electrician;
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('تعديل الملف الشخصي', 'Modifier le profil')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          image:
                              _newProfileImage != null
                                  ? DecorationImage(
                                    image: FileImage(_newProfileImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : user?.profileImage != null
                                  ? DecorationImage(
                                    image: FileImage(File(user!.profileImage!)),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _newProfileImage == null &&
                                    user?.profileImage == null
                                ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primary,
                                )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tr('اضغط لتغيير الصورة', 'Appuyez pour changer la photo'),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.tr('الاسم الكامل', 'Nom complet'),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.tr(
                      'الرجاء إدخال الاسم',
                      'Veuillez saisir le nom',
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

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.tr('رقم الهاتف', 'Numero de telephone'),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.tr(
                      'الرجاء إدخال رقم الهاتف',
                      'Veuillez saisir le numero de telephone',
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

              // Experience Field (only for electricians)
              if (isElectrician) ...[
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.tr('سنوات الخبرة', 'Annees d experience'),
                    prefixIcon: const Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final years = int.tryParse(value);
                      if (years == null || years < 0 || years > 50) {
                        return l10n.tr(
                          'الرجاء إدخال عدد صحيح',
                          'Veuillez saisir un nombre valide',
                        );
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Location Info (read-only for electricians)
              if (isElectrician && user?.wilaya != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('الموقع', 'Localisation'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            l10n.location(user!.wilaya!, user.commune ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tr(
                    'لتغيير الموقع، يرجى التواصل مع الدعم',
                    'Pour changer la localisation, contactez le support',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            l10n.tr(
                              'حفظ التغييرات',
                              'Enregistrer les modifications',
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
