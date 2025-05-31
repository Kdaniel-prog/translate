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
            decoration: InputDecoration(
              hintText: "....",
              border: InputBorder.none,
              counterText: '${controller.text.length}/2000',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClear,
                child: const Text("Clear"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onTranslate,
                child: const Text("Translate"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
