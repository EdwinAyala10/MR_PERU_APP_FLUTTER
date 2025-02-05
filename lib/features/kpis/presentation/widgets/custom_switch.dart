import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSwitch extends StatefulWidget {
  final List<String> options;
  final List<String>? icons;
  final ValueChanged<int>? onChanged;
  final int index;

  const CustomSwitch({
    super.key,
    required this.options,
    required this.index,
    this.onChanged,
    this.icons,
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(1);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? Colors.grey.withOpacity(.2)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                      border: selectedIndex == 1
                          ? Border.all(color: Colors.grey)
                          : null),
                  child: Center(
                    child: widget.icons != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/${widget.icons![0]}",
                                width: 24,
                                height: 25,
                                color: selectedIndex == 1
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.options[0],
                              ),
                            ],
                          )
                        : Text(
                            widget.options[0],
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(2);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                      color: selectedIndex == 2
                          ? Colors.black.withOpacity(.2)
                          : null,
                      borderRadius: BorderRadius.circular(15.0),
                      border: selectedIndex == 2
                          ? Border.all(color: Colors.grey)
                          : null),
                  child: Center(
                    child: widget.icons != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/${widget.icons![1]}",
                                width: 24,
                                height: 15,
                                color: selectedIndex == 2
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.options[1],
                                softWrap: false,
                              )
                            ],
                          )
                        : Text(
                            widget.options[1],
                            softWrap: false,
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
