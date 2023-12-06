import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePageCubit extends Cubit<int> {
  MyHomePageCubit() : super(0);

  void setSelectedIndex(int index) {
    emit(index);
  }
}
