import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pfa_mobile/services/auth_service.dart';
import 'package:pfa_mobile/config/theme.dart';
import 'package:pfa_mobile/config/routes.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add performance logging
  debugPrint('App startup: initializing...');
  final startTime = DateTime.now();
  
  try {
    debugPrint('App startup: initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Verify Firebase Storage is accessible
    try {
      final storageRef = FirebaseStorage.instance.ref().child('test');
      debugPrint('Firebase Storage initialized successfully');
    } catch (storageError) {
      debugPrint('Firebase Storage initialization warning: $storageError');
      // Continue anyway, we'll handle storage errors in the app
    }
    
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  final endTime = DateTime.now();
  debugPrint('App startup completed in ${endTime.difference(startTime).inMilliseconds}ms');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Iris Analysis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.accueil,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        navigatorKey: AppRoutes.navigatorKey,
        scaffoldMessengerKey: AppRoutes.scaffoldKey,
      ),
    );
  }
}
