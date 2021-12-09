import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:eth_toto_board_flutter/import.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:eth_toto_board_flutter/screens/login.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_toto_board_flutter/utilities/web3dartutil.dart';
import 'package:eth_toto_board_flutter/utilities/authenticator.dart';

class ProfilePage extends StatefulWidget {
  final String passAddressValue;
  const ProfilePage({Key? key, required this.passAddressValue}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String currentAddress = widget.passAddressValue;
  // Initialize the Web3DartHelper class from utility packages
  Web3DartHelper web3util = Web3DartHelper();
  // The user's ID which is unique from the Firebase project
  User? user = FirebaseAuth.instance.currentUser;
  bool _isSigningOut = false;
  List<Map<dynamic, dynamic>> accountList = [];
  List<String> addressList = [];
  List<String> ethList = [];
  List<String> usdList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    // Initialize web3utility
    await web3util.initState();
    // Firebase Initialize App Function
    await Firebase.initializeApp();
    WidgetsFlutterBinding.ensureInitialized();
    await updatePriceValues();
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

  Future<void> getPriceValues(String address) async {
    // addressList.add(address);
    // print(addressList);
    // print(addressList.length);
    String ethPrice = await web3util.getAccountEthBalance(address);
    ethList.add(ethPrice);
    print(ethList);
    print(ethList.length);
    String usdPrice = await web3util.getConvEthUSD(ethPrice);
    usdList.add(usdPrice);
    print(usdList);
    print(usdList.length);
  }

  Future<void> updatePriceValues() async {
    addressList.clear();
    ethList.clear();
    usdList.clear();
    List<Map<dynamic, dynamic>> accountList = [];
    accountList = await web3util.getVaultData();
    for(int i=0; i<accountList.length; i++){
      getPriceValues(accountList[i]['accountAddress']);
    }

    // String ethPrice = await web3util.getAccountEthBalance(address);
    // ethList.add(ethPrice);
    // print(ethList);
    // print(ethList.length);
    // String usdPrice = await web3util.getConvEthUSD(ethPrice);
    // usdList.add(usdPrice);
    // print(usdList);
    // print(usdList.length);
  }

  Widget _getAccountVaults(){
    return
      Column(
          children: <Widget>[
            FutureBuilder(
                future: web3util.dbRef.child('vaults/${user?.uid}').once(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.connectionState == ConnectionState.done) {
                    if(snapshot.data.value == null) {
                      return const Text('\n No Account Data has existed.', textScaleFactor: 1.5, style: TextStyle(color: Colors.red));
                    } else {
                      // 'DataSnapshot' value != null
                      accountList.clear();
                      // ethList.clear();
                      // usdList.clear();
                      Map<dynamic, dynamic> values = snapshot.data?.value;
                      values.forEach((key, values) async {
                        accountList.add(values);
                        await getPriceValues(accountList[accountList.length-1]['accountAddress']);
                        // String ethPrice = await web3util.getAccountEthBalance(accountList[accountList.length-1]['accountAddress']);
                        // ethList.add(ethPrice);
                        // String usdPrice = await web3util.getConvEthUSD(ethPrice);
                        // usdList.add(usdPrice);
                        // print(accountList[accountList.length-1]['accountAddress']);
                        // print(ethList);
                        // print(usdList);
                        // print(ethList.length);
                        // print(usdList.length);
                      });
                      if(usdList.length == accountList.length){
                        return ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: accountList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    RichText(
                                        text: TextSpan(
                                            children: [
                                              const TextSpan(style: TextStyle(color: Colors.black, fontSize: 14), text: "Address: "),
                                              TextSpan(
                                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
                                                  text: '${accountList[index]["accountAddress"]}',
                                                  recognizer: TapGestureRecognizer()..onTap = () {
                                                    setState(() async {
                                                      currentAddress = accountList[index]["accountAddress"];
                                                    });
                                                  }
                                              ),
                                            ]
                                        )),
                                    // Text("Ethereum: " +ethList[index]+" ETH"+"      USD: " +usdList[index]+" \$"),
                                  ],
                                ),
                              );
                            });
                      }
                    }
                  }
                  return const CircularProgressIndicator();
                }),
          ]
      );

      // Row(
      //   children: <Widget>[ Expanded(
      //       child: ListView.builder(
      //           primary: false,
      //           shrinkWrap: true,
      //           scrollDirection: Axis.vertical,
      //           itemCount: addressList.length,
      //           // A Separate Function called from itemBuilder
      //           itemBuilder: (BuildContext ctxt, int index) {
      //             return Text("${index + 1}: " + addressList[index] + "\n" +
      //                 "Ethereum: " + ethList[index] + " ETH" + "      USD: " +
      //                 usdList[index] + " \$\n", textScaleFactor: 1.2);
      //           }
      //       )
      //   ),
      //   ],
      // );


  }

  // QRCode Display Widget
  Widget _qrContentWidget() {
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
                  child: _getCardWithIcon(currentAddress),
                ),
                const Padding(padding: EdgeInsets.all(5.0),
                  child: Text("\nCurrent Account Address: ", textScaleFactor: 1.5),
                ),
              ],
            ),
            Row(
              children: <Widget>[ Expanded(
                child: Text(" $currentAddress\n", textScaleFactor: 1.2),
              ),],
            ),
            Center(
                child: QrImage(
                          data: currentAddress,
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
                    Clipboard.setData(ClipboardData(text: currentAddress)).then((value) {
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
                  "\n My Accounts: \n",
                  textScaleFactor: 1.2,
                ),
              ),],
            ),
            // Account Inventory in firebase vaults
            _getAccountVaults(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No account has imported yet in vault database
    if(currentAddress == '') {
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

// https://flutter-examples.com/get-selected-radio-button-group-value-in-flutter/
