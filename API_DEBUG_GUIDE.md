# API Debug Guide - Status Code 400 Error

## Current Issue
You're getting "Server returned status code 400" when clicking "Analyser mon iris". This indicates a **Bad Request** error.

## Debugging Steps

### Step 1: Check Debug Console
I've added detailed logging to the API calls. When you click "Analyser mon iris", check the Flutter debug console for these logs:

```
🔍 Starting iris prediction...
📁 Image file path: /path/to/image
📏 Image file size: 12345 bytes
👤 User ID: user123
🌐 API URL: https://carefree-warmth-production.up.railway.app/api/predict-efficient
📋 Request headers: {Connection: keep-alive, Accept: application/json}
📝 Request fields: {user_id: user123}
📎 Added file: iris_image.jpg, size: 12345 bytes
🚀 Sending request...
📨 Response status: 400
📨 Response headers: {...}
📨 Response body: {"error": "detailed error message"}
```

### Step 2: Common 400 Error Causes

#### A. Wrong Field Name
Your backend might expect a different field name for the image:
- Current: `image`
- Try: `file`, `iris_image`, `photo`

#### B. Missing Required Fields
Your backend might require additional fields:
- `Content-Type` header
- Specific image format
- Additional metadata

#### C. Image Size/Format Issues
- Image too large (>10MB)
- Wrong format (not JPEG/PNG)
- Corrupted image data

#### D. Authentication Issues
- Missing API key
- Wrong user ID format
- Invalid authentication headers

### Step 3: Test Backend Directly

#### Test Health Endpoint
```bash
curl https://carefree-warmth-production.up.railway.app/health
```

#### Test Prediction Endpoint
```bash
curl -X POST \
  https://carefree-warmth-production.up.railway.app/api/predict-efficient \
  -F "image=@test_image.jpg" \
  -F "user_id=test123"
```

### Step 4: Check Backend Documentation

Look for:
1. **Required fields**: What fields does `/api/predict-efficient` expect?
2. **Image requirements**: Size limits, format requirements
3. **Authentication**: Does it need API keys or special headers?
4. **Request format**: Multipart form-data vs JSON

### Step 5: Common Fixes

#### Fix 1: Change Image Field Name
If backend expects `file` instead of `image`:
```dart
// In lib/config/api_config.dart
static const String imageFieldName = 'file'; // Change from 'image'
```

#### Fix 2: Add Content-Type Header
```dart
// In API service
request.headers['Content-Type'] = 'multipart/form-data';
```

#### Fix 3: Remove User ID (if not required)
```dart
// Comment out user ID if backend doesn't expect it
// if (userId != null) {
//   request.fields[ApiConfig.userIdFieldName] = userId;
// }
```

#### Fix 4: Use Different Endpoint
Try the standard prediction endpoint instead:
```dart
// In iris form, change:
final leftIrisResult = await ApiService.predictIrisStandard(_leftIrisImage!);
```

## Next Steps

1. **Run the app** and click "Analyser mon iris"
2. **Check the debug console** for the detailed logs
3. **Share the exact error message** from the response body
4. **Test the backend directly** using curl commands
5. **Check your backend documentation** for the exact API requirements

## Quick Test

I've added a health check before the prediction. If you see:
- ✅ "Backend health check passed" → Backend is accessible
- ❌ "Backend health check failed" → Backend connectivity issue

## Most Likely Solutions

Based on common 400 errors:

1. **Wrong field name**: Backend expects `file` not `image`
2. **Missing Content-Type**: Need proper multipart headers
3. **User ID format**: Backend doesn't expect user_id field
4. **Image format**: Backend only accepts specific formats

Try these fixes in order and check the debug logs after each attempt.
