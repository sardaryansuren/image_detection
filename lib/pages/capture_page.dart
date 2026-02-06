import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/ml_controller.dart';
import '../utils/constants.dart';
import 'live_camera_page.dart';

class CapturePage extends StatelessWidget {
  final controller = Get.find<MLController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              const Text(
                'Choose Source',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildSourceButton(
                label: 'Camera',
                icon: '📷', // You can use an Icon() if you prefer
                onTap: () => controller.pickFile(ImageSource.camera),
                // onTap: () => Get.to(() => LiveCameraPage()),

              ),
              const SizedBox(height: 16),
              _buildSourceButton(
                label: 'Gallery',
                icon: '🖼️',
                onTap: () => controller.pickFile(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              _buildSourceButton(
                label: 'Live Detection',
                icon: '🔍', // You can use an Icon() if you prefer
                // onTap: () => controller.pickFile(ImageSource.camera),
                onTap: () => Get.to(() => LiveCameraPage(),
                  transition: Transition.cupertino,
                  duration: Duration(milliseconds: 600),),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cardInnerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}