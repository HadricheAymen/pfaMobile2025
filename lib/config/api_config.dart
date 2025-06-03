class ApiConfig {
  // Backend API Configuration
  // Update this URL with your actual backend domain
  static const String baseUrl =
      'https://carefree-warmth-production.up.railway.app';

  // API Endpoints based on your backend specification
  static const String healthEndpoint = '/health';
  static const String efficientPredictionEndpoint = '/api/predict-efficient';
  static const String mobilenetPredictionEndpoint = '/api/predict-mobilenet';
  static const String predictionEndpoint = '/api/predict';
  static const String irisExtractionEndpoint = '/api/extract-iris';
  static const String enhancedAnalysisEndpoint = '/api/analyze-iris-enhanced';

  // Full URLs
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get efficientPredictionUrl =>
      '$baseUrl$efficientPredictionEndpoint';
  static String get mobilenetPredictionUrl =>
      '$baseUrl$mobilenetPredictionEndpoint';
  static String get predictionUrl => '$baseUrl$predictionEndpoint';
  static String get irisExtractionUrl => '$baseUrl$irisExtractionEndpoint';
  static String get enhancedAnalysisUrl => '$baseUrl$enhancedAnalysisEndpoint';

  // Request configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration longRequestTimeout = Duration(minutes: 2);

  // API Response format expectations
  // Backend expects 'image' field based on error "Aucune image fournie"
  static const String imageFieldName = 'image'; // Backend expects 'image' field
  static const String userIdFieldName = 'user_id';

  // Expected response fields from your backend
  static const String leftIrisField = 'left_iris';
  static const String rightIrisField = 'right_iris';
  static const String primaryTypeField = 'primary_type';
  static const String confidenceField = 'confidence';
  static const String errorField = 'error';
}
