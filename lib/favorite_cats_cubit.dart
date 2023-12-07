import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCatsCubit extends Cubit<List<String>> {
  FavoriteCatsCubit() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    emit(List.from(favorites));
  }

  Future<void> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favorites);
  }

  void addToFavorites(String catId) {
    state.add(catId);
    emit(List.from(state));
    _saveFavorites(state);
  }

  void removeFromFavorites(String catId) {
    state.remove(catId);
    emit(List.from(state));
    _saveFavorites(state);
  }
}