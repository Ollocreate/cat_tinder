import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCatsCubit extends Cubit<List<String>> {
  FavoriteCatsCubit() : super([]);

  void addToFavorites(String catId) {
    state.add(catId);
    emit(List.from(state));
  }

  void removeFromFavorites(String catId) {
    state.remove(catId);
    emit(List.from(state));
  }
}
