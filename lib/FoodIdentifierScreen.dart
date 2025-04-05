import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foodzaam/custom_button.dart';
import 'package:foodzaam/error_view.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FoodIdentifierScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FoodIdentifierScreen({Key? key, required this.cameras})
    : super(key: key);

  @override
  _FoodIdentifierScreenState createState() => _FoodIdentifierScreenState();
}

class _FoodIdentifierScreenState extends State<FoodIdentifierScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _foodName = "No food identified yet";
  bool _isProcessing = false;
  File? _imageFile;
  bool _hasNetworkError = false;
  bool _hasCameraError = false;
  bool _appLifecyclePaused = false;

  // Gemini API configuration
  final String apiKey = dotenv.env['GEMINI_KEY'] ?? '';
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      _appLifecyclePaused = true;
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed && _appLifecyclePaused) {
      _appLifecyclePaused = false;
      _initCamera();
    }
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
        ResolutionPreset.medium,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        showSnackBar('Camera is not initialized');
        return;
      }

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      setState(() {
        _imageFile = File(image.path);
        _isProcessing = true;
        _foodName = "Processing image...";
      });

      await _identifyFood(File(image.path));
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _foodName = "Error taking picture";
      });
      print('Error taking picture: $e');
      showSnackBar('Error taking picture. Please try again.');
    }
  }

  Future<void> _pickImage() async {
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
          _foodName = "Processing image...";
        });

        await _identifyFood(File(image.path));
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _foodName = "Error selecting image";
      });
      print('Error selecting image: $e');
      showSnackBar('Error selecting image. Please try again.');
    }
  }

  Future<void> _identifyFood(File imageFile) async {
    try {
      // Check internet connection first
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
          _foodName = "No internet connection";
        });
        return;
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final Map<String, dynamic> checkFoodRequestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Is this image primarily showing food? Answer with ONLY 'YES' or 'NO'.",
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.1, "maxOutputTokens": 10},
        "safety_settings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE",
          },
        ],
      };

      final checkResponse = await http
          .post(
            Uri.parse('$baseUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(checkFoodRequestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (checkResponse.statusCode == 200) {
        final checkData = jsonDecode(checkResponse.body);

        if (!checkData.containsKey('candidates') ||
            checkData['candidates'].isEmpty ||
            !checkData['candidates'][0].containsKey('content') ||
            !checkData['candidates'][0]['content'].containsKey('parts') ||
            checkData['candidates'][0]['content']['parts'].isEmpty) {
          setState(() {
            _foodName = "Unable to process image";
            _isProcessing = false;
          });
          return;
        }

        final checkResult =
            checkData['candidates'][0]['content']['parts'][0]['text']
                .trim()
                .toUpperCase();

        if (checkResult != "YES") {
          setState(() {
            _foodName = "No food detected in this image";
            _isProcessing = false;
          });
          return;
        }

        final Map<String, dynamic> identifyRequestBody = {
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are a specialized AI for identifying specific prepared dishes and cuisines from images. Your task is to identify the COMPLETE and EXACT dish name, not just the ingredients.\n\n"
                      "Instructions:\n"
                      "1. Identify the SPECIFIC DISH NAME (e.g., 'Gujarati Undhiyu', 'Thai Green Curry', 'Margherita Pizza') rather than just listing ingredients or generic food types\n"
                      "2. Include the cuisine type whenever possible (e.g., Indian, Italian, Mexican)\n"
                      "3. Include traditional or regional names for the dish when applicable\n"
                      "4. Consider cultural context and preparation method\n"
                      "5. Focus on identifying the COMPLETE dish, not just components\n\n"
                      "IMPORTANT: Respond ONLY with the complete dish name. Do not include descriptions, ingredients lists, or explanations.\n\n"
                      "Examples of good responses:\n"
                      "- 'Gujarati Undhiyu' (NOT just 'mixed vegetables')\n"
                      "- 'Hyderabadi Biryani' (NOT just 'rice dish')\n"
                      "- 'Neapolitan Margherita Pizza' (NOT just 'pizza')\n"
                      "- 'Japanese Chicken Katsu Curry' (NOT just 'curry with chicken')\n\n"
                      "What is the SPECIFIC, COMPLETE name of this dish?",
                },
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image,
                  },
                },
              ],
            },
          ],
          "generationConfig": {"temperature": 0.1, "maxOutputTokens": 80},
          "safety_settings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
          ],
        };

        final identifyResponse = await http
            .post(
              Uri.parse('$baseUrl?key=$apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(identifyRequestBody),
            )
            .timeout(const Duration(seconds: 30));

        if (identifyResponse.statusCode == 200) {
          final data = jsonDecode(identifyResponse.body);

          if (!data.containsKey('candidates') ||
              data['candidates'].isEmpty ||
              !data['candidates'][0].containsKey('content') ||
              !data['candidates'][0]['content'].containsKey('parts') ||
              data['candidates'][0]['content']['parts'].isEmpty) {
            setState(() {
              _foodName = "Unable to identify food";
              _isProcessing = false;
            });
            return;
          }

          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];

          setState(() {
            _foodName = generatedText.trim();
            _isProcessing = false;
          });
        } else {
          setState(() {
            _foodName = "Unable to identify food";
            _isProcessing = false;
          });
          print("Error response: ${identifyResponse.body}");
        }
      } else {
        setState(() {
          _foodName = "Unable to process image";
          _isProcessing = false;
        });
        print("Error response: ${checkResponse.body}");
      }
    } catch (e) {
      setState(() {
        if (e is TimeoutException) {
          _foodName = "Request timed out";
        } else {
          _foodName = "Error processing image";
        }
        _isProcessing = false;
      });
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.food_bank, color: Colors.white, size: 60.0),
            const SizedBox(width: 10),

            Align(
              alignment: Alignment.topCenter,
              child: const Text(
                'FoodZaam',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10.5,
                  fontSize: 34,

                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child:
                      _hasCameraError && _imageFile == null
                          ? buildErrorView(
                            "Camera not available",
                            Icons.camera_alt_outlined,
                            onRetry:
                                widget.cameras.isNotEmpty ? _initCamera : null,
                          )
                          : _hasNetworkError
                          ? buildErrorView(
                            "No internet connection\nPlease check your connection and try again",
                            Icons.wifi_off,
                          )
                          : _buildCameraPreview(screenSize),
                ),
              ),
            ),
            _buildBottomSection(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(Size screenSize) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_imageFile != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(_imageFile!, fit: BoxFit.cover),
                if (_foodName == "No food detected in this image")
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.no_food,
                            color: Colors.white,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No food detected",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } else if (_controller != null && _controller!.value.isInitialized) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller!),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: screenSize.width * 0.7,
                  height: screenSize.width * 0.7,
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_camera, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Point camera at food",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(bool isSmallScreen) {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFoodNameDisplay(isSmallScreen),
            const SizedBox(height: 24),
            _buildActionButtons(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodNameDisplay(bool isSmallScreen) {
    if (_isProcessing) {
      return Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            _foodName,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _foodName == "No food detected in this image"
                  // ignore: deprecated_member_use
                  ? Colors.red.withOpacity(0.3)
                  // ignore: deprecated_member_use
                  : Colors.green.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      width: double.infinity,
      child: Text(
        _foodName,
        style: TextStyle(
          fontSize: isSmallScreen ? 20 : 22,
          fontWeight: FontWeight.bold,
          color:
              _foodName == "No food detected in this image"
                  ? Colors.red[700]
                  : _foodName == "No food identified yet"
                  ? Colors.grey[700]
                  : Colors.green[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildCustomButton(
                onPressed: _isProcessing ? null : _takePicture,
                icon: Icons.camera_alt,
                label: "Camera",
                isSmallScreen: true,
              ),
              buildCustomButton(
                onPressed: _isProcessing ? null : _pickImage,
                icon: Icons.photo_library,
                label: "Gallery",
                isSmallScreen: true,
              ),
            ],
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: buildCustomButton(
                onPressed:
                    _isProcessing
                        ? null
                        : () {
                          setState(() {
                            _imageFile = null;
                            _foodName = "No food identified yet";
                          });
                        },
                icon: Icons.refresh,
                label: "Reset",
                isSmallScreen: true,
              ),
            ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildCustomButton(
          onPressed: _isProcessing ? null : _takePicture,
          icon: Icons.camera_alt,
          label: "Take Photo",
        ),
        buildCustomButton(
          onPressed: _isProcessing ? null : _pickImage,
          icon: Icons.photo_library,
          label: "Gallery",
        ),
        if (_imageFile != null)
          buildCustomButton(
            onPressed:
                _isProcessing
                    ? null
                    : () {
                      setState(() {
                        _imageFile = null;
                        _foodName = "No food identified yet";
                      });
                    },
            icon: Icons.refresh,
            label: "Reset",
          ),
      ],
    );
  }
}
