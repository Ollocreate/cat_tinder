import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenCubit extends Cubit<int> {
  HomeScreenCubit() : super(0);

  void setSelectedIndex(int index) {
    emit(index);
  }
}
