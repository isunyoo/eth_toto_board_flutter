import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eth_toto_board_flutter/main.dart';

// https://stackoverflow.com/questions/59566675/flutter-how-to-copy-text-after-pressing-the-button

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
  }

  _qrContentWidget() {
    return  Container(
      color: const Color(0xFFFFFFFF),
      child:  Column(
        children: <Widget>[
          Center(
              child: QrImage(
                        data: widget.passedValue1,
                        version: QrVersions.auto,
                        size: 200,
                        gapless: false,
                     )
          ),
          Row(
            children: <Widget>[ Expanded(
              child: Text(
                "\nWallet Account Address: ${widget.passedValue1}",
                textScaleFactor: 1.3,
              ),
            ),
            ],
          ),
          Row(
            children: <Widget>[ Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 3),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.passedValue1)).then((value) {
                    final snackBar = SnackBar(
                        content: const Text('Copied to Clipboard'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {},
                        );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar));
                  };
                },
                child: const Text('Copy Address'),
              )
            ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Account Information'),
          automaticallyImplyLeading: false,
        ),
        // body: Column(
        // ),
        body: _qrContentWidget(),
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