import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

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

    // // Simulate AI analysis with delay (replace with actual API call)
    // await Future.delayed(const Duration(seconds: 3));

    // // Generate random results for demonstration
    // final types = ['Fleur', 'Bijou', 'Flux', 'Shaker'];
    // final routes = ['fleur', 'bijou', 'flux', 'shaker'];

    // // Generate random percentages that total 100%
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
    final size = MediaQuery.of(context).size;

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
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: size.height * 0.03),
                _buildImageUploadSection(size),
                SizedBox(height: size.height * 0.03),
                _buildForm(size),
                SizedBox(height: size.height * 0.03),
                _buildAnalyzeButton(),
                if (_analysisResult != null) ...[
                  SizedBox(height: size.height * 0.03),
                  _buildResults(size),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Analysez votre iris',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Découvrez votre type d\'iris grâce à notre IA',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          width: 80,
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

  Widget _buildImageUploadSection(Size size) {
    return Container(
      height: size.height * 0.3,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(_image!, fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Prenez une photo de votre iris'),
                const SizedBox(height: 16),
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

  Widget _buildForm(Size size) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Âge',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender.isEmpty ? null : _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Genre',
              border: OutlineInputBorder(),
            ),
            items: ['Homme', 'Femme', 'Autre']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentsController,
            decoration: const InputDecoration(
              labelText: 'Commentaires',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _image == null || _isAnalyzing ? null : _analyzeIris,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isAnalyzing
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text('Analyse en cours...'),
              ],
            )
          : const Text('Analyser mon iris'),
    );
  }

  Widget _buildResults(Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résultat de l\'analyse',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const Text(
            'Votre type d\'iris principal :',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            _analysisResult!['primaryType'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPercentageBar('Fleur', _analysisResult!['fleurPercentage']),
          _buildPercentageBar('Bijou', _analysisResult!['bijouPercentage']),
          _buildPercentageBar('Flux', _analysisResult!['fluxPercentage']),
          _buildPercentageBar('Shaker', _analysisResult!['shakerPercentage']),
        ],
      ),
    );
  }

  Widget _buildPercentageBar(String label, int percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $percentage%'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorForType(label),
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
