import 'package:eatnlift/custom_widgets/rotating_logo.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/expandable_image.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/relative_sizedbox.dart';
import '../../custom_widgets/messages_box.dart';

import '../../services/api_user_service.dart';
import '../../services/session_storage.dart';
import '../../services/storage_service.dart';

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

  String? initialDescription;
  String? initialImagePath;
  Map<String, dynamic> response = {};

  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    initialDescription = widget.userData?['description'];
    initialImagePath = widget.userData?['picture'];
    _descriptionController.text = initialDescription ?? '';
  }

  Future<void> _saveChanges() async {
    final updatedDescription = _descriptionController.text;
    String? updatedImageURL;

    final Map<String, dynamic> data = {};

    if (updatedDescription != initialDescription) {
      data['description'] = updatedDescription;
    }

    if (_selectedImage != null) {
      setState(() {
        isUploadingImage = true;
      });

      final storageService = StorageService();
      updatedImageURL = await storageService.uploadImage(
        _selectedImage!,
        'user_profile/${_selectedImage!.path.split('/').last}',
      );

      setState(() {
        isUploadingImage = false;
      });

      data['picture'] = updatedImageURL;
    }

    if (data.isNotEmpty) {
      final apiService = ApiUserService();
      final result = await apiService.updateProfile(data);

      if (result["success"]) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          response = result;
        });
      }
    } else {
      if (mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentImagePath = widget.userData?['picture'];
    final String username = widget.userData?['username'] ?? '';
    final String email = widget.userData?['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text("Editar perfil"),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RelativeSizedBox(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ExpandableImage(
                                initialImageUrl: currentImagePath,
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
              if (isUploadingImage) ...[
                Column(
                  children: [
                    RelativeSizedBox(height: 60),
                    Align(
                      alignment: Alignment.center,
                      child: RotatingImage(),
                    ),
                  ]
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}