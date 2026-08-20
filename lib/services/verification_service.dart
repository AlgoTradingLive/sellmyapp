import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// Verifies that a seller owns the app they're listing by sending a
/// one-time code to the app's public Play Store developer email
/// (see PlayStoreService) and checking the code the seller enters back.
///
/// Uses EmailJS (free tier, no backend needed) to actually send the email
/// from the client app. See README "EmailJS Setup" for how to get these.
class VerificationService {
  // TODO: fill these in after creating your free EmailJS account
  // (see README section "EmailJS Setup")
  static const String emailJsServiceId = 'service_kyr4qlq';
  static const String emailJsTemplateId = 'template_cm0rfsc';
  static const String emailJsPublicKey = 'rzUKRvzE-GuKC-B05';

  final _db = FirebaseFirestore.instance;

  String _generateCode() {
    final rand = Random.secure();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  /// Generates a code, stores it against the listing, and emails it to
  /// [developerEmail]. Returns true if the email was sent successfully.
  Future<bool> sendVerificationCode({
    required String listingId,
    required String developerEmail,
    required String appTitle,
  }) async {
    final code = _generateCode();

    await _db.collection('verifications').doc(listingId).set({
      'code': code,
      'email': developerEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'verified': false,
    });

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': emailJsServiceId,
        'template_id': emailJsTemplateId,
        'user_id': emailJsPublicKey,
        'template_params': {
          'to_email': developerEmail,
          'app_title': appTitle,
          'code': code,
        },
      }),
    );

    return response.statusCode == 200;
  }

  /// Checks the code the seller entered against what was emailed.
  Future<bool> checkCode({
    required String listingId,
    required String enteredCode,
  }) async {
    final doc = await _db.collection('verifications').doc(listingId).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final matches = data['code'] == enteredCode.trim();
    if (matches) {
      await _db.collection('verifications').doc(listingId).update({'verified': true});
    }
    return matches;
  }
}
