import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_header.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditUserPage({
    super.key,
    required this.userData,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final SessionStorage sessionStorage = SessionStorage();

  Map<String, dynamic> response = {};

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.userData?['description'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final updatedDescription = _descriptionController.text;
    final updatedImage = _selectedImage?.path;

    final data = {
      'description': updatedDescription,
      'picture': updatedImage,
    };

    final apiService = ApiUserService();
    final result = await apiService.updateProfile(data);

    if (result["success"]) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        response = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentImagePath = widget.userData?['imagePath'];
    final bool isNetworkImage = currentImagePath != null && currentImagePath.startsWith("http");
    final String username = widget.userData?['username'] ?? '';
    final String email = widget.userData?['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(title: "Editar perfil"),

              RelativeSizedBox(height: 2),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ExpandableImage(
                            initialImagePath: currentImagePath,
                            isNetwork: isNetworkImage,
                            onImageSelected: (imageFile) {
                              setState(() {
                                _selectedImage = imageFile;
                              });
                            },
                            editable: true,
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 27,
                                ),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      RelativeSizedBox(height: 2),

                      CustomTextfield(
                        controller: _descriptionController,
                        hintText: "Afegeix una descripció",
                        obscureText: false,
                        maxLines: 5,
                      ),

                      RelativeSizedBox(height: 2),

                      CustomButton(
                        text: "Desar els canvis",
                        icon: Icons.save,
                        onTap: _saveChanges,
                        height: 50,
                      ),

                      if (response.isNotEmpty && !response["success"]) ...[
                        const RelativeSizedBox(height: 3),
                        MessagesBox(
                          messages: response["errors"],
                          height: 6,
                          color: Colors.red,
                        ),
                        const RelativeSizedBox(height: 3),
                      ] else ...[
                        const RelativeSizedBox(height: 5),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}