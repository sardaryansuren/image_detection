import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui';

enum DetectionMode { face, document }

class LiveDetectionController extends GetxController {
  CameraController? cameraController;
  final Rx<DetectionMode> mode = DetectionMode.face.obs;
  bool _isProcessing = false;

  final _faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));
  final _textRecognizer = TextRecognizer();

  final faces = <Face>[].obs;
  final recognizedText = Rx<RecognizedText?>(null);
  Size? absoluteImageSize;
  final RxInt frameUpdateTrigger = 0.obs;
  final Rx<Rect?> documentRect = Rx<Rect?>(null);

  @override
  void onInit() {
    super.onInit();
    _initCamera();
    mode.value = DetectionMode.face;
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await cameraController!.initialize();
    cameraController!.startImageStream(_processFrame);
    update();
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing ) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        absoluteImageSize = Size(image.width.toDouble(), image.height.toDouble());

        if (mode.value == DetectionMode.face) {
          final result = await _faceDetector.processImage(inputImage);
          faces.assignAll(result);
          faces.refresh();
          recognizedText.value = null; // Clear text when in face mode
        } else {

          final result = await _textRecognizer.processImage(inputImage);
          recognizedText.value = result;
          faces.clear();

          if (result.blocks.isNotEmpty) {
            // 1. Start with the coordinates of the very first block
            double left = result.blocks.first.boundingBox.left;
            double top = result.blocks.first.boundingBox.top;
            double right = result.blocks.first.boundingBox.right;
            double bottom = result.blocks.first.boundingBox.bottom;

            // 2. Expand the boundaries to include every other block found
            for (var block in result.blocks) {
              if (block.boundingBox.left < left) left = block.boundingBox.left;
              if (block.boundingBox.top < top) top = block.boundingBox.top;
              if (block.boundingBox.right > right) right = block.boundingBox.right;
              if (block.boundingBox.bottom > bottom) bottom = block.boundingBox.bottom;
            }

            // 3. Store the "Big Rectangle" in your observable Rect
            // Adding +15 padding makes the box look professionally framed
            documentRect.value = Rect.fromLTRB(
                left - 15,
                top - 15,
                right + 15,
                bottom + 15
            );
          } else {
            documentRect.value = null;
          }
        }

        frameUpdateTrigger.value++;
      }
      await Future.delayed(const Duration(milliseconds: 100));

    } catch (e) {
      debugPrint("ML Kit Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = cameraController!.description.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format, // Use our forced format
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _faceDetector.close();
    _textRecognizer.close();
    super.onClose();
  }
}