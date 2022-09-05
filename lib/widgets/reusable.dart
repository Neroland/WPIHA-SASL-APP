import 'package:flutter/material.dart';

Widget spacer(double height) {
  return SizedBox(
    height: height,
  );
}

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}
