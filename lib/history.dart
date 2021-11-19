import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryOutput extends StatefulWidget {

  const HistoryOutput({Key? key}) : super(key: key);
  @override
  State<HistoryOutput> createState() => _HistoryOutputState();
}

class _HistoryOutputState extends State<HistoryOutput> {
  // Create a DatabaseReference which references a node called txreceipts
  final DatabaseReference _txReceiptRef = FirebaseDatabase(databaseURL:dotenv.get('Firebase_Database')).reference().child('txreceipts');
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
        body: Column(children: <Widget>[
          Row(
            children: <Widget>[ Expanded(
              child: FutureBuilder(
                  future: _txReceiptRef.once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      lists.clear();
                      Map<dynamic, dynamic> values = snapshot.data?.value;
                      values.forEach((key, values) {
                        lists.add(values);
                      });
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: lists.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Date: " + lists[index]["date"]),
                                  Text("SlotData: "+ lists[index]["slotData"]),
                                  Text("TransactionHash: " +lists[index]["transactionHash"]),
                                  Text("Status: " +lists[index]["status"].toString()),
                                ],
                              ),
                            );
                          });
                    }
                    return const CircularProgressIndicator();
                  })
            ),],
          ),
          // Row(
          //   children: <Widget>[ Expanded(
          //       child: ListView.builder (
          //           shrinkWrap: true,
          //           scrollDirection: Axis.vertical,
          //           itemCount: widget.passedValue1.length,
          //           // A Separate Function called from itemBuilder
          //           itemBuilder: (BuildContext ctxt, int index) {
          //             return Text("${index+1}: " + widget.passedValue1[index].toString(), textScaleFactor: 2.0,);
          //           }
          //       )
          //   ),],
          // ),
        ],),
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


