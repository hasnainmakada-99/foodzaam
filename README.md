# FoodZAAM 🍔 

> Your personal food identification assistant - Like Shazam, but for food!

[![GitHub Release](https://img.shields.io/github/v/release/hasnainmakada-99/foodzaam)](https://github.com/hasnainmakada-99/foodzaam/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-1389FD.svg)](https://flutter.dev/)
[![Powered by Gemini](https://img.shields.io/badge/Powered%20by-Google%20Gemini-4285F4.svg)](https://ai.google.dev/)

<p align="center">
  <img src="./FoodZaam Banner.png" alt="FoodZAAM Banner" width="600">
</p>

## 🌟 Features

- 📸 **Real-time Camera Integration**: Live camera preview with food detection overlay
- 🖼️ **Gallery Support**: Upload images from your device gallery for identification
- 🤖 **AI-Powered Recognition**: Uses Google Gemini AI for accurate food identification
- 🍽️ **Specific Dish Detection**: Identifies complete dish names with cultural context (e.g., "Gujarati Undhiyu", "Thai Green Curry")
- 🔍 **Smart Food Validation**: Two-step AI process to ensure images contain food before identification
- 📱 **Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, and Linux
- 🌐 **Network Awareness**: Intelligent handling of connectivity issues with user feedback
- 📐 **Responsive Design**: Optimized UI for different screen sizes and orientations

## 📱 Installation

### Android

1. Download the latest APK from our [GitHub Releases](https://github.com/hasnainmakada-99/foodzaam/releases)
2. Enable "Install from Unknown Sources" in your device settings
3. Install the downloaded APK
4. Start identifying delicious foods! 🚀

### iOS

> Coming Soon! 🔜

## 🛠️ Tech Stack

### Core Technologies
- **Framework**: Flutter 3.7.2+ (Dart SDK)
- **AI/ML**: Google Gemini 1.5 Flash API
- **State Management**: StatefulWidget with built-in state management
- **HTTP Client**: Dart HTTP package for API communication

### Key Dependencies
- **Camera**: `camera ^0.11.1` - Real-time camera integration
- **Image Picker**: `image_picker ^1.1.2` - Gallery image selection
- **HTTP**: `http ^1.3.0` - API communication with Gemini
- **Environment Config**: `flutter_dotenv ^5.2.1` - Secure API key management
- **Connectivity**: `connectivity_plus ^6.1.3` - Network status monitoring
- **Permissions**: `permission_handler ^11.4.0` - Camera and storage permissions
- **Path Provider**: `path_provider ^2.1.5` - File system access

### Platform Support
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers with camera support
- **Desktop**: Windows, macOS, Linux

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch:
```bash
git checkout -b feature/AmazingFeature
```
3. Commit your changes:
```bash
git commit -m 'Add some AmazingFeature'
```
4. Push to the branch:
```bash
git push origin feature/AmazingFeature
```
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏗️ Architecture

### App Architecture
```
┌─────────────────────────────────────┐
│            FoodZAAM App             │
├─────────────────────────────────────┤
│  UI Layer (Flutter Widgets)        │
│  ├─ FoodIdentifierScreen           │
│  ├─ Custom Buttons & Components    │
│  └─ Error Handling Views           │
├─────────────────────────────────────┤
│  Business Logic Layer              │
│  ├─ Camera Controller              │
│  ├─ Image Processing               │
│  ├─ Network Connectivity Check     │
│  └─ State Management               │
├─────────────────────────────────────┤
│  Data Layer                        │
│  ├─ Gemini AI API Integration      │
│  ├─ HTTP Client                    │
│  ├─ Environment Configuration      │
│  └─ File System Access             │
└─────────────────────────────────────┘
```

### Key Design Patterns
- **StatefulWidget**: For reactive UI updates
- **Future/Async**: For asynchronous operations
- **Error Boundaries**: Comprehensive error handling
- **Responsive Design**: Adaptive layouts for different screen sizes

## 🔮 Roadmap

### ✅ Completed Features
- [x] Real-time camera integration
- [x] Gallery image selection
- [x] AI-powered food identification
- [x] Cross-platform support
- [x] Network connectivity handling
- [x] Responsive UI design

### 🚧 In Progress
- [ ] Enhanced error recovery mechanisms
- [ ] Performance optimizations
- [ ] UI/UX improvements

### 📋 Future Features
- [ ] Nutritional information display
- [ ] Recipe suggestions
- [ ] Social sharing capabilities
- [ ] Personal food journal
- [ ] Diet planning integration
- [ ] Restaurant menu scanner
- [ ] Multiple language support
- [ ] Offline caching
- [ ] Voice commands

## 👨‍💻 Development Setup

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Google Gemini API key

### Installation Steps

1. **Clone the repository:**
```bash
git clone https://github.com/hasnainmakada-99/foodzaam.git
cd foodzaam
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Set up environment variables:**
   - Create a `.env` file in the root directory
   - Add your Gemini API key:
```env
GEMINI_KEY=your_gemini_api_key_here
```

4. **Run the application:**
```bash
# For development
flutter run

# For specific platforms
flutter run -d android
flutter run -d ios
flutter run -d web
flutter run -d windows
```

### Getting Gemini API Key
1. Visit [Google AI Studio](https://aistudio.google.com/)
2. Create a new project or select existing one
3. Generate an API key for Gemini
4. Add the key to your `.env` file

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── FoodIdentifierScreen.dart # Main camera/identification screen
├── custom_button.dart        # Reusable button component
└── error_view.dart          # Error handling UI component

android/
├── app/
│   ├── build.gradle.kts     # Android build configuration
│   └── src/main/
│       └── AndroidManifest.xml # Android permissions & config

ios/
├── Runner/
│   └── Info.plist           # iOS permissions & config

web/
├── index.html               # Web app entry point
└── manifest.json           # PWA configuration
```

## 🔒 Permissions & Security

### Required Permissions
- **Camera Access**: For real-time food photography
- **Storage Access**: For gallery image selection
- **Internet Access**: For Gemini AI API communication
- **Network State**: For connectivity monitoring

### Security Features
- **API Key Protection**: Environment variables prevent key exposure
- **Input Validation**: Two-step AI validation prevents misuse
- **Network Security**: HTTPS-only API communication
- **Privacy**: No image storage on external servers
- **Local Processing**: Images processed locally before API calls

### Privacy Considerations
- Images are temporarily processed and not permanently stored
- No personal data collection beyond app functionality
- API calls are made directly to Google's secure endpoints
- Users maintain full control over their captured images

## 📸 Screenshots

<p align="center">
  <img src="./screenshots/screen1.png" width="200" alt="Screenshot 1">
  <img src="./screenshots/screen2.png" width="200" alt="Screenshot 2">
  <img src="./screenshots/screen3.png" width="200" alt="Screenshot 3">
</p>

## 🤔 How It Works

FoodZAAM uses a sophisticated AI-powered approach to identify food from images:

### 1. **Image Acquisition**
- **Camera Mode**: Real-time camera preview with overlay guide
- **Gallery Mode**: Select existing images from device storage
- **Image Processing**: Automatic compression and format optimization

### 2. **AI-Powered Analysis**
- **Step 1 - Food Detection**: Gemini AI first validates if the image contains food
- **Step 2 - Dish Identification**: If food is detected, performs detailed dish recognition
- **Cultural Context**: Identifies specific regional dishes with proper names (e.g., "Gujarati Undhiyu" vs "mixed vegetables")

### 3. **Smart Error Handling**
- **Network Monitoring**: Checks internet connectivity before API calls
- **Graceful Degradation**: Provides meaningful error messages for various failure scenarios
- **Retry Mechanisms**: Allows users to retry failed operations

### 4. **User Experience**
- **Real-time Feedback**: Loading indicators and progress updates
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Intuitive Controls**: Simple camera, gallery, and reset functionality

### Technical Implementation
```dart
// Two-step AI process
1. Food Validation: "Is this image primarily showing food? YES/NO"
2. Dish Identification: "What is the SPECIFIC, COMPLETE name of this dish?"
```

## 📫 Contact

- Website: [foodzaam.netlify.app](https://foodzaam.netlify.app)
- GitHub: [@hasnainmakada-99](https://github.com/hasnainmakada-99)

## 🔧 Troubleshooting

### Common Issues

**Camera not working:**
- Ensure camera permissions are granted
- Check if device has a working camera
- Restart the app if camera initialization fails

**"No internet connection" error:**
- Verify device internet connectivity
- Check if firewall/proxy is blocking API calls
- Ensure Gemini API key is valid and has quota

**"Unable to identify food" error:**
- Ensure image clearly shows food items
- Try better lighting conditions
- Use images with single, well-defined dishes

**API key issues:**
- Verify `.env` file exists in project root
- Check API key format and validity
- Ensure no extra spaces in environment file

### Performance Tips
- Use good lighting for better recognition accuracy
- Frame food items clearly in camera viewfinder
- Avoid blurry or low-quality images
- Ensure stable internet connection for faster processing

## 🙏 Acknowledgments

- **[Google Gemini](https://ai.google.dev/)** - Advanced AI model for food recognition
- **[Flutter Team](https://flutter.dev)** - Amazing cross-platform framework
- **[Dart Language](https://dart.dev)** - Powerful programming language
- **Flutter Community** - Extensive package ecosystem
- **Open Source Contributors** - Making this project possible 💪

---

<p align="center">Made with ❤️ by the [codesphere](https://codesphere.agency) Team</p>