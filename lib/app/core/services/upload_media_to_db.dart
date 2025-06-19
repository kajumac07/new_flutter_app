import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_flutter_app/app/core/services/collection_refrence.dart';

Future<List<String>> uploadMediaFiles(
  String locationName,
  List<XFile> mediaFiles,
) async {
  List<String> downloadUrls = [];
  final storage = FirebaseStorage.instance;

  for (var mediaFile in mediaFiles) {
    try {
      // Create a unique filename
      String fileName =
          '$locationName/$currentUId/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.name}';

      // Upload the file
      TaskSnapshot snapshot = await storage
          .ref(fileName)
          .putFile(File(mediaFile.path));

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    } catch (e) {
      log('Error uploading file: $e');
      // You might want to continue with other files or abort
      rethrow;
    }
  }

  return downloadUrls;
}
