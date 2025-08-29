import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/models/chat_model.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/global/widgets/chat_background.dart';
import 'package:new_flutter_app/app/presentation/followedUsers/followed_user_profile_page.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final UserModel receiver;

  const ChatScreen({Key? key, required this.chatId, required this.receiver})
    : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  bool _isSending = false;
  bool _hasUnreadMessages = false;

  // For managing the stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Listen to text changes to update send button
    _controller.addListener(() {
      setState(() {});
    });

    // Auto-scroll when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });

    // Start listening to messages
    _subscribeToMessages();

    // Mark messages as seen when opening the chat
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToMessages() {
    _messagesSubscription = FirebaseFirestore.instance
        .collection("Chats")
        .doc(widget.chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen(
          (querySnapshot) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
                _messages = querySnapshot.docs.map((doc) {
                  return ChatMessage.fromMap(doc.data());
                }).toList();

                // Check if there are unread messages from the other person
                final unreadMessages = _messages.where((msg) {
                  return !msg.seen && msg.senderId == widget.receiver.uid;
                }).toList();

                if (unreadMessages.isNotEmpty) {
                  _markMessagesAsSeen();
                }
              });

              // Auto-scroll to bottom when new message arrives
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
            print("Error listening to messages: $error");
          },
        );
  }

  void _markMessagesAsSeen() async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection("Chats")
          .doc(widget.chatId)
          .get();

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final lastMessageSender = chatData["lastMessageSender"] ?? "";

      if (lastMessageSender != currentUId) {
        await FirebaseFirestore.instance
            .collection("Chats")
            .doc(widget.chatId)
            .update({"unreadCount": 0});
      }

      final messagesSnapshot = await FirebaseFirestore.instance
          .collection("Chats")
          .doc(widget.chatId)
          .collection("messages")
          .where('seen', isEqualTo: false)
          .where('senderId', isEqualTo: widget.receiver.uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'seen': true});
      }
      await batch.commit();
    } catch (e) {
      print("Error marking messages as seen: $e");
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final message = ChatMessage(
      senderId: currentUId,
      text: _controller.text.trim(),
      timestamp: DateTime.now(),
      seen: false,
    );

    try {
      // Add the message first
      await FirebaseFirestore.instance
          .collection("Chats")
          .doc(widget.chatId)
          .collection("messages")
          .add(message.toMap());

      // Update chat metadata - only increment unread count for the receiver
      await FirebaseFirestore.instance
          .collection("Chats")
          .doc(widget.chatId)
          .set({
            "members": [currentUId, widget.receiver.uid],
            "lastMessage": message.text,
            "lastMessageTime": message.timestamp,
            "unreadCount": FieldValue.increment(1),
            "lastMessageSender": currentUId,
          }, SetOptions(merge: true));

      _controller.clear();
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Manually fetch the latest messages
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Chats")
          .doc(widget.chatId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .get();

      setState(() {
        _isLoading = false;
        _messages = querySnapshot.docs.map((doc) {
          return ChatMessage.fromMap(doc.data());
        }).toList();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: ChatBackground(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? _buildLoadingMessages()
                  : _hasError
                  ? _buildErrorWidget()
                  : _messages.isEmpty
                  ? _buildEmptyChat()
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.senderId == currentUId;
                          return _buildMessageBubble(msg, isMe, index);
                        },
                      ),
                    ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kCardColor,
      elevation: 0,
      iconTheme: IconThemeData(color: kWhite),
      title: InkWell(
        onTap: () {
          Get.to(
            () => FollowedUserProfilePage(user: widget.receiver),
            transition: Transition.rightToLeftWithFade,
            duration: Duration(milliseconds: 300),
          );
        },
        child: Row(
          children: [
            // Avatar with glowing effect
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE94560).withOpacity(0.5),
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.receiver.profilePicture,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.fullName,
                  style: appStyleLato(15, kDark, FontWeight.normal),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.receiver.isOnline
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.receiver.isOnline ? "Online" : "Offline",
                      style: TextStyle(color: kSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // actions: [
      //   IconButton(
      //     icon: Icon(Iconsax.call, color: kWhite),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: Icon(Iconsax.video, color: kWhite),
      //     onPressed: () {},
      //   ),
      // ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, int index) {
    // Check if previous message is from the same sender
    bool isSameSender =
        index < _messages.length - 1 &&
        _messages[index + 1].senderId == msg.senderId;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSameSender ? 2 : 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe && !isSameSender)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFE94560), width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.receiver.profilePicture,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (!isMe)
            SizedBox(width: 40), // Space for alignment when no avatar is shown

          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? kSecondary : Color(0xFF2D3B4C),
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
                      Text(
                        msg.text,
                        style: appStyleRoboto(16, kDark, FontWeight.normal),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(msg.timestamp),
                            style: TextStyle(
                              color: kDark.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          if (isMe) SizedBox(width: 4),
                          if (isMe)
                            Icon(
                              msg.seen ? Iconsax.eye : Iconsax.eye_slash,
                              color: msg.seen
                                  ? Colors.white
                                  : kWhite.withOpacity(0.5),
                              size: 12,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(
          top: BorderSide(color: Color(0xFFE94560).withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          Container(
            decoration: BoxDecoration(
              color: kSecondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Iconsax.add, color: kWhite, size: 22),
              onPressed: () {},
            ),
          ),
          SizedBox(width: 8),
          // Message input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kDark.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(color: kWhite, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: kSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          // Send button with animation
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: hasText ? 48 : 40,
            height: hasText ? 48 : 40,
            decoration: BoxDecoration(
              gradient: hasText
                  ? LinearGradient(
                      colors: [Color(0xFFE94560), Color(0xFFFF7B9C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasText ? null : kSecondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(kWhite),
                      ),
                    )
                  : Icon(
                      hasText ? Iconsax.send_2 : Iconsax.microphone_2,
                      color: kWhite,
                      size: 22,
                    ),
              onPressed: hasText && !_isSending ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessages() {
    return ListView(
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      children: List.generate(5, (index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isMe)
                Container(
                  width: 32,
                  height: 32,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                width: MediaQuery.of(context).size.width * (isMe ? 0.5 : 0.4),
                height: 50,
                decoration: BoxDecoration(
                  color: isMe
                      ? Color(0xFFE94560).withOpacity(0.3)
                      : Color(0xFF0F3460).withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 20 : 4),
                    topRight: Radius.circular(isMe ? 4 : 20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_search,
            size: 80,
            color: Color(0xFFE94560).withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            "Start the conversation",
            style: TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Send your first message to ${widget.receiver.fullName}",
            style: TextStyle(color: kSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kSecondary, kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () {
                _focusNode.requestFocus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Say Hello",
                style: appStyle(16, kDark, FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 64,
            color: Color(0xFFE94560).withOpacity(0.7),
          ),
          SizedBox(height: 16),
          Text(
            "Failed to load messages",
            style: TextStyle(
              color: kWhite,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFFFF7B9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _subscribeToMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Try Again",
                style: TextStyle(color: kWhite, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
