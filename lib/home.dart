import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    DateTime sekarang = DateTime.now();
    var waktuSekarang = int.parse(DateFormat('kk').format(sekarang));
    var salam = "";
    if (waktuSekarang >= 0 && waktuSekarang < 12) {
      salam = "Selamat Pagi";
    } else if (waktuSekarang >= 12 && waktuSekarang < 15) {
      salam = "Selamat Siang";
    } else if (waktuSekarang >= 15 && waktuSekarang < 18) {
      salam = "Selamat Sore";
    } else {
      salam = "Selamat Malam";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(salam),
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Card(
            child: GridTile(
              header: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                ),
              ),
              child: Center(child: Text(_items[index])),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _items.add("Item ${_items.length + 1}");
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
