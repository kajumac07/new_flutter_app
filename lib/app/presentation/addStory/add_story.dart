import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
import 'package:new_flutter_app/app/global/helper/compress_image.dart';
import 'package:new_flutter_app/app/global/models/category_model.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _locationControllers = [];
  final List<TextEditingController> _activityControllers = [];
  List<XFile> _mediaFiles = [];
  final List<String> _tags = [];
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _fullStoryController = TextEditingController();
  final _accommodationCostController = TextEditingController();
  final _foodCostController = TextEditingController();
  final _transportCostController = TextEditingController();
  final _activitiesCostController = TextEditingController();
  final _stayNameController = TextEditingController();
  final _stayReviewController = TextEditingController();
  final _travelTipsController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  double _tripRating = 3.0;
  double _budgetRating = 3.0;
  double _safetyRating = 3.0;

  List<CategoryItem> _allCategories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _addLocationField();
    _addActivityField();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      setState(() => _isLoadingCategories = true);

      final snapshot = await FirebaseFirestore.instance
          .collection("Categories")
          .get();

      // Flatten and filter categories
      _allCategories = [];
      for (var doc in snapshot.docs) {
        final categoryModel = CategoryModel.fromDoc(doc.id, doc.data());
        _allCategories.addAll(
          categoryModel.lists.where((item) => item.isCommunity == false),
        );
      }

      setState(() {}); // trigger UI update
    } catch (e) {
      // Handle error gracefully (maybe show a snackbar or toast)
      debugPrint("Error fetching categories: $e");
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  void _addLocationField() {
    setState(() {
      _locationControllers.add(TextEditingController());
    });
  }

  void _removeLocationField(int index) {
    setState(() {
      _locationControllers.removeAt(index);
    });
  }

  void _addActivityField() {
    setState(() {
      _activityControllers.add(TextEditingController());
    });
  }

  void _removeActivityField(int index) {
    setState(() {
      _activityControllers.removeAt(index);
    });
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add('#${_tagController.text}');
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
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

  // Future<List<String>> _uploadMediaFiles() async {
  //   List<String> downloadUrls = [];
  //   final storage = FirebaseStorage.instance;

  //   for (var mediaFile in _mediaFiles) {
  //     try {
  //       // Create a unique filename
  //       String fileName =
  //           'stories/$currentUId/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.name}';

  //       // Upload the file
  //       TaskSnapshot snapshot = await storage
  //           .ref(fileName)
  //           .putFile(File(mediaFile.path));

  //       // Get download URL
  //       String downloadUrl = await snapshot.ref.getDownloadURL();
  //       downloadUrls.add(downloadUrl);
  //     } catch (e) {
  //       log('Error uploading file: $e');
  //       rethrow;
  //     }
  //   }

  //   return downloadUrls;
  // }

  Future<List<String>> _uploadMediaFiles() async {
    List<String> downloadUrls = [];
    final storage = FirebaseStorage.instance;

    for (var mediaFile in _mediaFiles) {
      try {
        // Compress the image first
        File? compressedFile;
        if (mediaFile.path.toLowerCase().endsWith('.jpg') ||
            mediaFile.path.toLowerCase().endsWith('.jpeg') ||
            mediaFile.path.toLowerCase().endsWith('.png')) {
          compressedFile = await compressImage(File(mediaFile.path));
        }

        // Use the compressed file if available, otherwise use original
        final fileToUpload = compressedFile ?? File(mediaFile.path);

        // Create a unique filename
        String fileName =
            'stories/$currentUId/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.name}';

        // Upload the file
        TaskSnapshot snapshot = await storage
            .ref(fileName)
            .putFile(fileToUpload);

        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        // Delete the temporary compressed file if it exists
        if (compressedFile != null && compressedFile.existsSync()) {
          compressedFile.deleteSync();
        }
      } catch (e) {
        log('Error uploading file: $e');
        rethrow;
      }
    }

    return downloadUrls;
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      showToastMessage("Error", "Please select trip dates", kRed);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 1. Upload media files to storage
      List<String> mediaUrls = [];
      if (_mediaFiles.isNotEmpty) {
        mediaUrls = await _uploadMediaFiles();
      }

      // Create a batch write
      final batch = FirebaseFirestore.instance.batch();

      // Create a new document reference with auto-generated ID
      final storyRef = FirebaseFirestore.instance.collection('Stories').doc();

      // 2. Prepare the story data
      final storyData = {
        'sId': storyRef.id,
        'uid': currentUId.toString(),
        'title': _titleController.text.trim(),
        'summary': _summaryController.text.trim(),
        'fullStory': _fullStoryController.text.trim(),
        'locations': _locationControllers
            .where((controller) => controller.text.isNotEmpty)
            .map((controller) => controller.text.trim())
            .toList(),
        'budget': {
          'accommodation': int.tryParse(_accommodationCostController.text) ?? 0,
          'food': int.tryParse(_foodCostController.text) ?? 0,
          'transport': int.tryParse(_transportCostController.text) ?? 0,
          'activities': int.tryParse(_activitiesCostController.text) ?? 0,
          'total':
              (int.tryParse(_accommodationCostController.text) ?? 0) +
              (int.tryParse(_foodCostController.text) ?? 0) +
              (int.tryParse(_transportCostController.text) ?? 0) +
              (int.tryParse(_activitiesCostController.text) ?? 0),
        },
        'stay': {
          'name': _stayNameController.text.trim(),
          'review': _stayReviewController.text.trim(),
        },
        'thingsToDo': _activityControllers
            .where((controller) => controller.text.isNotEmpty)
            .map((controller) => controller.text.trim())
            .toList(),
        'media': mediaUrls,
        'category': _selectedCategory,
        'tags': _tags,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'ratings': {
          'tripExperience': _tripRating,
          'budgetFriendliness': _budgetRating,
          'safety': _safetyRating,
        },
        'travelTips': _travelTipsController.text.trim(),
        'likes': [],
        'comments': [],
        'isComentable': true,
        'isPublic': true,
        'isFeatured': false,
        'isShared': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final userRef = FirebaseFirestore.instance
          .collection('Persons')
          .doc(currentUId);
      final userData = {
        'stories': FieldValue.arrayUnion([storyRef.id]),
      };
      // 3. Update user profile with stories array
      batch.update(userRef, userData);
      // 3. Save to Firestore
      batch.set(storyRef, storyData);
      // Commit the batch
      await batch.commit();
      // 4. Show success and close
      showToastMessage("Success", "Story published successfully!", kPrimary);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showToastMessage("Error", "Failed to publish story: $e", kRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Share Your Adventure"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Title & Description
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('✏️ Story Overview', icon: Icons.edit),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Trip Title',
                        hint: 'E.g., "5 Days in Manali on a Budget"',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _summaryController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Short Summary',
                        hint: 'Brief highlights of your trip',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullStoryController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Full Story',
                        hint: 'Share your detailed experience...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Trip Details Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🗺️ Trip Details', icon: Icons.place),
                    const SizedBox(height: 12),

                    // Locations
                    ..._locationControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                style: const TextStyle(fontSize: 16),
                                decoration: _buildInputDecoration(
                                  label: 'Place ${index + 1}',
                                  hint: 'City or specific location',
                                  prefixIcon: Icons.location_on,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red[400],
                                size: 28,
                              ),
                              onPressed: () => _removeLocationField(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    _buildAddButton(
                      text: 'Add another place',
                      onPressed: _addLocationField,
                    ),
                    const SizedBox(height: 20),

                    // Trip Duration
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: _buildInputDecoration(
                                label: 'Start Date',
                                prefixIcon: Icons.calendar_today,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startDate == null
                                        ? 'Select date'
                                        : _startDate.toString().substring(
                                            0,
                                            10,
                                          ),
                                    style: appStylePoppins(
                                      12,
                                      kDark,
                                      FontWeight.w300,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, size: 10.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: _buildInputDecoration(
                                label: 'End Date',
                                prefixIcon: Icons.calendar_today,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endDate == null
                                        ? 'Select date'
                                        : _endDate.toString().substring(0, 10),
                                    style: appStylePoppins(
                                      12,
                                      kDark,
                                      FontWeight.w300,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, size: 10.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            children: [
                              const TextSpan(text: 'Duration: '),
                              TextSpan(
                                text:
                                    '${_endDate!.difference(_startDate!).inDays + 1} days',
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Budget Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      '💸 Budget Breakdown',
                      icon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share your expenses to help others plan better',
                      style: appStylePoppins(
                        12,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCurrencyInput(
                            controller: _accommodationCostController,
                            label: 'Accommodation',
                            icon: Icons.hotel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCurrencyInput(
                            controller: _foodCostController,
                            label: 'Food',
                            icon: Icons.restaurant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCurrencyInput(
                            controller: _transportCostController,
                            label: 'Transport',
                            icon: Icons.directions_bus,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCurrencyInput(
                            controller: _activitiesCostController,
                            label: 'Activities',
                            icon: Icons.landscape,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Accommodation Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🏠 Accommodation', icon: Icons.hotel),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stayNameController,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Where did you stay?',
                        hint: 'Hotel/Hostel name',
                        prefixIcon: Icons.business,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stayReviewController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Your experience',
                        hint: 'Share your review...',
                        prefixIcon: Icons.star,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Activities Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      '🚴 Activities',
                      icon: Icons.directions_run,
                    ),
                    const SizedBox(height: 12),
                    ..._activityControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                style: const TextStyle(fontSize: 16),
                                decoration: _buildInputDecoration(
                                  label: 'Activity ${index + 1}',
                                  hint: 'What did you do?',
                                  prefixIcon: Icons.emoji_events,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red[400],
                                size: 28,
                              ),
                              onPressed: () => _removeActivityField(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    _buildAddButton(
                      text: 'Add another activity',
                      onPressed: _addActivityField,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Media Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('📷 Media', icon: Icons.photo_library),
                    const SizedBox(height: 12),
                    if (_mediaFiles.isEmpty)
                      GestureDetector(
                        onTap: _pickMedia,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add photos/videos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(Up to 10 items)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount:
                                _mediaFiles.length +
                                (_mediaFiles.length < 10 ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _mediaFiles.length) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_mediaFiles[index].path),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _mediaFiles.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
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
                                );
                              } else {
                                return GestureDetector(
                                  onTap: _pickMedia,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_mediaFiles.length < 10)
                            _buildAddButton(
                              text: 'Add more photos',
                              onPressed: _pickMedia,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tags & Category Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🏷️ Tags & Category', icon: Icons.tag),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _buildInputDecoration(
                        label: 'Category',
                        prefixIcon: Icons.category,
                      ),
                      items: _allCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.label,
                          child: Text(category.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagController,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Add tags',
                        hint: 'E.g., budget, solo, hiking',
                        prefixIcon: Icons.tag,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ),
                      onFieldSubmitted: (value) => _addTag(),
                    ),
                    const SizedBox(height: 12),
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tag = entry.value;
                          return Chip(
                            label: Text(tag),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            backgroundColor: kPrimary,
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                            onDeleted: () => _removeTag(index),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Travel Tips Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      '🕐 Travel Tips',
                      icon: Icons.lightbulb,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share your advice to help fellow travelers',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _travelTipsController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                      decoration: _buildInputDecoration(
                        label: 'Your tips & advice',
                        hint: 'What to pack, best time to visit, warnings etc.',
                        prefixIcon: Icons.help_outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ratings Section
              _buildModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🎯 Rate Your Trip', icon: Icons.star),
                    const SizedBox(height: 12),
                    _buildRatingRow('Overall Experience', _tripRating, (value) {
                      setState(() {
                        _tripRating = value;
                      });
                    }),
                    _buildRatingRow('Budget Friendliness', _budgetRating, (
                      value,
                    ) {
                      setState(() {
                        _budgetRating = value;
                      });
                    }),
                    _buildRatingRow('Safety', _safetyRating, (value) {
                      setState(() {
                        _safetyRating = value;
                      });
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: kPrimary.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Publish Your Adventure',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: kPrimary, size: 24),
        if (icon != null) const SizedBox(width: 8),
        Text(title, style: appStyleRaleway(18, kDark, FontWeight.w600)),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: appStylePoppins(13, Colors.black54, FontWeight.w500),
      hintStyle: appStylePoppins(13, Colors.grey[400]!, FontWeight.w400),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[600])
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 10),
      decoration: _buildInputDecoration(
        label: label,
        prefixIcon: icon,
        // suffixIcon: const Text(
        //   '₹',
        //   style: TextStyle(fontSize: 8, color: Colors.black87),
        // ),
      ),
    );
  }

  Widget _buildAddButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRatingRow(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Slider(
                  value: value,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: value.toStringAsFixed(1),
                  onChanged: onChanged,
                  activeColor: kPrimary,
                  inactiveColor: const Color(0xFFD6D3F0),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: kPrimary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _locationControllers) {
      controller.dispose();
    }
    for (var controller in _activityControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _summaryController.dispose();
    _fullStoryController.dispose();
    _accommodationCostController.dispose();
    _foodCostController.dispose();
    _transportCostController.dispose();
    _activitiesCostController.dispose();
    _stayNameController.dispose();
    _stayReviewController.dispose();
    _travelTipsController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
