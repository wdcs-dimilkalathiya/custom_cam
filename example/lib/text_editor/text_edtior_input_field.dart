import 'package:example/text_editor/cubit/text_editor_cubit.dart';
import 'package:example/text_editor/font_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextEditorInputField extends StatelessWidget {
  const TextEditorInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TextEditorCubit>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ValueListenableBuilder(
          valueListenable: cubit.selectedIndex,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                      height: 70,
                      child: FontSelector(
                        fontList: cubit.fontList,
                        selectedIndex: value,
                        onIndexChanged: cubit.onIndexChanged,
                      )),
                ),
                Container(
                  height: 55,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 3),
                          child: TextFormField(
                            cursorColor: Colors.black,
                            autofocus: true,
                            controller: cubit.textCotroller,
                            style: cubit.fontList[value].style().copyWith(color: Colors.black, fontSize: 20),
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            if (cubit.textCotroller.text.isNotEmpty) {
                              cubit.onTextSend();
                              Navigator.pop(context);
                            }
                            cubit.textCotroller.clear();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ))
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
