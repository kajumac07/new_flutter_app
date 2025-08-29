import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot> _groupStream;
  late Stream<QuerySnapshot> _messagesStream;
  Map<String, String> _userNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _groupStream = FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .snapshots();

    _messagesStream = FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();

    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.groupId)
          .get();

      if (groupDoc.exists) {
        final members = List<String>.from(groupDoc['members'] ?? []);

        for (String memberId in members) {
          if (memberId != currentUser.uid) {
            final userDoc = await FirebaseFirestore.instance
                .collection("Persons")
                .doc(memberId)
                .get();

            if (userDoc.exists) {
              _userNames[memberId] = userDoc['fullName'] ?? 'Unknown User';
            }
          }
        }
      }
    } catch (e) {
      print("Error loading user names: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'text': _messageController.text.trim(),
      'senderId': currentUser.uid,
      'timestamp': Timestamp.now(),
      'type': 'text',
    };

    try {
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.groupId)
          .collection("messages")
          .add(message);

      // Update last message in group
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.groupId)
          .update({
            'lastMessage': _messageController.text.trim(),
            'lastMessageTime': Timestamp.now(),
            'lastMessageSender': currentUser.uid,
          });

      _messageController.clear();

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send message");
    }
  }

  Future<void> _leaveGroup() async {
    Get.defaultDialog(
      title: "Leave Group",
      content: Text(
        "Are you sure you want to leave this group? You'll need to be invited again to rejoin.",
        style: appStyle(14, kWhite, FontWeight.normal),
        textAlign: TextAlign.center,
      ),
      backgroundColor: kCardColor,
      titleStyle: appStyle(18, kWhite, FontWeight.bold),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "Cancel",
            style: appStyle(14, kSecondary, FontWeight.normal),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection("groups")
                  .doc(widget.groupId)
                  .update({
                    'members': FieldValue.arrayRemove([currentUser.uid]),
                  });

              Get.back();
              Get.back(); // Go back to previous screen
              Get.snackbar(
                "Left Group",
                "You have left the group",
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar("Error", "Failed to leave group");
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE94560)),
          child: Text("Leave", style: appStyle(14, kWhite, FontWeight.w600)),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Column(
        children: [
          // Group Header
          StreamBuilder<DocumentSnapshot>(
            stream: _groupStream,
            builder: (context, snapshot) {
              final groupName = snapshot.hasData && snapshot.data!.exists
                  ? snapshot.data!['groupName'] ?? 'Group Chat'
                  : 'Group Chat';

              return Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: kCardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.arrow_left, color: kWhite, size: 24),
                      onPressed: () => Get.back(),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupName,
                            style: appStyle(18, kWhite, FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("groups")
                                .doc(widget.groupId)
                                .collection("messages")
                                .orderBy("timestamp", descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, messageSnapshot) {
                              if (messageSnapshot.hasData &&
                                  messageSnapshot.data!.docs.isNotEmpty) {
                                final lastMessage =
                                    messageSnapshot.data!.docs.first;
                                final senderId = lastMessage['senderId'];
                                final isYou = senderId == currentUser.uid;

                                return Text(
                                  isYou
                                      ? "You: ${lastMessage['text']}"
                                      : "${_userNames[senderId] ?? 'Someone'}: ${lastMessage['text']}",
                                  style: appStyle(
                                    12,
                                    kSecondary,
                                    FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                "Start a conversation",
                                style: appStyle(
                                  12,
                                  kSecondary,
                                  FontWeight.normal,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Iconsax.more, color: kWhite),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'leave',
                          child: Row(
                            children: [
                              Icon(Iconsax.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Leave Group",
                                style: appStyle(
                                  14,
                                  Colors.red,
                                  FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'leave') _leaveGroup();
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          // Messages List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFE94560)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.messages,
                          size: 64,
                          color: kSecondary.withOpacity(0.4),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: appStyle(16, kWhite, FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Send a message to start the conversation",
                          style: appStyle(14, kSecondary, FontWeight.normal),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser.uid;
                    final timestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    return _buildMessageBubble(
                      message,
                      isMe,
                      timestamp,
                      context,
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor,
              border: Border(
                top: BorderSide(color: kSecondary.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: appStyle(16, kWhite, FontWeight.normal),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        hintText: "Type a message...",
                        hintStyle: appStyle(16, kSecondary, FontWeight.normal),
                        border: InputBorder.none,
                        suffixIcon: _messageController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Iconsax.close_circle,
                                  color: kSecondary,
                                  size: 20,
                                ),
                                onPressed: () => _messageController.clear(),
                              )
                            : null,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE94560), Color(0xFFFF7B9C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Iconsax.send_2, color: kWhite, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isMe,
    DateTime timestamp,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFD1D1D),
                    Color(0xFF833AB4),
                    Color(0xFF405DE6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Persons")
                    .doc(message['senderId'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final profilePic = snapshot.data!['profilePicture'] ?? '';
                    return CircleAvatar(
                      backgroundImage: NetworkImage(profilePic),
                      backgroundColor: kCardColor,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: kCardColor,
                    child: Icon(Iconsax.user, color: kWhite, size: 16),
                  );
                },
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Color(0xFFE94560) : Color(0xFF2D3748),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 20 : 5),
                  topRight: Radius.circular(isMe ? 5 : 20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      _userNames[message['senderId']] ?? 'Unknown User',
                      style: appStyle(
                        12,
                        kWhite.withOpacity(0.7),
                        FontWeight.w600,
                      ),
                    ),
                  if (!isMe) SizedBox(height: 4),
                  Text(
                    message['text'],
                    style: appStyle(16, kWhite, FontWeight.normal),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getTimeAgo(timestamp),
                    style: appStyle(
                      10,
                      kWhite.withOpacity(0.6),
                      FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
