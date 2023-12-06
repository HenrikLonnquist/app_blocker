import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//! Seems to be rebuilding the overlayentry every second,
//! probably because of the monitoring logic/file. So maybe
//! it also rebuilds the whole program every 1 second.
//TODO: I should customize so that I can re-use it

class CustomOverlayPortal extends StatefulWidget {
  const CustomOverlayPortal({
    super.key,
    required this.dataList,
    required this.onSaved,
    this.currentTab = 0,
    this.width = 200,
    this.height = 130,
  });

  final double? width;
  final double? height;
  final List dataList;
  final int currentTab;
  
  final void Function(List) onSaved;


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

  Map weekdaySelected = {"0": true};
  List<String> repeatNames = ["days", "weeks", "months", "years"];
  bool weeksSelected = false;
  String? customRepeatValue;

  List<String> weekday = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",];
  List<String> dropdownList = ["Repeat", "Daily", "Weekdays", "Weekly", "Monthly", "Yearly", "Custom",];

  final FocusNode myFocusNode = FocusNode();
  TextEditingController formController = TextEditingController();


  void toggleOverlayPortal() {
    tooltipController.toggle();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    try {
      formController.text = widget.dataList[1];
      customRepeatValue = widget.dataList[2];
      if (widget.dataList[2] == "weeks"){
        weeksSelected = true;
        height = height + weekdayButtonsHeight;
      }

      if(widget.dataList.isNotEmpty && 
        widget.dataList[0] == "Custom" && 
        widget.dataList[2] == "weeks" ){
          
          weekdaySelected = widget.dataList[3];
          
      }
      
      
    } catch (e) {
      formController.text = "1";
      customRepeatValue = null;
    }
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    formController.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: tooltipController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: const Alignment(-1, -3.8),
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
                                  focusNode: myFocusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onFieldSubmitted: (value){
                                    if (value.isEmpty){
                                      print("hello2");
                                      print(formController.text.isEmpty);
                                      myFocusNode.requestFocus();
                                    }
                                  },
                                  controller: formController,
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
                              // TODO: make the dropdownmenu shorter
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  items: repeatNames.map((String value) {
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
                                    repeatNames[0],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    )
                                  ),
                                  value: customRepeatValue,
                                  onChanged: (String? value) {
                                    
                                    setState(() {
                                      if (value == "weeks" && weeksSelected == false) {
                                        height = height + weekdayButtonsHeight;
                                        weeksSelected = true;
                                      } else {
                                        if (height > 130) {
                                          height = height - weekdayButtonsHeight;
                                        }
                                        weeksSelected = false;
                                      }
                                      customRepeatValue = value!;
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
                            color: weekdaySelected["$index"] == null ?
                            Colors.white : 
                            const Color.fromRGBO(245, 113, 161, 1.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5.0), 
                              hoverColor: const Color.fromRGBO(245, 113, 161, .1),
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (weekdaySelected.containsKey("$index") && weekdaySelected.length > 1) {
                                    weekdaySelected.remove("$index");
                                  } else {
                                    weekdaySelected["$index"] = weekday[index];
                                  }
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
                              backgroundColor: formController.text.isNotEmpty ? Colors.white : Colors.grey.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )
                            ),
                            // TODO: disable if the textformfield is empty;
                            onPressed: formController.text.isNotEmpty ? () {
                              //TODO I need to update the repeat value of the second third (fourth) value the date is past timeNow


                              widget.dataList.clear();
                              widget.dataList.add("Custom");
                              if(formController.text.isEmpty){
                                formController.text = "1";
                              }
                              widget.dataList.add(formController.text);
                              widget.dataList.add(customRepeatValue);
                              if(customRepeatValue == "weeks"){
                                widget.dataList.add(weekdaySelected);
                              }

                              setState(() {
                                widget.onSaved(widget.dataList);
                                toggleOverlayPortal();
                              });
                            } : null,
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
        // TODO: FocusNode widget here? >
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
            value: widget.dataList.isEmpty ? null : widget.dataList[0].toString(),
            onChanged: (String? value) {
              setState(() {
                if (value == "Custom") {
                  // myFocusNode.requestFocus()
                  toggleOverlayPortal();
                } else {
                  if(value != "Repeat"){
                    widget.dataList.clear();
                    widget.dataList.add(value);
                    //addvalue time
                    widget.onSaved(widget.dataList);
                  }
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
              // padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
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
  