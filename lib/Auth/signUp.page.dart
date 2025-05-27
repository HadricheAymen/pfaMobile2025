import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _showPassword = false;
  bool _termsAccepted = false;
  final _formKey = GlobalKey<FormState>();

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B3CFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Conditions d\'utilisation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '1. Acceptation des conditions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'En accédant et en utilisant l\'application IrisLock, vous acceptez d\'être lié par ces conditions. Si vous n\'acceptez pas ces conditions, vous ne devez pas utiliser l\'application.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '2. Utilisation du service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Vous acceptez d\'utiliser le service conformément à toutes les lois et réglementations applicables. Vous êtes responsable de maintenir la confidentialité de votre compte.',
                          style: TextStyle(fontSize: 14),
                        ),
                        // Add more sections as needed
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B3CFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Politique de confidentialité',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '1. Collecte des données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nous collectons certaines informations personnelles lorsque vous utilisez notre application, notamment votre nom, votre adresse e-mail et vos données biométriques pour l\'authentification.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '2. Utilisation des données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Vos données sont utilisées uniquement pour fournir et améliorer nos services. Nous ne vendons pas vos informations personnelles à des tiers.',
                          style: TextStyle(fontSize: 14),
                        ),
                        // Add more sections as needed
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

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
              // Back Button
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    label: const Text(
                      'Retour',
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Header
                                Text(
                                  'Inscription',
                                  style: TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontSize: size.width *
                                        (isSmallScreen ? 0.06 : 0.04),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Créez votre compte IrisLock',
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

                                // First Name & Last Name Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Prénom',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: size.width *
                                                  (isSmallScreen
                                                      ? 0.035
                                                      : 0.025),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Le prénom est requis';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Votre prénom',
                                              prefixIcon: const Icon(
                                                  Icons.person_outline),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.04),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nom',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: size.width *
                                                  (isSmallScreen
                                                      ? 0.035
                                                      : 0.025),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Le nom est requis';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Votre nom',
                                              prefixIcon: const Icon(
                                                  Icons.person_outline),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),

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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'L\'email est requis';
                                        }
                                        if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Veuillez entrer un email valide';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Votre adresse email',
                                        prefixIcon:
                                            const Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                      obscureText: !_showPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Le mot de passe est requis';
                                        }
                                        if (value.length < 6) {
                                          return 'Le mot de passe doit contenir au moins 6 caractères';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Créez un mot de passe',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Confirm Password Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Confirmer le mot de passe',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: size.width *
                                            (isSmallScreen ? 0.035 : 0.025),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      obscureText: !_showPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'La confirmation du mot de passe est requise';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Confirmez votre mot de passe',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Terms Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _termsAccepted,
                                      onChanged: (value) {
                                        setState(() {
                                          _termsAccepted = value ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'J\'accepte les ',
                                          style: TextStyle(
                                            fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'conditions d\'utilisation',
                                              style: const TextStyle(
                                                color: Color(0xFF0B3CFD),
                                                decoration: TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = _showTermsDialog,
                                            ),
                                            const TextSpan(text: ' et la '),
                                            TextSpan(
                                              text: 'politique de confidentialité',
                                              style: const TextStyle(
                                                color: Color(0xFF0B3CFD),
                                                decoration: TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = _showPrivacyDialog,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.03),

                                // Sign Up Button
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
                                    onPressed: _termsAccepted
                                        ? () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // Handle sign up
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      'Créer un compte',
                                      style: TextStyle(
                                        fontSize: size.width *
                                            (isSmallScreen ? 0.04 : 0.03),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),

                                // Social Sign Up
                                Text(
                                  'Ou inscrivez-vous avec',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: size.width *
                                        (isSmallScreen ? 0.035 : 0.025),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Social Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: Image.asset(
                                          'assets/google-icon.png',
                                          height: 24,
                                        ),
                                        label: const Text('Google'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.facebook,
                                            color: Color(0xFF1877F2)),
                                        label: const Text('Facebook'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.03),

                                // Sign In Link
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/signin'),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Vous avez déjà un compte? ',
                                      style: TextStyle(
                                        fontSize: size.width *
                                            (isSmallScreen ? 0.035 : 0.025),
                                        color: Colors.black54,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Connectez-vous',
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
}
