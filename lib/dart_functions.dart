
import "dart:convert";
import 'dart:io';


// open Json file
Future<List> readJsonFile() async {
  var input = await File("assets/data.json").readAsString();
  var jsonData = const JsonDecoder().convert(input);
  return jsonData["exe_list"];
}

// save to Json file
Future<void> writeJsonFile(String filePath, List dataList) async {
  var jsonData = {
    "exe_list": dataList
  };
  var jsonString = json.encode(jsonData);
  await File(filePath).writeAsString(jsonString);
}

// remove from Json file
void removeDataJsonFile(String dataPath, List dataList) async {

  // current list displaying
  // open Json file
  // save new list to json file...
  final List fileData = await readJsonFile();

  fileData.add(dataList);

  stdout.write(fileData);
  
  writeJsonFile(dataPath, fileData);


}














