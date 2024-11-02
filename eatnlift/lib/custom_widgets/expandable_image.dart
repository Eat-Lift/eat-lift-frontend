import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import './custom_button.dart';

class ExpandableImage extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File imageFile)? onImageSelected;
  final bool editable;
  final double width;
  final double height;

  const ExpandableImage({
    super.key,
    required this.initialImageUrl,
    this.onImageSelected,
    this.width = 100,
    this.height = 100,
    this.editable = false,
  });

  @override
  ExpandableImageState createState() => ExpandableImageState();
}

class ExpandableImageState extends State<ExpandableImage> {
  File? selectedImageFile;

  @override
  void initState() {
    super.initState();
    // initial image will display via URL if provided
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        selectedImageFile = imageFile;
      });
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);  // Return the File to the parent widget
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
                  Center(
                    child: InteractiveViewer(
                      child: selectedImageFile != null
                          ? Image.file(selectedImageFile!, fit: BoxFit.contain)
                          : (widget.initialImageUrl != null
                              ? Image.network(widget.initialImageUrl!, fit: BoxFit.contain)
                              : Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
                    ),
                  ),
                  if (widget.editable)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: CustomButton(
                        text: "Edita la image",
                        width: 50,
                        height: 40,
                        onTap: () async {
                          await _pickImage();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: Icons.edit,
                      ),
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
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(10),
          image: selectedImageFile != null
              ? DecorationImage(
                  image: FileImage(selectedImageFile!),
                  fit: BoxFit.cover,
                )
              : (widget.initialImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.initialImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
        ),
        child: (selectedImageFile == null && widget.initialImageUrl == null)
            ? Center(child: Icon(Icons.add_a_photo, color: Colors.grey))
            : null,
      ),
    );
  }
}