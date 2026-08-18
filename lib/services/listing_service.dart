import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_listing.dart';

class ListingService {
  final CollectionReference _listings =
      FirebaseFirestore.instance.collection('listings');

  // सगळे listings मिळवणे (नवीन आधी)
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

  // एका seller चे listings मिळवणे
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

  // नवीन listing add करणे
  Future<void> addListing(AppListing listing) async {
    await _listings.add(listing.toMap());
  }

  // listing update करणे
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _listings.doc(id).update(data);
  }

  // listing delete करणे
  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }
}
