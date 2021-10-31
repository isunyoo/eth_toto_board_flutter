import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';

class GeneratedOutput extends StatelessWidget {
  final List passedValue1;
  const GeneratedOutput({Key? key, required this.passedValue1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Slots'),
        automaticallyImplyLeading: false,
      ),
      body: Text(
        '\nGenerated Slots: $passedValue1',
        textAlign: TextAlign.left,
        // overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 30),
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