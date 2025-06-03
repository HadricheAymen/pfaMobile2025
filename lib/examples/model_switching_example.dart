import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pfa_mobile/services/api_service.dart';
import 'package:pfa_mobile/config/model_config.dart';

/// Example class demonstrating how to use model switching functionality
/// 
/// This class provides examples for developers on how to:
/// 1. Switch between models programmatically
/// 2. Compare model results
/// 3. Handle different model responses
/// 4. Test model availability
class ModelSwitchingExample {
  
  /// Example 1: Basic model switching
  static void basicModelSwitching() {
    debugPrint('=== Basic Model Switching Example ===');
    
    // Get current model
    final currentModel = ApiService.currentModel;
    debugPrint('Current model: ${currentModel.displayName}');
    
    // Switch to MobileNet model
    ApiService.setModel(PredictionModel.mobilenet);
    debugPrint('Switched to: ${ApiService.currentModel.displayName}');
    
    // Switch to Efficient model
    ApiService.setModel(PredictionModel.efficient);
    debugPrint('Switched to: ${ApiService.currentModel.displayName}');
    
    // Use configuration helper methods
    ModelConfig.useMobileNetModel();
    debugPrint('Using MobileNet: ${ApiService.currentModel.displayName}');
    
    ModelConfig.useEfficientModel();
    debugPrint('Using Efficient: ${ApiService.currentModel.displayName}');
  }
  
  /// Example 2: Compare predictions from both models
  static Future<void> compareModels(File leftIrisImage, File rightIrisImage) async {
    debugPrint('=== Model Comparison Example ===');
    
    final results = <PredictionModel, Map<String, dynamic>>{};
    
    // Test each model
    for (final model in ApiService.availableModels) {
      debugPrint('Testing ${model.displayName}...');
      
      try {
        final result = await ApiService.predictIrisWithBothImagesUsingModel(
          leftIrisImage,
          rightIrisImage,
          model,
        );
        
        results[model] = result;
        
        if (result.containsKey('error')) {
          debugPrint('❌ ${model.displayName} failed: ${result['error']}');
        } else {
          final prediction = result['primary_class'] ?? result['prediction'] ?? 'Unknown';
          debugPrint('✅ ${model.displayName} predicted: $prediction');
        }
      } catch (e) {
        debugPrint('💥 ${model.displayName} exception: $e');
        results[model] = {'error': 'Exception: $e'};
      }
    }
    
    // Compare results
    debugPrint('\n=== Comparison Results ===');
    final predictions = <String>[];
    
    for (final entry in results.entries) {
      final model = entry.key;
      final result = entry.value;
      
      if (!result.containsKey('error')) {
        final prediction = result['primary_class'] ?? result['prediction'] ?? 'Unknown';
        predictions.add(prediction);
        debugPrint('${model.displayName}: $prediction');
      } else {
        debugPrint('${model.displayName}: ERROR - ${result['error']}');
      }
    }
    
    // Check if predictions match
    if (predictions.isNotEmpty && predictions.toSet().length == 1) {
      debugPrint('🎯 All models agree: ${predictions.first}');
    } else if (predictions.length > 1) {
      debugPrint('⚠️ Models disagree: ${predictions.join(' vs ')}');
    } else {
      debugPrint('❌ No successful predictions');
    }
  }
  
  /// Example 3: Model-specific prediction with error handling
  static Future<Map<String, dynamic>> predictWithModel(
    File leftIrisImage,
    File rightIrisImage,
    PredictionModel model,
  ) async {
    debugPrint('=== Model-Specific Prediction Example ===');
    debugPrint('Using model: ${model.displayName}');
    debugPrint('Endpoint: ${model.endpoint}');
    
    try {
      final result = await ApiService.predictIrisWithBothImagesUsingModel(
        leftIrisImage,
        rightIrisImage,
        model,
      );
      
      if (result.containsKey('error')) {
        debugPrint('❌ Prediction failed: ${result['error']}');
        return {
          'success': false,
          'error': result['error'],
          'model': model.displayName,
        };
      } else {
        final prediction = result['primary_class'] ?? result['prediction'] ?? 'Unknown';
        debugPrint('✅ Prediction successful: $prediction');
        return {
          'success': true,
          'prediction': prediction,
          'model': model.displayName,
          'full_result': result,
        };
      }
    } catch (e) {
      debugPrint('💥 Exception during prediction: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
        'model': model.displayName,
      };
    }
  }
  
