import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// https://pub.dev/packages/qr_flutter
// https://medium.com/flutter-community/building-flutter-qr-code-generator-scanner-and-sharing-app-703e73b228d3

class QRGenerator extends StatefulWidget {
  final String passedValue1;
  const QRGenerator({Key? key, required this.passedValue1}) : super(key: key);

  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.passedValue1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account Information'),
          automaticallyImplyLeading: false,
        ),
        body: Column(


        ),
    );
  }

}