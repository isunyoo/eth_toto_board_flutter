import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:eth_toto_board_flutter/import.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:eth_toto_board_flutter/screens/login.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_toto_board_flutter/utilities/authenticator.dart';

class ProfilePage extends StatefulWidget {
  final String passAddressValue;
  const ProfilePage({Key? key, required this.passAddressValue}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // The user's ID which is unique from the Firebase project
  User? user = FirebaseAuth.instance.currentUser;
  bool _isSigningOut = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // https://pub.dev/packages/jdenticon_dart/example
  Widget _getCardWithIcon(String name) {
  final String rawSvg = Jdenticon.toSvg(name);
  return Card(
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.string(
                rawSvg,
                fit: BoxFit.fill,
                height: 32,
                width: 32,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.string(
                rawSvg,
                fit: BoxFit.fill,
                height: 32,
                width: 32,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.string(
                rawSvg,
                fit: BoxFit.fill,
                height: 32,
                width: 32,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12.0,
        ),
        SvgPicture.string(
          rawSvg,
          fit: BoxFit.contain,
          height: 64,
          width: 64,
        ),
        const SizedBox(
          height: 12.0,
        ),
        SvgPicture.string(
          rawSvg,
          fit: BoxFit.scaleDown,
          height: 128,
          width: 128,
        ),
        const SizedBox(
          height: 12.0,
        ),
        SvgPicture.string(
          rawSvg,
          fit: BoxFit.fitWidth,
          width: 256,
        ),
        Text(
          name,
          textScaleFactor: 1.5,
          style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.6),
        ),
      ],
    ),
  );
}

  // QRCode Display Widget
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
              // child: Card(
              //   child: Column(
              //     children: <Widget>[
              //       SvgPicture.string(rawSvg, fit: BoxFit.contain, height: 64, width: 64,),
              //       const SizedBox(height: 12.0,),
              //       SvgPicture.string(rawSvg, fit: BoxFit.scaleDown, height: 128, width: 128,),
              //       const SizedBox(height: 12.0,),
              //       SvgPicture.string(rawSvg, fit: BoxFit.fitWidth, width: 256,),
              //     ],
              //   ),
              // );
              child: _getCardWithIcon(widget.passAddressValue),
            ),
            ],
          ),
          Row(
            children: <Widget>[ Expanded(
              child: Text(
                "\nCurrent Wallet Account Address: ${widget.passAddressValue}\n",
                textScaleFactor: 1.2,
              ),
            ),
            ],
          ),
          Center(
              child: QrImage(
                        data: widget.passAddressValue,
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
                  Clipboard.setData(ClipboardData(text: widget.passAddressValue)).then((value) {
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
    // No account has imported yet in vault database
    if(widget.passAddressValue == '') {
      // The delay to route BoardMain Page Scaffold
      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        // Navigate to the main screen using a named route.
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportKey()));
      });
    }
    // SigningOut Status Parameter
    _isSigningOut;
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
            child: const Icon(Icons.vpn_key_rounded),
            label: 'Import Key',
            backgroundColor: Colors.blue,
            onTap: () {
              // Navigate to the main screen using a named route.
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportKey()));
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.exit_to_app),
            label: 'Logout',
            backgroundColor: Colors.blue,
            onTap: () async {
              setState(() {
                _isSigningOut = true;
              });
              await FirebaseAuth.instance.signOut();
              await FireAuth.signOutWithGoogle(context: context);
              setState(() {
                _isSigningOut = false;
              });
              // Navigate Push Replacement which will not going back and return back to the LoginPage
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
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

// https://api.flutter.dev/flutter/material/RadioListTile-class.html