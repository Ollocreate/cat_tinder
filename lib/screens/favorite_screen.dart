import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/favorite_cats_cubit.dart';
import 'cat_hero_image_screen.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCatsCubit, List<String>>(
      builder: (context, favoriteCats) {
        return Scaffold(
          body: Center(
            child: favoriteCats.isEmpty
                ? Text('No favorite cats')
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: favoriteCats.length,
              itemBuilder: (context, index) {
                return GridTile(
                  child: GestureDetector(
                    onTap: () {
                      _openCatHeroImage(context, favoriteCats[index]);
                    },
                    child: _buildCatImage(context, favoriteCats[index]),
                  ),
                  footer: SizedBox(
                    width: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String catId = favoriteCats[index];
                          context.read<FavoriteCatsCubit>().removeFromFavorites(catId);
                        },
                        icon: Icon(Icons.not_interested),
                        label: Text('Unlike'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade400),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          overlayColor: MaterialStateProperty.all<Color>(Colors.red.shade300),
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatImage(BuildContext context, String imageUrl) {
    return Image.network(
      imageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
    );
  }

  void _openCatHeroImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CatHeroImage(imageUrl: imageUrl),
    ));
  }
}