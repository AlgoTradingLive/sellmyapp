import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  // Upload a list of image files for a listing and return their download URLs
  Future<List<String>> uploadListingImages(
      String sellerId, List<File> images) async {
    final List<String> urls = [];
    for (var i = 0; i < images.length; i++) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final ref = _storage.ref().child('listings/$sellerId/$fileName');
      await ref.putFile(images[i]);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }
}
