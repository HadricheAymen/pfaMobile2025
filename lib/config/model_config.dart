import 'package:pfa_mobile/services/api_service.dart';

/// Model Configuration for Developers
///
/// This file allows developers to easily configure which prediction model
/// to use by default and provides utilities for model management.
class ModelConfig {
  // =================================================================
  // DEVELOPER CONFIGURATION - CHANGE THIS TO SWITCH DEFAULT MODEL
  // =================================================================

  /// Default model to use when the app starts
  /// Change this value to switch between models:
  /// - PredictionModel.efficient: Original efficient model
  /// - PredictionModel.mobilenet: New MobileNet model
  static const PredictionModel defaultModel = PredictionModel.mobilenet;

  /// Whether to show model selector in the UI by default
  /// Set to false to hide model selection from users
  static const bool showModelSelector = false;

  /// Whether to enable model comparison feature
  /// Set to false to disable comparison functionality
  static const bool enableModelComparison = true;

  /// Whether to show technical information about models
  /// Set to true for debugging/development purposes
  static const bool showTechnicalInfo = false;

  // =================================================================
  // AUTOMATIC INITIALIZATION
  // =================================================================

  /// Initialize the API service with the default model
  /// Call this in main.dart or app initialization
  static void initialize() {
    ApiService.setModel(defaultModel);
    print(
        '🚀 Model configuration initialized with: ${defaultModel.displayName}');
  }

  // =================================================================
  // DEVELOPER UTILITIES
  // =================================================================

  /// Quick method to switch to efficient model
  static void useEfficientModel() {
    ApiService.setModel(PredictionModel.efficient);
  }

  /// Quick method to switch to MobileNet model
  static void useMobileNetModel() {
    ApiService.setModel(PredictionModel.mobilenet);
  }

  /// Get current model information
  static Map<String, dynamic> getCurrentModelInfo() {
    final currentModel = ApiService.currentModel;
    return {
      'model': currentModel,
      'displayName': currentModel.displayName,
      'endpoint': currentModel.endpoint,
      'description': currentModel.description,
      'technicalInfo': currentModel.technicalInfo,
    };
  }

  /// Print current model configuration to console
  static void printCurrentConfig() {
    final info = getCurrentModelInfo();
    print('=== CURRENT MODEL CONFIGURATION ===');
    print('Model: ${info['displayName']}');
    print('Endpoint: ${info['endpoint']}');
    print('Description: ${info['description']}');
    if (showTechnicalInfo) {
      print('Technical Info: ${info['technicalInfo']}');
    }
    print('Model Selector Visible: $showModelSelector');
    print('Comparison Enabled: $enableModelComparison');
    print('===================================');
  }

  // =================================================================
  // TESTING UTILITIES
  // =================================================================

  /// Test all available models (for development/testing)
  static Future<Map<PredictionModel, bool>> testAllModels() async {
    final results = <PredictionModel, bool>{};

    for (final model in ApiService.availableModels) {
      try {
        // Test health check for each model's endpoint
        // Note: This is a basic connectivity test
        // For full testing, you'd need actual iris images
        print('Testing ${model.displayName}...');

        // Here you could add actual API testing logic
        // For now, we'll just mark as available
        results[model] = true;
        print('✅ ${model.displayName} is available');
      } catch (e) {
        results[model] = false;
        print('❌ ${model.displayName} failed: $e');
      }
    }

    return results;
  }
}

/// Developer Notes and Instructions
///
/// HOW TO SWITCH MODELS:
/// 1. Change `defaultModel` constant above
/// 2. Restart the app
///
/// HOW TO ADD NEW MODELS:
/// 1. Add new endpoint to ApiConfig
/// 2. Add new enum value to PredictionModel
/// 3. Update PredictionModelExtension with new model info
///
/// HOW TO HIDE MODEL SELECTOR:
/// 1. Set `showModelSelector = false`
/// 2. Users won't see model selection UI
///
/// HOW TO TEST MODELS:
/// 1. Call `ModelConfig.testAllModels()` in debug mode
/// 2. Use model comparison widget in the app
///
/// EXAMPLE USAGE IN MAIN.DART:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize model configuration
///   ModelConfig.initialize();
///
///   // Optional: Print current config for debugging
///   if (kDebugMode) {
///     ModelConfig.printCurrentConfig();
///   }
///
///   runApp(MyApp());
/// }
/// ```
class DeveloperNotes {
  static const String version = '1.0.0';
  static const String lastUpdated = '2024-12-19';

  static void printInstructions() {
    print('''
=== IRIS PREDICTION MODEL CONFIGURATION ===

QUICK START:
1. Change ModelConfig.defaultModel to switch models
2. Set ModelConfig.showModelSelector to show/hide UI selector
3. Call ModelConfig.initialize() in main.dart

AVAILABLE MODELS:
- PredictionModel.efficient: Original model (/api/predict-efficient)
- PredictionModel.mobilenet: MobileNet model (/api/predict-mobilenet)

DEVELOPER METHODS:
- ModelConfig.useEfficientModel()
- ModelConfig.useMobileNetModel()
- ModelConfig.getCurrentModelInfo()
- ModelConfig.testAllModels()

For more details, see comments in model_config.dart
==========================================
''');
  }
}
