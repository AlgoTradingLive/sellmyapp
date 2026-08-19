import 'package:flutter/material.dart';
import '../models/app_listing.dart';
import '../services/listing_service.dart';
import '../services/auth_service.dart';

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

  String _category = 'Utility';
  String _platform = 'Android';
  bool _saving = false;

  final _categories = const [
    'Gaming', 'Utility', 'E-commerce', 'Social', 'Education', 'Finance', 'Other'
  ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final user = AuthService().currentUser;
    final listing = AppListing(
      id: '',
      title: _title.text.trim(),
      category: _category,
      platform: _platform,
      description: _description.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      storeLink: _storeLink.text.trim().isEmpty ? null : _storeLink.text.trim(),
      monthlyDownloads: int.tryParse(_downloads.text.trim()),
      monthlyRevenue: double.tryParse(_revenue.text.trim()),
      techStack: _techStack.text.trim(),
      screenshotUrls: const [], // image upload will be added in phase 2
      sellerId: user?.uid ?? '',
      sellerContact: _contact.text.trim(),
      createdAt: DateTime.now(),
    );
    await ListingService().addListing(listing);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
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
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _storeLink,
              decoration: const InputDecoration(
                  labelText: 'Play Store / App Store Link', border: OutlineInputBorder()),
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
