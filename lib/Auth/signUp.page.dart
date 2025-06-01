import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController email = new TextEditingController();
  TextEditingController firstName = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController pwd = new TextEditingController();
  TextEditingController repeatpwd = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showTermsDialog() {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width < 650 ? size.width * 0.95 : 600,
              maxHeight: size.height < 700 ? size.height * 0.85 : 600,
            ),
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 20),
                        Text(
                          '3. Propriété intellectuelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tous les droits de propriété intellectuelle liés à l\'application IrisLock sont la propriété exclusive de notre entreprise. Aucune partie de l\'application ne peut être reproduite sans notre autorisation écrite préalable.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '4. Limitation de responsabilité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Notre application est fournie "telle quelle" sans garantie d\'aucune sorte. Nous ne serons pas responsables des dommages directs, indirects, accessoires ou consécutifs résultant de l\'utilisation de notre application.',
                          style: TextStyle(fontSize: 14),
                        ),
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
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width < 650 ? size.width * 0.95 : 600,
              maxHeight: size.height < 700 ? size.height * 0.85 : 600,
            ),
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
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Politique de confidentialité',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 20),
                        Text(
                          '3. Protection des données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles pour protéger vos données personnelles contre tout accès non autorisé, perte ou altération.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '4. Vos droits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Vous avez le droit d\'accéder à vos données personnelles, de les rectifier, de les supprimer ou d\'en limiter le traitement. Vous pouvez également vous opposer au traitement de vos données et exercer votre droit à la portabilité des données.',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '5. Conservation des données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nous conservons vos données personnelles aussi longtemps que nécessaire pour fournir nos services ou pour respecter nos obligations légales.',
                          style: TextStyle(fontSize: 14),
                        ),
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
                                isSmallScreen
                                    ? Column(
                                        children: [
                                          // Prénom
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prénom',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: size.width * 0.035,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: firstName,
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
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.02),
                                          // Nom
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nom',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: size.width * 0.035,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: lastName,
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
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
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
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  controller: firstName,
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
                                                          BorderRadius.circular(
                                                              12),
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
                                                    fontSize:
                                                        size.width * 0.025,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  controller: lastName,
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
                                                          BorderRadius.circular(
                                                              12),
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
                                      controller: email,
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
                                      controller: pwd,
                                      obscureText: !_showPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Le mot de passe est requis';
                                        }
                                        if (value.length < 6) {
                                          return 'contenir au moins 6 caractères';
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
                                      controller: repeatpwd,
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
                                            fontSize: size.width *
                                                (isSmallScreen ? 0.035 : 0.025),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'conditions d\'utilisation',
                                              style: const TextStyle(
                                                color: Color(0xFF0B3CFD),
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = _showTermsDialog,
                                            ),
                                            const TextSpan(text: ' et la '),
                                            TextSpan(
                                              text:
                                                  'politique de confidentialité',
                                              style: const TextStyle(
                                                color: Color(0xFF0B3CFD),
                                                decoration:
                                                    TextDecoration.underline,
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
                                              _createUserWithEmailAndPassword();
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

  Future<void> _createUserWithEmailAndPassword() async {
    if (pwd.text.trim() != repeatpwd.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas.')),
      );
      return;
    }
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pwd.text.trim(),
      );
      await credential.user!.updateDisplayName('${firstName.text.trim()} ${lastName.text.trim()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès!')),
      );
      Navigator.pushReplacementNamed(context, '/accueil');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Un compte existe déjà pour cet email.';
      } else {
        message = 'Erreur lors de la création du compte.';
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
