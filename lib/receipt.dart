import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';

class Receipt extends StatefulWidget {
  final String passedValue1;
  const Receipt({Key? key, required this.passedValue1}) : super(key: key);

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blockchain Transacted Data'),
          automaticallyImplyLeading: false,
        ),
        body: Column(children: <Widget>[
          Row(
            children: <Widget>[ Expanded(
              child: Text(widget.passedValue1, textScaleFactor: 1.8),
            ),],
          ),
        ],),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: const Text('Main'),
                // Within the OutputDataScreen widget
                onPressed: () {
                  // Navigate to the main screen using a named route.
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp(),),);
                },
              )
            ]
        )
    );
  }
}