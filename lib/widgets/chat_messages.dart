// import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found"),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userID'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userID'] : null;

              final nextUserIsSame = currentMessageUserId == nextMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
              return MessageBubble.first(
                  userImage: chatMessage['imageUrl'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            });
      },
    );
  }
}
