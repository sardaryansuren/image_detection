import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_processing/utils/constants.dart';

class TextScreen extends StatelessWidget {
  final String text;

  const TextScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white), // Back icon white
        title: const Text('Extracted Text',style: TextStyle(color: Colors.white70),),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            color: Colors.white70,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Text copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: const TextStyle(fontSize: 16,
                color: Colors.white70,),
          ),
        ),
      ),
    );
  }
}
