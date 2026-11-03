import 'package:flutter/material.dart';

class Course {
  final String name;
  final String instructor;
  final int credits;
  final double fee;
  const Course(this.name, this.instructor, this.credits, this.fee);
}

const List<Course> allCourses = [
  Course('Flutter Development', 'Dr. Arun Kumar', 4, 4500),
  Course('Data Structures', 'Prof. Meena S', 3, 3500),
  Course('Machine Learning', 'Dr. Ravi Shankar', 4, 5000),
  Course('Cloud Computing', 'Prof. Divya R', 3, 4000),
];

// Central place for route names
class AppRoutes {
  static const home = '/';
  static const details = '/details';
  static const summary = '/summary';
}

void main() => runApp(const NavApp());

class NavApp extends StatelessWidget {
  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Enrollment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.details: (context) => const DetailsPage(),
        AppRoutes.summary: (context) => const SummaryPage(),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const NotFoundPage()),
    );
  }
}

// ---------------- Screen 1: Home ----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Course> _enrolled = [];

  Future<void> _openDetails(Course course) async {
    // Send data forward, wait for the value sent back by pop()
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.details,
      arguments: course,
    );

    if (!mounted) return;
    if (result == true && !_enrolled.contains(course)) {
      setState(() => _enrolled.add(course));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enrolled in ${course.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_enrolled.length}'),
              isLabelVisible: _enrolled.isNotEmpty,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.summary,
              arguments: _enrolled,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: allCourses.length,
        itemBuilder: (context, i) {
          final c = allCourses[i];
          final done = _enrolled.contains(c);
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.menu_book)),
              title: Text(c.name),
              subtitle: Text(c.instructor),
              trailing: done
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openDetails(c),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Screen 2: Details ----------------
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive data passed through the named route
    final course = ModalRoute.of(context)!.settings.arguments as Course;

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Instructor : ${course.instructor}'),
            Text('Credits    : ${course.credits}'),
            Text('Fee        : ₹${course.fee.toStringAsFixed(2)}'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // Return a result to the previous screen
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Enroll'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Screen 3: Summary ----------------
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enrolled = ModalRoute.of(context)!.settings.arguments as List<Course>;
    final total = enrolled.fold<double>(0, (s, c) => s + c.fee);

    return Scaffold(
      appBar: AppBar(title: const Text('Enrollment Summary')),
      body: Column(
        children: [
          Expanded(
            child: enrolled.isEmpty
                ? const Center(child: Text('No courses enrolled yet'))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: enrolled
                        .map(
                          (c) => Card(
                            child: ListTile(
                              title: Text(c.name),
                              trailing: Text('₹${c.fee.toStringAsFixed(2)}'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total Fee: ₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  // Jump back to the home route
                  onPressed: () =>
                      Navigator.popUntil(context, ModalRoute.withName('/')),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Unknown route ----------------
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('404 - Page not found')),
    );
  }
}