  /// Example 4: Test model availability
  static Future<void> testModelAvailability() async {
    debugPrint('=== Model Availability Test ===');
    
    for (final model in ApiService.availableModels) {
      debugPrint('Testing ${model.displayName}...');
      debugPrint('  Endpoint: ${model.endpoint}');
      debugPrint('  Description: ${model.description}');
      
      // Here you could add actual connectivity tests
      // For now, we'll just show the configuration
      debugPrint('  ✅ Configuration valid');
    }
    
    // Test using the utility method
    final results = await ModelConfig.testAllModels();
    debugPrint('\nAvailability Results:');
    for (final entry in results.entries) {
      final status = entry.value ? '✅ Available' : '❌ Unavailable';
      debugPrint('${entry.key.displayName}: $status');
    }
  }
  
  /// Example 5: Configuration management
  static void configurationExample() {
    debugPrint('=== Configuration Management Example ===');
    
    // Print current configuration
    ModelConfig.printCurrentConfig();
    
    // Get detailed model information
    final info = ModelConfig.getCurrentModelInfo();
    debugPrint('\nDetailed Model Info:');
    debugPrint('Display Name: ${info['displayName']}');
    debugPrint('Endpoint: ${info['endpoint']}');
    debugPrint('Description: ${info['description']}');
    debugPrint('Technical Info: ${info['technicalInfo']}');
    
    // Show all available models
    debugPrint('\nAll Available Models:');
    for (final model in ApiService.availableModels) {
      debugPrint('- ${model.displayName}: ${model.endpoint}');
    }
  }
  
  /// Example 6: Performance comparison
  static Future<void> performanceComparison(File leftIrisImage, File rightIrisImage) async {
    debugPrint('=== Performance Comparison Example ===');
    
    final performanceResults = <PredictionModel, Duration>{};
    
    for (final model in ApiService.availableModels) {
      debugPrint('Testing performance of ${model.displayName}...');
      
      final stopwatch = Stopwatch()..start();
      
      try {
        await ApiService.predictIrisWithBothImagesUsingModel(
          leftIrisImage,
          rightIrisImage,
          model,
        );
        
        stopwatch.stop();
        performanceResults[model] = stopwatch.elapsed;
        debugPrint('✅ ${model.displayName}: ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        stopwatch.stop();
        debugPrint('❌ ${model.displayName}: Failed after ${stopwatch.elapsedMilliseconds}ms');
      }
    }
    
    // Find fastest model
    if (performanceResults.isNotEmpty) {
      final fastest = performanceResults.entries.reduce(
        (a, b) => a.value < b.value ? a : b,
      );
      debugPrint('\n🏆 Fastest model: ${fastest.key.displayName} (${fastest.value.inMilliseconds}ms)');
    }
  }
  
  /// Example 7: Fallback mechanism
  static Future<Map<String, dynamic>> predictWithFallback(
    File leftIrisImage,
    File rightIrisImage,
  ) async {
    debugPrint('=== Fallback Mechanism Example ===');
    
    // Try primary model first
    final primaryModel = PredictionModel.efficient;
    final fallbackModel = PredictionModel.mobilenet;
    
    debugPrint('Trying primary model: ${primaryModel.displayName}');
    
    try {
      final result = await ApiService.predictIrisWithBothImagesUsingModel(
        leftIrisImage,
        rightIrisImage,
        primaryModel,
      );
      
      if (!result.containsKey('error')) {
        debugPrint('✅ Primary model succeeded');
        return result;
      } else {
        debugPrint('❌ Primary model failed: ${result['error']}');
      }
    } catch (e) {
      debugPrint('💥 Primary model exception: $e');
    }
    
    // Fallback to secondary model
    debugPrint('Trying fallback model: ${fallbackModel.displayName}');
    
    try {
      final result = await ApiService.predictIrisWithBothImagesUsingModel(
        leftIrisImage,
        rightIrisImage,
        fallbackModel,
      );
      
      if (!result.containsKey('error')) {
        debugPrint('✅ Fallback model succeeded');
        result['used_fallback'] = true;
        return result;
      } else {
        debugPrint('❌ Fallback model also failed: ${result['error']}');
      }
    } catch (e) {
      debugPrint('💥 Fallback model exception: $e');
    }
    
    // Both models failed
    return {
      'error': 'Both primary and fallback models failed',
      'primary_model': primaryModel.displayName,
      'fallback_model': fallbackModel.displayName,
    };
  }
}
