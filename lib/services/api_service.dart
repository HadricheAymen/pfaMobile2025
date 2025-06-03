import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pfa_mobile/config/api_config.dart';

// Enum to define available prediction models
enum PredictionModel {
  efficient, // Original efficient model (/api/predict-efficient)
  mobilenet, // New MobileNet model (/api/predict-mobilenet)
}

// Extension to get model-specific configurations
extension PredictionModelExtension on PredictionModel {
  String get displayName {
    switch (this) {
      case PredictionModel.efficient:
        return 'Modèle Efficace';
      case PredictionModel.mobilenet:
        return 'Modèle MobileNet';
    }
  }

  String get endpoint {
    switch (this) {
      case PredictionModel.efficient:
        return ApiConfig.efficientPredictionUrl;
      case PredictionModel.mobilenet:
        return ApiConfig.mobilenetPredictionUrl;
    }
  }

  String get description {
    switch (this) {
      case PredictionModel.efficient:
        return 'Modèle d\'analyse d\'iris optimisé pour la rapidité et la précision';
      case PredictionModel.mobilenet:
        return 'Modèle MobileNet optimisé pour les appareils mobiles avec architecture légère';
    }
  }

  String get technicalInfo {
    switch (this) {
      case PredictionModel.efficient:
        return 'Architecture: CNN personnalisé\nOptimisation: Vitesse et précision\nTaille: Modèle complet';
      case PredictionModel.mobilenet:
        return 'Architecture: MobileNet\nOptimisation: Efficacité mobile\nTaille: Modèle léger';
    }
  }
}

class ApiService {
  // Current selected model - can be changed by developer
  static PredictionModel _currentModel = PredictionModel.efficient;

  // Getter for current model
  static PredictionModel get currentModel => _currentModel;

  // Method to switch between models
  static void setModel(PredictionModel model) {
    _currentModel = model;
    debugPrint('🔄 Switched to model: ${model.displayName}');
    debugPrint('📍 Endpoint: ${model.endpoint}');
  }

  // Get all available models
  static List<PredictionModel> get availableModels => PredictionModel.values;
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

  // Method to predict iris from image file using the correct field name
  static Future<Map<String, dynamic>> predictIris(File imageFile) async {
    // Use the efficient prediction endpoint with 'image' field
    return await _tryPredictIris(
        imageFile, ApiConfig.efficientPredictionUrl, 'image');
  }

