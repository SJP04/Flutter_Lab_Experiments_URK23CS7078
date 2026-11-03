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
      title: 'Library Book Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const BookSearchPage(),
    );
  }
}

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final _titleController = TextEditingController();
  final CollectionReference<Map<String, dynamic>> _books = FirebaseFirestore
      .instance
      .collection('books');

  bool _loading = false;
  bool _searched = false;
  Map<String, dynamic>? _book;

  // SEARCH: fetch all books, compare title ignoring case
  Future<void> _searchBook() async {
    final query = _titleController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = true;
      _book = null;
    });

    Map<String, dynamic>? found;
    try {
      final snapshot = await _books.get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['title'] ?? '').toString().toLowerCase() == query) {
          found = data;
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    if (!mounted) return;
    setState(() {
      _book = found;
      _loading = false;
    });
  }

  Widget _buildResult() {
    if (_loading) return const CircularProgressIndicator();
    if (!_searched) return const SizedBox.shrink();

    if (_book == null) {
      return const Text(
        'Book not found',
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final int copies = (_book!['copies'] as num?)?.toInt() ?? 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${_book!['title']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Author: ${_book!['author']}'),
            const SizedBox(height: 6),
            Text('Copies Available: $copies'),
            if (copies == 0) ...[
              const SizedBox(height: 10),
              const Text(
                'Not Available - All Copies Issued',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Shown in Figure 8.1: all books stored in the collection
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library Book Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Enter Book Title',
              prefixIcon: Icon(Icons.menu_book),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _searchBook(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _searchBook,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: _buildResult()),
          const SizedBox(height: 20),
          _buildAvailableBooks(),
        ],
      ),
      // Footer seen in the screenshots (optional)
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
