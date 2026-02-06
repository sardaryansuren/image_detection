import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../controllers/live_detection_controller.dart';

class DetectionPainter extends CustomPainter {
  final List<Face>? faces;
  final RecognizedText? text;
  final Size imageSize;
  final DetectionMode mode;
  final Rect? documentRect;

  DetectionPainter({this.faces, this.text,this.documentRect, required this.imageSize, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = mode == DetectionMode.face ? Colors.greenAccent : Colors.blueAccent;

    // Portrait mode usually requires swapping width and height for correct scaling
    // because the camera sensor is rotated.
    final double scaleX = size.width / imageSize.height;
    final double scaleY = size.height / imageSize.width;

    if (mode == DetectionMode.face && faces != null) {
      for (final face in faces!) {
        canvas.drawRect(_scaleRect(face.boundingBox, scaleX, scaleY), paint);
      }
    } else if (mode == DetectionMode.document && text != null) {
      canvas.drawRect(
        Rect.fromLTRB(
          documentRect!.left * scaleX,
          documentRect!.top * scaleY,
          documentRect!.right * scaleX,
          documentRect!.bottom * scaleY,
        ),
        paint,
      );
    }
  }



  Rect _scaleRect(Rect rect, double scaleX, double scaleY) {
    // In portrait, the 'top' of the image is often the 'left' of the sensor
    return Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}