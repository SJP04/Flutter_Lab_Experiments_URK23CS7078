import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LibraryApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform => null;
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Book Copies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const BookUpdatePage(),
    );
  }
}

class BookUpdatePage extends StatefulWidget {
  const BookUpdatePage({super.key});

  @override
  State<BookUpdatePage> createState() => _BookUpdatePageState();
}

class _BookUpdatePageState extends State<BookUpdatePage> {
  final _titleController = TextEditingController();
  final _copiesController = TextEditingController();
  final CollectionReference<Map<String, dynamic>> _books = FirebaseFirestore
      .instance
      .collection('books');

  bool _searched = false;
  DocumentReference<Map<String, dynamic>>? _bookRef;
  Map<String, dynamic>? _book;

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // SEARCH: find the book document by title and keep its reference
  Future<void> _searchBook() async {
    final query = _titleController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _searched = true;
      _book = null;
      _bookRef = null;
    });

    try {
      final snapshot = await _books.get();
      if (!mounted) return;
      for (final doc in snapshot.docs) {
        if ((doc.data()['title'] ?? '').toString().toLowerCase() == query) {
          setState(() {
            _bookRef = doc.reference;
            _book = doc.data();
          });
          break;
        }
      }
    } catch (e) {
      if (!mounted) return;
      _msg('Error: $e');
    }
  }

  // UPDATE: modify only the copies field, then show the refreshed record
  Future<void> _updateBook() async {
    if (_bookRef == null) {
      _msg('Search for a book first');
      return;
    }

    final newCopies = int.tryParse(_copiesController.text.trim());
    if (newCopies == null || newCopies < 0) {
      _msg('Enter a valid number of copies');
      return;
    }

    try {
      await _bookRef!.update({'copies': newCopies});
      final fresh = await _bookRef!.get();
      if (!mounted) return;
      setState(() => _book = fresh.data());
      _copiesController.clear();
      _msg('Book updated successfully');
    } catch (e) {
      if (!mounted) return;
      _msg('Update failed: $e');
    }
  }

  // Live list shown in the screenshot: updates automatically after Update
  Widget _buildAvailableBooks() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _books.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Books',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...docs.map((doc) {
              final d = doc.data();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text('${d['title']}'),
                  subtitle: Text('${d['author']} · ${d['copies']} copies'),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Book Copies')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Book Title',
              prefixIcon: Icon(Icons.menu_book),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _copiesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Updated Number of Copies',
              prefixIcon: Icon(Icons.numbers),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchBook,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _updateBook,
                  icon: const Icon(Icons.update),
                  label: const Text('Update'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_searched && _book == null)
            const Text(
              'Book not found',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_book != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: ${_book!['title']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Author: ${_book!['author']}'),
                    const SizedBox(height: 6),
                    Text('Copies Available: ${_book!['copies']}'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildAvailableBooks(),
        ],
      ),
      // Footer seen in the screenshot (optional)
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Register No: URK23CS7016',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
