import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) toggleFavorite;

  FavoritesScreen(this.favoriteProducts, this.toggleFavorite);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: ListView.builder(
        itemCount: widget.favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = widget.favoriteProducts[index];
          return ListTile(
            title: Text(product['name']),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.toggleFavorite(product);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
