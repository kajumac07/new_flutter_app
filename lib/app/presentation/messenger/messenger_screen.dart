import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/presentation/messenger/widgets/chat_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

class MessengerScreen extends StatefulWidget {
  @override
  _MessengerScreenState createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadFollowUsers();
  }

  Future<void> _loadFollowUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      // Get current user data
      final currentUserDoc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUId)
          .get();

      if (currentUserDoc.exists) {
        final currentUser = UserModel.fromMap(
          currentUserDoc.data() as Map<String, dynamic>,
        );

        // Get followers
        final followersSnapshot = await FirebaseFirestore.instance
            .collection("Persons")
            .where("uid", whereIn: currentUser.followers)
            .get();

        _followers = followersSnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList();

        // Get following
        final followingSnapshot = await FirebaseFirestore.instance
            .collection("Persons")
            .where("uid", whereIn: currentUser.following)
            .get();

        _following = followingSnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print("Error loading follow users: $e");
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: kCardColor,
            iconTheme: IconThemeData(color: kDark),
            pinned: true,
            floating: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              title: _isSearching
                  ? _buildSearchField()
                  : Text(
                      "Messages",
                      style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
              centerTitle: true,
              titlePadding: EdgeInsets.only(bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kCardColor, kCardColor.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Iconsax.close_circle : Iconsax.search_normal,
                  color: kWhite,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
            ],
          ),

          // Chat list
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Chats")
                .where("members", arrayContains: currentUId)
                .orderBy("lastMessageTime", descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShimmerItem(),
                    childCount: 8,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message,
                        size: 64,
                        color: kSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No conversations yet",
                        style: TextStyle(color: kSecondary, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Start a conversation with someone!",
                        style: TextStyle(
                          color: kSecondary.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final chats = snapshot.data!.docs;

              // Filter chats based on search query
              final filteredChats = _searchQuery.isEmpty
                  ? chats
                  : chats.where((chat) {
                      final data = chat.data() as Map<String, dynamic>;
                      final List members = data["members"];
                      final String otherUid = members.firstWhere(
                        (id) => id != currentUId,
                        orElse: () => "",
                      );

                      // We'll check the user's name in the async part
                      return true;
                    }).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = filteredChats[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final List members = data["members"];

                  // find the other user (receiver)
                  final String otherUid = members.firstWhere(
                    (id) => id != currentUId,
                    orElse: () => "",
                  );

                  if (otherUid.isEmpty) return SizedBox();

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("Persons")
                        .doc(otherUid)
                        .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) {
                        return _buildShimmerItem();
                      }

                      final UserModel userData = UserModel.fromMap(
                        userSnap.data!.data() as Map<String, dynamic>,
                      );

                      // Apply search filter
                      if (_searchQuery.isNotEmpty &&
                          !userData.fullName.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          )) {
                        return SizedBox();
                      }

                      // Check if the last message was sent by the current user
                      final lastMessageSender = data["lastMessageSender"] ?? "";
                      final isMyMessage = lastMessageSender == currentUId;

                      // Only show unread count if there are unread messages AND the last message wasn't sent by me
                      final hasUnread =
                          data["unreadCount"] != null &&
                          data["unreadCount"] > 0 &&
                          !isMyMessage;

                      // Build receiver UserModel
                      final receiver = UserModel(
                        uid: userData.uid,
                        fullName: userData.fullName,
                        userName: userData.userName,
                        bio: userData.bio,
                        currentAddress: userData.currentAddress,
                        emailAddress: userData.emailAddress,
                        profilePicture: userData.profilePicture,
                        isAdmin: userData.isAdmin,
                        isActive: userData.isActive,
                        status: userData.status,
                        isOnline: userData.isOnline,
                        posts: userData.posts,
                        stories: userData.stories,
                        followers: userData.followers,
                        following: userData.following,
                        createdAt: userData.createdAt,
                        updatedAt: userData.updatedAt,
                      );

                      return _buildChatItem(doc.id, data, receiver, hasUnread);
                    },
                  );
                }, childCount: filteredChats.length),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //went to other screen to select user to chat
        },
        backgroundColor: kSecondary,
        child: Icon(Iconsax.edit, color: kWhite, size: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: kWhite, fontSize: 18),
      decoration: InputDecoration(
        hintText: "Search conversations...",
        hintStyle: TextStyle(color: kWhite.withOpacity(0.6)),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      cursorColor: kPrimary,
      autofocus: true,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(width: 120, height: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(
    String chatId,
    Map<String, dynamic> data,
    UserModel receiver,
    bool hasUnread,
  ) {
    final lastMessage = data["lastMessage"] ?? "";
    final lastMessageTime = data["lastMessageTime"] != null
        ? (data["lastMessageTime"] as Timestamp).toDate()
        : DateTime.now();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => ChatScreen(chatId: chatId, receiver: receiver),
              transition: Transition.rightToLeftWithFade,
              duration: Duration(milliseconds: 400),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kSecondary.withOpacity(0.1), width: 1),
            ),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
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
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            receiver.profilePicture,
                          ),
                          backgroundColor: kCardColor,
                        ),
                      ),
                    ),
                    if (receiver.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: kCardColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              receiver.fullName,
                              style: TextStyle(
                                color: kWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(lastMessageTime),
                            style: TextStyle(color: kSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: hasUnread ? kWhite : kSecondary,
                          fontSize: 14,
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      data["unreadCount"].toString(),
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
