import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';

class Output extends StatefulWidget {
  final List passedValue1;
  final int passedValue2;
  const Output({Key? key, required this.passedValue1, required this.passedValue2}) : super(key: key);

  @override
  State<Output> createState() => _OutputState();
}

class _OutputState extends State<Output> {

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
            child: Text("\nNewly Stored Slot Numbers: ${widget.passedValue2}", textScaleFactor: 1.8),
          ),],
        ),
        Row(
          children: const <Widget>[ Expanded(
            child: Text(
              "Newly Stored Slot Data: ",
              textScaleFactor: 1.8,
            ),
          ),],
        ),
        Row(
          children: <Widget>[ Expanded(
              child: ListView.builder (
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.passedValue1.length,
                  // A Separate Function called from itemBuilder
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Text("${index+1}: " + widget.passedValue1[index].toString(), textScaleFactor: 2.0);
                  }
              )
          ),],
        ),
      ],),
      floatingActionButton: ElevatedButton(
        child: const Text('Main'),
        // Within the OutputDataScreen widget
        onPressed: () {
          // Navigate to the main screen using a named route.
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp(),),);
        },
      ),
    );
  }
}