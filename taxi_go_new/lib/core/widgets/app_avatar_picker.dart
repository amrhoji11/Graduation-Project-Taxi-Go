import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';

/// Circular profile photo with a camera-icon button that lets the user pick
/// a replacement from the gallery. Shows [pickedFile] when set (local
/// preview before saving), else [networkUrl] (the persisted photo), else
/// [fallbackIcon] - used identically across the passenger/driver/admin
/// profile edit dialogs so picking/preview behavior stays consistent.
class AppAvatarPicker extends StatelessWidget {
  final String? networkUrl;
  final File? pickedFile;
  final double radius;
  final IconData fallbackIcon;
  final ValueChanged<File> onPicked;

  const AppAvatarPicker({
    super.key,
    required this.onPicked,
    this.networkUrl,
    this.pickedFile,
    this.radius = 45,
    this.fallbackIcon = Icons.person,
  });

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = networkUrl != null && networkUrl!.isNotEmpty;
    final hasImage = pickedFile != null || hasNetworkImage;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: pickedFile != null
              ? FileImage(pickedFile!) as ImageProvider
              : hasNetworkImage
              ? NetworkImage(networkUrl!)
              : null,
          child: hasImage
              ? null
              : Icon(fallbackIcon, size: radius, color: AppColors.primary),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pick,
            child: CircleAvatar(
              radius: radius * 0.3,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.camera_alt,
                size: radius * 0.32,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
