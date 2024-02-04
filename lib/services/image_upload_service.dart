import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage() async {
    if (kIsWeb) {
      // Web-specific code
      return await _uploadImageWeb();
    } else {
      // Mobile-specific code
      return await _uploadImageMobile();
    }
  }

  Future<String?> _uploadImageWeb() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    await input.onChange.first;
    if (input.files!.isEmpty) return null;

    final html.File file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;

    String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    TaskSnapshot snapshot = await _storage.ref().child(fileName).putBlob(file);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> _uploadImageMobile() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
        TaskSnapshot snapshot = await _storage.ref().child(fileName).putFile(file);
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    } else {
      print('No image selected');
      return null;
    }
  }
}
