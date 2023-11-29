// ignore_for_file: avoid_print

import "dart:convert";
import 'dart:io';

const dataPath = "assets/data.json";

// open Json file
List readJsonFile(String nameOf) {
  try {
    final fileContent = File(dataPath).readAsStringSync();
    final jsonData = json.decode(fileContent);
    return jsonData[nameOf];
  } catch (e) {
        print('Error reading JSON file: $e');
    return [];
  }
}

// save to Json file
void writeJsonFile(List dataList, String nameOf) {
  var jsonData = {nameOf : dataList};
  var jsonString = json.encode(jsonData);
  File(dataPath).writeAsStringSync(jsonString);
}

// remove from Json file
void removeDataJsonFile(List dataList, String nameOf) {
  // current list displaying
  // open Json file
  // save new list to json file...
  List fileData = readJsonFile(nameOf);
  fileData = dataList;
  

  writeJsonFile(fileData, nameOf);
}
