import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final CustomButtonSize size;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = true,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return Material(
      elevation: isEnabled ? _getElevation() : 0,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      shadowColor:
          isPrimary
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          padding: _getPadding(),
          decoration: BoxDecoration(
            gradient: isEnabled && isPrimary ? AppTheme.primaryGradient : null,
            color:
                isEnabled
                    ? (isPrimary ? null : Colors.white)
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            border: Border.all(
              color:
                  isEnabled
                      ? (isPrimary
                          ? Colors.transparent
                          : AppTheme.primaryColor.withOpacity(0.3))
                      : Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  size: _getIconSize(),
                  color:
                      isEnabled
                          ? (isPrimary ? Colors.white : AppTheme.primaryColor)
                          : Colors.grey[600],
                ),
              if (_shouldShowLabel()) ...[
                SizedBox(width: _getSpacing()),
                Flexible(
                  child: Text(
                    label,
                    style: _getTextStyle(isEnabled),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _getElevation() {
    switch (size) {
      case CustomButtonSize.small:
        return 4;
      case CustomButtonSize.medium:
        return 6;
      case CustomButtonSize.large:
        return 8;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case CustomButtonSize.small:
        return 10;
      case CustomButtonSize.medium:
        return 12;
      case CustomButtonSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 18;
      case CustomButtonSize.medium:
        return 22;
      case CustomButtonSize.large:
        return 26;
    }
  }

  double _getSpacing() {
    switch (size) {
      case CustomButtonSize.small:
        return 6;
      case CustomButtonSize.medium:
        return 8;
      case CustomButtonSize.large:
        return 12;
    }
  }

  bool _shouldShowLabel() {
    return size != CustomButtonSize.small || label.length <= 8;
  }

  TextStyle _getTextStyle(bool isEnabled) {
    final baseStyle =
        size == CustomButtonSize.large
            ? AppTheme.bodyLarge
            : AppTheme.bodyMedium;

    return baseStyle.copyWith(
      color:
          isEnabled
              ? (isPrimary ? Colors.white : AppTheme.primaryColor)
              : Colors.grey[600],
      fontWeight: FontWeight.w600,
    );
  }
}
