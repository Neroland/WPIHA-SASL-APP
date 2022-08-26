import 'package:flutter/material.dart';

Widget games() {
  return Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        heightFactor: 6,
        child: Container(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 10,
            color: Colors.red,
            backgroundColor: Colors.lightBlue,
          ),
        ),
      ),
    ),
  );
}
