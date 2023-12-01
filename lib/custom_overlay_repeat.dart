import 'package:app_blocker/dart_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';


class CustomOverlayPortal extends StatefulWidget {
  const CustomOverlayPortal({
    super.key,
    required this.dataList,
    this.currentTab = 0,
    this.width = 200,
    this.height = 130,
  });

  final double? width;
  final double? height;
  final Map dataList;
  final int currentTab;


  @override
  // ignore: library_private_types_in_public_api
  CustomOverlayPortalState createState() => CustomOverlayPortalState();
}

class CustomOverlayPortalState extends State<CustomOverlayPortal> {
  final OverlayPortalController tooltipController = OverlayPortalController();
  final _link = LayerLink();

  double width = 200;
  double height = 120;
  double weekdayButtonsHeight = 85;

  List<String> repeatList = ["days", "weeks", "months", "years"];
  bool weeksSelected = false;
  String? repeatValue;

  //TODO: need to make an array of buttons for the days of the week when weeks are chosen
  // Mon, Tue, Wed, Thu, Fri, Sat, Sun,
  List<String> weekday = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",];

  List<String> dropdownList = ["Daily", "Weekdays", "Weekly", "Monthly", "Yearly", "Custom",];
  String? dropValue;

  late List dataRepeatList;


  void toggleOverlayPortal() {
    tooltipController.toggle();
  }

  void addToDataList(String? value) {

    // If it's custom to do something else as well. wrap below 

    if (value == "Custom") {

      

    }

    if (dataRepeatList.isEmpty){
      dataRepeatList.add(value);
    }else {
      dataRepeatList[0] = value;
    }
  }


  @override
  Widget build(BuildContext context) {
    
    dataRepeatList = widget.dataList["tab_list"][widget.currentTab]["options"]["repeat"];
    
    if (dataRepeatList.isNotEmpty) {
      if (dataRepeatList[0] == "Custom") {
        repeatValue = dataRepeatList[0];
      }
      dropValue = dataRepeatList[0];

    } else {
      dropValue = null;
    }
    // dropValue = dataRepeatList.isEmpty ? null : dataRepeatList[0];
    // repeatValue = dataRepeatList[0] != "Custom" ? null : dataRepeatList[0]; 
    
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: tooltipController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Container(
                width: width,
                height: height,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color.fromRGBO(9, 80, 113, 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("  Repeat every ...",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 14,
                        )),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 40,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Material(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                                child: TextFormField(

                                  initialValue: "1",
                                  maxLines: 1,
                                  cursorHeight: 20,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    height: 1.1,
                                    fontSize: 18,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.fromLTRB(0, 4, 4, 4)
                                  ),
                                  
                                  // TODO: add to datalist on save or similar
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 7,
                            child: Material(
                              borderRadius: BorderRadius.circular(5.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  items: repeatList.map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    repeatList[0],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )
                                  ),
                                  value: repeatValue,
                                  onChanged: (String? value) {
                                    
                                    setState(() {
                                      if (value == "weeks") {
                                        height = height + weekdayButtonsHeight;
                                        weeksSelected = true;
                                      } else {
                                        if (height > 130) {
                                          height = height - weekdayButtonsHeight;
                                        }
                                        weeksSelected = false;
                                      }
                                      repeatValue = value!;
                                    });

                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (weeksSelected) Container(
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      height: weekdayButtonsHeight,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 40,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: weekday.length,
                        itemBuilder: (context, index) {
                          return Material(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.grey,
                              onTap: () {
                                // change color;
                                setState(() {
                                  // selectedItem == index;
                                });
                              },
                              child: Center(
                                child: Text(
                                  weekday[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              )
                            ),
                          );
                        }
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextButton( // TODO: fix the borderRadius
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)
                              )
                            ),
                            onPressed: toggleOverlayPortal,
                            child: const Text("Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 5,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white, // TODO: change to a different color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )
                            ),
                            onPressed: () {
                              // TODO: call the "database" to save and display the new info
                              //to the Triggered widget -> DropdownButton2{Custom}
                              setState(() {
                                addToDataList("Custom");
                                dropValue = dataRepeatList[0];

                                // TODO: add the repeatValue + textformfield value

                                // writeJsonFile(widget.dataList);
                                toggleOverlayPortal();
                              });
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                              )
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          );
        },
        // TODO: FocusNode widget here?
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            hint: const Text(
              "Repeat",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            items: dropdownList.map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )
              );
            }).toList(),
            value: dropValue,
            onChanged: (String? value) {
              setState(() {
                if (value == "Custom") {
                  // myFocusNode.requestFocus()
                  toggleOverlayPortal();
                } else {
                  addToDataList(value);
                  dropValue = dataRepeatList[0];
                  
                  writeJsonFile(widget.dataList);
                }
              });
            },
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down_outlined,
              ),
              iconSize: 20,
              iconEnabledColor: Colors.white,
          
            ),
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color.fromRGBO(9, 80, 113, 1),
              )
            ),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(0, 150),
              maxHeight: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color.fromRGBO(9, 80, 113, 1),
              )
            ),
          ),
        )
      ),
    );
  }

  
}