import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Imagehandler {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage(BuildContext context) async {
    try {
      // pick image from gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800.0, imageQuality: 85);

      if(image == null) return null;

      // show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      // convert to Base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      // save to localStorage
      await _saveImageToStorage(base64String);

      // close loading dialog
      if(context.mounted) Navigator.pop(context);

      // show success message
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image saved successfully')));
      }

      return base64String;
    } catch (e) {
      if(context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  // save Based64 image string to SharedPreferences
  static Future<void> _saveImageToStorage(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', base64Image);
  }

  // Retrieve saved image from SharedPreferences
  static Future<Image?> getSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString('user_image');
    if (base64Image == null || base64Image.isEmpty) return null;

    return Image.memory(
      base64Decode(base64Image),
      fit: BoxFit.cover, 
      errorBuilder: (_, __, ___,) => const Icon(Icons.error),
    );
  }

  // Clears saved image 
  static Future<void> clearSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
  }
}