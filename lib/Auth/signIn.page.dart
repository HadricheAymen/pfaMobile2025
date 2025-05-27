import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back to Home Button
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/accueil'),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    label: const Text(
                      'Retour à l\'accueil',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      children: [
                        // Auth Card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(size.width * 0.06),
                          child: Column(
                            children: [
                              // Header
                              Text(
                                'Connexion',
                                style: TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: size.width *
                                      (isSmallScreen ? 0.06 : 0.04),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Accédez à votre compte IrisLock',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: size.width *
                                      (isSmallScreen ? 0.035 : 0.025),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                width: 60,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF8A4F),
                                      Color(0xFF4F8AFF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              SizedBox(height: size.height * 0.04),

                              // Email Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.035 : 0.025),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: email,
                                    decoration: InputDecoration(
                                      hintText: 'Votre adresse email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),

                              // Password Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mot de passe',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.035 : 0.025),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: password,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Votre mot de passe',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      suffixIcon:
                                          const Icon(Icons.visibility_off),
                                    ),
                                  ),
                                ],
                              ),

                              // Remember Me & Forgot Password
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02,
                                  horizontal: size.width * 0.02,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth > 400) {
                                      // For wider screens - horizontal layout
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildRememberMeSection(
                                              size, isSmallScreen),
                                          _buildForgotPasswordButton(
                                              size, isSmallScreen),
                                        ],
                                      );
                                    } else {
                                      // For narrow screens - vertical layout
                                      return const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //   _buildRememberMeSection(
                                          //       size, isSmallScreen),
                                          //   SizedBox(height: size.height * 0.01),
                                          //   _buildForgotPasswordButton(
                                          //       size, isSmallScreen),
                                          //
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: size.height * 0.06,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B3CFD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    signInWithEmailAndPassword(
                                        context, email, password);
                                  },
                                  child: Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.04 : 0.03),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),

                              // Sign Up Link
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/signup'),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Vous n\'avez pas de compte? ',
                                    style: TextStyle(
                                      fontSize: size.width *
                                          (isSmallScreen ? 0.035 : 0.025),
                                      color: Colors.black54,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Inscrivez-vous',
                                        style: TextStyle(
                                          color: Color(0xFF0B3CFD),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeSection(Size size, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: isSmallScreen ? 0.9 : 1.0,
          child: SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: false,
              onChanged: (value) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          'Se souvenir de moi',
          style: TextStyle(
            fontSize: size.width * (isSmallScreen ? 0.032 : 0.022),
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton(Size size, bool isSmallScreen) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02,
          vertical: size.height * 0.01,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Mot de passe oublié?',
        style: TextStyle(
          color: const Color(0xFF0B3CFD),
          fontSize: size.width * (isSmallScreen ? 0.032 : 0.022),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> signInWithEmailAndPassword(BuildContext context,
      TextEditingController email, TextEditingController password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      // On success, show a message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie!')),
      );
      // Optionally navigate to another screen
      Navigator.pushReplacementNamed(context, '/accueil');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé pour cet email.';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect.';
      } else {
        message = 'Erreur de connexion.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
