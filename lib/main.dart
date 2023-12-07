import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'cat_cubit.dart';
import 'favorite_cats_cubit.dart';
import 'my_home_page_cubit.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(
        onSplashScreenComplete: () {
          runApp(MyAppContent());
        },
      ),
    );
  }
}

class MyAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CatCubit()),
          BlocProvider(create: (_) => FavoriteCatsCubit()),
          BlocProvider(create: (_) => MyHomePageCubit()),
        ],
        child: MyHomePage(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final VoidCallback onSplashScreenComplete;

  SplashScreen({Key? key, required this.onSplashScreenComplete}) : super(key: key);

  // Внешний метод для проверки соединения с интернетом
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      _checkInternetConnection().then((isConnected) {
        if (isConnected) {
          onSplashScreenComplete();
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ошибка'),
              content: Text('Отсутствует подключение к интернету.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    exit(0);
                  },
                  child: Text('Выйти'),
                ),
              ],
            ),
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/splashscreen_logo.png', width: 150, height: 150),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatCubit, String>(
      builder: (context, catState) {
        return Scaffold(
          backgroundColor: Colors.pink.shade50,
          appBar: AppBar(
            backgroundColor: Colors.pink.shade50,
            title: Text('Cat tinder'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Quit'),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrange.shade400),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    overlayColor: MaterialStateProperty.all<Color>(Colors.deepOrange.shade200),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: context.select((MyHomePageCubit cubit) => cubit.state),
                        children: [
                          CatPage(),
                          FavoritePage(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
            ],
            currentIndex: context.watch<MyHomePageCubit>().state,
            onTap: (index) {
              context.read<MyHomePageCubit>().setSelectedIndex(index);
            },
            backgroundColor: Colors.deepOrange.shade400,
            iconSize: 30,
            mouseCursor: SystemMouseCursors.click,
            selectedItemColor: Colors.white,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            showUnselectedLabels: false,
          ),
        );
      },
    );
  }
}

class CatPage extends StatefulWidget {
  @override
  State<CatPage> createState() => _CatPageState();
}

class _CatPageState extends State<CatPage> {
  void initState() {
    super.initState();
    context.read<CatCubit>().loadCatImage();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        // Если есть, удаляем из избранного
                        favoriteCatsCubit.removeFromFavorites(catId);
                      } else {
                        // Если нет, добавляем в избранное
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
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCatsCubit, List<String>>(
      builder: (context, favoriteCats) {
        return Scaffold(
            body: Center(
              child: BlocBuilder<FavoriteCatsCubit, List<String>>(
                  builder: (context, favoriteCats) {
                    return favoriteCats.isEmpty
                        ? Text('Нет понравившихся котов.')
                        : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Количество столбцов в сетке
                        crossAxisSpacing: 8.0, // Расстояние между столбцами
                        mainAxisSpacing: 8.0, // Расстояние между строками
                      ),
                      itemCount: favoriteCats.length,
                      itemBuilder: (context, index) {
                        return GridTile(
                          child: _buildCatImage(context, favoriteCats[index]),
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
                    );
                  }
              ),
            )
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
}
