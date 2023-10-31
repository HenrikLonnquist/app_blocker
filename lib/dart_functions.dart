
// ignore_for_file: unused_import, 
import "dart:convert";
import 'dart:io';
import "package:path_provider/path_provider.dart";


// Read Json file
Future<List> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var jsonData = const JsonDecoder().convert(input);
  return jsonData["exe_list"];
}


// Directory path
Future<String> get _localPath async {

  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

//File path
Future<File> get _localFile async {

  final path = await _localPath;
  return File("$path/data.txt");

}

// Write data to file
Future<File> writeDataToFile(String data) async { 

  final file = await _localFile;

  return file.writeAsString(data);

}

// Read data from file
Future<String> readDataFromFile(String data) async {

  final file = await _localFile;

  final contents =  file.readAsString();

  return contents;

}





