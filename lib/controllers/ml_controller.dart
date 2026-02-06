import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/app_database.dart';
import '../models/history_item.dart';
import '../pages/processing_page.dart';
import '../pages/result_page.dart';
import '../utils/face_image_processor.dart';
import '../utils/document_processor.dart';

enum DetectionMode { face, document }

class MLController extends GetxController {
  final history = <HistoryItem>[].obs;
  final selectedFile = Rx<File?>(null);
  final resultFile = Rx<File?>(null);
  final isProcessing = false.obs;
  final errorMessage = RxnString();
  final resultText = RxString('');
  final isFromHistory = RxBool(false);
  final picker = ImagePicker();
  late FaceDetector faceDetector;
  DetectionMode detectionMode = DetectionMode.face;

  @override
  void onInit() {
    super.onInit();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
    _loadHistory();
  }

  @override
  void onClose() {
    faceDetector.close();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    final items = await AppDatabase.instance.getAll();
    history.assignAll(items);
  }

  Future<void> pickFile(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    selectedFile.value = File(picked.path);
    resultFile.value = null;

    Get.to(() => ProcessingPage(),
      transition: Transition.cupertino,
    );
    await processFile();
  }

  Future<void> processFile() async {
    if (selectedFile.value == null) return;

    isProcessing.value = true;
    errorMessage.value = null;
    try {
      final file = selectedFile.value!;
      final inputImage = InputImage.fromFile(file);

      final faces = await faceDetector.processImage(inputImage);

      File processedFile;
      HistoryType type;
      int faceCount = 0;

      if (faces.isNotEmpty) {
        processedFile = await FaceImageProcessor.process(
          originalFile: file,
          faces: faces,
        );
        type = HistoryType.face;
        faceCount = faces.length;
      } else {
        final processed = await DocumentProcessor.process(file);
        processedFile = processed.pdfFile;
        resultText.value = processed.text;

        type = HistoryType.document;
      }

      resultFile.value = processedFile;

      final historyItem = HistoryItem(
        filePath: processedFile.path,
        type: type,
        faceCount: faceCount,
        createdAt: DateTime.now(),
      );

      final id = await AppDatabase.instance.insert(historyItem);

      history.insert(
        0,
        HistoryItem(
          id: id,
          filePath: historyItem.filePath,
          type: historyItem.type,
          faceCount: historyItem.faceCount,
          createdAt: historyItem.createdAt,
        ),
      );

      isProcessing.value = false;

      isFromHistory.value = false;
      Get.off(() => ResultPage(),
        transition: Transition.cupertino,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> deleteHistory(HistoryItem item) async {
    if (item.id == null) return;
    await AppDatabase.instance.delete(item.id!);
    history.remove(item);
  }
}
