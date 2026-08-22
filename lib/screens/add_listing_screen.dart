import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_listing.dart';
import '../services/listing_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/play_store_service.dart';
import '../services/verification_service.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _storeLink = TextEditingController();
  final _techStack = TextEditingController();
  final _contact = TextEditingController();
  final _downloads = TextEditingController();
  final _revenue = TextEditingController();
  final _codeController = TextEditingController();

  String _category = 'Utility';
  String _platform = 'Android';
  String _currency = 'INR';
  bool _saving = false;
  final List<File> _selectedImages = [];
  late final String _listingId;

  // Ownership verification state
  bool _verifying = false;
  bool _isVerified = false;
  String? _foundEmail; // masked email shown to seller
  bool _codeSent = false;
  String? _verifyError;

  final _categories = const [
    'Gaming', 'Utility', 'E-commerce', 'Social', 'Education', 'Finance', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _listingId = ListingService().newListingId();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length > 2 ? name.substring(0, 2) : name;
    return '$visible***@${parts[1]}';
  }

  Future<void> _startVerification() async {
    final link = _storeLink.text.trim();
    if (link.isEmpty) {
      setState(() => _verifyError = 'Enter your Play Store link first');
      return;
    }
    setState(() {
      _verifying = true;
      _verifyError = null;
    });
    try {
      final email = await PlayStoreService().fetchDeveloperEmail(link);
      if (email == null) {
        setState(() => _verifyError =
            "Couldn't find a developer email on that Play Store page");
        return;
      }
      final sent = await VerificationService().sendVerificationCode(
        listingId: _listingId,
        developerEmail: email,
        appTitle: _title.text.trim().isEmpty ? 'your app' : _title.text.trim(),
      );
      if (!sent) {
        setState(() => _verifyError = 'Failed to send verification email. Try again.');
        return;
      }
      setState(() {
        _foundEmail = email;
        _codeSent = true;
      });
    } catch (e) {
      setState(() => _verifyError = 'Verification failed: $e');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _submitCode() async {
    setState(() {
      _verifying = true;
      _verifyError = null;
    });
    try {
      final ok = await VerificationService()
          .checkCode(listingId: _listingId, enteredCode: _codeController.text);
      if (ok) {
        setState(() => _isVerified = true);
      } else {
        setState(() => _verifyError = 'Incorrect code, try again');
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      _selectedImages.addAll(picked.map((x) => File(x.path)));
      // Keep at most 5 screenshots per listing
      if (_selectedImages.length > 5) {
        _selectedImages.removeRange(5, _selectedImages.length);
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final user = AuthService().currentUser;
    List<String> imageUrls = [];
    try {
      if (_selectedImages.isNotEmpty) {
        imageUrls = await StorageService()
            .uploadListingImages(user?.uid ?? 'unknown', _selectedImages);
      }
      final listing = AppListing(
        id: '',
        title: _title.text.trim(),
        category: _category,
        platform: _platform,
        description: _description.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0,
        currency: _currency,
        storeLink: _storeLink.text.trim().isEmpty ? null : _storeLink.text.trim(),
        monthlyDownloads: int.tryParse(_downloads.text.trim()),
        monthlyRevenue: double.tryParse(_revenue.text.trim()),
        techStack: _techStack.text.trim(),
        screenshotUrls: imageUrls,
        sellerId: user?.uid ?? '',
        sellerContact: _contact.text.trim(),
        createdAt: DateTime.now(),
        isVerified: _isVerified,
      );
      await ListingService().setListing(_listingId, listing);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Your App')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Screenshots (up to 5)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._selectedImages.asMap().entries.map((entry) {
                    final i = entry.key;
                    final file = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeImage(i),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_selectedImages.length < 5)
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'App Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _platform,
              decoration: const InputDecoration(labelText: 'Platform', border: OutlineInputBorder()),
              items: const ['Android', 'iOS', 'Both']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                      DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? 'INR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _storeLink,
              decoration: const InputDecoration(
                  labelText: 'Play Store / App Store Link', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            if (_isVerified)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Ownership verified', style: TextStyle(color: Colors.green)),
                  ],
                ),
              )
            else if (!_codeSent)
              OutlinedButton.icon(
                onPressed: _verifying ? null : _startVerification,
                icon: _verifying
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.verified_outlined, size: 18),
                label: const Text('Verify Ownership'),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We sent a 6-digit code to ${_maskEmail(_foundEmail ?? '')} '
                      '(your app\'s Play Store developer email). Enter it below:',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              hintText: '6-digit code',
                              border: OutlineInputBorder(),
                              counterText: '',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _verifying ? null : _submitCode,
                          child: _verifying
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_verifyError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_verifyError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _techStack,
              decoration: const InputDecoration(
                  labelText: 'Tech Stack (e.g. Flutter, Native)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _downloads,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Monthly Downloads', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _revenue,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Monthly Revenue (₹)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contact,
              decoration: const InputDecoration(
                  labelText: 'WhatsApp Number (91XXXXXXXXXX)', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
