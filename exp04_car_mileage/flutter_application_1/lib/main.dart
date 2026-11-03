import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for FilteringTextInputFormatter

void main() => runApp(const MileageApp());

class MileageApp extends StatelessWidget {
  const MileageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Mileage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const MileageCalculator(),
    );
  }
}

class MileageCalculator extends StatefulWidget {
  const MileageCalculator({super.key});

  @override
  State<MileageCalculator> createState() => _MileageCalculatorState();
}

class _MileageCalculatorState extends State<MileageCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _fuelController = TextEditingController();

  double? _mileage; // null = nothing calculated yet

  // One validator reused for both fields. null means "valid".
  String? _validate(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    final number = double.tryParse(value.trim());
    if (number == null) return 'Enter a valid number';
    if (number <= 0) return '$label must be greater than 0';
    return null;
  }

  void _calculate() {
    // validate() runs every validator; true only if all pass
    if (_formKey.currentState!.validate()) {
      final distance = double.parse(_distanceController.text.trim());
      final fuel = double.parse(_fuelController.text.trim());
      setState(() => _mileage = distance / fuel);
    }
  }

  void _reset() {
    _formKey.currentState!.reset(); // clears error messages
    _distanceController.clear();
    _fuelController.clear();
    setState(() => _mileage = null); // hides the result card
  }

  String _rating(double m) {
    if (m >= 18) return 'Excellent';
    if (m >= 12) return 'Good';
    return 'Average';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Mileage Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.directions_car, size: 80, color: Colors.orange),
              const SizedBox(height: 16),

              TextFormField(
                controller: _distanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Distance Travelled (km)',
                  prefixIcon: Icon(Icons.route),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 'distance'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fuelController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Fuel Consumed (litres)',
                  prefixIcon: Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 'fuel'),
              ),
              const SizedBox(height: 20),

              // Buttons (missing from the sample code, added here)
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _calculate,
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Result card appears only when _mileage is not null
              if (_mileage != null)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Mileage', style: TextStyle(fontSize: 16)),
                        Text(
                          '${_mileage!.toStringAsFixed(2)} km/l',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Efficiency: ${_rating(_mileage!)}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
