import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data
  final String userName = 'Food Explorer';
  final String userEmail = 'explorer@foodzaam.com';
  final int totalScans = 47;
  final int favoriteCuisines = 8;
  final int savedRecipes = 23;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 100,
            ),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildStatsCards(),
                const SizedBox(height: 32),
                _buildMenuItems(),
                const SizedBox(height: 32),
                _buildAppInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration.copyWith(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // User Name
          Text(
                userName,
                style: AppTheme.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 8),

          // User Email
          Text(
                userEmail,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Edit Profile Button
          CustomButton(
                onPressed: _editProfile,
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                isPrimary: false,
                size: CustomButtonSize.medium,
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .scale(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For very small screens, stack the cards vertically
        if (constraints.maxWidth < 320) {
          return Column(
            children: [
              _buildStatCard(
                icon: Icons.camera_alt_rounded,
                value: totalScans.toString(),
                label: 'Total Scans',
                color: AppTheme.primaryColor,
                delay: 0,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.restaurant_rounded,
                      value: favoriteCuisines.toString(),
                      label: 'Cuisines',
                      color: AppTheme.secondaryColor,
                      delay: 100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bookmark_rounded,
                      value: savedRecipes.toString(),
                      label: 'Saved',
                      color: AppTheme.accentColor,
                      delay: 200,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // For normal screens, use the row layout
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.camera_alt_rounded,
                value: totalScans.toString(),
                label: 'Total Scans',
                color: AppTheme.primaryColor,
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.restaurant_rounded,
                value: favoriteCuisines.toString(),
                label: 'Cuisines',
                color: AppTheme.secondaryColor,
                delay: 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.bookmark_rounded,
                value: savedRecipes.toString(),
                label: 'Saved',
                color: AppTheme.accentColor,
                delay: 200,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(
                  value,
                  style: AppTheme.headingMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, delay: delay.ms, duration: 600.ms);
  }

  Widget _buildMenuItems() {
    final menuItems = [
      MenuItemData(
        icon: Icons.history_rounded,
        title: 'Food History',
        subtitle: 'View your identified foods',
        onTap: () {},
      ),
      MenuItemData(
        icon: Icons.favorite_rounded,
        title: 'Favorite Cuisines',
        subtitle: 'Manage your preferences',
        onTap: () {},
      ),
      MenuItemData(
        icon: Icons.settings_rounded,
        title: 'Settings',
        subtitle: 'App preferences and options',
        onTap: () {},
      ),
      MenuItemData(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'Get help and contact us',
        onTap: () {},
      ),
      MenuItemData(
        icon: Icons.star_rounded,
        title: 'Rate App',
        subtitle: 'Share your feedback',
        onTap: () {},
      ),
      MenuItemData(
        icon: Icons.share_rounded,
        title: 'Share App',
        subtitle: 'Tell friends about FoodZaam',
        onTap: () {},
      ),
    ];

    return Column(
      children:
          menuItems.asMap().entries.map((entry) {
            return _buildMenuItem(entry.value, entry.key);
          }).toList(),
    );
  }

  Widget _buildMenuItem(MenuItemData item, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: AppTheme.cardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppTheme.primaryColor, size: 24),
            ),
            title: Text(
              item.title,
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.subtitle,
              style: AppTheme.bodySmall.copyWith(color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
            onTap: item.onTap,
          ),
        )
        .animate()
        .fadeIn(delay: (300 + index * 100).ms, duration: 600.ms)
        .slideX(
          begin: 0.3,
          end: 0,
          delay: (300 + index * 100).ms,
          duration: 600.ms,
        );
  }

  Widget _buildAppInfo() {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // App Name and Version
              Text(
                'FoodZaam',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: AppTheme.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Discover and identify food with the power of AI. Explore cuisines from around the world and build your culinary knowledge.',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Footer Links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Privacy Policy',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 16, color: Colors.grey[300]),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Terms of Service',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 600.ms);
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfileSheet(),
    );
  }

  Widget _buildEditProfileSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Edit Profile', style: AppTheme.headingMedium),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form Fields
          TextField(
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: userName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: userEmail,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.close,
                  label: 'Cancel',
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Save profile changes
                  },
                  icon: Icons.check,
                  label: 'Save',
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
