import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  _CalorieCalculatorScreenState createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> allProducts = [];
  Map<String, Map<String, dynamic>> selectedProducts = {};
  String selectedMealTime = 'Завтрак';

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    // Получаем данные из супабейз
    try {
      final milkProducts = await supabase.from('milk_products').select();
      final breadsProducts = await supabase.from('breads_products').select();
      final fruitsProducts = await supabase.from('fruits_product').select();
      final vegetablesProducts =
          await supabase.from('vegetables_product').select();
      final meatProducts = await supabase.from('meat_product').select();
      final seafoodProducts = await supabase.from('seafood_product').select();
      final beveragesProducts =
          await supabase.from('beverages_product').select();
      final snacksProducts = await supabase.from('snacks_product').select();
      final grainsProducts = await supabase.from('grains_product').select();
      final condimentsProducts =
          await supabase.from('condiments_product').select();

      setState(() {
        allProducts = [
          ...milkProducts,
          ...breadsProducts,
          ...fruitsProducts,
          ...vegetablesProducts,
          ...meatProducts,
          ...seafoodProducts,
          ...beveragesProducts,
          ...snacksProducts,
          ...grainsProducts,
          ...condimentsProducts,
        ];
      });
    } catch (error) {
      print('Ошибка загрузки данных: $error');
    }
  }

  void addProduct(Map<String, dynamic> product, int portions) {
    // добавить продукт
    setState(() {
      selectedProducts[product['name']] = {
        'product': product,
        'portions': portions,
      };
    });
  }

  void removeProduct(String productName) {
    // убрать продукт
    setState(() {
      selectedProducts.remove(productName);
    });
  }

  num calculateTotalCalories() {
    // логика подсчета калорий
    return selectedProducts.values.fold(0, (sum, entry) {
      final product = entry['product'];
      final portions = entry['portions'];
      return sum + (product['calories'] * portions);
    });
  }

  Future<void> saveData() async {
    // внесение данных в супабейз
    try {
      final data = selectedProducts.entries.map((entry) {
        final product = entry.value['product'];
        final portions = entry.value['portions'];
        return {
          'meal_time': selectedMealTime,
          'product_name': product['name'],
          'calories': product['calories'] * portions,
          'portions': portions,
        };
      }).toList();

      await supabase.from('consumed_calories').insert(data);
      print('Данные успешно сохранены');

      // Сброс данных
      setState(() {
        selectedProducts.clear();
      });

      // Показ уведомления
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно сохранены'),
        ),
      );
    } catch (error) {
      print('Ошибка сохранения данных: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения данных: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор калорий'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedMealTime,
            items: ['Завтрак', 'Обед', 'Ужин']
                .map((meal) => DropdownMenuItem(
                      value: meal,
                      child: Text(meal),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedMealTime = value!;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                final product = allProducts[index];
                final isSelected =
                    selectedProducts.containsKey(product['name']);
                return ListTile(
                  title: Text(product['name']),
                  trailing: isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                removeProduct(product['name']);
                              },
                            ),
                            Text(
                                '${selectedProducts[product['name']]!['portions']} порций'),
                          ],
                        )
                      : IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                int portions = 1;
                                return AlertDialog(
                                  title:
                                      const Text('Введите количество порций'),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      portions = int.parse(value);
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addProduct(product, portions);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Добавить'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Общее количество калорий: ${calculateTotalCalories()} ккал',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: saveData,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
