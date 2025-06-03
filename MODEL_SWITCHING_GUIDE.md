# Model Switching Guide

This guide explains how to seamlessly switch between different iris prediction models in the Flutter app.

## Overview

The app now supports multiple prediction models:
- **Efficient Model** (`/api/predict-efficient`) - Original optimized model
- **MobileNet Model** (`/api/predict-mobilenet`) - New lightweight model

## Quick Start

### 1. Switch Default Model (Recommended)

Edit `lib/config/model_config.dart`:

```dart
// Change this line to switch the default model
static const PredictionModel defaultModel = PredictionModel.mobilenet; // or PredictionModel.efficient
```

### 2. Restart the App

The new model will be used automatically.

## Configuration Options

### Model Configuration (`lib/config/model_config.dart`)

```dart
class ModelConfig {
  // Default model to use
  static const PredictionModel defaultModel = PredictionModel.efficient;
  
  // Show model selector in UI
  static const bool showModelSelector = true;
  
  // Enable model comparison feature
  static const bool enableModelComparison = true;
  
  // Show technical information
  static const bool showTechnicalInfo = false;
}
```

### API Configuration (`lib/config/api_config.dart`)

```dart
class ApiConfig {
  // Endpoints
  static const String efficientPredictionEndpoint = '/api/predict-efficient';
  static const String mobilenetPredictionEndpoint = '/api/predict-mobilenet';
  
  // Full URLs
  static String get efficientPredictionUrl => '$baseUrl$efficientPredictionEndpoint';
  static String get mobilenetPredictionUrl => '$baseUrl$mobilenetPredictionEndpoint';
}
```

## Usage Methods

### Method 1: Configuration File (Recommended)
```dart
// In model_config.dart
static const PredictionModel defaultModel = PredictionModel.mobilenet;
```

### Method 2: Programmatic Switching
```dart
// Switch to MobileNet model
ApiService.setModel(PredictionModel.mobilenet);

// Switch to Efficient model
ApiService.setModel(PredictionModel.efficient);
```

### Method 3: UI Model Selector
Users can switch models using the model selector widget in the iris form.

### Method 4: Specific Model Prediction
```dart
// Use a specific model for one prediction
final result = await ApiService.predictIrisWithBothImagesUsingModel(
  leftIrisImage,
  rightIrisImage,
  PredictionModel.mobilenet,
);
```

## Model Information

### Efficient Model
- **Endpoint**: `/api/predict-efficient`
- **Description**: Original optimized model for speed and accuracy
- **Architecture**: Custom CNN
- **Use Case**: General purpose, balanced performance

### MobileNet Model
- **Endpoint**: `/api/predict-mobilenet`
- **Description**: Lightweight model optimized for mobile devices
- **Architecture**: MobileNet
- **Use Case**: Resource-constrained environments, faster inference

## Features

### 1. Model Selector Widget
- Dropdown to switch between models
- Shows model descriptions
- Optional technical information
- Automatic API service update

### 2. Model Comparison Widget
- Compare predictions from both models
- Side-by-side results display
- Error handling for each model
- Performance comparison

### 3. Developer Utilities
```dart
// Get current model info
final info = ModelConfig.getCurrentModelInfo();

// Test all models
final results = await ModelConfig.testAllModels();

// Print current configuration
ModelConfig.printCurrentConfig();
```

## Implementation Details

### File Structure
```
lib/
├── config/
│   ├── api_config.dart          # API endpoints
│   └── model_config.dart        # Model configuration
├── services/
│   └── api_service.dart         # API service with model support
├── widgets/
│   ├── model_selector_widget.dart    # UI model selector
│   └── model_comparison_widget.dart  # Model comparison UI
└── forms/
    └── iris-form.dart           # Updated form with model selector
```

### Key Classes

#### PredictionModel Enum
```dart
enum PredictionModel {
  efficient,    // /api/predict-efficient
  mobilenet,    // /api/predict-mobilenet
}
```

#### ApiService Methods
```dart
// Use current model
static Future<Map<String, dynamic>> predictIrisWithBothImages(...)

// Use specific model
static Future<Map<String, dynamic>> predictIrisWithBothImagesUsingModel(..., PredictionModel model)

// Switch model
static void setModel(PredictionModel model)
```

## Testing

### 1. Manual Testing
1. Change model in configuration
2. Restart app
3. Test iris prediction
4. Verify correct endpoint is called

### 2. Model Comparison
1. Use ModelComparisonWidget
2. Compare results from both models
3. Verify both endpoints work

### 3. Automated Testing
```dart
// Test all models
final results = await ModelConfig.testAllModels();
for (final entry in results.entries) {
  print('${entry.key.displayName}: ${entry.value ? "✅" : "❌"}');
}
```

## Troubleshooting

### Model Not Switching
1. Check if `ModelConfig.initialize()` is called in main.dart
2. Verify the model configuration is correct
3. Restart the app completely

### API Errors
1. Check backend endpoints are available
2. Verify API configuration URLs
3. Test with model comparison widget

### UI Issues
1. Check if model selector is enabled: `ModelConfig.showModelSelector = true`
2. Verify imports in iris form
3. Check widget integration

## Best Practices

1. **Use Configuration File**: Change `ModelConfig.defaultModel` for permanent switches
2. **Test Both Models**: Use comparison widget to verify both work
3. **Handle Errors**: Both models should have proper error handling
4. **User Experience**: Consider showing model information to users
5. **Performance**: Monitor response times for different models

## Future Enhancements

1. **Model Performance Metrics**: Track response times and accuracy
2. **A/B Testing**: Automatically switch models for testing
3. **Model Caching**: Cache model responses for better performance
4. **Dynamic Model Loading**: Load models based on device capabilities
5. **Model Versioning**: Support multiple versions of the same model type

## Support

For issues or questions:
1. Check the debug console for model switching logs
2. Use `ModelConfig.printCurrentConfig()` to verify setup
3. Test individual models with the comparison widget
4. Verify backend endpoints are accessible
