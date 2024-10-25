import 'package:flutter/material.dart';

class MessagesBox extends StatelessWidget {
  final List<String> messages;
  final double height;
  final Color color;

  const MessagesBox({
    super.key,
    required this.messages,
    required this.height,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: height*screenHeight/100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            width: 2,
            color: color,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
            .map<Widget>((message) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    message, // Just the message, no key prefix
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
            .toList(),
          ),
        ),
      ),
    );
  }
}