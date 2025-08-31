// screens/create_community_post_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/controller/community_controller.dart';
import 'package:new_flutter_app/app/global/models/community_post_model.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final CommunityController controller = Get.find<CommunityController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (controller.allCategories.isNotEmpty) {
      _selectedCategoryId = controller.allCategories.first.id;
      _selectedCategoryName = controller.allCategories.first.label;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar('Error', 'Please select a category');
        return;
      }

      final post = CommunityPost(
        id: '',
        userId: controller.currentUserId,
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategoryName!,
        categoryId: _selectedCategoryId!,
        createdAt: DateTime.now(),
        images: _selectedImages.map((image) => image.path).toList(),
      );

      controller.createPost(post);
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
      return SizedBox();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Images (${_selectedImages.length})',
            style: appStyle(16, kWhite, FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (context, index) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButtons() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          _buildImageButton(
            icon: Icons.photo_library,
            text: 'Gallery',
            onTap: _pickImages,
            color: kSecondary,
          ),
          SizedBox(width: 12.w),
          _buildImageButton(
            icon: Icons.camera_alt,
            text: 'Camera',
            onTap: _takePhoto,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20.w),
              SizedBox(width: 8.w),
              Text(text, style: appStyle(14, color, FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: Text(
          'Create Post',
          style: appStyle(20, kWhite, FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: kDark),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: kSecondary),
                  )
                : TextButton(
                    onPressed: _submitPost,
                    child: Text(
                      'Post',
                      style: appStyle(16, kSecondary, FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: CustomGradientContainer(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selection
                Text(
                  'Choose Category',
                  style: appStyle(16, kWhite, FontWeight.w600),
                ),
                SizedBox(height: 12.h),

                // Category Chips with Emojis
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: CircularProgressIndicator(color: kSecondary),
                      ),
                    );
                  }

                  if (controller.allCategories.isEmpty) {
                    return Text(
                      'No categories available',
                      style: appStyle(14, Colors.grey, FontWeight.w500),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: kCardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: kSecondary.withOpacity(0.2)),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: controller.allCategories.map((category) {
                        final isSelected = _selectedCategoryId == category.id;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.emoji ?? '📝',
                                style: TextStyle(fontSize: 16.w),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                category.label,
                                style: appStyle(
                                  14,
                                  isSelected ? kWhite : kWhite.withOpacity(0.8),
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryId = category.id;
                                _selectedCategoryName = category.label;
                              }
                            });
                          },
                          selectedColor: kSecondary,
                          backgroundColor: kCardColor,
                          side: BorderSide(
                            color: isSelected
                                ? kSecondary
                                : kSecondary.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  );
                }),
                SizedBox(height: 24.h),

                // Image Upload Section
                _buildImageButtons(),
                _buildImagePreview(),

                // Title Field
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: kCardColor),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    style: appStyle(18, kWhite, FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Add a catchy title...',
                      hintStyle: appStyle(18, Colors.grey, FontWeight.w500),
                      border: InputBorder.none,
                      icon: Icon(Icons.title, color: kSecondary, size: 20.w),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // Content Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: kCardColor),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: TextFormField(
                      controller: _contentController,
                      style: appStyle(16, kWhite, FontWeight.w400),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:
                            'Share your amazing travel experience... ✈️🌍',
                        hintStyle: appStyle(16, Colors.grey, FontWeight.w400),
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please share your experience';
                        }
                        return null;
                      },
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
}
