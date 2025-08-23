import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File?> compressImage(File file, {int quality = 75}) async {
  try {
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    // Compress the image
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: quality,
      minWidth: 1080, // Maximum width
      minHeight: 1080, // Maximum height
    );

    return result != null ? File(result.path) : null;
  } catch (e) {
    log('Error compressing image: $e');
    return file;
  }
}
