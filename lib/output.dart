import 'package:flutter/material.dart';

class Output extends StatelessWidget {
  final List passedValue1;
  final List passedValue2;
  const Output({Key? key, required this.passedValue1, required this.passedValue2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Output Data'),
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
          // Navigate back to the first screen by popping the current route off the stack.
          Navigator.pop(context);
        },
      ),
    );
  }
}