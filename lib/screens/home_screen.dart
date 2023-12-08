import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/authentication_cubit.dart';
import '../cubits/cat_cubit.dart';
import '../cubits/home_screen_cubit.dart';
import 'cat_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
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
                        index: context.select((HomeScreenCubit cubit) => cubit.state),
                        children: [
                          CatScreen(),
                          FavoriteScreen(),
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
            currentIndex: context.watch<HomeScreenCubit>().state,
            onTap: (index) {
              context.read<HomeScreenCubit>().setSelectedIndex(index);
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