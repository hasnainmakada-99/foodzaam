import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Scanning frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  ...List.generate(4, (index) => _buildCornerIndicator(index)),

                  // Scanning line animation
                  _buildScanningLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerIndicator(int index) {
    final positions = [
      const Alignment(-1, -1), // Top-left
      const Alignment(1, -1), // Top-right
      const Alignment(-1, 1), // Bottom-left
      const Alignment(1, 1), // Bottom-right
    ];

    return Align(
          alignment: positions[index],
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                left:
                    index == 0 || index == 2
                        ? BorderSide(color: AppTheme.accentColor, width: 4)
                        : BorderSide.none,
                right:
                    index == 1 || index == 3
                        ? BorderSide(color: AppTheme.accentColor, width: 4)
                        : BorderSide.none,
                top:
                    index == 0 || index == 1
                        ? BorderSide(color: AppTheme.accentColor, width: 4)
                        : BorderSide.none,
                bottom:
                    index == 2 || index == 3
                        ? BorderSide(color: AppTheme.accentColor, width: 4)
                        : BorderSide.none,
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: 1500.ms);
  }

  Widget _buildScanningLine() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.accentColor,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(
                  begin: -140,
                  end: 140,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}
