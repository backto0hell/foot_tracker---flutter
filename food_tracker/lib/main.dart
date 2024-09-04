import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'favorites_screen.dart';
import 'calculate_calories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xyjhtgmfccryjxbnvqwf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5amh0Z21mY2NyeWp4Ym52cXdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI5NDUyMjMsImV4cCI6MjAzODUyMTIyM30.Bwel-M68XMieA4sF_-sPFBVZU89ozCbejbzzywBqfxo',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Справочник продуктов',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CategoriesScreen(),
    );
  }
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filteredCategories = [];
  List<Map<String, dynamic>> favoriteProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    searchController.addListener(_filterCategories);
  }

  Future<void> fetchCategories() async {
    try {
      final milkProductsResponse =
          await supabase.from('milk_products').select();
      final breadsProductsResponse =
          await supabase.from('breads_products').select();
      final fruitsProducts = await supabase.from('fruits_product').select();
      final vegetablesProductsResponse =
          await supabase.from('vegetables_product').select();
      final meatProductsResponse = await supabase.from('meat_product').select();
      final seafoodProductsResponse =
          await supabase.from('seafood_product').select();
      final beveragesProductsResponse =
          await supabase.from('beverages_product').select();
      final snacksProductsResponse =
          await supabase.from('snacks_product').select();
      final grainsProductsResponse =
          await supabase.from('grains_product').select();
      final condimentsProductsResponse =
          await supabase.from('condiments_product').select();

      final milkProducts = milkProductsResponse as List<dynamic>;
      final breadsProducts = breadsProductsResponse as List<dynamic>;
      final vegetablesProducts = vegetablesProductsResponse as List<dynamic>;
      final meatProducts = meatProductsResponse as List<dynamic>;
      final seafoodProducts = seafoodProductsResponse as List<dynamic>;
      final beveragesProducts = beveragesProductsResponse as List<dynamic>;
      final snacksProducts = snacksProductsResponse as List<dynamic>;
      final grainsProducts = grainsProductsResponse as List<dynamic>;
      final condimentsProducts = condimentsProductsResponse as List<dynamic>;

      setState(() {
        categories = [
          {'name': 'Молочные продукты', 'products': milkProducts},
          {'name': 'Хлебобулочные изделия', 'products': breadsProducts},
          {'name': 'Фрукты', 'products': fruitsProducts},
          {'name': 'Овощи', 'products': vegetablesProducts},
          {'name': 'Мясо', 'products': meatProducts},
          {'name': 'Морепродукты', 'products': seafoodProducts},
          {'name': 'Напитки', 'products': beveragesProducts},
          {'name': 'Закуски', 'products': snacksProducts},
          {'name': 'Зерновые', 'products': grainsProducts},
          {'name': 'Приправы', 'products': condimentsProducts},
        ];
        filteredCategories = categories;
      });
    } catch (error) {
      print('Ошибка загрузки данных: $error');
    }
  }

  void _filterCategories() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCategories = categories
          .map((category) => {
                'name': category['name'],
                'products': (category['products'] as List<dynamic>)
                    .where((product) =>
                        product['name'].toLowerCase().contains(query))
                    .toList()
              })
          .where(
              (category) => (category['products'] as List<dynamic>).isNotEmpty)
          .toList();
    });
  }

  void toggleFavorite(Map<String, dynamic> product) {
    setState(() {
      if (favoriteProducts.contains(product)) {
        favoriteProducts.remove(product);
      } else {
        favoriteProducts.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории продуктов'), actions: [
        IconButton(
          icon: const Icon(Icons.calculate_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalorieCalculatorScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FavoritesScreen(favoriteProducts, toggleFavorite),
              ),
            );
          },
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailScreen(
                            category: filteredCategories[index]['name'],
                            products: filteredCategories[index]['products'],
                            favoriteProducts: favoriteProducts,
                            toggleFavorite: toggleFavorite,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            filteredCategories[index]['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  final List<dynamic> products;
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) toggleFavorite;

  CategoryDetailScreen({
    required this.category,
    required this.products,
    required this.favoriteProducts,
    required this.toggleFavorite,
  });

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          final isFavorite = widget.favoriteProducts.contains(product);
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('${product['name']} на 100 грамм продукта'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Жиры: ${product['fats']} г.'),
                        Text('Калории: ${product['calories']} Ккал'),
                        Text('Белки: ${product['proteins']} г.'),
                        Text('Углеводы: ${product['carbohydrates']} г.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Закрыть'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Card(
              elevation: 4.0,
              child: ListTile(
                title: Text(product['name']),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.toggleFavorite(product);
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
