import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
