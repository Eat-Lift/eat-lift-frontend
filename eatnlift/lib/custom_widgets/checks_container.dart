import 'package:eatnlift/custom_widgets/check_card.dart';
import 'package:flutter/material.dart';

class ChecksContainer extends StatelessWidget {
  final List<String> checks;
  final double height;
  final String? title;

  const ChecksContainer({
    super.key,
    required this.checks,
    this.height = 170,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Revisions",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            children: [
              checks.isNotEmpty
                  ? ListView.builder(
                      itemCount: checks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: CheckCard(date: checks[index]),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No hi ha revisions",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              if (title != null) ...[
                Positioned(
                  top: 8,
                  left: 8,
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}