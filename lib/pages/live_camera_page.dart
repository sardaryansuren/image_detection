import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/live_detection_controller.dart';
import '../widgets/detection_painter.dart';

class LiveCameraPage extends StatelessWidget {
  const LiveCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveDetectionController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("ML Kit Live Stream"), backgroundColor: Colors.transparent),
      body: GetBuilder<LiveDetectionController>(
        builder: (_) {
          if (controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller.cameraController!),
              Obx((){
                controller.frameUpdateTrigger.value;
                return CustomPaint(
                painter: DetectionPainter(
                  faces: controller.faces,
                  documentRect: controller.documentRect.value,
                  text: controller.recognizedText.value,
                  imageSize: controller.absoluteImageSize ?? const Size(720, 1280),
                  mode: controller.mode.value,
                ),
              );
              }),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.mode.value = DetectionMode.face,
                      child: const Text("Face Mode"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => controller.mode.value = DetectionMode.document,
                      child: const Text("Text Mode"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}