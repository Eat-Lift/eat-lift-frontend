import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextAlign textAlign;
  final double size;

  const ExpandableText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.justify,
    this.size = 14,
  });

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: widget.text,
          style: TextStyle(fontSize: 16),
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 5, // Max lines before overflow
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);
        isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: TextStyle(fontSize: widget.size),
              maxLines: isExpanded ? null : 5,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              textAlign: widget.textAlign,
            ),
            if (isOverflowing) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? "Mostrar menys" : "Mostrar més",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ]  
          ],
        );
      },
    );
  }
}