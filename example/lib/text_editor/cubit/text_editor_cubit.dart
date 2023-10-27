import 'package:bloc/bloc.dart';
import 'package:example/text_editor/cubit/text_editor_state.dart';

class TextEditorBloc extends Cubit<TextEditorState> {
  TextEditorBloc() : super(InitialTextEditorState());

}
