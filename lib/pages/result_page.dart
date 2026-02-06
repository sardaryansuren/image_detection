import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_processing/pages/text_screen.dart';
import '../controllers/ml_controller.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/constants.dart';


class ResultPage extends StatelessWidget {
  ResultPage({super.key});

  final controller = Get.find<MLController>();


  bool _isPdf(File file) => file.path.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    final File? original = controller.selectedFile.value;
    final File? processed = controller.resultFile.value;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: Text(
          processed != null && _isPdf(processed) ? 'PDF Created' : 'Face Result',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: processed == null
          ? const Center(child: Text('No result', style: TextStyle(color: Colors.white)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: _isPdf(processed)
                  ? _buildPdfView(processed)
                  : _buildImageCompare(original, processed),
            ),
            const SizedBox(height: 20),
            _buildBottomButton(processed),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildImageCompare(File? original, File processed) {
    return Row(
      children: [
        if(!controller.isFromHistory.value) _buildImageCard("Original", "Original", original),
        if(!controller.isFromHistory.value) const SizedBox(width: 16),
        _buildImageCard("Processed", "B&W", processed),
      ],
    );
  }

  Widget _buildImageCard(String label, String subLabel, File? file) {
    return Expanded(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardInnerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: file != null
                      ? Image.file(file, fit: BoxFit.fitHeight)
                      : Center(child: Text(subLabel, style: const TextStyle(color: Colors.white38))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView(File pdf) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: brandPink, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'PDF',
              style: TextStyle(color: brandPink, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            pdf.path.split('/').last,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(File processed) {
    bool isPdf = _isPdf(processed);
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              if (isPdf) {
                OpenFilex.open(processed.path);
              } else {
                Get.back();
              }
            },
            child: Text(
              isPdf ? 'Open PDF' : 'Done',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (isPdf && !controller.isFromHistory.value) const SizedBox(height: 12),
        if (isPdf && !controller.isFromHistory.value)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                // Navigate to text screen
                Get.to(() => TextScreen(text: controller.resultText.value));
              },
              child: Text(
                'Show Text',
                style: TextStyle(color: brandPink, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }
}