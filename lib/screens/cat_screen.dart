import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cat_cubit.dart';
import '../cubits/favorite_cats_cubit.dart';
import 'cat_hero_image_screen.dart';

class CatScreen extends StatefulWidget {
  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  void initState() {
    super.initState();
    context.read<CatCubit>().loadCatImage();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          _openCatHeroImage(context);
        },
        child: Container(
          height: 500,
          width: 350,
          child: Column(
            children: [
              Container(
                height: 350,
                child: BlocBuilder<CatCubit, String>(
                  builder: (context, imageUrl) {
                    return imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ) : Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        String catId = context.read<CatCubit>().state;
                        var favoriteCatsCubit = context.read<FavoriteCatsCubit>();

                        if (favoriteCatsCubit.state.contains(catId)) {
                          favoriteCatsCubit.removeFromFavorites(catId);
                        } else {
                          favoriteCatsCubit.addToFavorites(catId);
                        }
                      },
                      icon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: BlocBuilder<FavoriteCatsCubit, List<String>>(
                            builder: (context, favoriteCats) {
                              String catId = context.read<CatCubit>().state;

                              bool isFavorite = favoriteCats.contains(catId);

                              return Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 35,
                                color: isFavorite ? Colors.white : null,
                              );
                            },
                          )
                      ),
                      label: Text('Like'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        overlayColor: MaterialStateProperty.all<Color>(Colors.green.shade300),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CatCubit>().loadCatImage();
                      },
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Icon(
                          Icons.not_interested,
                          size: 35,
                        ),
                      ),
                      label: Text('Next'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        overlayColor: MaterialStateProperty.all<Color>(Colors.red.shade300),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCatHeroImage(BuildContext context) {
    String imageUrl = context.read<CatCubit>().state;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CatHeroImage(imageUrl: imageUrl),
    ));
  }
}