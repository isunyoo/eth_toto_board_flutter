import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:eth_toto_board_flutter/screens/login.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class QRGenerator extends StatefulWidget {
  final String passedValue1;
  const QRGenerator({Key? key, required this.passedValue1}) : super(key: key);

  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  // The user's ID which is unique from the Firebase project
  User? user = FirebaseAuth.instance.currentUser;
  bool _isSigningOut = false;

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
          Row(
            children: <Widget>[ Expanded(
              child: Text(
                "\nName: ${user?.displayName}",
                textScaleFactor: 1.5,
              ),
            ),
            ],
          ),
          Row(
            children: <Widget>[ Expanded(
              child: Text(
                "Email: ${user?.email}",
                textScaleFactor: 1.5,
              ),
            ),
            ],
          ),
          Row(
            children: <Widget>[ Expanded(
              child: Text(
                "\nWallet Account Address: ${widget.passedValue1}\n",
                textScaleFactor: 1.3,
              ),
            ),
            ],
          ),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 3),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.passedValue1)).then((value) {
                    final snackBar = SnackBar(
                        content: const Text('Copied to Clipboard'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: ''));
                          },
                        ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
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
        body: _qrContentWidget(),
        floatingActionButton: SpeedDial(
        icon: Icons.menu,
        backgroundColor: Colors.blueAccent,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.exit_to_app),
            label: 'Logout',
            backgroundColor: Colors.blue,
            onTap: () async {
              _isSigningOut = true;
              await FirebaseAuth.instance.signOut();
              // Navigate to the main screen using a named route.
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage(),),);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.menu_rounded),
            label: 'Main',
            backgroundColor: Colors.blue,
            onTap: () {
              // Navigate to the main screen using a named route.
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardMain(),),);
            },
          ),
        ]
    ),
    );
  }
}