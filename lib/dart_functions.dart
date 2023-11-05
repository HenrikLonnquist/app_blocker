// ignore_for_file: avoid_print

import "dart:convert";
import 'dart:io';

// open Json file
List readJsonFile() {
  try {
    final fileContent = File("assets/data.json").readAsStringSync();
    final jsonData = json.decode(fileContent);
    return jsonData["exe_list"];
  } catch (e) {
        print('Error reading JSON file: $e');
    return [];
  }
}

// save to Json file
Future<void> writeJsonFile(String filePath, List dataList) async {
  var jsonData = {"exe_list": dataList};
  var jsonString = json.encode(jsonData);
  await File(filePath).writeAsString(jsonString);
}

// remove from Json file
void removeDataJsonFile(String dataPath, List dataList) async {
  // current list displaying
  // open Json file
  // save new list to json file...
  final List fileData = readJsonFile();

  fileData.add(dataList);

  stdout.write(fileData);

  writeJsonFile(dataPath, fileData);
}
