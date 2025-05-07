import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Imagehandler {
  static final ImagePicker _picker = ImagePicker();

  // Pick image with option for camera or gallery and save it with a customer-specific key
  static Future<String?> pickAndSaveImage(
    BuildContext context, {
    required String customerId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Pick image from specified source
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600.0, // Reduced max width for better performance
        maxHeight: 600.0, // Added max height to maintain aspect ratio
        imageQuality: 80, // Slightly lower quality for smaller file size
      );

      if (image == null) return null;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Convert to Base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      // Save to SharedPreferences with customer-specific key
      await _saveImageToStorage(customerId, base64String);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }

      return base64String;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  // Save Base64 image string to SharedPreferences with customer-specific key
  static Future<void> _saveImageToStorage(String customerId, String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_image_$customerId', base64Image);
  }

  // Retrieve saved image for a specific customer
  static Future<Image?> getSavedImage(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString('customer_image_$customerId');
    if (base64Image == null || base64Image.isEmpty) return null;

    return Image.memory(
      base64Decode(base64Image),
      fit: BoxFit.cover,
      width: 40, // Match CircleAvatar size
      height: 40,
      errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 40),
    );
  }

  // Clear saved image for a specific customer
  static Future<void> clearSavedImage(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer_image_$customerId');
  }
}



// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Imagehandler {
//   static final ImagePicker _picker = ImagePicker();

//   static Future<String?> pickAndSaveImage(BuildContext context) async {
//     try {
//       // pick image from gallery
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800.0, imageQuality: 85);

//       if(image == null) return null;

//       // show loading dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );
//       // convert to Base64
//       final bytes = await image.readAsBytes();
//       final base64String = base64Encode(bytes);

//       // save to localStorage
//       await _saveImageToStorage(base64String);

//       // close loading dialog
//       if(context.mounted) Navigator.pop(context);

//       // show success message
//       if(context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image saved successfully')));
//       }

//       return base64String;
//     } catch (e) {
//       if(context.mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//       return null;
//     }
//   }

//   // save Based64 image string to SharedPreferences
//   static Future<void> _saveImageToStorage(String base64Image) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_image', base64Image);
//   }

//   // Retrieve saved image from SharedPreferences
//   static Future<Image?> getSavedImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final base64Image = prefs.getString('user_image');
//     if (base64Image == null || base64Image.isEmpty) return null;

//     return Image.memory(
//       base64Decode(base64Image),
//       fit: BoxFit.cover, 
//       errorBuilder: (_, __, ___,) => const Icon(Icons.error),
//     );
//   }

//   // Clears saved image 
//   static Future<void> clearSavedImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('user_image');
//   }
// }