import 'dart:async';
import 'package:intl/intl.dart';

import 'dart_functions.dart';
import "logic.dart";

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
  String time = DateFormat.Hms().format(DateTime.now());
  var currentHwnd = 0;
  

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) => _currentTime());

    watchingActiveWindow();

  }

  void _currentTime() {
    Timer.periodic(const Duration(seconds: 1), (updatetime) {
      setState(() {
        time = DateFormat.Hms().format(DateTime.now());
      });
    });
  }

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

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    PlatformFile file = result.files.single;
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
            Text(
              time,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _strings.length,
                itemBuilder: (context, index) => _strings[index],
              ),
            ),
            Text(
              timeLeft == 0 ? "DONE" : timeLeft.toString(),
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
