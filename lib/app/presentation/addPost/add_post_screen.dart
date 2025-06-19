import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/services/upload_media_to_db.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/controller/profile_controller.dart';
import 'package:new_flutter_app/app/global/helper/location_picker_sheet.dart';
import 'package:new_flutter_app/app/global/helper/tags_editor.dart';
import 'package:new_flutter_app/app/global/models/category_model.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final profileController = Get.put(ProfileController());

  List<XFile> _mediaFiles = [];
  DateTime? _scheduledDate;
  bool _isPublic = true;
  List<String> _tags = [];
  bool _isLoading = false;

  List<CategoryItem> _allCategories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;

  // Colors for category chips
  final List<Color> _categoryColors = [
    const Color(0xFF4285F4), // Blue
    const Color(0xFF34A853), // Green
    const Color(0xFFEA4335), // Red
    const Color(0xFFFBBC05), // Yellow
    const Color(0xFF673AB7), // Purple
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF009688), // Teal
    const Color(0xFFE91E63), // Pink
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      setState(() => _isLoadingCategories = true);
      final snapshot = await FirebaseFirestore.instance
          .collection("Categories")
          .get();

      // Flatten all categories from all documents
      _allCategories = [];
      for (var doc in snapshot.docs) {
        final categoryModel = CategoryModel.fromDoc(doc.id, doc.data());
        _allCategories.addAll(categoryModel.lists);
      }

      setState(() {});
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _mediaFiles = pickedFiles;
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _addTag() {
    if (_tagsController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectScheduleDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitPost() async {
    try {
      setState(() => _isLoading = true);

      // 1. Upload media files to storage
      List<String> mediaUrls = [];
      if (_mediaFiles.isNotEmpty) {
        mediaUrls = await uploadMediaFiles("posts", _mediaFiles);
      }

      // Create a batch write
      final batch = FirebaseFirestore.instance.batch();

      // Create a new document reference with auto-generated ID
      final postRef = FirebaseFirestore.instance.collection('Posts').doc();

      // 2. Prepare post data
      final postData = {
        'uid': currentUId,
        'postId': postRef.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'media': mediaUrls,
        'category': _selectedCategoryId != null ? [_selectedCategoryId!] : [],
        'location': _locationController.text.trim(),
        'isPublic': _isPublic,
        'allowComments': true,
        'tags': _tags,
        'created_at': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
        'scheduled_at': _scheduledDate ?? DateTime.now(),
        'status': _scheduledDate == null ? 'published' : 'scheduled',
      };

      // 3. Save to Firestore
      batch.set(postRef, postData);
      // Commit the batch
      await batch.commit();
      // 4. Show success and close
      showToastMessage("Success", "Post Published Successfully", kPrimary);
      setState(() {
        _isLoading = false;
      });
      _resetForm();
    } catch (e) {
      showToastMessage("Error", "Error Publishing Post $e", kRed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryChips() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allCategories.isEmpty) {
      return const Text('No categories available');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allCategories.map((category) {
        final colorIndex =
            _allCategories.indexOf(category) % _categoryColors.length;
        final color = _categoryColors[colorIndex];

        return FilterChip(
          selected: _selectedCategoryId == category.label,
          label: Text(
            category.label,
            style: TextStyle(
              color: _selectedCategoryId == category.label
                  ? Colors.white
                  : color,
              fontWeight: FontWeight.w500,
            ),
          ),
          avatar: category.emoji.isNotEmpty ? Text(category.emoji) : null,
          onSelected: (selected) {
            setState(() {
              _selectedCategoryId = selected ? category.label : null;
            });
          },
          backgroundColor: Colors.white,
          selectedColor: color,
          side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  void _resetForm() {
    // Clear text fields
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _tagsController.clear();

    // Clear media files
    setState(() {
      _mediaFiles = [];
    });

    // Reset category selection
    setState(() {
      _selectedCategoryId = null;
    });

    // Reset tags
    setState(() {
      _tags = [];
    });

    // Reset schedule
    setState(() {
      _scheduledDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kSecondary,
        foregroundColor: kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Info
              _buildAuthorInfo(profileController),
              const SizedBox(height: 24),

              // Media Upload
              _buildMediaUploadSection(),
              const SizedBox(height: 28),

              // Post Content
              _buildPostContentSection(),
              const SizedBox(height: 28),

              // Post Settings
              _buildPostSettingsSection(),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(profileController) {
    final user = profileController.currentUser;
    if (profileController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (user == null) {
      return const Center(child: Text('User not found'));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              user?.profilePicture.isNotEmpty
                  ? user.profilePicture
                  : 'https://via.placeholder.com/150',
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Anonymous',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                _isPublic ? 'Visible to everyone' : 'Visible to you only',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isPublic ? Colors.blue[50] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPublic ? Icons.public : Icons.lock_outline,
                size: 20,
                color: _isPublic ? Colors.blue : Colors.grey[700],
              ),
            ),
            onPressed: () {
              setState(() => _isPublic = !_isPublic);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'MEDIA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (_mediaFiles.isEmpty)
          GestureDetector(
            onTap: _pickMedia,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add photos or videos',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPEG, PNG, MP4 up to 10MB',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == _mediaFiles.length - 1 ? 0 : 12,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.file(
                                File(_mediaFiles[index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add More',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onPressed: _pickMedia,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPostContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          decoration: InputDecoration(
            labelText: 'Post title',
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            labelText: 'What would you like to share?',
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Categories
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _buildCategoryChips(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'POST SETTINGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Location
              _buildSettingTile(
                icon: Icons.location_on_outlined,
                title: 'Add Location',
                subtitle: _locationController.text.isEmpty
                    ? 'Not specified'
                    : _locationController.text,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => LocationPickerSheet(
                      controller: _locationController,
                      onSave: () => setState(() {}),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // Tags
              _buildSettingTile(
                icon: Icons.tag_outlined,
                title: 'Add Tags',
                subtitle: _tags.isEmpty ? 'Not specified' : _tags.join(', '),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) => TagsEditorSheet(
                      tags: _tags,
                      controller: _tagsController,
                      onAdd: _addTag,
                      onRemove: _removeTag,
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),

              // Schedule
              _buildSettingTile(
                icon: Icons.schedule_outlined,
                title: 'Schedule Post',
                subtitle: _scheduledDate == null
                    ? 'Post immediately'
                    : 'Schedule for ${_scheduledDate!.toString()}',
                onTap: _selectScheduleDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      minVerticalPadding: 0,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: _isLoading ? null : _submitPost,
        child: _isLoading
            ? CircularProgressIndicator()
            : Text(
                'Publish Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
