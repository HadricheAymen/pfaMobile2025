import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/responsive_utils.dart';

class IrisForm extends StatefulWidget {
  const IrisForm({Key? key}) : super(key: key);

  @override
  _IrisFormState createState() => _IrisFormState();
}

class _IrisFormState extends State<IrisForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (FirebaseAuth.instance.currentUser == null) {
      // Delay navigation to avoid build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/signup');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Veuillez vous connecter pour analyser votre iris')),
        );
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _analyzeIris() async {
    // if (_image == null) return;

    // setState(() {
    //   _isAnalyzing = true;
    // });

    // Simulate AI analysis with delay (replace with actual API call)
    // await Future.delayed(const Duration(seconds: 3));

    // Generate random results for demonstration
    // final types = ['Fleur', 'Bijou', 'Flux', 'Shaker'];
    // final routes = ['fleur', 'bijou', 'flux', 'shaker'];

    // Generate random percentages that total 100%
    // final random = DateTime.now().millisecondsSinceEpoch;
    // final fleur = random % 100;
    // final bijou = random % (100 - fleur);
    // final flux = random % (100 - fleur - bijou);
    // final shaker = 100 - fleur - bijou - flux;

    // final percentages = [fleur, bijou, flux, shaker];
    // final maxIndex =
    //     percentages.indexOf(percentages.reduce((a, b) => a > b ? a : b));

    // setState(() {
    //   _analysisResult = {
    //     'primaryType': types[maxIndex],
    //     'primaryTypeRoute': routes[maxIndex],
    //     'fleurPercentage': fleur,
    //     'bijouPercentage': bijou,
    //     'fluxPercentage': flux,
    //     'shakerPercentage': shaker,
    //   };
    //   _isAnalyzing = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Padding(
            padding: context.responsivePadding(
              mobilePortrait: 0.05,
              mobileLandscape: 0.04,
              tabletPortrait: 0.06,
              tabletLandscape: 0.05,
            ),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(
                    height: context.responsiveSpacing(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.02,
                  tabletPortrait: 0.04,
                  tabletLandscape: 0.025,
                )),
                _buildImageSection(context),
                SizedBox(
                    height: context.responsiveSpacing(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.02,
                  tabletPortrait: 0.04,
                  tabletLandscape: 0.025,
                )),
                _buildForm(context),
                SizedBox(
                    height: context.responsiveSpacing(
                  mobilePortrait: 0.03,
                  mobileLandscape: 0.02,
                  tabletPortrait: 0.04,
                  tabletLandscape: 0.025,
                )),
                _buildAnalyzeButton(context),
                if (_analysisResult != null) ...[
                  SizedBox(
                      height: context.responsiveSpacing(
                    mobilePortrait: 0.03,
                    mobileLandscape: 0.02,
                    tabletPortrait: 0.04,
                    tabletLandscape: 0.025,
                  )),
                  _buildResults(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Analysez votre iris',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              mobilePortrait: 0.07,
              mobileLandscape: 0.055,
              tabletPortrait: 0.05,
              tabletLandscape: 0.04,
              desktopPortrait: 0.035,
              desktopLandscape: 0.03,
            ),
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        SizedBox(
            height: context.responsiveSpacing(
          mobilePortrait: 0.01,
          mobileLandscape: 0.005,
          tabletPortrait: 0.015,
          tabletLandscape: 0.008,
        )),
        Text(
          'Découvrez votre type d\'iris grâce à notre IA',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              mobilePortrait: 0.045,
              mobileLandscape: 0.035,
              tabletPortrait: 0.035,
              tabletLandscape: 0.028,
              desktopPortrait: 0.025,
              desktopLandscape: 0.02,
            ),
            color: Colors.grey[600],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.01,
              tabletPortrait: 0.025,
              tabletLandscape: 0.015,
            ),
          ),
          width: context.responsiveWidth(
            mobilePortrait: 0.18,
            mobileLandscape: 0.15,
            tabletPortrait: 0.15,
            tabletLandscape: 0.12,
            desktopPortrait: 0.12,
            desktopLandscape: 0.1,
          ),
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.blue, Colors.green, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: context.responsiveHeight(
        mobilePortrait: 0.3,
        mobileLandscape: 0.4, // Increased from 0.25 to 0.4 for landscape
        tabletPortrait: 0.35,
        tabletLandscape: 0.45, // Increased from 0.28 to 0.45 for landscape
        desktopPortrait: 0.4,
        desktopLandscape: 0.5, // Increased from 0.3 to 0.5 for landscape
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: _image != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => _showImageSourceOptions(),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min, // Add this to minimize vertical space
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: context.responsiveFontSize(
                    mobilePortrait: 0.12,
                    mobileLandscape: 0.07, // Reduce icon size in landscape
                    tabletPortrait: 0.1,
                    tabletLandscape: 0.06, // Reduce icon size in landscape
                    desktopPortrait: 0.08,
                    desktopLandscape: 0.05,
                  ),
                  color: Colors.grey[400],
                ),
                SizedBox(
                    height: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.005, // Reduce spacing in landscape
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.01, // Reduce spacing in landscape
                )),
                Text(
                  'Prenez une photo de votre iris',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      mobilePortrait: 0.04,
                      mobileLandscape: 0.028, // Smaller font in landscape
                      tabletPortrait: 0.035,
                      tabletLandscape: 0.025, // Smaller font in landscape
                    ),
                  ),
                ),
                SizedBox(
                    height: context.responsiveSpacing(
                  mobilePortrait: 0.02,
                  mobileLandscape: 0.01,
                  tabletPortrait: 0.025,
                  tabletLandscape: 0.015,
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Caméra'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une nouvelle photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Âge',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          DropdownButtonFormField<String>(
            value: _selectedGender.isEmpty ? null : _selectedGender,
            decoration: InputDecoration(
              labelText: 'Genre',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            items: ['Homme', 'Femme', 'Autre']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            mobilePortrait: 0.045,
                            mobileLandscape: 0.035,
                            tabletPortrait: 0.035,
                            tabletLandscape: 0.028,
                            desktopPortrait: 0.03,
                            desktopLandscape: 0.025,
                          ),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
            },
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.018,
            mobileLandscape: 0.015,
            tabletPortrait: 0.02,
            tabletLandscape: 0.016,
          )),
          TextFormField(
            controller: _commentsController,
            decoration: InputDecoration(
              labelText: 'Commentaires',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.responsiveSpacing(
                  mobilePortrait: 0.018,
                  mobileLandscape: 0.015,
                  tabletPortrait: 0.02,
                  tabletLandscape: 0.016,
                ),
                horizontal: context.responsiveSpacing(
                  mobilePortrait: 0.04,
                  mobileLandscape: 0.035,
                  tabletPortrait: 0.045,
                  tabletLandscape: 0.038,
                ),
              ),
            ),
            maxLines: 3,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.028,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    return SizedBox(
      width: context.responsiveWidth(
        mobilePortrait: 0.8,
        mobileLandscape: 0.6,
        tabletPortrait: 0.6,
        tabletLandscape: 0.5,
        desktopPortrait: 0.4,
        desktopLandscape: 0.35,
      ),
      child: ElevatedButton(
        onPressed: _image == null || _isAnalyzing ? null : _analyzeIris,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing(
              mobilePortrait: 0.08,
              mobileLandscape: 0.06,
              tabletPortrait: 0.1,
              tabletLandscape: 0.08,
            ),
            vertical: context.responsiveSpacing(
              mobilePortrait: 0.02,
              mobileLandscape: 0.015,
              tabletPortrait: 0.025,
              tabletLandscape: 0.018,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isAnalyzing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: context.responsiveFontSize(
                      mobilePortrait: 0.05,
                      mobileLandscape: 0.04,
                      tabletPortrait: 0.04,
                      tabletLandscape: 0.035,
                    ),
                    height: context.responsiveFontSize(
                      mobilePortrait: 0.05,
                      mobileLandscape: 0.04,
                      tabletPortrait: 0.04,
                      tabletLandscape: 0.035,
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(
                      width: context.responsiveSpacing(
                    mobilePortrait: 0.02,
                    mobileLandscape: 0.015,
                    tabletPortrait: 0.025,
                    tabletLandscape: 0.018,
                  )),
                  Text(
                    'Analyse en cours...',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        mobilePortrait: 0.045,
                        mobileLandscape: 0.035,
                        tabletPortrait: 0.035,
                        tabletLandscape: 0.03,
                        desktopPortrait: 0.03,
                        desktopLandscape: 0.025,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                'Analyser mon iris',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    mobilePortrait: 0.05,
                    mobileLandscape: 0.04,
                    tabletPortrait: 0.04,
                    tabletLandscape: 0.035,
                    desktopPortrait: 0.035,
                    desktopLandscape: 0.03,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    return Container(
      padding: context.responsivePadding(
        mobilePortrait: 0.04,
        mobileLandscape: 0.035,
        tabletPortrait: 0.045,
        tabletLandscape: 0.04,
        desktopPortrait: 0.05,
        desktopLandscape: 0.045,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résultat de l\'analyse',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.06,
                mobileLandscape: 0.048,
                tabletPortrait: 0.05,
                tabletLandscape: 0.042,
                desktopPortrait: 0.04,
                desktopLandscape: 0.035,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            'Votre type d\'iris principal :',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.03,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          Text(
            _analysisResult!['primaryType'],
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.08,
                mobileLandscape: 0.065,
                tabletPortrait: 0.065,
                tabletLandscape: 0.055,
                desktopPortrait: 0.055,
                desktopLandscape: 0.045,
              ),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.02,
            mobileLandscape: 0.015,
            tabletPortrait: 0.025,
            tabletLandscape: 0.018,
          )),
          _buildPercentageBar(
              context, 'Fleur', _analysisResult!['fleurPercentage']),
          _buildPercentageBar(
              context, 'Bijou', _analysisResult!['bijouPercentage']),
          _buildPercentageBar(
              context, 'Flux', _analysisResult!['fluxPercentage']),
          _buildPercentageBar(
              context, 'Shaker', _analysisResult!['shakerPercentage']),
        ],
      ),
    );
  }

  Widget _buildPercentageBar(
      BuildContext context, String label, int percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveSpacing(
          mobilePortrait: 0.01,
          mobileLandscape: 0.008,
          tabletPortrait: 0.012,
          tabletLandscape: 0.01,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $percentage%',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                mobilePortrait: 0.045,
                mobileLandscape: 0.035,
                tabletPortrait: 0.035,
                tabletLandscape: 0.03,
                desktopPortrait: 0.03,
                desktopLandscape: 0.025,
              ),
            ),
          ),
          SizedBox(
              height: context.responsiveSpacing(
            mobilePortrait: 0.004,
            mobileLandscape: 0.003,
            tabletPortrait: 0.005,
            tabletLandscape: 0.004,
          )),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForType(label),
            ),
            minHeight: context.responsiveSpacing(
              mobilePortrait: 0.012,
              mobileLandscape: 0.01,
              tabletPortrait: 0.014,
              tabletLandscape: 0.012,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Fleur':
        return Colors.purple;
      case 'Bijou':
        return Colors.blue;
      case 'Flux':
        return Colors.green;
      case 'Shaker':
        return Colors.orange;
      default:
        return Colors.grey;
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
}


