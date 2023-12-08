import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/authentication_cubit.dart';
import 'home_screen.dart';

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
                  builder: (context) => HomeScreen(),
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