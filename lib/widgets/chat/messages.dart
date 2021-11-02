import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/widgets/chat/message_bubbel.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('sentAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.docs;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => MessageBubbel(
            //data sent to Messagebubbel
            chatDocs[index].data()['text'],
            chatDocs[index].data()['username'], //for username
            chatDocs[index].data()['user_image'],
            chatDocs[index].data()['userId'] == user.uid,
            // key will make sure message list gets updated properly
            key: ValueKey(chatDocs[index].id),
          ),
        );
      },
    );
  }
  //);
}
