import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_listing.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import '../utils/format.dart';

class AppDetailScreen extends StatelessWidget {
  final AppListing listing;
  const AppDetailScreen({super.key, required this.listing});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _messageSeller(BuildContext context) async {
    final myId = AuthService().currentUser?.uid;
    if (myId == null) return;
    final conversationId = await ChatService().startConversation(
      listingId: listing.id,
      listingTitle: listing.title,
      buyerId: myId,
      sellerId: listing.sellerId,
    );
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            listingTitle: listing.title,
          ),
        ),
      );
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
            if (listing.screenshotUrls.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: listing.screenshotUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      listing.screenshotUrls[i],
                      width: 160,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const SizedBox(
                                  width: 160,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                      errorBuilder: (context, error, stack) => Container(
                        width: 160,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            if (listing.screenshotUrls.isNotEmpty) const SizedBox(height: 16),
            Row(
              children: [
                Chip(label: Text(listing.category)),
                const SizedBox(width: 8),
                Chip(label: Text(listing.platform)),
                if (listing.isVerified) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    avatar: Icon(Icons.verified, color: Colors.green, size: 18),
                    label: Text('Verified', style: TextStyle(color: Colors.green)),
                    backgroundColor: Color(0xFFE8F5E9),
                  ),
                ],
                const SizedBox(width: 8),
                Chip(label: Text(listing.techStack)),
              ],
            ),
            const SizedBox(height: 16),
            Text(formatPrice(listing.price, listing.currency),
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFB50101))),
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
                        _Stat(label: 'Monthly Revenue', value: formatPrice(listing.monthlyRevenue!, listing.currency)),
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
            if (listing.sellerId != AuthService().currentUser?.uid)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _messageSeller(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message Seller'),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('This is your own listing',
                    style: TextStyle(color: Colors.grey)),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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
