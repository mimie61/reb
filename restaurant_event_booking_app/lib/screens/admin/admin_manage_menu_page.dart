import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/menu_package.dart';
import '../../services/menu_service.dart';
import '../../services/service_locator.dart';
import '../../theme/colors.dart';

class AdminManageMenuPage extends StatefulWidget {
  const AdminManageMenuPage({super.key});

  @override
  State<AdminManageMenuPage> createState() => _AdminManageMenuPageState();
}

class _AdminManageMenuPageState extends State<AdminManageMenuPage> {
  final MenuService _menuService = serviceLocator<MenuService>();

  bool _isLoading = true;
  String? _error;
  List<MenuPackage> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final packages = await _menuService.getAllPackages();
      packages.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (!mounted) return;
      setState(() {
        _packages = packages;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(MenuPackage package, bool value) async {
    try {
      await _menuService.updatePackage(
        package.copyWith(active: value),
      );
      await _loadPackages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${package.title} marked as ${value ? 'Active' : 'Inactive'}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update package: $e')),
      );
    }
  }

  Future<void> _deletePackage(MenuPackage package) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Delete Package',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete "${package.title}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _menuService.deletePackage(package.id);
      await _loadPackages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${package.title} deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete package: $e')),
      );
    }
  }

  void _navigateToAdd() {
    context.push('/admin-add-menu');
  }

  void _navigateToEdit(MenuPackage package) {
    context.push('/admin-add-menu', extra: package);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin-dashboard');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentYellow,
        foregroundColor: AppColors.black,
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPackages,
        color: AppColors.accentYellow,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_isLoading) _buildLoadingList(),
            if (!_isLoading && _error != null) _buildErrorState(),
            if (!_isLoading && _error == null && _packages.isEmpty)
              _buildEmptyState(),
            if (!_isLoading && _error == null && _packages.isNotEmpty)
              ..._packages.map(_buildPackageCard),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(
        4,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _ShimmerBox(height: 140),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unable to load packages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadPackages,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentYellow,
              side: const BorderSide(color: AppColors.accentYellow),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No packages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first package to start offering bookings.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _navigateToAdd,
            child: const Text('Add Package'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(MenuPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPackageImage(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _buildAvailabilityBadge(package.active),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        package.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _infoChip(
                            icon: Icons.payments_outlined,
                            label: 'RM ${package.pricePerGuest.toStringAsFixed(0)}',
                          ),
                          const SizedBox(width: 8),
                          _infoChip(
                            icon: Icons.people_outline,
                            label: _guestLabel(package),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border),
            const SizedBox(height: 14),
            Row(
              children: [
                Row(
                  children: [
                    Switch(
                      value: package.active,
                      onChanged: (value) =>
                          _toggleAvailability(package, value),
                      activeColor: AppColors.accentYellow,
                    ),
                    Text(
                      package.active ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _actionButton(
                  label: 'Edit',
                  color: AppColors.accentYellow,
                  textColor: AppColors.black,
                  onTap: () => _navigateToEdit(package),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Delete',
                  color: AppColors.red,
                  textColor: AppColors.textPrimary,
                  onTap: () => _deletePackage(package),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageImage() {
    return Container(
      width: 82,
      height: 82,
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
      child: const Icon(
        Icons.restaurant_menu_outlined,
        color: AppColors.accentYellow,
      ),
    );
  }

  Widget _buildAvailabilityBadge(bool active) {
    final color = active ? AppColors.green : AppColors.textSecondary;
    final label = active ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _guestLabel(MenuPackage package) {
    if (package.maxGuests == null) {
      return 'Min ${package.minGuests}';
    }
    return '${package.minGuests}-${package.maxGuests}';
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.value * 2 - 1;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            gradient: LinearGradient(
              begin: Alignment(-1 + offset, -0.2),
              end: Alignment(1 + offset, 0.2),
              colors: [
                AppColors.surface,
                AppColors.gray.withOpacity(0.6),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}