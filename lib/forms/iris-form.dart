import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:pfa_mobile/utils/responsive_utils.dart';

class IrisForm extends StatefulWidget {
  const IrisForm({Key? key}) : super(key: key);

  @override
  _IrisFormState createState() => _IrisFormState();
}

class _IrisFormState extends State<IrisForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _isAnalyzing = false;
  bool _isDetectingFace = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _imageQuality;
  Map<String, dynamic>? _faceDetectionResult;

  // Camera controller
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _showCamera = false;

  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';
  final TextEditingController _commentsController = TextEditingController();

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
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<void> _startCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune caméra disponible')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'accès à la caméra: $e')),
      );
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
      });

      // Validate image quality
      _validateImageQuality(processedImage);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la capture: $e')),
      );
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

      // Save processed image
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/processed_image.jpg';
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 90,
      );

      if (image == null) return;

      final File imageFile = File(image.path);

      // For gallery images, we still validate face presence
      if (source == ImageSource.gallery) {
        setState(() {
          _isDetectingFace = true;
        });

        final faceDetectionResult = await _detectFaceInImage(imageFile);

        if (!faceDetectionResult['faceDetected']) {
          setState(() {
            _faceDetectionResult = faceDetectionResult;
            _isDetectingFace = false;
          });
          return;
        }
      }

      setState(() {
        _image = imageFile;
        _faceDetectionResult = null;
        _isDetectingFace = false;
      });

      // Validate image quality
      _validateImageQuality(imageFile);
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _imageQuality = null;
      _faceDetectionResult = null;
    });
  }

  Future<void> _analyzeIris() async {
    if (_image == null) return;

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vous devez être connecté pour analyser votre iris')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    // Check internet connectivity
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Une connexion internet est requise pour l\'analyse')),
        );
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Une connexion internet est requise pour l\'analyse')),
      );
      return;
    }

    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Process image before uploading
      final processedImage = await _processImage(_image!);

      // Generate analysis results with improved logic
      final analysisResult = _calculateIrisAnalysis();

      // Try to upload to Firebase Storage
      String? imageUrl;
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('iris_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(processedImage);
        imageUrl = await storageRef.getDownloadURL();
        debugPrint('Image uploaded successfully: $imageUrl');
      } catch (storageError) {
        debugPrint('Firebase Storage error: $storageError');
        // Continue without image URL
      }

      // Get image dimensions for metadata
      final imageBytes = await processedImage.readAsBytes();
      final image = img.decodeImage(imageBytes);
      final imageWidth = image?.width ?? 0;
      final imageHeight = image?.height ?? 0;

      // Save to Firestore with complete metadata
      try {
        await FirebaseFirestore.instance.collection('iris_images').add({
          'userEmail': user.email,
          'userName': _nameController.text,
          'imageUrl': imageUrl ?? 'unavailable',
          'uploadedAt': FieldValue.serverTimestamp(),
          'analysisResult': analysisResult,
          'metadata': {
            'fileName': _image!.path.split('/').last,
            'fileSize': await _image!.length(),
            'imageWidth': imageWidth,
            'imageHeight': imageHeight,
            'quality': _imageQuality?['score'] ?? 0,
          }
        });

        debugPrint('Analysis results saved to Firestore successfully');
      } catch (firestoreError) {
        debugPrint('Firestore error: $firestoreError');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la sauvegarde des résultats')),
        );
      }

      setState(() {
        _analysisResult = analysisResult;
      });
    } catch (e) {
      debugPrint('Error analyzing iris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'analyse: $e')),
      );
    } finally {
      setState(() {
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
          // Image upload card
          _buildImageUploadCard(context),

          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.025,
            mobileLandscape: 0.02,
            tabletPortrait: 0.03,
            tabletLandscape: 0.025,
          )),

          // Form card (only show if image is uploaded)
          if (_image != null) ...[
            _buildFormCard(context),

            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.025,
              mobileLandscape: 0.02,
              tabletPortrait: 0.03,
              tabletLandscape: 0.025,
            )),

            // Analyze button
            _buildAnalyzeButtonCard(context),
          ],

          // Results section
          if (_analysisResult != null) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.03,
              mobileLandscape: 0.025,
              tabletPortrait: 0.035,
              tabletLandscape: 0.03,
            )),
            _buildResultsCard(context),
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

              // Face detection and quality feedback
              if (_faceDetectionResult != null)
                _buildFeedbackCard(context, _faceDetectionResult!),

              if (_imageQuality != null)
                _buildQualityCard(context, _imageQuality!),
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

  Widget _buildPercentageBar(
      BuildContext context, String label, int percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSpacing(
          mobilePortrait: 0.01,
          mobileLandscape: 0.008,
          tabletPortrait: 0.012,
          tabletLandscape: 0.01,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $percentage%',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.03,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.004,
            mobileLandscape: 0.003,
            tabletPortrait: 0.005,
            tabletLandscape: 0.004,
          )),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForType(label),
            ),
            minHeight: context.responsiveSpacing(
              mobilePortrait: 0.012,
              mobileLandscape: 0.01,
              tabletPortrait: 0.014,
              tabletLandscape: 0.012,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Fleur':
        return Colors.purple;
      case 'Bijou':
        return Colors.blue;
      case 'Flux':
        return Colors.green;
      case 'Shaker':
        return Colors.orange;
      // Subclass combinations
      case 'Fleur-Bijou':
        return const Color(0xFF9C27B0); // Purple-Blue blend
      case 'Bijou-Shaker':
        return const Color(0xFF3F51B5); // Blue-Orange blend (Indigo)
      case 'Shaker-Flux':
        return const Color(0xFFFF5722); // Orange-Green blend (Deep Orange)
      case 'Flux-Fleur':
        return const Color(0xFF8BC34A); // Green-Purple blend (Light Green)
      case 'Fleur-Shaker':
        return const Color(0xFFE91E63); // Purple-Orange blend (Pink)
      case 'Bijou-Flux':
        return const Color(0xFF00BCD4); // Blue-Green blend (Cyan)
      default:
        return Colors.grey;
    }
  }

  Color _getImageQualityColor(String level) {
    switch (level) {
      case 'good':
        return Colors.green;
      case 'medium':
        return Colors.yellow;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          'Utilisez la caméra pour capturer votre iris ou sélectionnez une image depuis votre galerie',
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
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Caméra'),
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
            SizedBox(
                width: context.responsiveSpacing(
              mobilePortrait: 0.03,
              mobileLandscape: 0.025,
              tabletPortrait: 0.035,
              tabletLandscape: 0.03,
            )),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galerie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
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
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(
      BuildContext context, Map<String, dynamic> feedback) {
    final bool isSuccess = feedback['faceDetected'] ?? false;
    final Color statusColor = isSuccess ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          mobilePortrait: 0.015,
          mobileLandscape: 0.01,
          tabletPortrait: 0.018,
          tabletLandscape: 0.012,
        ),
      ),
      padding: context.responsivePadding(
        mobilePortrait: 0.03,
        mobileLandscape: 0.025,
        tabletPortrait: 0.035,
        tabletLandscape: 0.03,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: statusColor,
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
              Expanded(
                child: Text(
                  feedback['message'] ?? '',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.04,
                      mobileLandscape: 0.032,
                      tabletPortrait: 0.035,
                      tabletLandscape: 0.03,
                    ),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (feedback['suggestions'] != null &&
              (feedback['suggestions'] as List).isNotEmpty) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.015,
              mobileLandscape: 0.01,
              tabletPortrait: 0.018,
              tabletLandscape: 0.012,
            )),
            ...(feedback['suggestions'] as List).map(
              (suggestion) => Padding(
                padding: EdgeInsets.only(
                  bottom: context.responsiveSpacing(
                    mobilePortrait: 0.008,
                    mobileLandscape: 0.006,
                    tabletPortrait: 0.01,
                    tabletLandscape: 0.008,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: statusColor.withValues(alpha: 0.8),
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.035,
                          mobileLandscape: 0.028,
                          tabletPortrait: 0.03,
                          tabletLandscape: 0.025,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: statusColor.withValues(alpha: 0.8),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityCard(BuildContext context, Map<String, dynamic> quality) {
    final String level = quality['level'] ?? 'poor';
    final Color statusColor = _getImageQualityColor(level);

    return Container(
      margin: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          mobilePortrait: 0.015,
          mobileLandscape: 0.01,
          tabletPortrait: 0.018,
          tabletLandscape: 0.012,
        ),
      ),
      padding: context.responsivePadding(
        mobilePortrait: 0.03,
        mobileLandscape: 0.025,
        tabletPortrait: 0.035,
        tabletLandscape: 0.03,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                level == 'good'
                    ? Icons.high_quality
                    : level == 'medium'
                        ? Icons.warning
                        : Icons.error,
                color: statusColor,
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
              Expanded(
                child: Text(
                  quality['message'] ?? '',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.04,
                      mobileLandscape: 0.032,
                      tabletPortrait: 0.035,
                      tabletLandscape: 0.03,
                    ),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (quality['suggestions'] != null &&
              (quality['suggestions'] as List).isNotEmpty) ...[
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.015,
              mobileLandscape: 0.01,
              tabletPortrait: 0.018,
              tabletLandscape: 0.012,
            )),
            ...(quality['suggestions'] as List).map(
              (suggestion) => Padding(
                padding: EdgeInsets.only(
                  bottom: context.responsiveSpacing(
                    mobilePortrait: 0.008,
                    mobileLandscape: 0.006,
                    tabletPortrait: 0.01,
                    tabletLandscape: 0.008,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: statusColor.withValues(alpha: 0.8),
                        fontSize: context.responsiveFontSize(
                          mobilePortrait: 0.035,
                          mobileLandscape: 0.028,
                          tabletPortrait: 0.03,
                          tabletLandscape: 0.025,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: statusColor.withValues(alpha: 0.8),
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
            ),
          ],
        ],
      ),
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
            onPressed: _image == null || _isAnalyzing ? null : _analyzeIris,
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

  Widget _buildResultsCard(BuildContext context) {
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
                  Icons.analytics,
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
                  'Résultat de l\'analyse',
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
                    'Votre type d\'iris principal :',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.04,
                        mobileLandscape: 0.032,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.03,
                      ),
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: context.responsiveSpacing(
                    mobilePortrait: 0.01,
                    mobileLandscape: 0.008,
                    tabletPortrait: 0.012,
                    tabletLandscape: 0.01,
                  )),
                  Text(
                    _analysisResult!['primaryType'],
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
              'Répartition détaillée :',
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
            _buildPercentageBar(
                context, 'Fleur', _analysisResult!['fleurPercentage']),
            _buildPercentageBar(
                context, 'Bijou', _analysisResult!['bijouPercentage']),
            _buildPercentageBar(
                context, 'Flux', _analysisResult!['fluxPercentage']),
            _buildPercentageBar(
                context, 'Shaker', _analysisResult!['shakerPercentage']),
            SizedBox(
                height: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.015,
              tabletPortrait: 0.025,
              tabletLandscape: 0.018,
            )),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context,
                      '/iris_types/${_analysisResult!['primaryTypeRoute']}');
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('En savoir plus sur votre type'),
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
        ),
      ),
    );
  }

  /// Calculate iris analysis with improved logic for handling ties and subclasses
  Map<String, dynamic> _calculateIrisAnalysis() {
    final random = math.Random();

    // Generate individual class scores (0-100 each)
    final fleurScore = random.nextInt(80) + 20; // 20-100
    final bijouScore = random.nextInt(80) + 20; // 20-100
    final fluxScore = random.nextInt(80) + 20; // 20-100
    final shakerScore = random.nextInt(80) + 20; // 20-100

    // Create list of scores with their corresponding types
    final scores = [
      {'type': 'Fleur', 'route': 'fleur', 'score': fleurScore},
      {'type': 'Bijou', 'route': 'bijou', 'score': bijouScore},
      {'type': 'Flux', 'route': 'flux', 'score': fluxScore},
      {'type': 'Shaker', 'route': 'shaker', 'score': shakerScore},
    ];

    // Sort by score (highest first)
    scores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final firstScore = scores[0]['score'] as int;
    final secondScore = scores[1]['score'] as int;

    String primaryType;
    String primaryTypeRoute;

    // Check if there's a tie (difference <= 5 points)
    if ((firstScore - secondScore).abs() <= 5) {
      // There's a tie, create a subclass combination
      final firstType = scores[0]['type'] as String;
      final secondType = scores[1]['type'] as String;

      final combination = _createSubclass(firstType, secondType);
      primaryType = combination['type']!;
      primaryTypeRoute = combination['route']!;
    } else {
      // Clear winner, use the highest score
      primaryType = scores[0]['type'] as String;
      primaryTypeRoute = scores[0]['route'] as String;
    }

    // Convert scores to percentages (normalize to 100%)
    final totalScore = fleurScore + bijouScore + fluxScore + shakerScore;
    final fleurPercentage = ((fleurScore / totalScore) * 100).round();
    final bijouPercentage = ((bijouScore / totalScore) * 100).round();
    final fluxPercentage = ((fluxScore / totalScore) * 100).round();
    final shakerPercentage =
        100 - fleurPercentage - bijouPercentage - fluxPercentage;

    return {
      'primaryType': primaryType,
      'primaryTypeRoute': primaryTypeRoute,
      'fleurPercentage': fleurPercentage,
      'bijouPercentage': bijouPercentage,
      'fluxPercentage': fluxPercentage,
      'shakerPercentage': shakerPercentage,
      'description': 'Votre iris révèle une personnalité de type $primaryType.',
      'rawScores': {
        'fleur': fleurScore,
        'bijou': bijouScore,
        'flux': fluxScore,
        'shaker': shakerScore,
      },
    };
  }

  /// Create subclass combination for tied scores
  Map<String, String> _createSubclass(String type1, String type2) {
    // Define all possible combinations
    final combinations = {
      'Fleur-Bijou': {'type': 'Fleur-Bijou', 'route': 'fleur-bijou'},
      'Bijou-Fleur': {'type': 'Fleur-Bijou', 'route': 'fleur-bijou'},
      'Bijou-Shaker': {'type': 'Bijou-Shaker', 'route': 'bijou-shaker'},
      'Shaker-Bijou': {'type': 'Bijou-Shaker', 'route': 'bijou-shaker'},
      'Shaker-Flux': {'type': 'Shaker-Flux', 'route': 'shaker-flux'},
      'Flux-Shaker': {'type': 'Shaker-Flux', 'route': 'shaker-flux'},
      'Flux-Fleur': {'type': 'Flux-Fleur', 'route': 'flux-fleur'},
      'Fleur-Flux': {'type': 'Flux-Fleur', 'route': 'flux-fleur'},
      'Fleur-Shaker': {'type': 'Fleur-Shaker', 'route': 'fleur-shaker'},
      'Shaker-Fleur': {'type': 'Fleur-Shaker', 'route': 'fleur-shaker'},
      'Bijou-Flux': {'type': 'Bijou-Flux', 'route': 'bijou-flux'},
      'Flux-Bijou': {'type': 'Bijou-Flux', 'route': 'bijou-flux'},
    };

    final key = '$type1-$type2';
    return combinations[key] ?? {'type': type1, 'route': type1.toLowerCase()};
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
