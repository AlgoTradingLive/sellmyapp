import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = AuthService().currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('My Chats')),
      body: StreamBuilder<List<ChatConversation>>(
        stream: ChatService().getMyConversations(myId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(
                child: Text('No conversations yet', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = chats[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(
                    c.otherUserLabel == 'Seller' ? Icons.storefront : Icons.person,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                title: Text(c.listingTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${c.otherUserLabel}: ${c.lastMessage ?? "No messages yet"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: c.id,
                      listingTitle: c.listingTitle,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
