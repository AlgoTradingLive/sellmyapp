import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Uploads images to Cloudinary's free tier using an unsigned upload preset.
/// Cloud name and preset are safe to keep in client code — Cloudinary's
/// unsigned presets are designed for this and only allow uploads, not
/// reading/deleting other users' data.
class StorageService {
  // TODO: fill these in after creating your free Cloudinary account
  // (see README section "Cloudinary Setup")
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UNSIGNED_UPLOAD_PRESET';

  // Upload a list of image files for a listing and return their URLs
  Future<List<String>> uploadListingImages(
      String sellerId, List<File> images) async {
    final List<String> urls = [];
    for (final image in images) {
      final url = await _uploadSingle(image, sellerId);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  Future<String?> _uploadSingle(File image, String sellerId) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'sellmyapp/$sellerId'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String?;
  }
}
