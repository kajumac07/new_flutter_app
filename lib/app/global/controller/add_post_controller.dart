// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:new_flutter_app/app/core/constants/constdata.dart';
// import 'package:new_flutter_app/app/core/services/collection_refrence.dart';
// import 'package:new_flutter_app/app/core/utils/toast_msg.dart';
// import 'package:new_flutter_app/app/global/models/category_model.dart';

// class AddPostController extends GetxController {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController tagsController = TextEditingController();

//   final RxList<XFile> mediaFiles = <XFile>[].obs;
//   Rxn<DateTime> scheduledDate = Rxn<DateTime>();
//   RxBool isPublic = true.obs;
//   RxList<String> tags = <String>[].obs;
//   RxBool isLoading = false.obs;

//   RxList<CategoryItem> allCategories = <CategoryItem>[].obs;
//   Rxn<String> selectedCategoryId = Rxn<String>();
//   RxBool isLoadingCategories = true.obs;

//   // Colors for category chips
//   final List<Color> categoryColors = [
//     const Color(0xFF4285F4), // Blue
//     const Color(0xFF34A853), // Green
//     const Color(0xFFEA4335), // Red
//     const Color(0xFFFBBC05), // Yellow
//     const Color(0xFF673AB7), // Purple
//     const Color(0xFFFF5722), // Deep Orange
//     const Color(0xFF009688), // Teal
//     const Color(0xFFE91E63), // Pink
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     fetchCategories();
//   }

//   void fetchCategories() async {
//     try {
//       isLoadingCategories.value = true;
//       final snapshot = await FirebaseFirestore.instance
//           .collection("Categories")
//           .get();

//       // Flatten all categories from all documents
//       allCategories.clear();
//       for (var doc in snapshot.docs) {
//         final categoryModel = CategoryModel.fromDoc(doc.id, doc.data());
//         allCategories.addAll(categoryModel.lists);
//       }
//     } catch (e) {
//       log("Error fetching categories: $e");
//     } finally {
//       isLoadingCategories.value = false;
//     }
//   }

//   Future<void> pickMedia() async {
//     final ImagePicker picker = ImagePicker();
//     final List<XFile>? pickedFiles = await picker.pickMultiImage();
//     if (pickedFiles != null) {
//       mediaFiles.assignAll(pickedFiles);
//     }
//   }

//   Future<List<String>> uploadMediaFiles() async {
//     List<String> downloadUrls = [];
//     final storage = FirebaseStorage.instance;

//     for (var mediaFile in mediaFiles) {
//       try {
//         // Create a unique filename
//         String fileName =
//             'posts/$currentUId/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.name}';

//         // Upload the file
//         TaskSnapshot snapshot = await storage
//             .ref(fileName)
//             .putFile(File(mediaFile.path));

//         // Get download URL
//         String downloadUrl = await snapshot.ref.getDownloadURL();
//         downloadUrls.add(downloadUrl);
//       } catch (e) {
//         log('Error uploading file: $e');
//         rethrow;
//       }
//     }

//     return downloadUrls;
//   }

//   void removeMedia(int index) {
//     mediaFiles.removeAt(index);
//   }

//   void addTag() {
//     if (tagsController.text.trim().isNotEmpty) {
//       tags.add(tagsController.text.trim());
//       tagsController.clear();
//     }
//   }

//   void removeTag(String tag) {
//     tags.remove(tag);
//   }

//   Future<void> selectScheduleDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       final TimeOfDay? time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (time != null) {
//         scheduledDate.value = DateTime(
//           picked.year,
//           picked.month,
//           picked.day,
//           time.hour,
//           time.minute,
//         );
//       }
//     }
//   }

//   Future<void> submitPost() async {
//     try {
//       isLoading.value = true;

//       // 1. Upload media files to storage
//       List<String> mediaUrls = [];
//       if (mediaFiles.isNotEmpty) {
//         mediaUrls = await uploadMediaFiles();
//       }

//       // Create a batch write
//       final batch = FirebaseFirestore.instance.batch();

//       // Create a new document reference with auto-generated ID
//       final postRef = FirebaseFirestore.instance.collection('Posts').doc();

//       // 2. Prepare post data
//       final postData = {
//         'uid': currentUId,
//         'postId': postRef.id,
//         'title': titleController.text.trim(),
//         'description': descriptionController.text.trim(),
//         'media': mediaUrls,
//         'category': selectedCategoryId.value != null
//             ? [selectedCategoryId.value!]
//             : [],
//         'location': locationController.text.trim(),
//         'isPublic': isPublic.value,
//         'allowComments': true,
//         'tags': tags,
//         'created_at': FieldValue.serverTimestamp(),
//         'likes': [],
//         'comments': [],
//         'scheduled_at': scheduledDate.value ?? DateTime.now(),
//         'status': scheduledDate.value == null ? 'published' : 'scheduled',
//       };

//       // 3. Save to Firestore
//       batch.set(postRef, postData);
//       // Commit the batch
//       await batch.commit();
//       // 4. Show success and close
//       showToastMessage("Success", "Post Published Successfully", kPrimary);
//       resetForm();
//     } catch (e) {
//       showToastMessage("Error", "Error Publishing Post $e", kRed);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void resetForm() {
//     // Clear text fields
//     titleController.clear();
//     descriptionController.clear();
//     locationController.clear();
//     tagsController.clear();

//     // Clear media files
//     mediaFiles.clear();

//     // Reset category selection
//     selectedCategoryId.value = null;

//     // Reset tags
//     tags.clear();

//     // Reset schedule
//     scheduledDate.value = null;
//   }
// }
