import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import './custom_button.dart';

class ExpandableImage extends StatefulWidget {
  final String? initialImagePath;
  final bool isNetwork;
  final Function(File? imageFile)? onImageSelected;
  final bool editable;
  final int width;
  final int height;

  const ExpandableImage({
    super.key,
    required this.initialImagePath,
    this.isNetwork = false,
    this.onImageSelected,
    this.width = 100,
    this.height = 100,
    this.editable = false,
  });

  @override
  ExpandableImageState createState() => ExpandableImageState();
}

class ExpandableImageState extends State<ExpandableImage> {
  File? imageFile;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNetwork && widget.initialImagePath != null) {
      try {
        imageFile = File(widget.initialImagePath!);
        if (!imageFile!.existsSync()) {
          throw Exception("File does not exist");
        }
      } catch (e) {
        hasError = true;
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        hasError = false;
      });
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);
      }
    }
  }

  void _showExpandedImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 350,
              maxWidth: 350,
            ),
            child: Container(
              width: 350,
              height: 350,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey, width: 3),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: InteractiveViewer(
                            child: hasError || imageFile == null
                                ? Icon(Icons.broken_image, size: 50, color: Colors.grey)
                                : (widget.isNetwork
                                    ? Image.network(widget.initialImagePath!, fit: BoxFit.contain)
                                    : Image.file(imageFile!, fit: BoxFit.contain)),
                          ),
                        ),
                      ),
                      if (widget.editable)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            text: "Edit Image",
                            width: 130,
                            height: 40,
                            onTap: () async {
                              await _pickImage();
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            icon: Icons.edit,
                          ),
                        ),
                    ],
                  ),
                  Positioned(
                    top: -15,
                    right: -15,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.all(0),
                      constraints: BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExpandedImage(context),
      child: Container(
        height: widget.height.toDouble(),
        width: widget.width.toDouble(),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(10),
          image: hasError || imageFile == null
              ? null
              : widget.isNetwork
                  ? DecorationImage(
                      image: NetworkImage(widget.initialImagePath!),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    ),
        ),
        child: hasError || (imageFile == null && !widget.isNetwork)
            ? Center(child: Icon(Icons.add_a_photo, color: Colors.grey))
            : null,
      ),
    );
  }
}