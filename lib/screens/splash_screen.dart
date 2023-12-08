import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/authentication_cubit.dart';
import 'home_screen.dart';
import 'login_screen.dart';

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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
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