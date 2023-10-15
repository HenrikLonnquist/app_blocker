import 'dart:async';

import 'package:flutter/material.dart';
import "package:file_picker/file_picker.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _strings = [];
  int timeLeft = 5;

  // timer method
  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

/* 
  void _chooseProgram(){
    setState(() {
      
    });
  } */
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    PlatformFile file = result.files.single;

    // ignore: avoid_print
    print(file.name);

    setState(() {
      _strings.add(Text(file.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _strings.length,
                itemBuilder: (context, index) => _strings[index],
              ),
            ),
            Text(
              timeLeft.toString(),
              style: const TextStyle(fontSize: 50),
            ),
            MaterialButton(
              onPressed: _startCountdown,
              color: Colors.amberAccent[100],
              child: const Text("START"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickFile();
        },
        tooltip: 'Add program',
        child: const Icon(Icons.add),
      ),
    );
  }
}
