import 'package:flutter/material.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<String> orders = [];
  final TextEditingController _orderController = TextEditingController();

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  void _addOrder() {
    setState(() {
      orders.add(_orderController.text);
      _orderController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesanan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _orderController,
              decoration: InputDecoration(
                labelText: 'Enter order',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addOrder,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to order details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
