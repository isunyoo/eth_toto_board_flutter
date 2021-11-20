import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eth_toto_board_flutter/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HistoryOutput extends StatefulWidget {

  const HistoryOutput({Key? key}) : super(key: key);
  @override
  State<HistoryOutput> createState() => _HistoryOutputState();
}

class _HistoryOutputState extends State<HistoryOutput> {
  // Create a DatabaseReference which references a node called txreceipts
  final DatabaseReference _txReceiptRef = FirebaseDatabase(databaseURL:dotenv.get('Firebase_Database')).reference();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Slot Data History'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                  future: _txReceiptRef.child('txreceipts').orderByChild("timestamp").once(),
                  // future: _txReceiptRef.child('txreceipts').orderByChild("timestamp").limitToLast(10).once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      lists.clear();
                      Map<dynamic, dynamic> values = snapshot.data?.value;
                      values.forEach((key, values) {
                        lists.add(values);
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
                                  Text("Date: " + lists[index]["date"]),
                                  Text("SlotData: "+ lists[index]["slotData"]),
                                  RichText(
                                      text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              style: TextStyle(color: Colors.black, fontSize: 14),
                                              text: "TransactionHash: ",
                                            ),
                                            TextSpan(
                                                style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
                                                text: lists[index]["transactionHash"],
                                                recognizer: TapGestureRecognizer()..onTap =  () async{
                                                  var url = "https://ropsten.etherscan.io/tx/0x${lists[index]["transactionHash"]}";
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                }
                                            ),
                                          ]
                                      )),
                                  Text("Status: " +lists[index]["status"].toString()),
                                ],
                              ),
                            );
                          });
                    }
                    return const CircularProgressIndicator();
                  }),
            ]
          ),
        ),
        floatingActionButton: SpeedDial(
            icon: Icons.menu,
            backgroundColor: Colors.blueAccent,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.menu_rounded),
                label: 'Main',
                backgroundColor: Colors.blue,
                onTap: () {
                  // Navigate to the main screen using a named route.
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp(),),);
                },
              ),
            ]
        ),

    );
  }

}


