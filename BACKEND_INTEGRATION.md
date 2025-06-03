# Backend Integration Guide

## Overview
This document explains how to integrate your Flutter app with the iris profiling backend API.

## Backend API Endpoints
Your backend provides the following endpoints:
- `/health` - Health check endpoint
- `/api/predict-efficient` - Efficient iris prediction
- `/api/predict` - Standard iris prediction  
- `/api/extract-iris` - Iris extraction from face images

## Configuration

### 1. Update Backend URL
Edit the file `lib/config/api_config.dart` and update the `baseUrl` with your actual backend domain:

```dart
class ApiConfig {
  // Update this URL with your actual backend domain
  static const String baseUrl = 'https://your-actual-backend-domain.com';
  // ... rest of the configuration
}
```

### 2. API Integration Features

#### Iris Extraction
- The app calls `/api/extract-iris` endpoint to extract iris regions from face images
- Supports base64 encoded iris images in response
- Falls back to using original image if extraction fails

#### Iris Prediction
- Uses `/api/predict-efficient` endpoint by default for faster predictions
- Supports both left and right iris analysis
- Combines results from both eyes for final prediction

#### Expected API Response Format

**Iris Extraction Response:**
```json
{
  "left_iris": "base64_encoded_image_data",
  "right_iris": "base64_encoded_image_data"
}
```

**Prediction Response:**
```json
{
  "primary_type": "Flower|Jewel|Stream|Shaker",
  "confidence": 0.85,
  "additional_data": "..."
}
```

### 3. Error Handling
The app handles various error scenarios:
- Network connectivity issues
- API server errors
- Invalid response formats
- Authentication failures

### 4. User Authentication
- The app sends Firebase user ID with API requests
- Field name: `user_id`
- Used for tracking and analytics

## Testing the Integration

1. Update the backend URL in `api_config.dart`
2. Run the app and try the iris analysis feature
3. Check the debug console for API call logs
4. Verify that images are being sent and responses received

## Troubleshooting

### Common Issues:
1. **Connection Timeout**: Increase timeout values in `ApiConfig`
2. **Invalid Response**: Check backend response format matches expected structure
3. **Authentication Errors**: Verify Firebase user is logged in
4. **Image Upload Fails**: Check image file size and format

### Debug Logs:
The app logs detailed information about API calls. Check the Flutter debug console for:
- API request URLs
- Response status codes
- Error messages
- Response data

## Security Considerations
- Use HTTPS for all API communications
- Validate user authentication on backend
- Implement rate limiting
- Sanitize uploaded images
