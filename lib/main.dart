import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_dev/cubits/authentication_cubit.dart';
import 'package:mobile_dev/cubits/cat_cubit.dart';
import 'package:mobile_dev/cubits/favorite_cats_cubit.dart';
import 'package:mobile_dev/cubits/home_screen_cubit.dart';
import 'package:mobile_dev/screens/home_screen.dart';
import 'package:mobile_dev/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthenticationCubit authenticationCubit = AuthenticationCubit();
  final CatCubit catCubit = CatCubit();
  final FavoriteCatsCubit favoriteCatsCubit = FavoriteCatsCubit();
  final HomeScreenCubit homeScreenCubit = HomeScreenCubit();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authenticationCubit),
        BlocProvider.value(value: catCubit),
        BlocProvider.value(value: favoriteCatsCubit),
        BlocProvider.value(value: homeScreenCubit),
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
    return HomeScreen();
  }
}