import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';

class Output extends StatelessWidget {
  final List passedValue1, passedValue2;
  const Output({Key? key, required this.passedValue1, required this.passedValue2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Output Data'),
        automaticallyImplyLeading: false,
      ),
        body: Text(
          '\nAll_ArrayData: $passedValue1 \n\nArray_Data: $passedValue2',
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