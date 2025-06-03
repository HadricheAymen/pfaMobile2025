import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfa_mobile/services/api_service.dart';
import 'package:pfa_mobile/services/personality_class_service.dart';

class EnhancedIrisForm extends StatefulWidget {
  const EnhancedIrisForm({Key? key}) : super(key: key);

  @override
  State<EnhancedIrisForm> createState() => _EnhancedIrisFormState();
}

class _EnhancedIrisFormState extends State<EnhancedIrisForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Enhanced iris analysis state
  File? _leftIrisImage;
  File? _rightIrisImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _personalityDescription;

  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';
  final TextEditingController _commentsController = TextEditingController();

  // UI state
  bool _showResults = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  // Enhanced iris analysis method
  Future<void> _analyzeIrisEnhanced() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_leftIrisImage == null || _rightIrisImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les deux images d\'iris'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
      _personalityDescription = null;
    });

    try {
      // Prepare user profile data
      final userProfile = {
        'name': _nameController.text,
        'email': _emailController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'comments': _commentsController.text,
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

      // Call enhanced iris analysis API
      final result = await ApiService.analyzeIrisEnhanced(
        leftIrisImage: _leftIrisImage!,
        rightIrisImage: _rightIrisImage!,
        userProfile: userProfile,
      );

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'];
          _isAnalyzing = false;
        });
        return;
      }

      // Get primary personality class from API response
      final primaryClass = result['primary_class'];
      if (primaryClass == null) {
        setState(() {
          _errorMessage = 'Aucune classe de personnalité retournée par l\'API';
          _isAnalyzing = false;
        });
        return;
      }

      // Fetch personality class description from Firestore
      final personalityDescription =
          await PersonalityClassService.findPersonalityClass(primaryClass);

      setState(() {
        _analysisResult = result;
        _personalityDescription = personalityDescription ??
            PersonalityClassService.createFallbackDescription(primaryClass);
        _showResults = true;
        _isAnalyzing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analyse terminée! Votre type: $primaryClass'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'analyse: $e';
        _isAnalyzing = false;
      });
    }
  }

  // Image picker methods
  Future<void> _pickLeftIrisImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _leftIrisImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickRightIrisImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _rightIrisImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _leftIrisImage = null;
      _rightIrisImage = null;
      _analysisResult = null;
      _personalityDescription = null;
      _showResults = false;
      _errorMessage = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.06),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      iconSize: size.width * 0.06,
                    ),
                    Expanded(
                      child: Text(
                        'Analyse d\'Iris Avancée',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: size.width * 0.06),
                  ],
                ),

                SizedBox(height: size.height * 0.03),

                if (_showResults)
                  _buildResultsCard(context, size, isSmallScreen)
                else
                  _buildFormCard(context, size, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, Size size, bool isSmallScreen) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: size.width * (isSmallScreen ? 0.05 : 0.035),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // User form fields
              _buildUserFormFields(size, isSmallScreen),

              SizedBox(height: size.height * 0.03),

              // Iris images section
              Text(
                'Images d\'iris',
                style: TextStyle(
                  fontSize: size.width * (isSmallScreen ? 0.05 : 0.035),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              _buildIrisImageSection(size, isSmallScreen),

              SizedBox(height: size.height * 0.03),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize:
                                size.width * (isSmallScreen ? 0.035 : 0.025),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ],

              // Analyze button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeIrisEnhanced,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4FFF),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isAnalyzing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.05,
                              height: size.width * 0.05,
                              child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              'Analyse en cours...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    size.width * (isSmallScreen ? 0.04 : 0.03),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Analyser les iris',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                size.width * (isSmallScreen ? 0.04 : 0.03),
                            fontWeight: FontWeight.w600,
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

  Widget _buildUserFormFields(Size size, bool isSmallScreen) {
    return Column(
      children: [
        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            return null;
          },
        ),

        SizedBox(height: size.height * 0.02),

        // Email field
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre email';
            }
            if (!value.contains('@')) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),

        SizedBox(height: size.height * 0.02),

        // Age and Gender row
        Row(
          children: [
            // Age field
            Expanded(
              child: TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Âge',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Âge invalide';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(width: size.width * 0.04),

            // Gender dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender.isEmpty ? null : _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                  DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.02),

        // Comments field
        TextFormField(
          controller: _commentsController,
          decoration: InputDecoration(
            labelText: 'Commentaires (optionnel)',
            prefixIcon: const Icon(Icons.comment),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIrisImageSection(Size size, bool isSmallScreen) {
    return Row(
      children: [
        // Left iris image
        Expanded(
          child: _buildIrisImageSelector(
            context: context,
            size: size,
            isSmallScreen: isSmallScreen,
            title: 'Iris gauche',
            imageFile: _leftIrisImage,
            onTap: _pickLeftIrisImage,
          ),
        ),

        SizedBox(width: size.width * 0.04),

        // Right iris image
        Expanded(
          child: _buildIrisImageSelector(
            context: context,
            size: size,
            isSmallScreen: isSmallScreen,
            title: 'Iris droit',
            imageFile: _rightIrisImage,
            onTap: _pickRightIrisImage,
          ),
        ),
      ],
    );
  }

  Widget _buildIrisImageSelector({
    required BuildContext context,
    required Size size,
    required bool isSmallScreen,
    required String title,
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: size.width * (isSmallScreen ? 0.04 : 0.03),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: size.height * 0.015),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: size.height * 0.2,
            decoration: BoxDecoration(
              color: imageFile != null ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: imageFile != null
                    ? const Color(0xFF8A4FFF)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: size.width * (isSmallScreen ? 0.08 : 0.06),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Ajouter image',
                        style: TextStyle(
                          fontSize:
                              size.width * (isSmallScreen ? 0.035 : 0.025),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCard(
      BuildContext context, Size size, bool isSmallScreen) {
    final primaryClass = _analysisResult!['primary_class'];
    final personalityData = _personalityDescription!;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xFF8A4FFF),
                  size: size.width * (isSmallScreen ? 0.06 : 0.04),
                ),
                SizedBox(width: size.width * 0.03),
                Text(
                  'Résultats de l\'analyse',
                  style: TextStyle(
                    fontSize: size.width * (isSmallScreen ? 0.05 : 0.035),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),

            // Personality type display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(size.width * 0.06),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8A4FFF).withValues(alpha: 0.1),
                    const Color(0xFF8A4FFF).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF8A4FFF).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    personalityData['icon'] ?? '👁️',
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.1 : 0.08),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    personalityData['name'] ?? primaryClass,
                    style: TextStyle(
                      fontSize: size.width * (isSmallScreen ? 0.06 : 0.04),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A4FFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.045 : 0.032),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),

            SizedBox(height: size.height * 0.015),

            Text(
              personalityData['description'] ?? 'Description non disponible',
              style: TextStyle(
                fontSize: size.width * (isSmallScreen ? 0.04 : 0.028),
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            // Characteristics
            if (personalityData['characteristics'] != null) ...[
              SizedBox(height: size.height * 0.025),
              Text(
                'Caractéristiques',
                style: TextStyle(
                  fontSize: size.width * (isSmallScreen ? 0.045 : 0.032),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: size.height * 0.015),
              Wrap(
                spacing: size.width * 0.02,
                runSpacing: size.height * 0.01,
                children: (personalityData['characteristics'] as List)
                    .map((characteristic) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8A4FFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8A4FFF)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            characteristic.toString(),
                            style: TextStyle(
                              fontSize:
                                  size.width * (isSmallScreen ? 0.035 : 0.025),
                              color: const Color(0xFF8A4FFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],

            SizedBox(height: size.height * 0.03),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Nouvelle analyse',
                      style: TextStyle(
                        fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to detailed personality page
                      // Navigator.pushNamed(context, '/personality-details', arguments: primaryClass);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4FFF),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'En savoir plus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * (isSmallScreen ? 0.035 : 0.025),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
