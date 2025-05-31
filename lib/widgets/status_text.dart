import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  final String status;

  const StatusText({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Text(
      status,
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      textAlign: TextAlign.center,
    );
  }
}
