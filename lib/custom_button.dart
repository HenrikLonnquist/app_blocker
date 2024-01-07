import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:win32/win32.dart';


//TODO: LATER: I should customize so that I can re-use it
class CustomDropdownButton extends StatefulWidget {
  const CustomDropdownButton({
    super.key,
    required this.dataList,
    required this.onSaved,
    required this.link,
    this.currentTab = 0,
    this.width = 200,
    this.height = 130,
  });

  final LayerLink link;
  final double? width;
  final double? height;
  final List dataList;
  final int currentTab;
  
  final void Function(List) onSaved;


  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  List<String> dropdownList = ["Daily", "Weekdays", "Weekly", "Custom",]; 


  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
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
              // Maybe add icons
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            )
          );
        }).toList(),
        customButton: Material(
          color: Colors.transparent,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
              backgroundColor: const Color.fromRGBO(71, 71, 71, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              )
            ),
            onPressed: null,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: widget.dataList.length >= 2 ?
                      const EdgeInsets.all(0) : 
                      const EdgeInsets.all(5.5),
                      child: Text(
                        widget.dataList.length > 3 ?  // Checks if the data is "Custom"
                        "Every ${widget.dataList[1]} ${widget.dataList[2]}" :
                        widget.dataList.isEmpty ? 
                        "Repeat" : 
                        widget.dataList[0],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: widget.dataList.length >= 2 ? 14 : 20,
                        ),
                      ),
                    ),
                    if(widget.dataList.length >= 2)
                    Text(
                      widget.dataList.length == 2 ? 
                      widget.dataList[1] :
                      widget.dataList[3].values.toList().join(", "),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if(widget.dataList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Material(
                    color: const Color.fromRGBO(71, 71, 71, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: (){
        
                        setState(() {
                          widget.dataList.clear();
                          widget.onSaved(widget.dataList);
                        });
        
                      },
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 30,
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {
            if (value == "Custom") {

              Navigator.of(context).push(CustomMenuRoute(
                link: widget.link,
                dataList: widget.dataList,
                currentTab: widget.currentTab,
                onSaved: widget.onSaved,
              ));
              
            } else {
              if(value != "Repeat"){
                widget.dataList.clear();
                widget.dataList.add(value);
                if(value == "Weekly") {
                  var timeNow = DateTime.now();
                  var formattedDate = DateFormat("E").format(timeNow);
                  widget.dataList.add(formattedDate);
                }
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
        dropdownStyleData: DropdownStyleData(
          offset: const Offset(0, 150),
          width: 200,
          maxHeight: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: const Color.fromRGBO(71, 71, 71, 1),
          )
        ),
      ),
    );
  }

}

class CustomMenuRoute extends PopupRoute{
  CustomMenuRoute({
    required this.link,
    required this.dataList,
    required this.currentTab,
    required this.onSaved,
    this.height,
    this.width,
    this.alignment,
    this.offset,
  });

  final int currentTab;
  final List dataList;
  final LayerLink link;
  final Alignment? alignment; // Can be removed
  final Offset? offset; // Can be removed
  final double? width;
  final double? height;

  final void Function(List) onSaved;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 20);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {

    return Stack(
      children: [
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.center,
          offset: const Offset(-52, -150),
          child: CustomMenu(
            dataList: dataList,
            currentTab: currentTab,
            onSaved: onSaved,
          ),
        ),
      ],
    );
  }

  
}

class CustomMenu extends StatefulWidget {
  const CustomMenu({
    super.key,
    required this.dataList,
    required this.currentTab,
    required this.onSaved,
  });

  final List dataList;
  final int currentTab;
  final void Function(List) onSaved;

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  Map weekdaySelected = {"0": "Mon"};
  List<String> repeatNames = ["days", "weeks", "months", "years"];
  bool weeksSelected = false;
  String? customRepeatValue;

  double width = 200;
  double height = 120;
  double weekdayButtonsHeight = 85;

  List<String> weekday = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",];
  
  final FocusNode _myFocusNode = FocusNode();
  TextEditingController formController = TextEditingController();

  int? tempTab;



  @override
  void initState() {
    super.initState();

    tempTab = widget.currentTab;
    formController.text = widget.dataList.isNotEmpty && widget.dataList.length > 1 ? widget.dataList[1] : "1";
    customRepeatValue = widget.dataList.isNotEmpty && widget.dataList.length > 3 ? widget.dataList[2] : null;

    if (widget.dataList.isNotEmpty && widget.dataList.length > 3 && widget.dataList[2] == "weeks"){
      weeksSelected = true;
      height = height + weekdayButtonsHeight;
    } 

    weekdaySelected = widget.dataList.length > 3 ? widget.dataList[3] : {"0": "Mon"};
    
  }





  @override
  void dispose() {
    formController.dispose();
    _myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if(tempTab != widget.currentTab){
        tempTab = widget.currentTab;
        height = 120;
        if(widget.dataList.length > 3) {
          weekdaySelected = widget.dataList[3];
          customRepeatValue = widget.dataList[2];
          weeksSelected = true;
          height = height + weekdayButtonsHeight;
        } else {

          if (height > 130) {
            height = height - weekdayButtonsHeight;
          }
          weekdaySelected = {"0": "Mon"};
          customRepeatValue = null;
          weeksSelected = false;
      }

    }

    _myFocusNode.requestFocus();

    return Container(
            width: width,
              height: height,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color.fromRGBO(71, 71, 71, 1)
              ),
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
                                focusNode: _myFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onFieldSubmitted: (value){
                                  if (value.isEmpty){
                                    _myFocusNode.requestFocus();
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
                                dropdownStyleData: DropdownStyleData(
                                  offset: const Offset(0, 80),
                                  isOverButton: true,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //* Weeks
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
                        child: TextButton( 
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                            )
                          ),
                          onPressed: (){
                            Navigator.pop(context);
                          },
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
                          onPressed: formController.text.isNotEmpty ? () {

                            // TODO: I need to update the repeat value(custom?) of the second third (fourth) value if the date is past timeNow
                            // But this is not where I check for conditions tho..
                            // Here I only need choose or specify the repeat settings?. The calculations should be done in the logic file.
            
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
                              Navigator.pop(context);
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
            );
  }
}