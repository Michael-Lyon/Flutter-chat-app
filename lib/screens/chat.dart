import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();
    print(token);

    fcm.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();

    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PyChat"),
        actions: [
          IconButton(
            onPressed: () async {
              await _firebase.signOut();
            },
            icon: const Icon(Icons.exit_to_app_rounded),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
      body: const Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ChatMessage(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: NewMessage(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChatMessages();
  }
}
