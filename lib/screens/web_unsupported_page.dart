import 'package:flutter/material.dart';

class WebUnsupportedPage extends StatelessWidget {
  const WebUnsupportedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Artha26'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Web Platform Not Supported',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This application requires a native platform (Android, iOS, Windows, macOS, or Linux) to function properly.\n\nThe web version does not support the SQLite database required for this POS system.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please use a native platform to run this app'),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Native App'),
              ),
              const SizedBox(height: 16),
              const Text(
                'For development testing on native platform:\n'
                '• flutter run -d android\n'
                '• flutter run -d windows',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
