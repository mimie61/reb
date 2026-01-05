import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/menu_package.dart';
import '../../services/menu_service.dart';
import '../../services/service_locator.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/package_card.dart';
import '../../widgets/section_title.dart';

class AdminAddEditMenuPage extends StatefulWidget {
  final MenuPackage? package;

  const AdminAddEditMenuPage({super.key, this.package});

  @override
  State<AdminAddEditMenuPage> createState() => _AdminAddEditMenuPageState();
}

class _AdminAddEditMenuPageState extends State<AdminAddEditMenuPage> {
  final MenuService _menuService = serviceLocator<MenuService>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _minGuestsController = TextEditingController();
  final _maxGuestsController = TextEditingController();

  final List<TextEditingController> _featureControllers = [];

  bool _isAvailable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    if (package != null) {
      _nameController.text = package.title;
      _descController.text = package.description;
      _priceController.text = package.pricePerGuest.toStringAsFixed(0);
      _minGuestsController.text = package.minGuests.toString();
      _maxGuestsController.text = package.maxGuests?.toString() ?? '';
      _isAvailable = package.active;
      if (package.features.isNotEmpty) {
        for (final feature in package.features) {
          _featureControllers.add(TextEditingController(text: feature));
        }
      }
    }

    if (_featureControllers.isEmpty) {
      _featureControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _minGuestsController.dispose();
    _maxGuestsController.dispose();
    for (final controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final minGuests = int.tryParse(_minGuestsController.text.trim()) ??
        widget.package?.minGuests ??
        1;
    final maxGuests = int.tryParse(_maxGuestsController.text.trim());

    if (maxGuests != null && maxGuests < minGuests) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum guests must be greater than minimum.')),
      );
      return;
    }

    final features = _featureControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final package = MenuPackage(
      id: widget.package?.id ?? const Uuid().v4(),
      title: _nameController.text.trim(),
      description: _descController.text.trim(),
      pricePerGuest: price,
      minGuests: minGuests,
      maxGuests: maxGuests,
      imagePath: widget.package?.imagePath,
      features: features,
      active: _isAvailable,
      createdAt: widget.package?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.package == null) {
        await _menuService.createPackage(package);
      } else {
        await _menuService.updatePackage(package);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.package == null
                ? 'Package created successfully.'
                : 'Package updated successfully.',
          ),
        ),
      );
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/admin-manage-menu');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save package: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _addFeatureField() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    if (_featureControllers.length <= 1) return;
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.package != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Package' : 'Add Package'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin-manage-menu');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePackage,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? AppColors.textSecondary : AppColors.accentYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            const SectionTitle('Package Details'),
            CustomTextField(
              label: 'Package Name',
              hint: 'Enter package name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Package name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              hint: 'Describe the package',
              controller: _descController,
              minLines: 3,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Price Per Guest (RM)',
              hint: 'e.g. 120',
              controller: _priceController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
              validator: (value) {
                final price = double.tryParse(value?.trim() ?? '');
                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Minimum Guests',
                    hint: 'e.g. 20',
                    controller: _minGuestsController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Maximum Guests',
                    hint: 'Optional',
                    controller: _maxGuestsController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.people_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFeaturesSection(),
            const SizedBox(height: 24),
            _buildAvailabilitySection(),
            const SizedBox(height: 24),
            const SectionTitle('Preview'),
            PackageCard(package: _previewPackage()),
            const SizedBox(height: 24),
            LoadingButton(
              label: isEditing ? 'Update Package' : 'Create Package',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _savePackage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentYellow.withOpacity(0.3),
                  AppColors.gray,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: AppColors.accentYellow,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Image uploads coming soon',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Add Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Features'),
        ..._featureControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Feature ${index + 1}',
                    hint: 'e.g. Welcome drinks',
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeFeatureField(index),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addFeatureField,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentYellow,
            side: const BorderSide(color: AppColors.accentYellow),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add Feature'),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Package Availability',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _isAvailable,
            activeColor: AppColors.accentYellow,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
    );
  }

  MenuPackage _previewPackage() {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final minGuests = int.tryParse(_minGuestsController.text.trim()) ??
        widget.package?.minGuests ??
        1;
    final maxGuests = int.tryParse(_maxGuestsController.text.trim());

    return MenuPackage(
      id: widget.package?.id ?? 'preview',
      title: _nameController.text.trim().isEmpty
          ? 'Package Preview'
          : _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'Package description will appear here.'
          : _descController.text.trim(),
      pricePerGuest: price <= 0 ? 0 : price,
      minGuests: minGuests,
      maxGuests: maxGuests,
      imagePath: widget.package?.imagePath,
      features: _featureControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
      active: _isAvailable,
      createdAt: widget.package?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}