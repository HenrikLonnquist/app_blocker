// ignore_for_file: avoid_print

import "dart:convert";
import 'dart:io';

const dataPath = "assets/data.json";

// open Json file
List readJsonFile() {
  try {
    final fileContent = File(dataPath).readAsStringSync();
    final jsonData = json.decode(fileContent);
    return jsonData["exe_list"];
  } catch (e) {
        print('Error reading JSON file: $e');
    return [];
  }
}

// save to Json file
void writeJsonFile(List dataList) {
  var jsonData = {"exe_list": dataList};
  var jsonString = json.encode(jsonData);
  File(dataPath).writeAsStringSync(jsonString);
}

// remove from Json file
void removeDataJsonFile(List dataList) {
  // current list displaying
  // open Json file
  // save new list to json file...
  List fileData = readJsonFile();
  fileData = dataList;
  

  writeJsonFile(fileData);
}
