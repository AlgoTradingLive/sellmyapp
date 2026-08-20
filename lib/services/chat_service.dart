import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime? sentAt;

  ChatMessage({required this.senderId, required this.text, this.sentAt});

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
      };
}

class ChatConversation {
  final String id;
  final String listingId;
  final String listingTitle;
  final String buyerId;
  final String sellerId;
  final String otherUserLabel; // who the current user is chatting with
  final String? lastMessage;
  final DateTime? lastMessageAt;

  ChatConversation({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.buyerId,
    required this.sellerId,
    required this.otherUserLabel,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatConversation.fromMap(String id, Map<String, dynamic> map, String currentUserId) {
    final buyerId = map['buyerId'] ?? '';
    final sellerId = map['sellerId'] ?? '';
    final isBuyer = currentUserId == buyerId;
    return ChatConversation(
      id: id,
      listingId: map['listingId'] ?? '',
      listingTitle: map['listingTitle'] ?? '',
      buyerId: buyerId,
      sellerId: sellerId,
      otherUserLabel: isBuyer ? 'Seller' : 'Buyer',
      lastMessage: map['lastMessage'],
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ChatService {
  final _db = FirebaseFirestore.instance;

  // One conversation per (listing, buyer) pair — seller is fixed per listing
  String conversationId(String listingId, String buyerId) => '${listingId}_$buyerId';

  // Creates the conversation doc if it doesn't exist yet, then returns its id
  Future<String> startConversation({
    required String listingId,
    required String listingTitle,
    required String buyerId,
    required String sellerId,
  }) async {
    final id = conversationId(listingId, buyerId);
    final ref = _db.collection('conversations').doc(id);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'listingId': listingId,
        'listingTitle': listingTitle,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'participants': [buyerId, sellerId],
        'lastMessage': null,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }
    return id;
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }

  Future<void> sendMessage(String conversationId, String senderId, String text) async {
    final convoRef = _db.collection('conversations').doc(conversationId);
    await convoRef.collection('messages').add(
          ChatMessage(senderId: senderId, text: text).toMap(),
        );
    await convoRef.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // All conversations the current user is part of (as buyer or seller)
  Stream<List<ChatConversation>> getMyConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ChatConversation.fromMap(d.id, d.data(), userId))
            .toList());
  }
}
