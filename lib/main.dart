import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// TODO: Проверка на наличие интернета, splash скрин (во время загрузки проверка авторизации);
// TODO: По нажатию на фотку кота с помощью hero animation должна открывать фотка на весь экран (в виде нового экрана)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = <Widget>[
    CatPage(),
    FavoritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,

      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        title: Text('Cat tinder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
// TODO: Сделать выход из системы
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
                    index: _selectedIndex,
                    children: _pages,
                  )
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites'),
          ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        backgroundColor: Colors.deepOrange.shade400,
        iconSize: 30,
        mouseCursor: SystemMouseCursors.click,
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold
        ),
        showUnselectedLabels: false,
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    }
    );
  }
}

class CatPage extends StatefulWidget {
  @override
  _CatPageState createState() => _CatPageState();
}

class _CatPageState extends State<CatPage> {
  String imageUrl = '';

  // IconData icon;
  // if (appState.favorites.contains(pair)) {
  //   icon = Icons.favorite;
  // } else {
  //   icon = Icons.favorite_border;
  // }

  @override
  void initState() {
    super.initState();
    _loadCatImage();
  }

  Future<void> _loadCatImage() async {
    final response = await http.get(Uri.parse('https://api.thecatapi.com/v1/images/search'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        imageUrl = data[0]['url'];
      });
    } else {
      print('Failed to load cat image');
    }
  }

  @override
  Widget build(BuildContext context) {
      return Center(
        child: SizedBox(
          height: 500,
          width: 350,
          child: Column(
            children: [
              SizedBox(
                height: 350,
                child: imageUrl.isNotEmpty ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                ) : CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Icon(
                            Icons.favorite,
                            size: 35),
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
                        _loadCatImage();
                      },
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Icon(
                            Icons.not_interested,
                            size: 35),
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
        )
      );
    }
  }

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    // if (appState.favorites.isEmpty) {
    //   return Center(
    //     child: Text('No favorites yet.'),
    //   );
    // }

    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have 0 favorites:'),
        ),
        // for (var pair in appState.favorites)
        // TODO: В избранное добавляется при нажатии лайка Сделать сохранение локально sharedPreferences;

          ListTile(
            leading: Icon(Icons.favorite),
          ),
      ],
    );
  }
}

// TODO: Добавить AuthorizationPage, сделать сохранение пользователя локально sharedPreferences;

