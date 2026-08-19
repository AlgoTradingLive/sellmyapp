import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_listing.dart';

class AppDetailScreen extends StatelessWidget {
  final AppListing listing;
  const AppDetailScreen({super.key, required this.listing});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(listing.category)),
                const SizedBox(width: 8),
                Chip(label: Text(listing.platform)),
                const SizedBox(width: 8),
                Chip(label: Text(listing.techStack)),
              ],
            ),
            const SizedBox(height: 16),
            Text('₹${listing.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(listing.description),
            const SizedBox(height: 16),
            if (listing.monthlyDownloads != null || listing.monthlyRevenue != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (listing.monthlyDownloads != null)
                        _Stat(label: 'Monthly Downloads', value: '${listing.monthlyDownloads}'),
                      if (listing.monthlyRevenue != null)
                        _Stat(label: 'Monthly Revenue', value: '₹${listing.monthlyRevenue}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (listing.storeLink != null)
              OutlinedButton.icon(
                onPressed: () => _launch(listing.storeLink!),
                icon: const Icon(Icons.store),
                label: const Text('View on Play Store / App Store'),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _launch('https://wa.me/${listing.sellerContact}'),
                icon: const Icon(Icons.chat),
                label: const Text('Contact Seller on WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }
}
