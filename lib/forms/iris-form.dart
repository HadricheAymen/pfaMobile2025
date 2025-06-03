import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pfa_mobile/utils/responsive_utils.dart';
import 'package:pfa_mobile/services/api_service.dart';
import 'package:pfa_mobile/services/personality_class_service.dart';
import 'package:pfa_mobile/widgets/model_selector_widget.dart';
import 'package:pfa_mobile/widgets/model_comparison_widget.dart';
import 'package:pfa_mobile/config/model_config.dart';

class IrisForm extends StatefulWidget {
  const IrisForm({Key? key}) : super(key: key);

  @override
  State<IrisForm> createState() => _IrisFormState();
}

class _IrisFormState extends State<IrisForm> {
  final _formKey = GlobalKey<FormState>();

  // Enhanced iris analysis state
  File? _leftIrisImage;
  File? _rightIrisImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _personalityDescription;

  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';
  final TextEditingController _commentsController = TextEditingController();

  // UI state
  bool _showResults = false;
  String? _errorMessage;

  // Camera and image processing state
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  bool _showCamera = false;
  File? _image;
  bool _isDetectingFace = false;
  Map<String, dynamic>? _faceDetectionResult;
  bool _isExtractingIris = false;
  bool _showExtractedIris = false;
  Map<String, dynamic>? _imageQuality;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeCamera();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      debugPrint('Found ${_cameras?.length ?? 0} cameras');
      if (_cameras != null && _cameras!.isNotEmpty) {
        for (var camera in _cameras!) {
          debugPrint(
              'Camera: ${camera.name}, Direction: ${camera.lensDirection}');
        }
      }
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'initialisation de la caméra: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _startCamera() async {
    // Try to reinitialize cameras if they're not available
    if (_cameras == null || _cameras!.isEmpty) {
      debugPrint('Cameras not initialized, trying to reinitialize...');
      await _initializeCamera();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Aucune caméra disponible. Vérifiez les permissions de l\'app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Use front camera for selfies if available
    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _showCamera = true;
      });
    } catch (e) {
      debugPrint('Error starting camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'accès à la caméra: $e')),
        );
      }
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    setState(() {
      _showCamera = false;
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isDetectingFace = true;
      _faceDetectionResult = null;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File photoFile = File(photo.path);

      // Detect face in the captured image
      final faceDetectionResult = await _detectFaceInImage(photoFile);

      if (!faceDetectionResult['faceDetected']) {
        setState(() {
          _faceDetectionResult = faceDetectionResult;
          _isDetectingFace = false;
        });
        return; // Don't proceed if no face detected
      }

      // Process the image if face is detected
      final File processedImage = await _processImage(photoFile);

      setState(() {
        _image = processedImage;
        _faceDetectionResult = null;
        _showCamera = false;
        _leftIrisImage = null;
        _rightIrisImage = null;
        _showExtractedIris = false;
        _analysisResult = null; // Clear previous analysis results
        _imageQuality = null; // Reset image quality
      });

      // Validate image quality
      _validateImageQuality(processedImage);

      // Extract iris automatically
      _extractIris(processedImage);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la capture: $e')),
        );
      }
    } finally {
      setState(() {
        _isDetectingFace = false;
      });
    }
  }

  Future<Map<String, dynamic>> _detectFaceInImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
          enableClassification: true,
          minFaceSize: 0.1,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (faces.isEmpty) {
        return {
          'faceDetected': false,
          'confidence': 0,
          'message': 'Aucun visage humain détecté',
          'suggestions': [
            'Positionnez votre visage face à la caméra',
            'Assurez-vous d\'avoir un bon éclairage',
            'Retirez les lunettes de soleil ou masques',
            'Évitez les objets devant votre visage',
            'Regardez directement la caméra'
          ]
        };
      }

      return {
        'faceDetected': true,
        'confidence': faces.first.headEulerAngleY != null
            ? (1.0 - faces.first.headEulerAngleY!.abs() / 45.0)
            : 0.9,
        'message': 'Visage détecté',
        'suggestions': []
      };
    } catch (e) {
      debugPrint('Error in face detection: $e');
      // In case of error, be strict and don't allow the capture
      return {
        'faceDetected': false,
        'confidence': 0,
        'message': 'Erreur lors de la détection de visage',
        'suggestions': [
          'Réessayez la capture',
          'Vérifiez votre connexion internet',
          'Assurez-vous que votre visage est bien visible',
          'Améliorez l\'éclairage de votre environnement'
        ]
      };
    }
  }

  Future<File> _processImage(File imageFile) async {
    try {
      // Decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      // Crop to square focusing on center (where face likely is)
      final size = math.min(image.width, image.height);
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;

      final croppedImage =
          img.copyCrop(image, x: x, y: y, width: size, height: size);

      // Resize to reasonable size for analysis
      final resizedImage = img.copyResize(
        croppedImage,
        width: 800,
        height: 800,
      );

      // Save processed image with unique filename to avoid caching issues
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${tempDir.path}/processed_image_$timestamp.jpg';
      final processedFile = File(tempPath);
      await processedFile
          .writeAsBytes(img.encodeJpg(resizedImage, quality: 90));

      return processedFile;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return imageFile; // Return original if processing fails
    }
  }

  void _validateImageQuality(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        setState(() {
          _imageQuality = {
            'level': 'poor',
            'message': 'Impossible d\'analyser l\'image',
            'suggestions': ['Essayez de prendre une autre photo'],
            'score': 0
          };
        });
        return;
      }

      int score = 100;
      final suggestions = <String>[];

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize < 100000) {
        // Less than 100KB
        score -= 30;
        suggestions
            .add('Image trop petite, utilisez une résolution plus élevée');
      }

      // Check dimensions
      if (image.width < 800 || image.height < 600) {
        score -= 25;
        suggestions.add('Résolution trop faible (minimum 800x600 recommandé)');
      }

      // Check aspect ratio
      final ratio = image.width / image.height;
      if (ratio < 0.8 || ratio > 1.2) {
        score -= 15;
        suggestions.add(
            'Cadrage inadéquat, assurez-vous que tout le visage soit visible');
      }

      // Simulate blur detection based on edge detection
      final blurScore = _detectBlur(image);
      if (blurScore > 0.6) {
        score -= 20;
        suggestions.add('Image floue, assurez-vous d\'une bonne mise au point');
      }

      // Determine quality level
      String level;
      String message;

      if (score >= 80) {
        level = 'good';
        message = 'Excellente qualité d\'image';
      } else if (score >= 50) {
        level = 'medium';
        message = 'Qualité d\'image acceptable';
      } else {
        level = 'poor';
        message = 'Qualité d\'image insuffisante';
      }

      setState(() {
        _imageQuality = {
          'level': level,
          'message': message,
          'suggestions': suggestions,
          'score': score
        };
      });
    } catch (e) {
      debugPrint('Error validating image quality: $e');
    }
  }

  double _detectBlur(img.Image image) {
    try {
      // Simple edge detection to estimate blur
      // Convert to grayscale
      final grayscale = img.grayscale(image);

      // Apply Sobel operator for edge detection
      int edgeCount = 0;
      int totalPixels = 0;

      for (int y = 1; y < grayscale.height - 1; y++) {
        for (int x = 1; x < grayscale.width - 1; x++) {
          // Get pixel values (convert Pixel to int)
          final topLeft = grayscale.getPixel(x - 1, y - 1).luminance;
          final top = grayscale.getPixel(x, y - 1).luminance;
          final topRight = grayscale.getPixel(x + 1, y - 1).luminance;
          final left = grayscale.getPixel(x - 1, y).luminance;
          final right = grayscale.getPixel(x + 1, y).luminance;
          final bottomLeft = grayscale.getPixel(x - 1, y + 1).luminance;
          final bottom = grayscale.getPixel(x, y + 1).luminance;
          final bottomRight = grayscale.getPixel(x + 1, y + 1).luminance;

          // Simplified Sobel
          final gx = (topRight + 2 * right + bottomRight) -
              (topLeft + 2 * left + bottomLeft);
          final gy = (bottomLeft + 2 * bottom + bottomRight) -
              (topLeft + 2 * top + topRight);

          final gradient = math.sqrt(gx * gx + gy * gy).toInt();

          if (gradient > 30) {
            // Threshold for edge detection
            edgeCount++;
          }

          totalPixels++;
        }
      }

      // Calculate edge ratio - lower ratio means more blur
      return 1.0 - (edgeCount / totalPixels);
    } catch (e) {
      debugPrint('Error in blur detection: $e');
      return 0.5; // Default middle value
    }
  }

  Future<void> _extractIris(File imageFile) async {
    setState(() {
      _isExtractingIris = true;
      _leftIrisImage = null;
      _rightIrisImage = null;
      _showExtractedIris = false;
    });

    try {
      // Call the backend API to extract iris
      final extractionResult = await ApiService.extractIris(imageFile);

      if (extractionResult.containsKey('error')) {
        throw Exception(extractionResult['error']);
      }

      // Check if the API returned iris images
      if (extractionResult.containsKey('left_iris') &&
          extractionResult.containsKey('right_iris')) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // Save left iris image from base64 or URL with unique filename
        final leftIrisPath = '${tempDir.path}/left_iris_$timestamp.jpg';
        final leftIrisFile = File(leftIrisPath);

        // Save right iris image from base64 or URL with unique filename
        final rightIrisPath = '${tempDir.path}/right_iris_$timestamp.jpg';
        final rightIrisFile = File(rightIrisPath);

        // Handle different response formats from the API
        if (extractionResult['left_iris'] is String &&
            extractionResult['right_iris'] is String) {
          // If the API returns base64 encoded images
          final leftIrisBytes = base64Decode(extractionResult['left_iris']);
          final rightIrisBytes = base64Decode(extractionResult['right_iris']);

          await leftIrisFile.writeAsBytes(leftIrisBytes);
          await rightIrisFile.writeAsBytes(rightIrisBytes);
        } else {
          // Fallback: use original image (for demo purposes)
          await leftIrisFile.writeAsBytes(await imageFile.readAsBytes());
          await rightIrisFile.writeAsBytes(await imageFile.readAsBytes());
        }

        setState(() {
          _leftIrisImage = leftIrisFile;
          _rightIrisImage = rightIrisFile;
          _showExtractedIris = true;
          _isExtractingIris = false;
        });
      } else {
        // Fallback with unique filenames
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final leftIrisPath = '${tempDir.path}/left_iris_$timestamp.jpg';
        final leftIrisFile = File(leftIrisPath);
        await leftIrisFile.writeAsBytes(await imageFile.readAsBytes());

        final rightIrisPath = '${tempDir.path}/right_iris_$timestamp.jpg';
        final rightIrisFile = File(rightIrisPath);
        await rightIrisFile.writeAsBytes(await imageFile.readAsBytes());

        setState(() {
          _leftIrisImage = leftIrisFile;
          _rightIrisImage = rightIrisFile;
          _showExtractedIris = true;
          _isExtractingIris = false;
        });
      }
    } catch (e) {
      debugPrint('Error extracting iris: $e');
      setState(() {
        _isExtractingIris = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'extraction des iris: $e')),
        );
      }
    }
  }

  void _removeImage() {
    // Clear image cache to ensure fresh images are loaded
    if (_image != null) {
      _image!.delete().catchError((e) {
        debugPrint('Error deleting image: $e');
        return _image!;
      });
    }
    if (_leftIrisImage != null) {
      _leftIrisImage!.delete().catchError((e) {
        debugPrint('Error deleting left iris: $e');
        return _leftIrisImage!;
      });
    }
    if (_rightIrisImage != null) {
      _rightIrisImage!.delete().catchError((e) {
        debugPrint('Error deleting right iris: $e');
        return _rightIrisImage!;
      });
    }

    setState(() {
      _image = null;
      _imageQuality = null;
      _faceDetectionResult = null;
      _leftIrisImage = null;
      _rightIrisImage = null;
      _showExtractedIris = false;
      _analysisResult = null;
      _personalityDescription = null;
      _showResults = false;
      _errorMessage = null;
    });

    // Force image cache clear
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  // Enhanced iris analysis method - now uses extracted iris images from camera
  Future<void> _analyzeIrisEnhanced() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_leftIrisImage == null || _rightIrisImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord extraire les iris de votre photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
      _personalityDescription = null;
    });

    try {
      // Use the efficient prediction endpoint with both iris images
      debugPrint('🔍 Starting iris prediction with both images...');

      final result = await ApiService.predictIrisWithBothImages(
        _leftIrisImage!,
        _rightIrisImage!,
      );

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'];
          _isAnalyzing = false;
        });
        return;
      }

      // Get primary personality class from API response
      final primaryClass = result['primary_class'] ?? result['prediction'];
      if (primaryClass == null) {
        setState(() {
          _errorMessage = 'Aucune classe de personnalité retournée par l\'API';
          _isAnalyzing = false;
        });
        return;
      }

      // Fetch personality class description from Firestore
      final personalityDescription =
          await PersonalityClassService.findPersonalityClass(primaryClass);

      setState(() {
        _analysisResult = result;
        _personalityDescription = personalityDescription ??
            PersonalityClassService.createFallbackDescription(primaryClass);
        _showResults = true;
        _isAnalyzing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analyse terminée! Votre type: $primaryClass'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'analyse: $e';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Analyse d\'iris',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            fontSize: context.responsiveFontSize(
              mobilePortrait: 0.05,
              mobileLandscape: 0.04,
              tabletPortrait: 0.045,
              tabletLandscape: 0.038,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF8A4FFF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: context.responsivePadding(
            mobilePortrait: 0.04,
            mobileLandscape: 0.03,
            tabletPortrait: 0.05,
            tabletLandscape: 0.04,
          ),
          child: Column(
            children: [
              // Header section
              _buildModernHeader(context),

              SizedBox(
                  height: context.responsiveSpacing(
                mobilePortrait: 0.02,
                mobileLandscape: 0.015,
                tabletPortrait: 0.025,
                tabletLandscape: 0.018,
              )),

              // Main content
              Expanded(
                child: _showCamera
                    ? _buildCameraInterface(context)
                    : _buildMainInterface(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: context.responsivePadding(
        mobilePortrait: 0.04,
        mobileLandscape: 0.03,
        tabletPortrait: 0.045,
        tabletLandscape: 0.035,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Analysez votre iris',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.06,
                mobileLandscape: 0.048,
                tabletPortrait: 0.05,
                tabletLandscape: 0.042,
                desktopPortrait: 0.04,
                desktopLandscape: 0.035,
              ),
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
              color: const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.015,
            mobileLandscape: 0.01,
            tabletPortrait: 0.018,
            tabletLandscape: 0.012,
          )),
          Text(
            'Découvrez votre type d\'iris grâce à notre IA',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.04,
                mobileLandscape: 0.032,
                tabletPortrait: 0.035,
                tabletLandscape: 0.03,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.02,
            mobileLandscape: 0.015,
            tabletPortrait: 0.025,
            tabletLandscape: 0.018,
          )),
          Container(
            width: context.responsiveWidth(
              mobilePortrait: 0.2,
              mobileLandscape: 0.18,
              tabletPortrait: 0.18,
              tabletLandscape: 0.15,
              desktopPortrait: 0.15,
              desktopLandscape: 0.12,
            ),
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.green,
                  Colors.orange
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraInterface(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: context.responsiveHeight(
            mobilePortrait: 0.7,
            mobileLandscape: 0.8,
            tabletPortrait: 0.6,
            tabletLandscape: 0.7,
          ),
          child: Stack(
            children: [
              // Camera preview - full container
              if (_cameraController != null &&
                  _cameraController!.value.isInitialized)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),

              // Face detection guide overlay
              Center(
                child: Container(
                  width: context.responsiveWidth(
                    mobilePortrait: 0.6,
                    mobileLandscape: 0.4,
                    tabletPortrait: 0.5,
                    tabletLandscape: 0.35,
                  ),
                  height: context.responsiveWidth(
                    mobilePortrait: 0.75,
                    mobileLandscape: 0.5,
                    tabletPortrait: 0.6,
                    tabletLandscape: 0.45,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Camera overlay with instructions
              Positioned(
                top: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
                left: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.03,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.035,
                ),
                right: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.03,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.035,
                ),
                child: Container(
                  padding: context.responsivePadding(
                    mobilePortrait: 0.03,
                    mobileLandscape: 0.025,
                    tabletPortrait: 0.035,
                    tabletLandscape: 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Positionnez votre visage dans le cadre\nRegardez directement la caméra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.035,
                        mobileLandscape: 0.028,
                        tabletPortrait: 0.03,
                        tabletLandscape: 0.025,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
                right: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _stopCamera,
                    iconSize: context.responsiveFontSize(
                      mobilePortrait: 0.05,
                      mobileLandscape: 0.04,
                      tabletPortrait: 0.045,
                      tabletLandscape: 0.038,
                    ),
                  ),
                ),
              ),

              // Capture button
              Positioned(
                bottom: context.responsiveSpacing(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.025,
                  tabletPortrait: 0.035,
                  tabletLandscape: 0.03,
                ),
                left: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.03,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.035,
                ),
                right: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.03,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.035,
                ),
                child: ElevatedButton(
                  onPressed: _isDetectingFace ? null : _capturePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4FFF),
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isDetectingFace
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: context.responsiveFontSize(
                                mobilePortrait: 0.05,
                                mobileLandscape: 0.04,
                                tabletPortrait: 0.045,
                                tabletLandscape: 0.038,
                              ),
                              height: context.responsiveFontSize(
                                mobilePortrait: 0.05,
                                mobileLandscape: 0.04,
                                tabletPortrait: 0.045,
                                tabletLandscape: 0.038,
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(
                                width: context.responsiveSpacing(
                              mobilePortrait: 0.02,
                              mobileLandscape: 0.015,
                              tabletPortrait: 0.025,
                              tabletLandscape: 0.018,
                            )),
                            Text(
                              'Détection de visage...',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  mobilePortrait: 0.04,
                                  mobileLandscape: 0.032,
                                  tabletPortrait: 0.035,
                                  tabletLandscape: 0.03,
                                ),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Prendre une photo',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              mobilePortrait: 0.045,
                              mobileLandscape: 0.035,
                              tabletPortrait: 0.04,
                              tabletLandscape: 0.033,
                            ),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInterface(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Single camera container
          _buildImageUploadCard(context),

          // Form card (only show if iris images are extracted)
          if (_showExtractedIris &&
              _leftIrisImage != null &&
              _rightIrisImage != null) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.025,
              mobileLandscape: 0.02,
              tabletPortrait: 0.03,
              tabletLandscape: 0.025,
            )),
            _buildFormCard(context),

            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.025,
              mobileLandscape: 0.02,
              tabletPortrait: 0.03,
              tabletLandscape: 0.025,
            )),

            // Model selector card (only show if enabled in configuration)
            if (ModelConfig.showModelSelector) ...[
              _buildModelSelectorCard(context),
              SizedBox(
                  height: context.responsiveSpacing(
                mobilePortrait: 0.025,
                mobileLandscape: 0.02,
                tabletPortrait: 0.03,
                tabletLandscape: 0.025,
              )),
            ],

            // Analyze button (only show when iris images are extracted)
            _buildAnalyzeButtonCard(context),
          ],

          // Results section
          if (_showResults &&
              _analysisResult != null &&
              _personalityDescription != null) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.03,
              mobileLandscape: 0.025,
              tabletPortrait: 0.035,
              tabletLandscape: 0.03,
            )),
            _buildEnhancedResultsCard(context),
          ],

          // Error message display
          if (_errorMessage != null) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.015,
              tabletPortrait: 0.025,
              tabletLandscape: 0.018,
            )),
            Container(
              padding: EdgeInsets.all(
                context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.04,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  SizedBox(
                      width: context.responsiveSpacing(
                    mobilePortrait: 0.02,
                    mobileLandscape: 0.015,
                    tabletPortrait: 0.025,
                    tabletLandscape: 0.018,
                  )),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.035,
                          mobileLandscape: 0.028,
                          tabletPortrait: 0.03,
                          tabletLandscape: 0.025,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageUploadCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: context.responsivePadding(
          mobilePortrait: 0.04,
          mobileLandscape: 0.035,
          tabletPortrait: 0.045,
          tabletLandscape: 0.04,
        ),
        child: Column(
          children: [
            if (_image != null) ...[
              // Image preview with controls
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: context.responsiveHeight(
                        mobilePortrait: 0.3,
                        mobileLandscape: 0.4,
                        tabletPortrait: 0.25,
                        tabletLandscape: 0.35,
                      ),
                      width: double.infinity,
                      child: Image.file(
                        _image!,
                        key: ValueKey(
                            _image!.path), // Force refresh when path changes
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: context.responsiveSpacing(
                      mobilePortrait: 0.015,
                      mobileLandscape: 0.01,
                      tabletPortrait: 0.018,
                      tabletLandscape: 0.012,
                    ),
                    right: context.responsiveSpacing(
                      mobilePortrait: 0.015,
                      mobileLandscape: 0.01,
                      tabletPortrait: 0.018,
                      tabletLandscape: 0.012,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Color(0xFF8A4FFF)),
                            onPressed: _startCamera,
                            iconSize: context.responsiveFontSize(
                              mobilePortrait: 0.05,
                              mobileLandscape: 0.04,
                              tabletPortrait: 0.045,
                              tabletLandscape: 0.038,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: context.responsiveSpacing(
                          mobilePortrait: 0.01,
                          mobileLandscape: 0.008,
                          tabletPortrait: 0.012,
                          tabletLandscape: 0.01,
                        )),
                        CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _removeImage,
                            iconSize: context.responsiveFontSize(
                              mobilePortrait: 0.05,
                              mobileLandscape: 0.04,
                              tabletPortrait: 0.045,
                              tabletLandscape: 0.038,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                  height: context.responsiveSpacing(
                mobilePortrait: 0.02,
                mobileLandscape: 0.015,
                tabletPortrait: 0.025,
                tabletLandscape: 0.018,
              )),

              // Extract iris button
              if (!_showExtractedIris && !_isExtractingIris)
                ElevatedButton.icon(
                  onPressed: () => _extractIris(_image!),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Extraire les iris'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4FFF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSpacing(
                        mobilePortrait: 0.018,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.02,
                        tabletLandscape: 0.016,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),

              // Loading indicator for extraction
              if (_isExtractingIris)
                Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF8A4FFF)),
                    ),
                    SizedBox(
                      height: context.responsiveSpacing(
                        mobilePortrait: 0.01,
                        mobileLandscape: 0.008,
                        tabletPortrait: 0.012,
                        tabletLandscape: 0.01,
                      ),
                    ),
                    const Text('Extraction des iris en cours...'),
                  ],
                ),

              // Extracted iris images
              if (_showExtractedIris &&
                  _leftIrisImage != null &&
                  _rightIrisImage != null) ...[
                SizedBox(
                  height: context.responsiveSpacing(
                    mobilePortrait: 0.02,
                    mobileLandscape: 0.015,
                    tabletPortrait: 0.025,
                    tabletLandscape: 0.018,
                  ),
                ),
                Text(
                  'Iris extraits',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.045,
                      mobileLandscape: 0.035,
                      tabletPortrait: 0.04,
                      tabletLandscape: 0.033,
                    ),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(
                  height: context.responsiveSpacing(
                    mobilePortrait: 0.02,
                    mobileLandscape: 0.015,
                    tabletPortrait: 0.025,
                    tabletLandscape: 0.018,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Iris gauche',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                mobilePortrait: 0.035,
                                mobileLandscape: 0.028,
                                tabletPortrait: 0.03,
                                tabletLandscape: 0.025,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: context.responsiveSpacing(
                              mobilePortrait: 0.01,
                              mobileLandscape: 0.008,
                              tabletPortrait: 0.012,
                              tabletLandscape: 0.01,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _leftIrisImage!,
                              key: ValueKey(_leftIrisImage!
                                  .path), // Force refresh when path changes
                              height: context.responsiveHeight(
                                mobilePortrait: 0.15,
                                mobileLandscape: 0.2,
                                tabletPortrait: 0.12,
                                tabletLandscape: 0.17,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Iris droit',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                mobilePortrait: 0.035,
                                mobileLandscape: 0.028,
                                tabletPortrait: 0.03,
                                tabletLandscape: 0.025,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: context.responsiveSpacing(
                              mobilePortrait: 0.01,
                              mobileLandscape: 0.008,
                              tabletPortrait: 0.012,
                              tabletLandscape: 0.01,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _rightIrisImage!,
                              key: ValueKey(_rightIrisImage!
                                  .path), // Force refresh when path changes
                              height: context.responsiveHeight(
                                mobilePortrait: 0.15,
                                mobileLandscape: 0.2,
                                tabletPortrait: 0.12,
                                tabletLandscape: 0.17,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              // Upload prompt
              _buildUploadPrompt(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Âge',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          DropdownButtonFormField<String>(
            value: _selectedGender.isEmpty ? null : _selectedGender,
            decoration: InputDecoration(
              labelText: 'Genre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            items: ['Homme', 'Femme', 'Autre']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.045,
                            mobileLandscape: 0.035,
                            tabletPortrait: 0.035,
                            tabletLandscape: 0.028,
                            desktopPortrait: 0.03,
                            desktopLandscape: 0.025,
                          ),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
            },
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _commentsController,
            decoration: InputDecoration(
              labelText: 'Commentaires (optionnel)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            maxLines: 3,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPrompt(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.camera_alt,
          size: context.responsiveFontSize(
            mobilePortrait: 0.15,
            mobileLandscape: 0.12,
            tabletPortrait: 0.12,
            tabletLandscape: 0.1,
          ),
          color: Colors.grey[400],
        ),
        SizedBox(
            height: context.responsiveSpacing(
          mobilePortrait: 0.02,
          mobileLandscape: 0.015,
          tabletPortrait: 0.025,
          tabletLandscape: 0.018,
        )),
        Text(
          'Prenez une photo de votre iris',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              mobilePortrait: 0.045,
              mobileLandscape: 0.035,
              tabletPortrait: 0.04,
              tabletLandscape: 0.033,
            ),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height: context.responsiveSpacing(
          mobilePortrait: 0.015,
          mobileLandscape: 0.01,
          tabletPortrait: 0.018,
          tabletLandscape: 0.012,
        )),
        Text(
          'Utilisez la caméra pour capturer votre visage et extraire vos iris',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              mobilePortrait: 0.035,
              mobileLandscape: 0.028,
              tabletPortrait: 0.03,
              tabletLandscape: 0.025,
            ),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height: context.responsiveSpacing(
          mobilePortrait: 0.03,
          mobileLandscape: 0.025,
          tabletPortrait: 0.035,
          tabletLandscape: 0.03,
        )),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ouvrir la caméra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A4FFF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: context.responsivePadding(
          mobilePortrait: 0.04,
          mobileLandscape: 0.035,
          tabletPortrait: 0.045,
          tabletLandscape: 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  mobilePortrait: 0.05,
                  mobileLandscape: 0.04,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.015,
              tabletPortrait: 0.025,
              tabletLandscape: 0.018,
            )),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButtonCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: context.responsivePadding(
          mobilePortrait: 0.04,
          mobileLandscape: 0.035,
          tabletPortrait: 0.045,
          tabletLandscape: 0.04,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _leftIrisImage == null ||
                    _rightIrisImage == null ||
                    _isAnalyzing
                ? null
                : _analyzeIrisEnhanced,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A4FFF),
              padding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: context.responsiveFontSize(
                          mobilePortrait: 0.05,
                          mobileLandscape: 0.04,
                          tabletPortrait: 0.045,
                          tabletLandscape: 0.038,
                        ),
                        height: context.responsiveFontSize(
                          mobilePortrait: 0.05,
                          mobileLandscape: 0.04,
                          tabletPortrait: 0.045,
                          tabletLandscape: 0.038,
                        ),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(
                          width: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      )),
                      Text(
                        'Analyse en cours...',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.045,
                            mobileLandscape: 0.035,
                            tabletPortrait: 0.04,
                            tabletLandscape: 0.033,
                          ),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: context.responsiveFontSize(
                          mobilePortrait: 0.05,
                          mobileLandscape: 0.04,
                          tabletPortrait: 0.045,
                          tabletLandscape: 0.038,
                        ),
                      ),
                      SizedBox(
                          width: context.responsiveSpacing(
                        mobilePortrait: 0.02,
                        mobileLandscape: 0.015,
                        tabletPortrait: 0.025,
                        tabletLandscape: 0.018,
                      )),
                      Text(
                        'Analyser mon iris',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.05,
                            mobileLandscape: 0.04,
                            tabletPortrait: 0.045,
                            tabletLandscape: 0.038,
                          ),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedResultsCard(BuildContext context) {
    final primaryClass = _analysisResult!['primary_class'];
    final personalityData = _personalityDescription!;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: context.responsivePadding(
          mobilePortrait: 0.04,
          mobileLandscape: 0.035,
          tabletPortrait: 0.045,
          tabletLandscape: 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xFF8A4FFF),
                  size: context.responsiveFontSize(
                    mobilePortrait: 0.06,
                    mobileLandscape: 0.048,
                    tabletPortrait: 0.05,
                    tabletLandscape: 0.042,
                  ),
                ),
                SizedBox(
                    width: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                )),
                Text(
                  'Résultats de l\'analyse',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.05,
                      mobileLandscape: 0.04,
                      tabletPortrait: 0.045,
                      tabletLandscape: 0.038,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.015,
              tabletPortrait: 0.025,
              tabletLandscape: 0.018,
            )),
            Container(
              width: double.infinity,
              padding: context.responsivePadding(
                mobilePortrait: 0.04,
                mobileLandscape: 0.035,
                tabletPortrait: 0.045,
                tabletLandscape: 0.04,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8A4FFF).withValues(alpha: 0.1),
                    const Color(0xFF8A4FFF).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF8A4FFF).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    personalityData['icon'] ?? '👁️',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.1,
                        mobileLandscape: 0.08,
                        tabletPortrait: 0.09,
                        tabletLandscape: 0.075,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: context.responsiveSpacing(
                    mobilePortrait: 0.01,
                    mobileLandscape: 0.008,
                    tabletPortrait: 0.012,
                    tabletLandscape: 0.01,
                  )),
                  Text(
                    personalityData['name'] ?? primaryClass,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.08,
                        mobileLandscape: 0.065,
                        tabletPortrait: 0.07,
                        tabletLandscape: 0.058,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A4FFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.025,
              mobileLandscape: 0.02,
              tabletPortrait: 0.03,
              tabletLandscape: 0.025,
            )),
            Text(
              'Description',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  mobilePortrait: 0.045,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.04,
                  tabletLandscape: 0.033,
                ),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.015,
              mobileLandscape: 0.01,
              tabletPortrait: 0.018,
              tabletLandscape: 0.012,
            )),
            Text(
              personalityData['description'] ?? 'Description non disponible',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.032,
                  tabletPortrait: 0.035,
                  tabletLandscape: 0.03,
                ),
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (personalityData['characteristics'] != null) ...[
              SizedBox(
                  height: context.responsiveSpacing(
                mobilePortrait: 0.02,
                mobileLandscape: 0.015,
                tabletPortrait: 0.025,
                tabletLandscape: 0.018,
              )),
              Text(
                'Caractéristiques',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    mobilePortrait: 0.045,
                    mobileLandscape: 0.035,
                    tabletPortrait: 0.04,
                    tabletLandscape: 0.033,
                  ),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(
                  height: context.responsiveSpacing(
                mobilePortrait: 0.01,
                mobileLandscape: 0.008,
                tabletPortrait: 0.012,
                tabletLandscape: 0.01,
              )),
              Wrap(
                spacing: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.018,
                ),
                runSpacing: context.responsiveSpacing(
                  mobilePortrait: 0.01,
                  mobileLandscape: 0.008,
                  tabletPortrait: 0.012,
                  tabletLandscape: 0.01,
                ),
                children: (personalityData['characteristics'] as List)
                    .map((characteristic) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveSpacing(
                              mobilePortrait: 0.03,
                              mobileLandscape: 0.025,
                              tabletPortrait: 0.035,
                              tabletLandscape: 0.03,
                            ),
                            vertical: context.responsiveSpacing(
                              mobilePortrait: 0.01,
                              mobileLandscape: 0.008,
                              tabletPortrait: 0.012,
                              tabletLandscape: 0.01,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8A4FFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8A4FFF)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            characteristic.toString(),
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                mobilePortrait: 0.035,
                                mobileLandscape: 0.028,
                                tabletPortrait: 0.03,
                                tabletLandscape: 0.025,
                              ),
                              color: const Color(0xFF8A4FFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelectorCard(BuildContext context) {
    return ModelSelectorWidget(
      onModelChanged: (PredictionModel model) {
        // Optional: Add any additional logic when model changes
        debugPrint('Model changed to: ${model.displayName}');
      },
      showDescription: true,
      showTechnicalInfo: false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _commentsController.dispose();
    _stopCamera();
    super.dispose();
  }
}
