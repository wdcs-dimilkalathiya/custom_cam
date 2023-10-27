import 'package:example/models/font_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return ListView.builder(
      itemCount: widget.fontList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: GoogleFonts.pendingFonts([
              widget.fontList[index].style,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTap: () => widget.onIndexChanged?.call(index),
                  child: Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: (index == widget.selectedIndex) ? Colors.black : Colors.white),
                    child: Center(
                      child: Text(
                        'a',
                        style: widget.fontList[index]
                            .style(color: (index == widget.selectedIndex) ? Colors.white : Colors.black, fontSize: 30),
                      ),
                    ),
                  ),
                );
              }
              return Container(
                  height: 60,
                  width: 60,
                  margin: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  ));
            });
      },
    );
  }
}
