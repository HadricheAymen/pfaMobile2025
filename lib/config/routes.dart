import 'package:flutter/material.dart';
import 'package:pfa_mobile/Auth/signIn.page.dart';
import 'package:pfa_mobile/Auth/signUp.page.dart';
import 'package:pfa_mobile/screens/accueil/accueil_screen.dart';
import 'package:pfa_mobile/screens/accueil/suivantacc_screen.dart';
import 'package:pfa_mobile/screens/accueil/typeiris_screen.dart';
import 'package:pfa_mobile/screens/accueil/iris2_screen.dart';
import 'package:pfa_mobile/screens/iris_types/bijou_screen.dart';
import 'package:pfa_mobile/screens/iris_types/fleur_screen.dart';
import 'package:pfa_mobile/screens/iris_types/flux_screen.dart';
import 'package:pfa_mobile/screens/iris_types/iris_diversity_screen.dart';
import 'package:pfa_mobile/screens/iris_types/shaker_screen.dart';
import 'package:pfa_mobile/screens/personality_test/personality_test_screen.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // Define all route names as constants
  static const String accueil = '/accueil';
  static const String signin = '/signin'; // Changed from login to signin
  static const String signup = '/signup';
  static const String suivantacc = '/suivantacc';
  static const String typeiris = '/typeiris';
  static const String iris2 = '/iris2';
  static const String irisDiversity = '/iris-diversity';
  static const String fleur = '/fleur';
  static const String bijou = '/bijou';
  static const String flux = '/flux';
  static const String shaker = '/shaker';
  static const String personalityTest = '/personality-test';
  static const String dashboard = '/dashboard';

  // Define all routes
  static Map<String, WidgetBuilder> get routes => {
        accueil: (context) => const AccueilScreen(),
        signin: (context) => const SignInPage(),
        signup: (context) => const SignUpPage(),
        suivantacc: (context) => const SuivantaccScreen(),
        typeiris: (context) => const TypeirisScreen(),
        iris2: (context) => const Iris2Screen(),
        irisDiversity: (context) => const IrisDiversityScreen(),
        fleur: (context) => const FleurScreen(),
        bijou: (context) => const BijouScreen(),
        flux: (context) => const FluxScreen(),
        shaker: (context) => const ShakerScreen(),
        personalityTest: (context) => const PersonalityTestScreen(),
        // dashboard: (context) => const DashboardScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle dynamic routes here if needed
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('Route ${settings.name} not found'),
        ),
      ),
    );
  }
}