  // Method to predict iris using both left and right iris images
  static Future<Map<String, dynamic>> predictIrisWithBothImages(
      File leftIrisImage, File rightIrisImage) async {
    try {
      debugPrint('🔍 Starting dual iris prediction...');
      debugPrint('🤖 Using model: ${_currentModel.displayName}');
      debugPrint('📁 Left iris file path: ${leftIrisImage.path}');
      debugPrint('📁 Right iris file path: ${rightIrisImage.path}');
      debugPrint(
          '📏 Left iris file size: ${await leftIrisImage.length()} bytes');
      debugPrint(
          '📏 Right iris file size: ${await rightIrisImage.length()} bytes');

      // Get current user ID if logged in
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      debugPrint('👤 User ID: $userId');

      // Use current model's endpoint
      final endpoint = _currentModel.endpoint;
      debugPrint('🌐 API URL: $endpoint');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      // Add headers
      request.headers.addAll({
        'Connection': 'keep-alive',
        'Accept': 'application/json',
      });

      debugPrint('📋 Request headers: ${request.headers}');

      // Add user ID if available
      if (userId != null) {
        request.fields['user_id'] = userId;
      }

      debugPrint('📝 Request fields: ${request.fields}');

      // Add both iris images as required by the API
      request.files.add(await http.MultipartFile.fromPath(
        'image1', // Left iris as image1
        leftIrisImage.path,
        filename: 'left_iris.jpg',
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'image2', // Right iris as image2
        rightIrisImage.path,
        filename: 'right_iris.jpg',
      ));

      debugPrint(
          '📎 Added left iris file: left_iris.jpg, size: ${await leftIrisImage.length()} bytes');
      debugPrint(
          '📎 Added right iris file: right_iris.jpg, size: ${await rightIrisImage.length()} bytes');

      debugPrint('🚀 Sending request...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response headers: ${response.headers}');
      debugPrint('📨 Response body: $responseBody');
      debugPrint('');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(responseBody);
        debugPrint('✅ Prediction successful: $result');
        return result;
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - $responseBody');
        debugPrint('');
        return {
          'error': 'API Error: ${response.statusCode} - $responseBody',
          'status_code': response.statusCode,
          'response_body': responseBody,
        };
      }
    } catch (e) {
      debugPrint('💥 Exception during prediction: $e');
      debugPrint('');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Method to predict iris using a specific model (advanced usage)
  static Future<Map<String, dynamic>> predictIrisWithBothImagesUsingModel(
      File leftIrisImage, File rightIrisImage, PredictionModel model) async {
    try {
      debugPrint('🔍 Starting dual iris prediction with specific model...');
      debugPrint('🤖 Using model: ${model.displayName}');
      debugPrint('📁 Left iris file path: ${leftIrisImage.path}');
      debugPrint('📁 Right iris file path: ${rightIrisImage.path}');
      debugPrint(
          '📏 Left iris file size: ${await leftIrisImage.length()} bytes');
      debugPrint(
          '📏 Right iris file size: ${await rightIrisImage.length()} bytes');

      // Get current user ID if logged in
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      debugPrint('👤 User ID: $userId');

      // Use specified model's endpoint
      final endpoint = model.endpoint;
      debugPrint('🌐 API URL: $endpoint');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      // Add headers
      request.headers.addAll({
        'Connection': 'keep-alive',
        'Accept': 'application/json',
      });

      debugPrint('📋 Request headers: ${request.headers}');

      // Add user ID if available
      if (userId != null) {
        request.fields['user_id'] = userId;
      }

      debugPrint('📝 Request fields: ${request.fields}');

      // Add both iris images as required by the API
      request.files.add(await http.MultipartFile.fromPath(
        'image1', // Left iris as image1
        leftIrisImage.path,
        filename: 'left_iris.jpg',
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'image2', // Right iris as image2
        rightIrisImage.path,
        filename: 'right_iris.jpg',
      ));

      debugPrint(
          '📎 Added left iris file: left_iris.jpg, size: ${await leftIrisImage.length()} bytes');
      debugPrint(
          '📎 Added right iris file: right_iris.jpg, size: ${await rightIrisImage.length()} bytes');

      debugPrint('🚀 Sending request...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response headers: ${response.headers}');
      debugPrint('📨 Response body: $responseBody');
      debugPrint('');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(responseBody);
        debugPrint('✅ Prediction successful: $result');
        // Add model info to result
        result['model_used'] = model.displayName;
        result['model_endpoint'] = endpoint;
        return result;
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - $responseBody');
        debugPrint('');
        return {
          'error': 'API Error: ${response.statusCode} - $responseBody',
          'status_code': response.statusCode,
          'response_body': responseBody,
          'model_used': model.displayName,
        };
      }
    } catch (e) {
      debugPrint('💥 Exception during prediction: $e');
      debugPrint('');
      return {
        'error': 'Failed to connect to server: $e',
        'model_used': model.displayName,
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
        request.fields[ApiConfig.userIdFieldName] = userId;
      }

      // Add the image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        ApiConfig.imageFieldName,
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

  // Method to extract iris from face image using the correct endpoint
  static Future<Map<String, dynamic>> extractIris(File faceImage) async {
    try {
      debugPrint('👁️ Starting iris extraction...');
      debugPrint('📁 Face image path: ${faceImage.path}');
      debugPrint('📏 Face image size: ${await faceImage.length()} bytes');

      // Get current user ID if logged in
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      debugPrint('👤 User ID: $userId');

      // Create multipart request using the iris extraction endpoint
      final uri = Uri.parse(ApiConfig.irisExtractionUrl);
      debugPrint('🌐 Extraction URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add timeout
      request.headers['Connection'] = 'keep-alive';
      request.headers['Accept'] = 'application/json';
      debugPrint('📋 Request headers: ${request.headers}');

      // Temporarily disable user_id to test if it's causing issues
      // if (userId != null) {
      //   request.fields[ApiConfig.userIdFieldName] = userId;
      // }
      debugPrint('📝 Request fields: ${request.fields}');

      // Check if file exists and is readable
      if (!await faceImage.exists()) {
        throw Exception('Face image file does not exist: ${faceImage.path}');
      }

      final fileLength = await faceImage.length();
      if (fileLength == 0) {
        throw Exception('Face image file is empty: ${faceImage.path}');
      }

      // Add the image file
      final fileStream = http.ByteStream(faceImage.openRead());

      final multipartFile = http.MultipartFile(
        'image', // Use 'image' field name for iris extraction
        fileStream,
        fileLength,
        filename: 'face_image.jpg',
      );

      request.files.add(multipartFile);
      debugPrint(
          '📎 Added face image: ${multipartFile.filename}, size: ${multipartFile.length} bytes');

      // Send the request
      debugPrint('🚀 Sending iris extraction request...');
      final streamedResponse =
          await request.send().timeout(ApiConfig.longRequestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📨 Extraction response status: ${response.statusCode}');
      debugPrint('📨 Extraction response body: ${response.body}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('Iris extraction successful: $result');
        return result;
      } else {
        debugPrint(
            'Iris extraction API Error: ${response.statusCode} - ${response.body}');
        return {
          'error': 'Server returned status code ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      debugPrint('Exception during iris extraction: $e');
      return {'error': 'Failed to connect to server: $e'};
    }
  }

  // Debug method to test API with minimal request
  static Future<Map<String, dynamic>> testApiEndpoint() async {
    try {
      debugPrint('🧪 Testing API endpoints...');

      // Test 1: Health check
      debugPrint('🏥 Testing health endpoint...');
      final healthResponse = await http.get(
        Uri.parse(ApiConfig.healthUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConfig.requestTimeout);

      debugPrint(
          'Health response: ${healthResponse.statusCode} - ${healthResponse.body}');

      // Test 2: Try a simple POST to prediction endpoint (without file)
      debugPrint('📡 Testing prediction endpoint structure...');
      final testResponse = await http.post(
        Uri.parse(ApiConfig.predictionUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(ApiConfig.requestTimeout);

      debugPrint(
          'Prediction test response: ${testResponse.statusCode} - ${testResponse.body}');

      return {
        'health_status': healthResponse.statusCode,
        'health_body': healthResponse.body,
        'prediction_status': testResponse.statusCode,
        'prediction_body': testResponse.body,
      };
    } catch (e) {
      debugPrint('🚨 API test failed: $e');
      return {'error': 'API test failed: $e'};
    }
  }
}
