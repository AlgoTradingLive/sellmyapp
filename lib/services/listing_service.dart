import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_listing.dart';

class ListingService {
  final CollectionReference _listings =
      FirebaseFirestore.instance.collection('listings');

  // Get all listings (newest first)
  Stream<List<AppListing>> getListings({String? category}) {
    Query query = _listings.orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            AppListing.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get a seller's listings
  Stream<List<AppListing>> getMyListings(String sellerId) {
    return _listings
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                AppListing.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Add a new listing
  Future<void> addListing(AppListing listing) async {
    await _listings.add(listing.toMap());
  }

  // Update a listing
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _listings.doc(id).update(data);
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }
}
