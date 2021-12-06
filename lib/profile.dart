import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:eth_toto_board_flutter/import.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eth_toto_board_flutter/screens/login.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_toto_board_flutter/utilities/web3dartutil.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/authenticator.dart';

class ProfilePage extends StatefulWidget {
  final String passAddressValue;
  const ProfilePage({Key? key, required this.passAddressValue}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum SingingCharacter { lafayette, jefferson }

class _ProfilePageState extends State<ProfilePage> {
  // Initialize the Web3DartHelper class from utility packages
  Web3DartHelper web3util = Web3DartHelper();
  // To create a new Firebase Remote Config instance
  // late final RemoteConfig remoteConfig = RemoteConfig.instance;
  // Create a DatabaseReference which references a node called txreceipts
  // late final DatabaseReference _dbRef = FirebaseDatabase(databaseURL:jsonDecode(_remoteConfig.getValue('Connection_Config').asString())['Firebase']['Firebase_Database']).reference();
  // The user's ID which is unique from the Firebase project
  User? user = FirebaseAuth.instance.currentUser;
  bool _isSigningOut = false;
  SingingCharacter? _character = SingingCharacter.lafayette;
  List<Map<dynamic, dynamic>> lists = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    // Initialize web3utility
    // await web3util.initState();
    // Firebase Initialize App Function
    await Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    // To fetch remote config from Firebase Remote Config
    // RemoteConfigService _remoteConfigService = RemoteConfigService();
    // _remoteConfig = await _remoteConfigService.setupRemoteConfig();
    // print(await web3util.getAccountEthBalance('0x35c74387683bfaadda78241b0c04a91cc6ae55e8')+' (ETH)');
    // print(await web3util.getConvEthUSD(await web3util.getAccountEthBalance('0x35c74387683bfaadda78241b0c04a91cc6ae55e8'))+' (USD)');
  }

  Future<String> getEthValue(String address) async {
    String value = await web3util.getAccountEthBalance(address);
    return value;
  }

  // Jdenticon Display Widget
  Widget _getCardWithIcon(String name) {
  final String rawSvg = Jdenticon.toSvg(name);
  return Card(
    child: Column(
      children: <Widget>[
        const SizedBox(
          height: 5.0,
        ),
        SvgPicture.string(
          rawSvg,
          fit: BoxFit.contain,
          height: 50,
          width: 50,
          color: Colors.lightBlueAccent,
        ),
      ],
    ),
  );}

  // QRCode Display Widget
  _qrContentWidget() {
    return  Container(
      color: const Color(0xFFFFFFFF),
      child: SingleChildScrollView(
        child:  Column(
          children: <Widget>[
            Row(
              children: <Widget>[ Expanded(
                child: Text("\n Name: ${user?.displayName}", textScaleFactor: 1.5),
              ),],
            ),
            Row(
              children: <Widget>[ Expanded(
                child: Text(" Email: ${user?.email}", textScaleFactor: 1.5),
              ),],
            ),
            Row(
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(5.0),
                  child: _getCardWithIcon(widget.passAddressValue),
                ),
                const Padding(padding: EdgeInsets.all(5.0),
                  child: Text("\nCurrent Account Address: ", textScaleFactor: 1.5),
                ),
              ],
            ),
            Row(
              children: <Widget>[ Expanded(
                child: Text(" ${widget.passAddressValue}\n", textScaleFactor: 1.2),
              ),],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: const Text('Copy Address', style: TextStyle(color: Colors.white)),
                )
              ),],
            ),
            Row(
              children: const <Widget>[ Expanded(
                child: Text(
                  "\n My Accounts: ",
                  textScaleFactor: 1.2,
                ),
              ),],
            ),
            // Column(
            //   children: <Widget>[
            //     RadioListTile<SingingCharacter>(
            //       title: const Text('Lafayette'),
            //       value: SingingCharacter.lafayette,
            //       groupValue: _character,
            //       onChanged: (SingingCharacter? value) {
            //         setState(() {
            //         _character = value;
            //         print(_character);
            //         });
            //       },
            //     ),
            //     RadioListTile<SingingCharacter>(
            //       title: const Text('Thomas Jefferson'),
            //       value: SingingCharacter.jefferson,
            //       groupValue: _character,
            //       onChanged: (SingingCharacter? value) {
            //         setState(() {
            //         _character = value;
            //         print(_character);
            //        });
            //       },
            //     ),
            //   ],
            // ),

            Column(
                children: <Widget>[
                  FutureBuilder(
                      future: web3util.dbRef.child('vaults/${user?.uid}').once(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if(snapshot.connectionState == ConnectionState.done) {
                          if(snapshot.data.value == null) {
                            return const Text('\n No Account Data has Existed.', textScaleFactor: 1.5, style: TextStyle(color: Colors.red));
                          } else {
                            // 'DataSnapshot' value != null
                            lists.clear();
                            Map<dynamic, dynamic> values = snapshot.data?.value;
                            values.forEach((key, values) async {
                              // Initialize web3utility
                              await web3util.initState();
                              lists.add(values);
                              print(lists.length);
                              // print(lists.toString());
                              print(lists.first['accountAddress']);
                              print(await web3util.getAccountEthBalance(lists.first['accountAddress'])+' (ETH)');
                            });
                            return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: lists.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Text("Date: " + lists[index]["date"] + " , Transaction Status: " + lists[index]["status"].toString()),
                                        Text("Address: " + lists[index]["accountAddress"]),
                                        // Text("Ethereum: " + await web3util.getAccountEthBalance(lists[index]["accountAddress"])),
                                        Text("USD: " + lists[index]["accountAddress"]),
                                        // Text("SlotData: " + lists[index]["slotData"]),
                                        // RichText(
                                        //     text: TextSpan(
                                        //         children: [
                                        //           const TextSpan(
                                        //             style: TextStyle(
                                        //                 color: Colors.black,
                                        //                 fontSize: 14),
                                        //             text: "Transaction Hash: ",
                                        //           ),
                                        //           TextSpan(
                                        //               style: const TextStyle(
                                        //                   color: Colors.blueAccent,
                                        //                   fontSize: 14),
                                        //               text: '0x${lists[index]["transactionHash"]}',
                                        //               recognizer: TapGestureRecognizer()
                                        //                 ..onTap = () async {
                                        //                   var url = "https://ropsten.etherscan.io/tx/0x${lists[index]["transactionHash"]}";
                                        //                   if (await canLaunch(url)) {
                                        //                     await launch(url);
                                        //                   } else {
                                        //                     throw 'Could not launch $url';
                                        //                   }
                                        //                 }
                                        //           ),
                                        //         ]
                                        //     )),
                                      ],
                                    ),
                                  );
                                });
                          }
                        }
                        return const CircularProgressIndicator();
                      }),
                ]
            ),



          ],
        ),
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
        ]),
    );
  }
}

// https://api.flutter.dev/flutter/material/RadioListTile-class.html
