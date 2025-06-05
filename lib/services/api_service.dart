import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pfa_mobile/config/api_config.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ApiService {
  // Helper method to get user-friendly error messages
  static String _getUserFriendlyError(String error) {
    if (error.contains('mobileNet.h5')) {
      return 'Le modèle d\'IA n\'est pas disponible actuellement. Veuillez réessayer plus tard.';
    } else if (error.contains('timeout')) {
      return 'La connexion a expiré. Vérifiez votre connexion internet et réessayez.';
    } else if (error.contains('Network error')) {
      return 'Erreur de réseau. Vérifiez votre connexion internet.';
    } else if (error.contains('Deux images sont requises')) {
      return 'Les deux images d\'iris sont requises pour l\'analyse.';
    } else if (error.contains('500')) {
      return 'Erreur du serveur. Veuillez réessayer dans quelques minutes.';
    } else if (error.contains('400')) {
      return 'Erreur de requête. Vérifiez que vos images sont valides.';
    }
    return error; // Return original error if no specific match
  }

  // Health check endpoint
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final uri = Uri.parse(ApiConfig.healthUrl);
      final response = await http.get(uri).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error': 'Health check failed with status ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Method to predict iris from image file using MobileNet as primary
  static Future<Map<String, dynamic>> predictIris(File imageFile) async {
    try {
      debugPrint('🤖 Trying MobileNet model first (primary)...');

      // Try MobileNet first
      final mobileNetResult = await _tryPredictIris(
          imageFile,
          ApiConfig.predictionUrl, // /api/predict-mobilenet
          'image');

      // If MobileNet succeeds, return immediately
      if (!mobileNetResult.containsKey('error')) {
        debugPrint('✅ MobileNet prediction successful!');
        mobileNetResult['model_used'] = 'MobileNet (Primary)';
        return mobileNetResult;
      }

      // If MobileNet fails, try efficient model as fallback
      debugPrint('🔄 MobileNet failed, trying Efficient model as fallback...');
      debugPrint('MobileNet error: ${mobileNetResult['error']}');

      final efficientResult =
          await _tryPredictIris(imageFile, ApiConfig.efficientNetUrl, 'image');

      // If efficient model also fails, return the original MobileNet error
      if (efficientResult.containsKey('error')) {
        debugPrint(
            '❌ Both models failed. Returning MobileNet error as primary.');
        return mobileNetResult;
      }

      // Efficient model succeeded as fallback
      debugPrint('✅ Efficient model succeeded as fallback');
      efficientResult['model_used'] = 'Efficient (Fallback)';
      efficientResult['fallback_used'] = true;
      efficientResult['primary_model_error'] = mobileNetResult['error'];
      return efficientResult;
    } catch (e) {
      debugPrint('💥 Exception during iris prediction: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Predict iris with both images using MobileNet as primary, with fallback
  static Future<Map<String, dynamic>> predictIrisWithBothImages(
    File leftIrisImage,
    File rightIrisImage, {
    String? userId,
  }) async {
    try {
      // Compress images before sending
      final compressedLeft = await _compressImage(leftIrisImage);
      final compressedRight = await _compressImage(rightIrisImage);
      
      debugPrint('🔍 Starting iris prediction with compressed images...');
      debugPrint('📏 Original left size: ${await leftIrisImage.length()} bytes');
      debugPrint('📏 Compressed left size: ${await compressedLeft.length()} bytes');
      
      // Try MobileNet endpoint FIRST (primary model)
      debugPrint('🤖 Trying MobileNet model first (primary)...');
      final mobileNetResult = await _tryPredictWithBothImages(
        compressedLeft,
        compressedRight,
        ApiConfig.predictionUrl, // This is /api/predict-mobilenet
        userId,
        'MobileNet Model (Primary)',
      );

      // If MobileNet succeeds, return immediately
      if (!mobileNetResult.containsKey('error')) {
        debugPrint('✅ MobileNet prediction successful!');
        return mobileNetResult;
      }

      // If MobileNet fails, try efficient model as fallback
      debugPrint('🔄 MobileNet failed, trying Efficient model as fallback...');
      debugPrint('MobileNet error: ${mobileNetResult['error']}');

      final efficientResult = await _tryPredictWithBothImages(
        compressedLeft,
        compressedRight,
        ApiConfig.efficientNetUrl,
        userId,
        'Efficient Model (Fallback)',
      );

      // If efficient model also fails, return the original MobileNet error
      if (efficientResult.containsKey('error')) {
        debugPrint(
            '❌ Both models failed. Returning MobileNet error as primary.');
        return mobileNetResult; // Return original MobileNet error
      }

      // Efficient model succeeded as fallback
      debugPrint('✅ Efficient model succeeded as fallback');
      efficientResult['fallback_used'] = true;
      efficientResult['primary_model_error'] = mobileNetResult['error'];
      return efficientResult;
    } catch (e) {
      debugPrint('💥 Exception during iris prediction: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Helper method to try prediction with both images
  static Future<Map<String, dynamic>> _tryPredictWithBothImages(
    File leftIrisImage,
    File rightIrisImage,
    String endpoint,
    String? userId,
    String modelName,
  ) async {
    try {
      debugPrint('🤖 Trying $modelName at: $endpoint');

      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers exactly like test HTML
      request.headers.addAll({
        'Accept': '*/*',
        'Connection': 'keep-alive',
      });

      // Add files with exact field names from test HTML
      request.files.add(await http.MultipartFile.fromPath(
        'image1', // Exact field name from test HTML
        leftIrisImage.path,
        filename: 'image1.jpg', // Simple filename like test HTML
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'image2', // Exact field name from test HTML
        rightIrisImage.path,
        filename: 'image2.jpg', // Simple filename like test HTML
      ));

      // Don't add user_id for now to match test HTML exactly
      // The test HTML doesn't send user_id

      debugPrint('📋 Request fields: ${request.fields}');
      debugPrint(
          '📎 Added file: image1.jpg, size: ${await leftIrisImage.length()} bytes');
      debugPrint(
          '📎 Added file: image2.jpg, size: ${await rightIrisImage.length()} bytes');
      debugPrint('🚀 Sending request to $modelName...');

      // Send request with longer timeout for MobileNet processing
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 180), // 3 minutes for MobileNet processing
        onTimeout: () {
          throw TimeoutException(
              'Request timeout', const Duration(seconds: 180));
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response headers: ${response.headers}');
      debugPrint('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        result['model_used'] = modelName;
        debugPrint('✅ $modelName prediction successful');
        return result;
      } else {
        debugPrint(
            '❌ $modelName API Error: ${response.statusCode} - ${response.body}');
        final errorBody =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        final rawError =
            errorBody['error'] ?? errorBody['message'] ?? 'Prediction failed';
        return {
          'error': _getUserFriendlyError(rawError),
          'raw_error': rawError,
          'status_code': response.statusCode,
          'model_used': modelName,
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ $modelName prediction timeout: $e');
      return {
        'error': 'La prédiction a pris trop de temps. Réessayez.',
        'model_used': modelName
      };
    } on SocketException catch (e) {
      debugPrint('🌐 Network error during $modelName prediction: $e');
      return {
        'error': 'Erreur de réseau. Vérifiez votre connexion internet.',
        'model_used': modelName
      };
    } catch (e) {
      debugPrint('💥 Exception during $modelName prediction: $e');
      return {
        'error': 'Erreur lors de la prédiction: $e',
        'model_used': modelName
      };
    }
  }

  // Helper method to try a specific prediction approach
  static Future<Map<String, dynamic>> _tryPredictIris(
      File imageFile, String endpoint, String fieldName) async {
    try {
      debugPrint('🔍 Starting iris prediction...');
      debugPrint('📁 Image file path: ${imageFile.path}');
      debugPrint('📏 Image file size: ${await imageFile.length()} bytes');

      // Get current user ID if logged in
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      debugPrint('👤 User ID: $userId');

      // Create multipart request using specified endpoint
      final uri = Uri.parse(endpoint);
      debugPrint('🌐 API URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Connection'] = 'keep-alive';
      request.headers['Accept'] = 'application/json';
      // Note: Don't set Content-Type manually for multipart requests
      debugPrint('📋 Request headers: ${request.headers}');

      // Temporarily disable user_id to test if it's causing the 400 error
      // if (userId != null) {
      //   request.fields[ApiConfig.userIdFieldName] = userId;
      // }
      debugPrint('📝 Request fields: ${request.fields}');

      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileLength = await imageFile.length();
      if (fileLength == 0) {
        throw Exception('Image file is empty: ${imageFile.path}');
      }

      // Add the image file
      final fileStream = http.ByteStream(imageFile.openRead());

      final multipartFile = http.MultipartFile(
        fieldName, // Use the specified field name
        fileStream,
        fileLength,
        filename: 'iris_image.jpg',
      );

      request.files.add(multipartFile);
      debugPrint(
          '📎 Added file: ${multipartFile.filename}, size: ${multipartFile.length} bytes');

      // Send the request
      debugPrint('🚀 Sending request...');
      final streamedResponse =
          await request.send().timeout(ApiConfig.longRequestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response headers: ${response.headers}');
      debugPrint('📨 Response body: ${response.body}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('✅ Prediction successful: $result');
        return result;
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');

        // Try to parse error details from response
        String errorMessage =
            'Server returned status code ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('error')) {
            errorMessage = errorBody['error'].toString();
          } else if (errorBody is Map && errorBody.containsKey('detail')) {
            errorMessage = errorBody['detail'].toString();
          } else if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'].toString();
          }
        } catch (parseError) {
          debugPrint('Could not parse error response: $parseError');
        }

        return {
          'error': errorMessage,
          'status_code': response.statusCode,
          'details': response.body
        };
      }
    } catch (e) {
      debugPrint('💥 Exception during API call: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Method to predict iris using standard prediction endpoint
  static Future<Map<String, dynamic>> predictIrisStandard(
      File imageFile) async {
    try {
      // Get current user ID if logged in
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      // Create multipart request using standard prediction endpoint
      final uri = Uri.parse(ApiConfig.predictionUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add timeout
      request.headers['Connection'] = 'keep-alive';

      // Add user ID if available
      if (userId != null) {
        request.fields['user_id'] = userId;
      }

      // Add the image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: 'iris_image.jpg',
      );

      request.files.add(multipartFile);

      // Send the request
      final streamedResponse =
          await request.send().timeout(ApiConfig.longRequestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Check if request was successful
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return {
          'error': 'Server returned status code ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Enhanced iris analysis method with two images and user profile
  static Future<Map<String, dynamic>> analyzeIrisEnhanced({
    required File leftIrisImage,
    required File rightIrisImage,
    required Map<String, String> userProfile,
  }) async {
    try {
      debugPrint('🔍 Starting enhanced iris analysis...');
      debugPrint('📁 Left iris image: ${leftIrisImage.path}');
      debugPrint('📁 Right iris image: ${rightIrisImage.path}');
      debugPrint('👤 User profile: $userProfile');

      // Create a proper request with the correct endpoint
      final uri = Uri.parse(ApiConfig.enhancedAnalysisUrl);
      debugPrint('🌐 API URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add timeout
      request.headers['Connection'] = 'keep-alive';

      // Add iris images
      request.files.add(await http.MultipartFile.fromPath(
        'left_iris',
        leftIrisImage.path,
        filename: 'left_iris.jpg',
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'right_iris',
        rightIrisImage.path,
        filename: 'right_iris.jpg',
      ));

      // Add user profile data
      userProfile.forEach((key, value) {
        request.fields[key] = value;
      });

      debugPrint('📤 Sending enhanced iris analysis request...');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        ApiConfig.longRequestTimeout,
        onTimeout: () {
          throw TimeoutException(
              'Request timeout', ApiConfig.longRequestTimeout);
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        debugPrint('✅ Enhanced iris analysis successful');
        return result;
      } else {
        debugPrint('❌ Enhanced iris analysis failed: ${response.statusCode}');
        final errorBody =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'error': errorBody['error'] ?? 'Enhanced iris analysis failed',
          'status_code': response.statusCode,
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ Enhanced iris analysis timeout: $e');
      return {'error': 'Request timeout. Please try again.'};
    } on SocketException catch (e) {
      debugPrint('🌐 Network error during enhanced iris analysis: $e');
      return {'error': 'Network error. Please check your connection.'};
    } catch (e) {
      debugPrint('Exception during enhanced iris analysis: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Method to extract iris from face image - matches test HTML exactly
  static Future<Map<String, dynamic>> extractIris(File faceImage) async {
    try {
      debugPrint('👁️ Starting iris extraction (matching test HTML)...');
      debugPrint('📁 Face image path: ${faceImage.path}');
      debugPrint('📏 Face image size: ${await faceImage.length()} bytes');

      // Create multipart request exactly like test HTML
      final uri = Uri.parse(ApiConfig.extractIrisUrl);
      debugPrint('🌐 Extraction URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add headers exactly like test HTML
      request.headers.addAll({
        'Accept': '*/*',
        'Connection': 'keep-alive',
      });

      debugPrint('📋 Request headers: ${request.headers}');

      // Check if file exists and is readable
      if (!await faceImage.exists()) {
        throw Exception('Face image file does not exist: ${faceImage.path}');
      }

      final fileLength = await faceImage.length();
      if (fileLength == 0) {
        throw Exception('Face image file is empty: ${faceImage.path}');
      }

      // Add the image file with exact field name from test HTML
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Exact field name from test HTML
        faceImage.path,
        filename: 'image.jpg', // Simple filename like test HTML
      ));

      debugPrint('📎 Added face image: image.jpg, size: $fileLength bytes');

      // Send the request with proper timeout
      debugPrint('🚀 Sending iris extraction request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120), // Longer timeout for extraction
        onTimeout: () {
          throw TimeoutException(
              'Iris extraction timeout', const Duration(seconds: 120));
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 Extraction response status: ${response.statusCode}');
      debugPrint('📨 Extraction response body: ${response.body}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('✅ Iris extraction successful');
        return result;
      } else {
        debugPrint('❌ Iris extraction failed: ${response.statusCode}');
        final errorBody =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'error': _getUserFriendlyError(
              errorBody['error'] ?? 'Iris extraction failed'),
          'raw_error': errorBody['error'] ?? 'Unknown error',
          'status_code': response.statusCode,
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ Iris extraction timeout: $e');
      return {
        'error':
            'L\'extraction d\'iris a pris trop de temps. Réessayez avec une image plus petite.'
      };
    } on SocketException catch (e) {
      debugPrint('🌐 Network error during iris extraction: $e');
      return {'error': 'Erreur de réseau. Vérifiez votre connexion internet.'};
    } catch (e) {
      debugPrint('💥 Exception during iris extraction: $e');
      return {'error': 'Erreur lors de l\'extraction d\'iris: $e'};
    }
  }

  // Helper method to compress images
  static Future<File> _compressImage(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final fileName = basename(imageFile.path);
    final targetPath = '$path/compressed_$fileName';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: 85,
      minWidth: 512,
      minHeight: 512,
    );
    
    return File(result!.path);
  }
}

