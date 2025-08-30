import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'dart:io';

import 'package:new_flutter_app/app/global/widgets/custom_container.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Here you would typically upload the image to Firebase Storage
        // and update the group picture URL in Firestore
        Get.snackbar(
          "Image Selected",
          "Save changes to update group picture",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image");
    }
  }

  Future<void> _updateGroupDetails() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, Object?> updates = {};

      if (_descController.text.trim().isNotEmpty) {
        updates['groupDescription'] = _descController.text.trim();
      }

      if (_nameController.text.trim().isNotEmpty) {
        updates['groupName'] = _nameController.text.trim();
      }

      // Here you would add code to handle image upload to Firebase Storage
      // and add the download URL to the updates map
      // if (_selectedImage != null) {
      //   final String downloadUrl = await uploadImage(_selectedImage!);
      //   updates['groupPicture'] = downloadUrl;
      // }

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("groups")
            .doc(widget.groupId)
            .update(updates);

        Get.snackbar(
          "Success",
          "Group details updated",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to update group details");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMember(String memberId) async {
    if (memberId == currentUser.uid) {
      Get.defaultDialog(
        title: "Leave Group",
        content: Text(
          "Are you sure you want to leave this group?",
          style: appStyle(14, kWhite, FontWeight.normal),
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
                Get.back();
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
    } else {
      Get.defaultDialog(
        title: "Remove Member",
        content: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("Persons")
              .doc(memberId)
              .get(),
          builder: (context, snapshot) {
            final userName = snapshot.hasData && snapshot.data!.exists
                ? snapshot.data!['fullName'] ?? 'This user'
                : 'This user';
            return Text(
              "Are you sure you want to remove $userName from the group?",
              style: appStyle(14, kWhite, FontWeight.normal),
            );
          },
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
                      'members': FieldValue.arrayRemove([memberId]),
                    });
                Get.back();
                Get.snackbar(
                  "Member Removed",
                  "User has been removed from the group",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar("Error", "Failed to remove member");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE94560)),
            child: Text("Remove", style: appStyle(14, kWhite, FontWeight.w600)),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomGradientContainer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("groups")
              .doc(widget.groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFFE94560)),
              );
            }

            final groupData = snapshot.data!.data() as Map<String, dynamic>;
            final isAdmin = groupData['creatorId'] == currentUser.uid;
            final members = List<String>.from(groupData['members'] ?? []);

            if (!_isEditing) {
              _descController.text = groupData['groupDescription'] ?? '';
              _nameController.text = groupData['groupName'] ?? '';
            }

            return CustomScrollView(
              slivers: [
                // Header with group image and name
                SliverAppBar(
                  expandedHeight: 250.0,
                  backgroundColor: kCardColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Group image with gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xFF0F172A).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : groupData['groupPicture'] != null &&
                                    groupData['groupPicture'].isNotEmpty
                              ? Image.network(
                                  groupData['groupPicture'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Container(
                                  color: Color(0xFF1E293B),
                                  child: Icon(
                                    Iconsax.people,
                                    size: 80,
                                    color: kSecondary,
                                  ),
                                ),
                        ),
                        // Edit button for admin
                        if (isAdmin && _isEditing)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: FloatingActionButton(
                              onPressed: _pickImage,
                              backgroundColor: Color(0xFFE94560),
                              mini: true,
                              child: Icon(Iconsax.camera, color: kWhite),
                            ),
                          ),
                      ],
                    ),
                  ),
                  pinned: true,
                  actions: [
                    if (isAdmin)
                      IconButton(
                        icon: Icon(
                          _isEditing ? Iconsax.close_circle : Iconsax.edit_2,
                          color: kWhite,
                        ),
                        onPressed: () {
                          if (_isEditing) {
                            setState(() {
                              _isEditing = false;
                              _selectedImage = null;
                              _descController.text =
                                  groupData['groupDescription'] ?? '';
                              _nameController.text =
                                  groupData['groupName'] ?? '';
                            });
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                      ),
                  ],
                ),

                // Group details section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group name (editable for admin)
                        _isEditing && isAdmin
                            ? TextField(
                                controller: _nameController,
                                style: appStyle(24, kWhite, FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: "Group Name",
                                  hintStyle: appStyle(
                                    24,
                                    kSecondary,
                                    FontWeight.bold,
                                  ),
                                  border: InputBorder.none,
                                ),
                              )
                            : Text(
                                groupData['groupName'] ?? 'Unnamed Group',
                                style: appStyle(24, kWhite, FontWeight.bold),
                              ),

                        SizedBox(height: 8),

                        // Members count
                        Text(
                          "${members.length} members",
                          style: appStyle(14, kSecondary, FontWeight.normal),
                        ),

                        SizedBox(height: 20),

                        // Group description section
                        Text(
                          "Description",
                          style: appStyle(16, kWhite, FontWeight.w600),
                        ),

                        SizedBox(height: 8),

                        // Group description (editable for admin)
                        _isEditing && isAdmin
                            ? TextField(
                                controller: _descController,
                                style: appStyle(14, kWhite, FontWeight.normal),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "Add a group description...",
                                  hintStyle: appStyle(
                                    14,
                                    kSecondary,
                                    FontWeight.normal,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFF1E293B),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  groupData['groupDescription']?.isNotEmpty ==
                                          true
                                      ? groupData['groupDescription']
                                      : "No description added yet",
                                  style: appStyle(
                                    14,
                                    groupData['groupDescription']?.isNotEmpty ==
                                            true
                                        ? kWhite
                                        : kSecondary,
                                    FontWeight.normal,
                                  ),
                                ),
                              ),

                        SizedBox(height: 20),

                        // Save button when editing
                        if (_isEditing && isAdmin)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _updateGroupDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE94560),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kWhite,
                                      ),
                                    )
                                  : Text(
                                      "Save Changes",
                                      style: appStyle(
                                        16,
                                        kWhite,
                                        FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                        SizedBox(height: 30),

                        // Members section header
                        Row(
                          children: [
                            Text(
                              "Members",
                              style: appStyle(16, kWhite, FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "(${members.length})",
                              style: appStyle(
                                14,
                                kSecondary,
                                FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Members list
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final memberId = members[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("Persons")
                          .doc(memberId)
                          .get(),
                      builder: (context, userSnapshot) {
                        final userData =
                            userSnapshot.hasData && userSnapshot.data!.exists
                            ? userSnapshot.data!.data() as Map<String, dynamic>
                            : null;

                        final userName =
                            userData?['fullName'] ?? 'Unknown User';
                        final userImage = userData?['profilePicture'];
                        final isUserAdmin =
                            memberId == groupData['groupCreator'];

                        return ListTile(
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
                            child: CircleAvatar(
                              backgroundColor: kCardColor,
                              backgroundImage:
                                  userImage != null && userImage.isNotEmpty
                                  ? NetworkImage(userImage)
                                  : null,
                              child: userImage == null || userImage.isEmpty
                                  ? Icon(Iconsax.user, color: kWhite)
                                  : null,
                            ),
                          ),
                          title: Text(
                            userName,
                            style: appStyle(16, kWhite, FontWeight.normal),
                          ),
                          subtitle: isUserAdmin
                              ? Text(
                                  "Group Admin",
                                  style: appStyle(
                                    12,
                                    Color(0xFFE94560),
                                    FontWeight.normal,
                                  ),
                                )
                              : null,
                          trailing:
                              (isAdmin && memberId != currentUser.uid) ||
                                  (!isAdmin && memberId == currentUser.uid)
                              ? IconButton(
                                  icon: Icon(
                                    Iconsax.trash,
                                    color: kSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeMember(memberId),
                                )
                              : null,
                        );
                      },
                    );
                  }, childCount: members.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
