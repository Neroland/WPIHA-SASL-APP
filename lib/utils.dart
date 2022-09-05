import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text, Color snackColor) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: snackColor,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Future<CroppedFile?> cropImage(
      file, double ratioX, double ratioY) async {
    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
    return croppedImage;
  }
}
