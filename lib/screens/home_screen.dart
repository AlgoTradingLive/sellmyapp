import 'package:flutter/material.dart';
import '../models/app_listing.dart';
import '../services/listing_service.dart';
import '../services/auth_service.dart';
import 'app_detail_screen.dart';
import 'add_listing_screen.dart';
import 'my_listings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ListingService();
  String _selectedCategory = 'All';

  final _categories = const [
    'All', 'Gaming', 'Utility', 'E-commerce', 'Social', 'Education', 'Finance', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SellMyApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My listings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddListingScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Sell App'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppListing>>(
              stream: _service.getListings(category: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No listings yet'));
                }
                final listings = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: listings.length,
                  itemBuilder: (context, i) => _ListingCard(listing: listings[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final AppListing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AppDetailScreen(listing: listing))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apps, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${listing.category} • ${listing.platform}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('₹${listing.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
              ),
              if (listing.isVerified)
                const Icon(Icons.verified, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
