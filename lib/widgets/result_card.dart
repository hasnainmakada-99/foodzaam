import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../core/theme/app_theme.dart';
import 'custom_button.dart';

class ResultCard extends StatelessWidget {
  final String foodName;
  final String cuisine;
  final String description;
  final VoidCallback onReset;
  final AnimationController animation;

  const ResultCard({
    Key? key,
    required this.foodName,
    required this.cuisine,
    required this.description,
    required this.onReset,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isTablet = screenSize.width > 600;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: Container(
        margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.7, // Max 70% of screen height
          minHeight: 200, // Minimum height for content
        ),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity, // Let it fill the container
          borderRadius: isSmallScreen ? 20 : 24,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.2),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : (isTablet ? 32 : 24)),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and action
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Text(
                          'Food Identified!',
                          style: AppTheme.headingSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : (isTablet ? 24 : 20),
                          ),
                        ),
                      ),
                      CustomButton(
                        onPressed: onReset,
                        icon: Icons.refresh_rounded,
                        label: isSmallScreen ? '' : 'New',
                        isPrimary: false,
                        size:
                            isSmallScreen
                                ? CustomButtonSize.small
                                : CustomButtonSize.medium,
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Food name - Make it responsive
                  Flexible(
                    child: Text(
                      foodName,
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 20 : (isTablet ? 32 : 28),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 6 : 8),

                  // Cuisine badge
                  if (cuisine.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.secondaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        cuisine,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                        ),
                      ),
                    ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Description - Make it scrollable if needed
                  if (description.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            description,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                              fontSize:
                                  isSmallScreen ? 12 : (isTablet ? 16 : 14),
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Action buttons - Stack them on small screens
                  if (isSmallScreen)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            onPressed: () {
                              // TODO: Save to history
                            },
                            icon: Icons.bookmark_add_rounded,
                            label: 'Save to History',
                            isPrimary: false,
                            size: CustomButtonSize.medium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            onPressed: () {
                              // TODO: Share result
                            },
                            icon: Icons.share_rounded,
                            label: 'Share Result',
                            isPrimary: true,
                            size: CustomButtonSize.medium,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              // TODO: Save to history
                            },
                            icon: Icons.bookmark_add_rounded,
                            label: 'Save',
                            isPrimary: false,
                            size:
                                isTablet
                                    ? CustomButtonSize.large
                                    : CustomButtonSize.medium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              // TODO: Share result
                            },
                            icon: Icons.share_rounded,
                            label: 'Share',
                            isPrimary: true,
                            size:
                                isTablet
                                    ? CustomButtonSize.large
                                    : CustomButtonSize.medium,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
