import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/profile.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/remote_config.dart';

class ImportKey extends StatefulWidget {
  const ImportKey({Key? key}) : super(key: key);

  @override
  State<ImportKey> createState() => _ImportKeyState();

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

}

class _ImportKeyState extends State<ImportKey> {
  // To create a new Firebase Remote Config instance
  late RemoteConfig _remoteConfig = RemoteConfig.instance;
  // Create a DatabaseReference which references a node called txreceipts
  late final DatabaseReference _txReceiptRef = FirebaseDatabase(databaseURL:_remoteConfig.getString('Firebase_Database')).reference();
  // The user's ID which is unique from the Firebase project
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<dynamic, dynamic>> lists = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    // Firebase Initialize App Function
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // To fetch remote config from Firebase Remote Config
    RemoteConfigService _remoteConfigService = RemoteConfigService();
    _remoteConfig = await _remoteConfigService.setupRemoteConfig();
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Private Key'),
        automaticallyImplyLeading: false,
      ),
      // body: SingleChildScrollView(
      //   child: Column(
      //       children: <Widget>[
      //         FutureBuilder(
      //             future: _txReceiptRef.child('vaults/$userId').orderByChild("timestamp").once(),
      //             // future: _txReceiptRef.child('txreceipts').orderByChild("timestamp").limitToLast(10).once(),
      //             builder: (BuildContext context, AsyncSnapshot snapshot) {
      //               if (snapshot.connectionState == ConnectionState.done) {
      //                 if(snapshot.data.value == null) {
      //                   return const Text('\n No History Transaction Data Existed.', textScaleFactor: 1.5, style: TextStyle(color: Colors.red));
      //                 } else {
      //                   // 'DataSnapshot' value != null
      //                   lists.clear();
      //                   Map<dynamic, dynamic> values = snapshot.data?.value;
      //                   values.forEach((key, values) {
      //                     lists.add(values);
      //                   });
      //                   return ListView.builder(
      //                       primary: false,
      //                       shrinkWrap: true,
      //                       itemCount: lists.length,
      //                       itemBuilder: (BuildContext context, int index) {
      //                         return Card(
      //                           child: Column(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: <Widget>[
      //                               Text("Date: " + lists[index]["date"] + " , Transaction Status: " + lists[index]["status"].toString()),
      //                               Text("SlotData: " + lists[index]["slotData"]),
      //                               RichText(
      //                                   text: TextSpan(
      //                                       children: [
      //                                         const TextSpan(
      //                                           style: TextStyle(
      //                                               color: Colors.black,
      //                                               fontSize: 14),
      //                                           text: "Transaction Hash: ",
      //                                         ),
      //                                         TextSpan(
      //                                             style: const TextStyle(
      //                                                 color: Colors.blueAccent,
      //                                                 fontSize: 14),
      //                                             text: '0x${lists[index]["transactionHash"]}',
      //                                             recognizer: TapGestureRecognizer()
      //                                               ..onTap = () async {
      //                                                 var url = "https://ropsten.etherscan.io/tx/0x${lists[index]["transactionHash"]}";
      //                                                 if (await canLaunch(url)) {
      //                                                   await launch(url);
      //                                                 } else {
      //                                                   throw 'Could not launch $url';
      //                                                 }
      //                                               }
      //                                         ),
      //                                       ]
      //                                   )),
      //                             ],
      //                           ),
      //                         );
      //                       });
      //                 }
      //               }
      //               return const CircularProgressIndicator();
      //             }),
      //       ]
      //   ),
      // ),
      floatingActionButton: SpeedDial(
          icon: Icons.menu,
          backgroundColor: Colors.blueAccent,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.account_circle_sharp),
              label: 'Profile',
              backgroundColor: Colors.blue,
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(passedValue1: myAddress)));
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


