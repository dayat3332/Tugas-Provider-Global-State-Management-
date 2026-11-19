import 'package:flutter/material.dart';

// Titik awal jalannya aplikasi
void main() {
  runApp(const MyApp());
}

// Widget akar yang membungkus seluruh aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tugas Flutter',
      home: MyWidget(), // Memanggil MyWidget sebagai halaman pertama
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              print('Teks saat ini: $value');
            },
          ),
        ),
      ),
    );
  }
}