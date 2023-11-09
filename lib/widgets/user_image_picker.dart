import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onSelectImage});

  final void Function(File selectedFile) onSelectImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _selecedImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();

    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxHeight: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selecedImage = File(pickedImage.path);
    });

    widget.onSelectImage(_selecedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CricleAvatar(selecedImage: _selecedImage),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image_rounded),
          label: Text(
            "Add Image",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        )
      ],
    );
  }
}

class CricleAvatar extends StatelessWidget {
  const CricleAvatar({
    super.key,
    required File? selecedImage,
  }) : _selecedImage = selecedImage;

  final File? _selecedImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        foregroundImage:
            _selecedImage != null ? FileImage(_selecedImage!) : null,
      ),
    );
  }
}
