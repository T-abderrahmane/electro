import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/app_provider.dart';
import '../../utils/constants.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedWilaya;
  String? _selectedCommune;
  final List<File> _images = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأقصى 5 صور')),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    // Guard: prevent double-click
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedWilaya == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار الولاية')),
        );
        return;
      }
      if (_selectedCommune == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار البلدية')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final provider = context.read<AppProvider>();
        final success = await provider.createRequest(
          title: _titleController.text,
          description: _descriptionController.text,
          wilaya: _selectedWilaya!,
          commune: _selectedCommune!,
          images: _images.map((f) => f.path).toList(),
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الطلب بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل إرسال الطلب. تحقق من الاتصال بالإنترنت.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب جديد'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الطلب',
                    hintText: 'مثال: تركيب مكيف هواء',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان الطلب';
                    }
                    if (value.length < 5) {
                      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'وصف الطلب',
                    hintText: 'اشرح تفاصيل الخدمة التي تحتاجها...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف الطلب';
                    }
                    if (value.length < 20) {
                      return 'الوصف يجب أن يكون 20 حرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Wilaya
                DropdownButtonFormField<String>(
                  value: _selectedWilaya,
                  decoration: const InputDecoration(
                    labelText: 'الولاية',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: algerianWilayas.map((wilaya) {
                    return DropdownMenuItem(
                      value: wilaya,
                      child: Text(wilaya),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWilaya = value;
                      _selectedCommune = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Commune
                DropdownButtonFormField<String>(
                  value: _selectedCommune,
                  decoration: const InputDecoration(
                    labelText: 'البلدية',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: _selectedWilaya != null &&
                          communesByWilaya.containsKey(_selectedWilaya)
                      ? communesByWilaya[_selectedWilaya]!.map((commune) {
                          return DropdownMenuItem(
                            value: commune,
                            child: Text(commune),
                          );
                        }).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      _selectedCommune = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Images Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'صور (اختياري)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_images.length}/5',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Image Grid
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Add Image Button
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'إضافة صورة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image Previews
                      ..._images.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(entry.value),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: 16,
                              child: GestureDetector(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('إرسال الطلب'),
                ),
                const SizedBox(height: 16),
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'سيتم إرسال طلبك للكهربائيين في منطقتك وستتلقى عروضهم قريباً',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
