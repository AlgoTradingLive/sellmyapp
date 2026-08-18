import 'package:flutter/material.dart';
import '../models/app_listing.dart';
import '../services/listing_service.dart';
import '../services/auth_service.dart';
import 'app_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('माझे Listings')),
      body: StreamBuilder<List<AppListing>>(
        stream: ListingService().getMyListings(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('तुम्ही अजून काहीही list केलेलं नाही'));
          }
          final listings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: listings.length,
            itemBuilder: (context, i) {
              final listing = listings[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(listing.title),
                  subtitle: Text('₹${listing.price.toStringAsFixed(0)} • ${listing.category}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => ListingService().deleteListing(listing.id),
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AppDetailScreen(listing: listing))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
