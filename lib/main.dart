import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'authentication_cubit.dart';
import 'cat_cubit.dart';
import 'favorite_cats_cubit.dart';
import 'my_home_page_cubit.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthenticationCubit authenticationCubit = AuthenticationCubit();
  final CatCubit catCubit = CatCubit();
  final FavoriteCatsCubit favoriteCatsCubit = FavoriteCatsCubit();
  final MyHomePageCubit myHomePageCubit = MyHomePageCubit();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authenticationCubit),
        BlocProvider.value(value: catCubit),
        BlocProvider.value(value: favoriteCatsCubit),
        BlocProvider.value(value: myHomePageCubit),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: SplashScreen(
          onSplashScreenComplete: () async {
            await authenticationCubit.checkAuthenticationStatus();
            navigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(
                builder: (context) => MyAppContent(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onSplashScreenComplete;

  SplashScreen({Key? key, required this.onSplashScreenComplete}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _checkAuthenticationStatus() async {
    bool isConnected = await _checkInternetConnection();
    await Future.delayed(Duration(seconds: 3));

    if (isConnected) {
      final authStatus = context.read<AuthenticationCubit>().state;
      if (authStatus == AuthenticationStatus.authenticated) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No internet connection'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                exit(0);
              },
              child: Text('Leave'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final AuthenticationStatus authStatus = context.watch<AuthenticationCubit>().state;
    if (authStatus == AuthenticationStatus.unauthenticated) {
      return LoginScreen();
    }

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
                  onPressed: () {
                    context.read<AuthenticationCubit>().logoutUser();
                  },
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

class FavoritePage extends StatelessWidget {
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

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Welcome!',
                style: const TextStyle(fontSize: 20.0)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2.0),
                    ),
                    labelText: 'Username'
                ),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2.0),
                  ),
                  labelText: 'Password'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text;
                final String password = passwordController.text;
                final User user = User(name: name, password: password);

                context.read<AuthenticationCubit>().loginUser(user, context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ));
              },
              child: Text('Login'),

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
          ],
        ),
      ),
    );
  }
}

class CatHeroImage extends StatelessWidget {
  final String imageUrl;

  CatHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Свайп вниз
          if (details.primaryDelta! < -4) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Hero(
              tag: imageUrl,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}