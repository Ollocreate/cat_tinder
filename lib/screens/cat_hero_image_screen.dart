import 'package:flutter/material.dart';

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