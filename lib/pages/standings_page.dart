import 'package:flutter/material.dart';

Widget standings() {
  return Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 10,
            width: 120,
            color: Colors.red,
          ),
          Container(
            height: 100,
            width: 120,
            color: Colors.green,
          ),
          Container(
            height: 100,
            width: 120,
            color: Colors.blue,
          ),
        ],
      ),
    ),
  );
}
