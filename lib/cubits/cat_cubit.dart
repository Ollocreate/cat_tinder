import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class CatCubit extends Cubit<String> {
  CatCubit() : super('');

  Future<void> loadCatImage() async {
    try {
      final response = await http.get(Uri.parse('https://api.thecatapi.com/v1/images/search'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data[0]['url'].toString();
        emit(imageUrl);
      } else {
        print('Failed to load cat image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading cat image: $error');
    }
  }
}