import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class DocumentProcessor {
  static Future<ProcessedDocument> process(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) throw Exception('Cannot decode image');

    final inputImage = InputImage.fromFile(originalFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    if (recognizedText.blocks.isEmpty) {
      throw Exception('Nothing detected');
    }

    String extractedText = recognizedText.text;


    double minX = recognizedText.blocks.map((b) => b.boundingBox.left).reduce(min);
    double minY = recognizedText.blocks.map((b) => b.boundingBox.top).reduce(min);
    double maxX = recognizedText.blocks.map((b) => b.boundingBox.right).reduce(max);
    double maxY = recognizedText.blocks.map((b) => b.boundingBox.bottom).reduce(max);

    minX = (minX - 30).clamp(0, original.width.toDouble());
    minY = (minY - 30).clamp(0, original.height.toDouble());
    maxX = (maxX+30).clamp(0, original.width.toDouble());
    maxY = (maxY+30).clamp(0, original.height.toDouble());

    final w = (maxX - minX).toInt();
    final h = (maxY - minY).toInt();

    img.Image cropped = img.copyCrop(original, x: minX.toInt(), y: minY.toInt(), width: w, height: h);
    img.adjustColor(cropped, contrast: 1.2);

    final pdf = pw.Document();
    final pngBytes = img.encodePng(cropped);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Image(pw.MemoryImage(pngBytes)),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final output = File('${dir.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await output.writeAsBytes(await pdf.save());

    return ProcessedDocument(pdfFile: output, text: extractedText);
  }
}

class ProcessedDocument {
  final File pdfFile;
  final String text;

  ProcessedDocument({required this.pdfFile, required this.text});
}
