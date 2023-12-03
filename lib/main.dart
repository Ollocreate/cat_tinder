import 'package:flutter/material.dart';

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
      home: MyHomePage(),
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
    GeneratorPage(),
    FavoritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat tinder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
// TODO: Сделать выход из системы
                onPressed: () {},
                child: Text('Quit')),
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
        backgroundColor: Colors.indigo,
        iconSize: 30,
        mouseCursor: SystemMouseCursors.click,
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold
        ),
        showUnselectedLabels: false,

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
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }
// TODO: Загрузка котов через API
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    // appState.toggleFavorite();
                  },
                  icon: Icon(Icons.favorite),
                  label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    // appState.getNext();
                  },
                  child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
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

