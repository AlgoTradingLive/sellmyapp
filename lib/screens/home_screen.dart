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
  final _searchController = TextEditingController();
  String _searchText = '';
  String? _platformFilter; // null = any
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'newest'; // newest | price_low | price_high | downloads

  final _categories = const [
    'All', 'Gaming', 'Utility', 'E-commerce', 'Social', 'Education', 'Finance', 'Other'
  ];

  List<AppListing> _applyFilters(List<AppListing> listings) {
    var result = listings.where((l) {
      if (_searchText.isNotEmpty &&
          !l.title.toLowerCase().contains(_searchText.toLowerCase()) &&
          !l.description.toLowerCase().contains(_searchText.toLowerCase())) {
        return false;
      }
      if (_platformFilter != null && _platformFilter != 'Any' && l.platform != _platformFilter) {
        return false;
      }
      if (_minPrice != null && l.price < _minPrice!) return false;
      if (_maxPrice != null && l.price > _maxPrice!) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'downloads':
        result.sort((a, b) =>
            (b.monthlyDownloads ?? 0).compareTo(a.monthlyDownloads ?? 0));
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  void _openFilterSheet() {
    final minCtrl = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
    String? platform = _platformFilter;
    String sortBy = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter & Sort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('Price Range (₹)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Platform'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Any', 'Android', 'iOS', 'Both'].map((p) {
                      return ChoiceChip(
                        label: Text(p),
                        selected: (platform ?? 'Any') == p,
                        onSelected: (_) => setSheetState(() => platform = p),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sort By'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: const [
                      MapEntry('newest', 'Newest'),
                      MapEntry('price_low', 'Price: Low to High'),
                      MapEntry('price_high', 'Price: High to Low'),
                      MapEntry('downloads', 'Downloads'),
                    ].map((e) {
                      return ChoiceChip(
                        label: Text(e.value),
                        selected: sortBy == e.key,
                        onSelected: (_) => setSheetState(() => sortBy = e.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                              _platformFilter = null;
                              _sortBy = 'newest';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = double.tryParse(minCtrl.text.trim());
                              _maxPrice = double.tryParse(maxCtrl.text.trim());
                              _platformFilter = platform;
                              _sortBy = sortBy;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _searchText = v),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.tune),
                      tooltip: 'Filter & Sort',
                      onPressed: _openFilterSheet,
                    ),
                    if (_minPrice != null || _maxPrice != null ||
                        (_platformFilter != null && _platformFilter != 'Any') ||
                        _sortBy != 'newest')
                      Positioned(
                        right: 4, top: 4,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ],
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
                final listings = _applyFilters(snapshot.data!);
                if (listings.isEmpty) {
                  return const Center(child: Text('No listings match your filters'));
                }
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: listing.screenshotUrls.isNotEmpty
                    ? Image.network(
                        listing.screenshotUrls.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.blue.shade50,
                          child: const Icon(Icons.apps, color: Color(0xFF2563EB)),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.blue.shade50,
                        child: const Icon(Icons.apps, color: Color(0xFF2563EB)),
                      ),
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
