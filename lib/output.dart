import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';

class Output extends StatefulWidget {
  final List passedValue1, passedValue2;
  const Output({Key? key, required this.passedValue1, required this.passedValue2}) : super(key: key);

  @override
  State<Output> createState() => _OutputState();
}

class _OutputState extends State<Output> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Output Data'),
        automaticallyImplyLeading: false,
      ),
        body: Text(
          '\nAll_ArrayData: ${widget.passedValue1} \n\nArray_Data: ${widget.passedValue2}',
          textAlign: TextAlign.left,
          // overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 25),
        ),
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