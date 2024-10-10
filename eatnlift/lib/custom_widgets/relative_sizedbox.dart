import 'package:flutter/material.dart';

class RelativeSizedBox extends StatelessWidget {
  final double width;
  final double height;

  const RelativeSizedBox({
    super.key,
    this.width = 0,
    this.height = 0,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: width*screenWidth/100,
      height: height*screenHeight/100,
    );
  }
}