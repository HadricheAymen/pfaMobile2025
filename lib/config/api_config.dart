class ApiConfig {
  // Base URL for the API
  static const String baseUrl = 'https://carefree-warmth-production.up.railway.app';
  
  // Prediction endpoints
  static const String predictionUrl = '$baseUrl/api/predict-mobilenet'; // Changed to match the test HTML
  static const String efficientNetUrl = '$baseUrl/api/predict-efficient';
  static const String extractIrisUrl = '$baseUrl/api/extract-iris';
  static const String enhancedAnalysisUrl = '$baseUrl/api/analyze-iris-enhanced';
  
  // Health check endpoint
  static const String healthUrl = '$baseUrl/health';
  
  // Debug endpoint
  static const String debugUrl = '$baseUrl/debug';
  
  // Force download endpoint
  static const String forceDownloadUrl = '$baseUrl/api/force-download';
  
  // Request timeouts
  static const Duration standardRequestTimeout = Duration(seconds: 30);
  static const Duration longRequestTimeout = Duration(seconds: 120);
  static const Duration extraLongRequestTimeout = Duration(seconds: 180);
  
  // Use the extra long timeout for image processing endpoints
  static Future<http.Response> postWithExtendedTimeout(Uri url, dynamic body) async {
    return await http.post(
      url,
      body: body,
    ).timeout(extraLongRequestTimeout);
  }
  
  // Field names for iris extraction
  static const String leftIrisField = 'left_iris';
  static const String rightIrisField = 'right_iris';
}


