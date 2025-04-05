import 'package:flutter/material.dart';

Widget buildCustomButton({
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
  bool isSmallScreen = false,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: isSmallScreen ? 18 : 20),
    label: Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red[700],
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 16,
        vertical: isSmallScreen ? 8 : 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
