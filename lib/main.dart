import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Identifier',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FoodIdentifierScreen(cameras: cameras),
    );
  }
}

class FoodIdentifierScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FoodIdentifierScreen({Key? key, required this.cameras})
    : super(key: key);

  @override
  _FoodIdentifierScreenState createState() => _FoodIdentifierScreenState();
}

class _FoodIdentifierScreenState extends State<FoodIdentifierScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _foodName = "No food identified yet";
  bool _isProcessing = false;
  File? _imageFile;

  // Replace with your actual Gemini API key
  final String apiKey = 'AIzaSyBx4ccYra41A3UJMCXthe6LvUjMD7ujaSE';
  // Updated URL for Gemini 1.5 Flash model
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      setState(() {
        _imageFile = File(image.path);
        _isProcessing = true;
        _foodName = "Processing image...";
      });

      await _identifyFood(File(image.path));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isProcessing = true;
        _foodName = "Processing image...";
      });

      await _identifyFood(File(image.path));
    }
  }

  Future<void> _identifyFood(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // First, check if the image contains food
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
      };

      // Check if image contains food
      final checkResponse = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(checkFoodRequestBody),
      );

      if (checkResponse.statusCode == 200) {
        final checkData = jsonDecode(checkResponse.body);
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

        // If it's food, proceed with identification - ENHANCED PROMPT
        final Map<String, dynamic> identifyRequestBody = {
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "This is a food image. Identify the specific food dish with its FULL and PRECISE name, including cuisine type, preparation method, and key ingredients if visible (e.g., 'Afghani Malai Chicken Tikka' instead of just 'Chicken Tikka'). Be as specific and detailed in the dish name as possible, but keep your response to just the dish name without additional description.",
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
          "generationConfig": {"temperature": 0.2, "maxOutputTokens": 80},
        };

        // Make API request for identification
        final identifyResponse = await http.post(
          Uri.parse('$baseUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(identifyRequestBody),
        );

        if (identifyResponse.statusCode == 200) {
          final data = jsonDecode(identifyResponse.body);
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];

          setState(() {
            _foodName = generatedText.trim();
            _isProcessing = false;
          });
        } else {
          setState(() {
            _foodName =
                "Error identifying food: ${identifyResponse.statusCode}";
            _isProcessing = false;
          });
          print("Error response: ${identifyResponse.body}");
        }
      } else {
        setState(() {
          _foodName = "Error checking image: ${checkResponse.statusCode}";
          _isProcessing = false;
        });
        print("Error response: ${checkResponse.body}");
      }
    } catch (e) {
      setState(() {
        _foodName = "Error: $e";
        _isProcessing = false;
      });
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodZaam'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_imageFile != null) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        if (_foodName == "No food detected in this image")
                          Container(
                            color: Colors.black45,
                            child: const Center(
                              child: Icon(
                                Icons.no_food,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(_controller),
                        Positioned(
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Point camera at food",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(_foodName, style: const TextStyle(fontSize: 18)),
                      ],
                    )
                  else
                    Text(
                      _foodName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            _foodName == "No food detected in this image"
                                ? Colors.red
                                : Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _takePicture,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take Photo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_imageFile != null)
                        ElevatedButton.icon(
                          onPressed:
                              _isProcessing
                                  ? null
                                  : () {
                                    setState(() {
                                      _imageFile = null;
                                      _foodName = "No food identified yet";
                                    });
                                  },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Reset"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
