import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/presentation/messenger/widgets/group_chat_screen.dart';

class InvitationScreen extends StatelessWidget {
  const InvitationScreen({super.key});

  Future<void> _acceptGroupInvite(String groupId, String userId) async {
    final groupRef = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId);
    final inviteRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(userId)
        .collection("groupInvites")
        .doc(groupId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final groupDoc = await transaction.get(groupRef);
      if (!groupDoc.exists) return;

      final data = groupDoc.data()!;
      final List members = List.from(data['members'] ?? []);
      final List pending = List.from(data['pendingInvites'] ?? []);

      if (pending.contains(userId)) {
        pending.remove(userId);
        members.add(userId);
      }

      transaction.update(groupRef, {
        'members': members,
        'pendingInvites': pending,
      });

      transaction.update(inviteRef, {'status': 'accepted'});
    });

    Get.snackbar(
      "Success",
      "You've joined the group!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.to(
      () => GroupChatScreen(groupId: groupId),
      transition: Transition.cupertino,
      duration: Duration(milliseconds: 300),
    );
  }

  Future<void> _rejectGroupInvite(String groupId, String userId) async {
    final groupRef = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId);
    final inviteRef = FirebaseFirestore.instance
        .collection("Persons")
        .doc(userId)
        .collection("groupInvites")
        .doc(groupId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final groupDoc = await transaction.get(groupRef);
      if (!groupDoc.exists) return;

      final data = groupDoc.data()!;
      final List pending = List.from(data['pendingInvites'] ?? []);

      if (pending.contains(userId)) {
        pending.remove(userId);
      }

      transaction.update(groupRef, {'pendingInvites': pending});
      transaction.update(inviteRef, {'status': 'rejected'});
    });

    Get.snackbar(
      "Invitation Declined",
      "Group invitation has been declined",
      backgroundColor: Color(0xFF2D3748),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<Map<String, dynamic>?> _getInviterDetails(String inviterId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(inviterId)
          .get();

      if (doc.exists) {
        return {
          'name': doc.data()?['fullName'] ?? 'Unknown User',
          'profilePic': doc.data()?['profilePicture'] ?? '',
        };
      }
    } catch (e) {
      print("Error fetching inviter details: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final invitesStream = FirebaseFirestore.instance
        .collection("Persons")
        .doc(currentUId)
        .collection("groupInvites")
        .where("status", isEqualTo: "pending")
        .orderBy("timestamp", descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: kWhite, size: 24),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Group Invitations",
          style: appStyle(20, kWhite, FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.info_circle, color: kSecondary, size: 22),
            onPressed: () {
              Get.defaultDialog(
                title: "Group Invitations",
                content: Text(
                  "Accept group invitations to join communities and connect with others. You can always leave groups later if you change your mind.",
                  style: appStyle(14, kWhite, FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: kCardColor,
                titleStyle: appStyle(18, kWhite, FontWeight.bold),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: invitesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final invites = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index].data() as Map<String, dynamic>;
              final groupId = invite["groupId"];
              final groupName = invite["groupName"] ?? "Unnamed Group";
              final invitedBy = invite["invitedBy"] ?? "";
              final timestamp = invite["timestamp"] as Timestamp?;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getInviterDetails(invitedBy),
                builder: (context, inviterSnapshot) {
                  final inviterName =
                      inviterSnapshot.data?['name'] ?? 'Someone';
                  final inviterProfilePic =
                      inviterSnapshot.data?['profilePic'] ?? '';

                  return _buildInvitationCard(
                    groupId: groupId,
                    groupName: groupName,
                    inviterName: inviterName,
                    inviterProfilePic: inviterProfilePic,
                    timestamp: timestamp,
                    context: context,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Shimmer avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kSecondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Shimmer text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 16,
                          decoration: BoxDecoration(
                            color: kSecondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: kSecondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Shimmer buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 80, color: kSecondary.withOpacity(0.4)),
          SizedBox(height: 20),
          Text("No Invitations", style: appStyle(22, kWhite, FontWeight.w700)),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "You don't have any pending group invitations right now. When someone invites you to a group, it will appear here.",
              textAlign: TextAlign.center,
              style: appStyle(14, kSecondary, FontWeight.normal),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE94560),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              "Explore Groups",
              style: appStyle(16, kWhite, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard({
    required String groupId,
    required String groupName,
    required String inviterName,
    required String inviterProfilePic,
    required Timestamp? timestamp,
    required BuildContext context,
  }) {
    final timeAgo = timestamp != null
        ? _getTimeAgo(timestamp.toDate())
        : 'Recently';

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inviter info
          Row(
            children: [
              // Inviter avatar
              Container(
                width: 50,
                height: 50,
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
                    backgroundImage: NetworkImage(inviterProfilePic),
                    backgroundColor: kCardColor,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inviterName,
                      style: appStyle(16, kWhite, FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      timeAgo,
                      style: appStyle(12, kSecondary, FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Invitation message
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2D3748).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE94560).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.people, color: Color(0xFFE94560), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Invited you to join \"$groupName\"",
                    style: appStyle(15, kWhite, FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Decline button
              ElevatedButton(
                onPressed: () async {
                  await _rejectGroupInvite(groupId, currentUId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color(0xFFE94560),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Color(0xFFE94560), width: 1.5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  "Decline",
                  style: appStyle(14, Color(0xFFE94560), FontWeight.w600),
                ),
              ),

              SizedBox(width: 12),

              // Accept button
              ElevatedButton(
                onPressed: () async {
                  await _acceptGroupInvite(groupId, currentUId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE94560),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                  shadowColor: Color(0xFFE94560).withOpacity(0.4),
                ),
                child: Text(
                  "Accept",
                  style: appStyle(14, kWhite, FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
