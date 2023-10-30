import 'package:example/models/font_info.dart';
import 'package:flutter/material.dart';

class FontSelector extends StatefulWidget {
  final List<FontInfo> fontList;
  final int selectedIndex;
  final Function(int)? onIndexChanged;
  const FontSelector({super.key, required this.fontList, required this.selectedIndex, this.onIndexChanged});

  @override
  State<FontSelector> createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: widget.fontList.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onIndexChanged?.call(index),
            child: Container(
              height: 60,
              width: 60,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (index == widget.selectedIndex) ? Colors.yellow[700] : Colors.black.withOpacity(0.4)),
              child: Center(
                child: Text(
                  'Ab',
                  style: widget.fontList[index]
                      .style()
                      .copyWith(color: (index == widget.selectedIndex) ? Colors.black : Colors.white, fontSize: 22),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
