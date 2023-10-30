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
          valueListenable: cubit.textAlign,
          builder: (context, textAlign, child) {
            return ValueListenableBuilder(
                valueListenable: cubit.selectedIndex,
                builder: (context, value, child) {
                  return SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
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
                                        style:
                                            cubit.fontList[value].style().copyWith(color: Colors.black, fontSize: 20),
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
                        ),
                        Center(
                          child: ValueListenableBuilder(
                              valueListenable: cubit.hasBackground,
                              builder: (context, hasbackground, child) {
                                return ValueListenableBuilder(
                                    valueListenable: cubit.textCotroller,
                                    builder: (context, value, child) {
                                      return (cubit.textCotroller.text.isEmpty)
                                          ? const SizedBox.shrink()
                                          : Container(
                                              constraints: BoxConstraints(
                                                maxWidth: (MediaQuery.sizeOf(context).width - 32),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: hasbackground ? Colors.white : Colors.transparent,
                                              ),
                                              child: Text(
                                                cubit.textCotroller.text,
                                                textAlign: textAlign,
                                                style: cubit.fontList[cubit.selectedIndex.value]
                                                    .style()
                                                    .copyWith(fontSize: 28, color: Colors.black),
                                              ),
                                            );
                                    });
                              }),
                        ),
                        Positioned(
                          top: 40,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: cubit.onTextAlignChange,
                                  icon: Icon(cubit.alignIcon()),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: cubit.hasBackground,
                                    builder: (context, hasBg, child) {
                                      return IconButton(
                                        onPressed: () {
                                          cubit.hasBackground.value = !hasBg;
                                        },
                                        icon: Icon(hasBg ? Icons.article : Icons.article_outlined),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
