import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/global/models/user_model.dart';
import 'package:new_flutter_app/app/presentation/createGroup/create_group_screen.dart';
import 'package:new_flutter_app/app/presentation/messenger/widgets/chat_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/presentation/messenger/widgets/group_chat_screen.dart';
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
  int _selectedTab = 0;

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
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 48),
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildTabBar(),
            ),
          ),
          // Content based on selected tab
          _selectedTab == 0 ? _buildChatsList() : _buildGroupsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      "Choose an option",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kWhite,
                      ),
                    ),
                    SizedBox(height: 20),

                    // New Conversation
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kSecondary.withOpacity(0.1),
                        child: Icon(Iconsax.message_add, color: kSecondary),
                      ),
                      title: Text(
                        "Start New Conversation",
                        style: TextStyle(color: kWhite, fontSize: 16),
                      ),
                      trailing: Icon(Iconsax.arrow_right_3, color: kSecondary),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to user selection screen
                      },
                    ),

                    Divider(color: Colors.grey[700]),

                    // Create Group
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        child: Icon(Iconsax.people, color: Colors.blueAccent),
                      ),
                      title: Text(
                        "Create Group",
                        style: TextStyle(color: kWhite, fontSize: 16),
                      ),
                      trailing: Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.blueAccent,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(
                          () => CreateGroupScreen(),
                          transition: Transition.leftToRight,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: kSecondary,
        child: Icon(Iconsax.edit, color: kWhite, size: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 0
                          ? kSecondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Chats",
                    style: TextStyle(
                      color: _selectedTab == 0 ? kWhite : kSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 1
                          ? kSecondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Groups",
                    style: TextStyle(
                      color: _selectedTab == 1 ? kWhite : kSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder(
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
                  isCommunityMember: userData.isCommunityMember,
                  posts: userData.posts,
                  stories: userData.stories,
                  followers: userData.followers,
                  following: userData.following,
                  createdAt: userData.createdAt,
                  updatedAt: userData.updatedAt,
                );

                return _buildChatItem(doc.id, data, receiver, hasUnread, false);
              },
            );
          }, childCount: filteredChats.length),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("groups")
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
                  Iconsax.people,
                  size: 64,
                  color: kSecondary.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  "No groups yet",
                  style: TextStyle(color: kSecondary, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Create a group or wait for invitations!",
                  style: TextStyle(
                    color: kSecondary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final groups = snapshot.data!.docs;

        // Filter groups based on search query
        final filteredGroups = _searchQuery.isEmpty
            ? groups
            : groups.where((group) {
                final data = group.data() as Map<String, dynamic>;
                final groupName = data["groupName"] ?? "";
                return groupName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              }).toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final doc = filteredGroups[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildChatItem(doc.id, data, null, false, true);
          }, childCount: filteredGroups.length),
        );
      },
    );
  }

  Widget _buildChatItem(
    String chatId,
    Map<String, dynamic> data,
    UserModel? receiver,
    bool hasUnread,
    bool isGroup,
  ) {
    final lastMessage = data["lastMessage"] ?? "";
    final lastMessageTime = data["lastMessageTime"] != null
        ? (data["lastMessageTime"] as Timestamp).toDate()
        : DateTime.now();

    final groupName = isGroup ? data["groupName"] ?? "Group Chat" : "";
    final membersCount = isGroup ? (data["members"] as List?)?.length ?? 0 : 0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isGroup) {
              Get.to(
                () => GroupChatScreen(groupId: chatId),
                transition: Transition.rightToLeftWithFade,
                duration: Duration(milliseconds: 400),
              );
            } else {
              Get.to(
                () => ChatScreen(chatId: chatId, receiver: receiver!),
                transition: Transition.rightToLeftWithFade,
                duration: Duration(milliseconds: 400),
              );
            }
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
                          colors: isGroup
                              ? [Color(0xFF833AB4), Color(0xFFFD1D1D)]
                              : [
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
                          backgroundColor: kCardColor,
                          child: isGroup
                              ? Icon(Iconsax.people, color: kWhite, size: 24)
                              : null,
                          backgroundImage: isGroup
                              ? null
                              : NetworkImage(receiver!.profilePicture),
                        ),
                      ),
                    ),
                    if (!isGroup && receiver!.isOnline)
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
                    if (isGroup)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: kCardColor, width: 2),
                          ),
                          child: Icon(Iconsax.people, size: 10, color: kWhite),
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
                              isGroup ? groupName : receiver!.fullName,
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
                        isGroup ? "$lastMessage" : lastMessage,
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
                      if (isGroup) SizedBox(height: 4),
                      if (isGroup)
                        Text(
                          "$membersCount members",
                          style: TextStyle(
                            color: kSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kSecondary,
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: kWhite, fontSize: 18),
      decoration: InputDecoration(
        hintText: _selectedTab == 0
            ? "Search conversations..."
            : "Search groups...",
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
