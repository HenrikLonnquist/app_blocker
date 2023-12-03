import 'package:flutter/material.dart';

class CustomOverlayTooltip extends StatefulWidget {
  const CustomOverlayTooltip({
    super.key,
    required this.controller,
  });

  final OverlayPortalController controller;

  @override
  State<CustomOverlayTooltip> createState() => _CustomOverlayTooltipState();
}

class _CustomOverlayTooltipState extends State<CustomOverlayTooltip> {
  final link = LayerLink();

  
  void hideOverlay(){
    widget.controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: OverlayPortal(
        controller: widget.controller,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: link,
            targetAnchor: Alignment.topRight,
            child: Align(
              alignment: const Alignment(-1.010,-0.85),
              child: GestureDetector(
                onTap: (){
                  hideOverlay();
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Center(
                    child: Text(
                      "HINT: 0900-1200,1300-1700; press enter to save",
                    )
                  )
                ),
              ),
            ),
          );
        },
        child: const SizedBox(),
      ),
    );
  }
}
 