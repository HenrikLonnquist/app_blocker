
import "dart:convert";
import 'dart:io';

import 'package:flutter/services.dart';




// Read Json file
Future<List> readJsonFile() async {
  var filePath = await rootBundle.loadString("assets/data.json");
  var input = await File(filePath).readAsString();
  var jsonData = const JsonDecoder().convert(input);
  return jsonData["exe_list"];
}

// Write Json file
Future<void> writeJsonFile(String filePath, List data) async {
  var jsonData = {
    "exe_list": data
  };
  var jsonString = json.encode(jsonData);
  await File(filePath).writeAsString(jsonString);
}















