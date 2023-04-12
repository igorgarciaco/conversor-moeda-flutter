import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Moeda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _controller = TextEditingController();
  double _dollarRate = 0.0;
  String _fromCurrency = 'Real';
  String _toCurrency = 'Dólar';

  @override
  void initState() {
    super.initState();
    _fetchDollarRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moeda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Converter $_fromCurrency para $_toCurrency',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor em $_fromCurrency',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _dollarRate == 0.0 ? null : _convert,
              child: Text(_dollarRate == 0.0 ? 'Carregando...' : 'Converter'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: TextEditingController(text: _getConvertedValue()),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Valor em $_toCurrency',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final temp = _fromCurrency;
                  _fromCurrency = _toCurrency;
                  _toCurrency = temp;
                  _controller.clear();
                });
              },
              child: const Text('Inverter conversão'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchDollarRate() async {
    final response = await http
        .get(Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL'));
    final jsonData = jsonDecode(response.body);
    final rate = jsonData['USDBRL']['bid'];
    setState(() {
      _dollarRate = double.parse(rate);
    });
  }

  void _convert() {
    final inputValue = double.parse(_controller.text.replaceAll(',', '.'));
    final convertedValue = _fromCurrency == 'Real'
        ? inputValue / _dollarRate
        : inputValue * _dollarRate;
    setState(() {
      _controller.text = convertedValue.toStringAsFixed(2).replaceAll('.', ',');
    });
  }

  String _getConvertedValue() {
    if (_controller.text.isEmpty) {
      return '';
    }
    final value = double.parse(_controller.text.replaceAll(',', '.'));
    final convertedValue =
        _fromCurrency == 'Real' ? value / _dollarRate : value * _dollarRate;
    return convertedValue.toStringAsFixed(2).replaceAll('.', ',');
  }
}
