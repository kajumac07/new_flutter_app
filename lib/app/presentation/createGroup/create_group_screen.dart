import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/models/group_model.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final List<String> _selectedMembers = [];
  List<Map<String, dynamic>> _followingUsers = [];
  bool _isLoading = true;
  bool _isGroupCreating = false;

  @override
  void initState() {
    super.initState();
    _fetchFollowingUsers();
  }

  Future<void> _fetchFollowingUsers() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("Persons")
          .doc(currentUId)
          .get();

      final List followingIds = userDoc["following"] ?? [];

      if (followingIds.isEmpty) {
        setState(() {
          _followingUsers = [];
          _isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("Persons")
          .where("uid", whereIn: followingIds)
          .get();

      setState(() {
        _followingUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "uid": data["uid"],
            "name": data["fullName"],
            "profilePic": data["profilePicture"],
            "username": data["userName"] ?? "",
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar("Error", "Failed to load contacts");
    }
  }

  Future<void> _createGroup() async {
    setState(() {
      _isGroupCreating = true;
    });
    if (_groupNameController.text.isEmpty) {
      showToastMessage(
        "Error",
        "Please firstly create a group name",
        kSecondary,
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      Get.snackbar("Error", "Please select at least one member");
      showToastMessage(
        "Error",
        "Please select at least one member",
        kSecondary,
      );
      return;
    }

    try {
      final groupDoc = FirebaseFirestore.instance.collection("groups").doc();
      final group = GroupModel(
        id: groupDoc.id,
        groupName: _groupNameController.text,
        creatorId: currentUser.uid,
        members: [currentUser.uid],
        pendingInvites: _selectedMembers,
        createdAt: Timestamp.now(),
      );

      await groupDoc.set(group.toMap());

      // Send invitations
      for (var uid in _selectedMembers) {
        await FirebaseFirestore.instance
            .collection("Persons")
            .doc(uid)
            .collection("groupInvites")
            .doc(groupDoc.id)
            .set({
              "groupId": groupDoc.id,
              "groupName": group.groupName,
              "invitedBy": currentUser.uid,
              "status": "pending",
              "timestamp": Timestamp.now(),
            });
      }

      Get.back();
      Get.snackbar(
        "Success",
        "Group created successfully!",
        backgroundColor: kPrimary,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create group",
        backgroundColor: kSecondary,
        colorText: kDark,
      );
    } finally {
      setState(() {
        _isGroupCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: kWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create New Group",
          style: appStyle(20, kWhite, FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.info_circle, color: kSecondary),
            onPressed: () {
              Get.defaultDialog(
                title: "Create Group",
                content: Text(
                  "Select people from your following list to add to your new group. They'll receive an invitation to join.",
                  style: appStyle(14, kWhite, FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: kSecondary,
                titleStyle: appStyle(18, kWhite, FontWeight.bold),
              );
            },
          ),
        ],
      ),
      body: _isGroupCreating
          ? Center(child: CircularProgressIndicator(color: kSecondary))
          : CustomGradientContainer(
              child: Column(
                children: [
                  // Group Name Input
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _groupNameController,
                        style: appStyle(16, kWhite, FontWeight.normal),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          hintText: "Enter group name...",
                          hintStyle: appStyle(
                            16,
                            kSecondary,
                            FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Iconsax.people, color: kSecondary),
                          suffixIcon: _groupNameController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Iconsax.close_circle,
                                    color: kSecondary,
                                  ),
                                  onPressed: () => _groupNameController.clear(),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Selected Members Count
                  if (_selectedMembers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${_selectedMembers.length} ${_selectedMembers.length == 1 ? 'person' : 'people'} selected",
                            style: appStyle(14, kSecondary, FontWeight.w500),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMembers.clear();
                              });
                            },
                            child: Text(
                              "Clear all",
                              style: appStyle(
                                14,
                                Color(0xFFE94560),
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Members List
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _followingUsers.isEmpty
                        ? _buildEmptyState()
                        : _buildMembersList(),
                  ),

                  // Create Button
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: kCardColor),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedMembers.isNotEmpty &&
                                  _groupNameController.text.isNotEmpty
                              ? Color(0xFFE94560)
                              : Color(0xFF2D3748),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Color(0xFFE94560).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.people, color: kWhite, size: 24),
                            SizedBox(width: 10),
                            Text(
                              "Create Group",
                              style: appStyle(16, kWhite, FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
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
              SizedBox(width: 16),
              // Shimmer text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Shimmer checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: kSecondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
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
          Icon(Iconsax.people, size: 64, color: kSecondary.withOpacity(0.5)),
          SizedBox(height: 20),
          Text(
            "No contacts found",
            style: appStyle(18, kWhite, FontWeight.w600),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "You need to follow people before you can add them to a group",
              textAlign: TextAlign.center,
              style: appStyle(14, kSecondary, FontWeight.normal),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE94560),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Explore People",
              style: appStyle(14, kWhite, FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _followingUsers.length,
      itemBuilder: (ctx, index) {
        final user = _followingUsers[index];
        final isSelected = _selectedMembers.contains(user["uid"]);

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE94560).withOpacity(0.1) : kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: Color(0xFFE94560).withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
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
                  backgroundImage: NetworkImage(user["profilePic"]),
                  backgroundColor: kCardColor,
                ),
              ),
            ),
            title: Text(
              user["name"],
              style: appStyle(16, kWhite, FontWeight.w600),
            ),
            subtitle: Text(
              "@${user["username"]}",
              style: appStyle(12, kSecondary, FontWeight.normal),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Color(0xFFE94560) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Color(0xFFE94560)
                      : kSecondary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedMembers.remove(user["uid"]);
                } else {
                  _selectedMembers.add(user["uid"]);
                }
              });
            },
          ),
        );
      },
    );
  }
}
