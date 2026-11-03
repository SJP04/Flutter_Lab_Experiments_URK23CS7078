import 'package:flutter/material.dart';

void main() => runApp(const ProductSearchApp());

// 1. Data model
class Product {
  final String name;
  final String category;
  final double price;

  const Product(this.name, this.category, this.price);
}

// 2. Predefined data
const List<Product> allProducts = [
  Product('Smartphone', 'Electronics', 15999),
  Product('Laptop', 'Electronics', 45999),
  Product('Tablet', 'Electronics', 19999),
  Product('Headphones', 'Accessories', 1999),
  Product('Smart Watch', 'Accessories', 3499),
  Product('Keyboard', 'Accessories', 999),
  Product('Bluetooth Speaker', 'Audio', 2499),
  Product('Earphones', 'Audio', 799),
];

class ProductSearchApp extends StatelessWidget {
  const ProductSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const ProductSearchPage(),
    );
  }
}

// 3. Stateful page: the part that changes
class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Electronics',
    'Accessories',
    'Audio',
  ];

  // The state: these two values drive the whole screen
  String _query = '';
  String _selectedCategory = 'All';

  // Applies BOTH filters together
  List<Product> get _filteredProducts {
    return allProducts.where((p) {
      final matchesName = p.name.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesName && matchesCategory;
    }).toList();
  }

  // Frees the controller's memory when the page closes
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProducts; // recalculated on every rebuild

    return Scaffold(
      appBar: AppBar(title: const Text('Product Search & Filter')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                // Clear (X) button appears only when something is typed
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 10),

            // Category chips
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: _selectedCategory == c,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Result count (missing from the sample code, added here)
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${results.length} product(s) found'),
            ),
            const SizedBox(height: 6),

            // Results list, or an empty-state message
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final p = results[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.shopping_bag),
                            ),
                            title: Text(p.name),
                            subtitle: Text(p.category),
                            trailing: Text(
                              '₹${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
