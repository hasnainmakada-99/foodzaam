import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import 'package:camera/camera.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.camera_alt,
      title: 'Snap & Identify',
      description:
          'Take a photo of any dish and discover its name instantly with our advanced AI technology.',
      color: AppTheme.primaryColor,
    ),
    OnboardingData(
      icon: Icons.restaurant_menu,
      title: 'Discover Cuisines',
      description:
          'Explore diverse cuisines from around the world and learn about traditional dishes.',
      color: AppTheme.secondaryColor,
    ),
    OnboardingData(
      icon: Icons.photo_library,
      title: 'Gallery Support',
      description:
          'Upload photos from your gallery to identify food items you\'ve captured before.',
      color: AppTheme.accentColor,
    ),
    OnboardingData(
      icon: Icons.star,
      title: 'Get Started',
      description:
          'Ready to explore the world of food? Let\'s begin your culinary journey!',
      color: AppTheme.successColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _navigateToHome,
                    child: Text(
                      'Skip',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], index);
                  },
                ),
              ),

              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _pages.asMap().entries.map((entry) {
                      return Container(
                        width: _currentIndex == entry.key ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentIndex == entry.key
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ).animate().scale(
                        duration: 300.ms,
                        curve: Curves.easeInOut,
                      );
                    }).toList(),
              ),

              const SizedBox(height: 32),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // For small screens, stack buttons vertically
                    if (constraints.maxWidth < 300) {
                      return Column(
                        children: [
                          if (_currentIndex > 0)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _previousPage,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Previous'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.grey[700],
                                  elevation: 4,
                                ),
                              ),
                            ),
                          if (_currentIndex > 0) const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _currentIndex == _pages.length - 1
                                      ? _navigateToHome
                                      : _nextPage,
                              icon: Icon(
                                _currentIndex == _pages.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                _currentIndex == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppTheme.primaryColor.withOpacity(
                                  0.3,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // For normal screens, use row layout
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button
                        if (_currentIndex > 0)
                          Flexible(
                            child: ElevatedButton.icon(
                              onPressed: _previousPage,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[700],
                                elevation: 4,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 100),

                        const SizedBox(width: 16),

                        // Next/Get Started Button
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed:
                                _currentIndex == _pages.length - 1
                                    ? _navigateToHome
                                    : _nextPage,
                            icon: Icon(
                              _currentIndex == _pages.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                            ),
                            label: Text(
                              _currentIndex == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(
                                0.3,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(data.icon, size: 60, color: data.color),
              )
              .animate()
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          FittedBox(
            child: Text(
                  data.title,
                  style: AppTheme.headingLarge.copyWith(
                    color: data.color,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
                data.description,
                style: AppTheme.bodyLarge.copyWith(fontSize: 16, height: 1.6),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToHome() async {
    // Get available cameras
    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
    } catch (e) {
      print('Error getting cameras: $e');
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  HomeScreen(cameras: cameras),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
