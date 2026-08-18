class AppListing {
  final String id;
  final String title;
  final String category; // e.g. Gaming, Utility, E-commerce, Social
  final String platform; // Android / iOS / Both
  final String description;
  final double price;
  final String? storeLink; // Play Store / App Store link
  final int? monthlyDownloads;
  final double? monthlyRevenue;
  final String techStack; // Flutter, Native Android, React Native, etc.
  final List<String> screenshotUrls;
  final String sellerId;
  final String sellerContact; // phone/whatsapp/email
  final DateTime createdAt;
  final bool isVerified;

  AppListing({
    required this.id,
    required this.title,
    required this.category,
    required this.platform,
    required this.description,
    required this.price,
    this.storeLink,
    this.monthlyDownloads,
    this.monthlyRevenue,
    required this.techStack,
    required this.screenshotUrls,
    required this.sellerId,
    required this.sellerContact,
    required this.createdAt,
    this.isVerified = false,
  });

  factory AppListing.fromMap(String id, Map<String, dynamic> map) {
    return AppListing(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      platform: map['platform'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      storeLink: map['storeLink'],
      monthlyDownloads: map['monthlyDownloads'],
      monthlyRevenue: (map['monthlyRevenue'] as num?)?.toDouble(),
      techStack: map['techStack'] ?? '',
      screenshotUrls: List<String>.from(map['screenshotUrls'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerContact: map['sellerContact'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'platform': platform,
      'description': description,
      'price': price,
      'storeLink': storeLink,
      'monthlyDownloads': monthlyDownloads,
      'monthlyRevenue': monthlyRevenue,
      'techStack': techStack,
      'screenshotUrls': screenshotUrls,
      'sellerId': sellerId,
      'sellerContact': sellerContact,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
