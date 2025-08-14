import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/result_card.dart';
import '../../widgets/camera_overlay.dart';

class FoodIdentifierScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FoodIdentifierScreen({Key? key, required this.cameras})
    : super(key: key);

  @override
  State<FoodIdentifierScreen> createState() => _FoodIdentifierScreenState();
}

class _FoodIdentifierScreenState extends State<FoodIdentifierScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _foodName = "";
  String _cuisine = "";
  String _description = "";
  bool _isProcessing = false;
  File? _imageFile;
  bool _hasNetworkError = false;
  bool _hasCameraError = false;
  bool _hasResult = false;

  late AnimationController _fabController;
  late AnimationController _resultController;
  late AnimationController _pulseController;

  // Gemini API configuration
  final String apiKey = dotenv.env['GEMINI_KEY'] ?? '';
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _initCamera();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _resultController.dispose();
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() {
        _hasCameraError = true;
      });
      return;
    }

    try {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid
                ? ImageFormatGroup.yuv420
                : ImageFormatGroup.bgra8888,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _hasCameraError = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasCameraError = true;
      });
      print('Error initializing camera: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _takePicture() async {
    HapticFeedback.lightImpact();
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        _showSnackBar('Camera is not initialized', isError: true);
        return;
      }

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      setState(() {
        _imageFile = File(image.path);
        _isProcessing = true;
        _hasResult = false;
      });

      _fabController.reverse();
      await _identifyFood(File(image.path));
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Error taking picture. Please try again.', isError: true);
    }
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isProcessing = true;
          _hasResult = false;
        });

        _fabController.reverse();
        await _identifyFood(File(image.path));
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Error selecting image. Please try again.', isError: true);
    }
  }

  Future<void> _identifyFood(File imageFile) async {
    try {
      // Check internet connection
      try {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode != 200) {
          throw Exception('No internet connection');
        }
        if (_hasNetworkError) {
          setState(() {
            _hasNetworkError = false;
          });
        }
      } catch (e) {
        setState(() {
          _hasNetworkError = true;
          _isProcessing = false;
        });
        _showSnackBar('No internet connection available', isError: true);
        return;
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Enhanced food identification with detailed response
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """You are an expert food identification AI. Analyze this image and provide a comprehensive response in the following JSON format:

{
  "isDishIdentified": true/false,
  "dishName": "Specific dish name",
  "cuisine": "Cuisine type (e.g., Italian, Indian, Chinese)",
  "description": "Brief description of the dish (2-3 sentences)",
  "confidence": "high/medium/low"
}

Requirements:
1. Only respond with valid JSON
2. If no food is detected, set isDishIdentified to false
3. For dishName, provide the specific, complete dish name (not just ingredients)
4. Include traditional/regional names when applicable
5. Keep description informative but concise
6. Set confidence based on image clarity and dish recognizability

Example good response:
{
  "isDishIdentified": true,
  "dishName": "Margherita Pizza",
  "cuisine": "Italian",
  "description": "A classic Neapolitan pizza topped with tomato sauce, fresh mozzarella cheese, and basil leaves. Known for its simple yet perfect combination of flavors.",
  "confidence": "high"
}""",
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.1, "maxOutputTokens": 300},
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'].trim();

          try {
            // Extract JSON from the response
            final jsonStart = generatedText.indexOf('{');
            final jsonEnd = generatedText.lastIndexOf('}') + 1;
            final jsonString = generatedText.substring(jsonStart, jsonEnd);
            final foodData = jsonDecode(jsonString);

            setState(() {
              if (foodData['isDishIdentified'] == true) {
                _foodName = foodData['dishName'] ?? 'Unknown Dish';
                _cuisine = foodData['cuisine'] ?? 'Unknown Cuisine';
                _description =
                    foodData['description'] ?? 'No description available';
                _hasResult = true;
                _resultController.forward();
              } else {
                _foodName = 'No food detected';
                _cuisine = '';
                _description =
                    'Please try taking another photo with clear food items.';
                _hasResult = false;
              }
              _isProcessing = false;
            });

            if (foodData['isDishIdentified'] == true) {
              HapticFeedback.lightImpact();
            } else {
              HapticFeedback.lightImpact();
            }
          } catch (e) {
            // Fallback parsing
            setState(() {
              _foodName = generatedText;
              _cuisine = 'Unknown';
              _description = 'Food identification completed';
              _hasResult = true;
              _isProcessing = false;
            });
            _resultController.forward();
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('API request failed');
      }
    } catch (e) {
      setState(() {
        _foodName = 'Error identifying food';
        _cuisine = '';
        _description = 'Please check your connection and try again.';
        _hasResult = false;
        _isProcessing = false;
      });
      _showSnackBar(
        'Failed to identify food. Please try again.',
        isError: true,
      );
    }
  }

  void _resetIdentification() {
    HapticFeedback.lightImpact();
    setState(() {
      _imageFile = null;
      _foodName = '';
      _cuisine = '';
      _description = '';
      _hasResult = false;
      _isProcessing = false;
    });
    _resultController.reset();
    _fabController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Camera/Image Preview
            _buildCameraPreview(),

            // Top App Bar
            _buildTopAppBar(),

            // Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),

            // Result Card
            if (_hasResult && !_isProcessing) _buildResultCard(),

            // FAB Actions
            if (!_isProcessing && !_hasResult) _buildFloatingActions(),

            // Reset Button
            if (_imageFile != null && !_isProcessing) _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'FoodZaam',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0);
  }

  Widget _buildCameraPreview() {
    if (_hasCameraError && _imageFile == null) {
      return _buildErrorView();
    }

    if (_hasNetworkError) {
      return _buildNetworkErrorView();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child:
          _imageFile != null ? _buildImagePreview() : _buildLiveCameraPreview(),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(_imageFile!, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller != null &&
            _controller!.value.isInitialized) {
          return Stack(
            children: [
              CameraPreview(_controller!),
              CameraOverlay(),
              _buildCameraHint(),
            ],
          );
        }
        return _buildCameraLoadingView();
      },
    );
  }

  Widget _buildCameraHint() {
    return Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Point camera at food to identify',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: 1500.ms);
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 120, // Increased to account for bottom navigation bar
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery Button
          CustomButton(
                onPressed: _pickImage,
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                isPrimary: false,
                size: CustomButtonSize.large,
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.5, end: 0),

          // Camera Button
          CustomButton(
                onPressed: _takePicture,
                icon: Icons.camera_alt_rounded,
                label: 'Capture',
                isPrimary: true,
                size: CustomButtonSize.large,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Positioned(
      top: 80,
      right: 20,
      child: CustomButton(
        onPressed: _resetIdentification,
        icon: Icons.refresh_rounded,
        label: 'Reset',
        isPrimary: false,
        size: CustomButtonSize.small,
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.3, end: 0),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing Food...',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our AI is identifying your dish',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildResultCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ResultCard(
        foodName: _foodName,
        cuisine: _cuisine,
        description: _description,
        onReset: _resetIdentification,
        animation: _resultController,
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Unavailable',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check camera permissions',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildNetworkErrorView() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Internet Connection',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your connection and try again',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCameraLoadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white24,
              highlightColor: Colors.white54,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Initializing Camera...',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
