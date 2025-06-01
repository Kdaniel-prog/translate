import 'package:flutter/material.dart';

class TranslateInputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onTranslate;

  const TranslateInputBox({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            maxLength: 2000,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "Text to translate...",
              border: InputBorder.none,
              counterText: '', // Hide default counter
            ),
          ),
          const SizedBox(height: 100), // Add vertical space
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.text.length}/2000',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10), 
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClear,
                child: const Text("Clear"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: onTranslate,
                child: const Text("Translate & Read"),
              ),
            ],
          ),         
        ],
      ),
    );
  }
}
