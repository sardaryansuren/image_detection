import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/history_item.dart';

class HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDocument = item.type == HistoryType.document;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: isDocument
                      ? const [Color(0xFF6A5CFF), Color(0xFF9A8CFF)]
                      : const [Color(0xFFFF5C7C), Color(0xFFFF8FA3)],
                ),
              ),
              child: isDocument
                  ? const Icon(
                Icons.description,
                color: Colors.white,
                size: 24,
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.filePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDocument ? 'Document Scan' : 'Face Processed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.type == HistoryType.face
                        ? 'Faces: ${item.faceCount}\n${_formattedDate}'
                        : _formattedDate,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white38,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }



  String get _formattedDate {
    return DateFormat('MMM d, yyyy').format(item.createdAt);
  }
}
