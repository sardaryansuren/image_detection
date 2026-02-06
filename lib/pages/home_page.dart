import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ml_controller.dart';
import '../widgets/history_tile.dart';
import 'capture_page.dart';
import 'result_page.dart';
import '../utils/constants.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(MLController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: brandPink,
          shape: const CircleBorder(),

          onPressed: () => Get.to(() => CapturePage(),
            transition: Transition.cupertino,
            duration: Duration(milliseconds: 600),),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const Text(
                  'ImageFlow',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                if (controller.history.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No history yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.history.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final item = controller.history[i];
                        return HistoryTile(
                          item: item,
                          onTap: () {
                            controller.resultFile.value =
                                File(item.filePath);
                            controller.isFromHistory.value = true;
                            Get.to(() => ResultPage(),
                              transition: Transition.cupertino,
                              duration: Duration(milliseconds: 600),);
                          },
                          onDelete: () =>
                              controller.deleteHistory(item),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
