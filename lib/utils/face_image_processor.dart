import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

class FaceImageProcessor {
  static Future<File> process({
    required File originalFile,
    required List<Face> faces,
  }) async {
    final bytes = await originalFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Cannot decode image');

    for (final face in faces) {
      final rect = face.boundingBox;

      final x = rect.left.toInt().clamp(0, original.width - 1);
      final y = rect.top.toInt().clamp(0, original.height - 1);
      final w = rect.width.toInt().clamp(1, original.width - x);
      final h = rect.height.toInt().clamp(1, original.height - y);

      final faceCrop = img.copyCrop(original, x: x, y: y, width: w, height: h);
      img.grayscale(faceCrop);
      img.compositeImage(original, faceCrop, dstX: x, dstY: y);
    }

    final dir = await getApplicationDocumentsDirectory();
    final output = File('${dir.path}/face_${DateTime.now().millisecondsSinceEpoch}.png');
    await output.writeAsBytes(img.encodePng(original));
    return output;
  }
}
