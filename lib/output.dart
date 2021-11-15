import 'dart:io';
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eth_toto_board_flutter/main.dart';
import 'dart:typed_data' show Uint8List;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:eth_toto_board_flutter/txreceipt.dart';

class Output extends StatefulWidget {
  final List passedValue1;
  final int passedValue2;
  final String passedValue3;
  const Output({Key? key, required this.passedValue1, required this.passedValue2, required this.passedValue3}) : super(key: key);

  @override
  State<Output> createState() => _OutputState();
}

class _OutputState extends State<Output> {
  // Initialize the Web3DartHelper class from utility packages
  Web3DartHelper web3util = Web3DartHelper();
  late AnimationController controller;
  // Create a DatabaseReference which references a node called txreceipts
  final DatabaseReference _txReceiptRef = FirebaseDatabase.instance.reference().child('txreceipts');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
    // Firebase Initialize App Function
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  // AlertDialog Wiget
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction in Progress Alert!"),
          content: const Text("Transaction is still processing, Try again later."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function takes a txReceipt as a parameter and uses a DatabaseReference to save the JSON message to Realtime Database.
  void saveTxReceipt(TransactionReceipt txReceipt) {
    _txReceiptRef.push().set(txReceipt.toJson());
  }

  // The data access object helps to access which have stored at the given Realtime Database reference
  Query getTxReceiptQuery() {
    return _txReceiptRef;
  }

  // https://medium.com/enappd/connecting-cloud-firestore-database-to-flutter-voting-app-2da5d8631662
  // https://stackoverflow.com/questions/62261619/how-to-upload-json-file-in-firebase-storage-flutter
  // https://firebase.flutter.dev/docs/storage/usage/
  // Uploading raw data
  Future<void> uploadData() async {
    String myAddress = await web3util.getAddress();
    String txReceipt = (await web3util.getTransactionDetails(widget.passedValue3)).toString();
    List<int> encoded = utf8.encode(txReceipt);
    Uint8List data = Uint8List.fromList(encoded);

    // To create a reference
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('txReceipts/$myAddress/${widget.passedValue3}.json');

    // Upload raw data
    await ref.putData(data);
    // Get raw data
    // Uint8List? downloadedData = await ref.getData();
    // Print downloadedData
    // print(utf8.decode(downloadedData!));
  }

  // PDF Creation
  Future<void> receiptPDF() async {
    // Get transaction details
    String txReceiptStr = (await web3util.getTransactionDetails(widget.passedValue3)).toString();
    var txReceipt = await web3util.getTransactionDetails(widget.passedValue3);
    Uint8List? transactionHashBytes = txReceipt?.transactionHash;
    print(hex.encode(transactionHashBytes!));
    print(txReceipt?.transactionIndex);
    Uint8List? blockHashBytes = txReceipt?.blockHash;
    print(hex.encode(blockHashBytes!));
    print(txReceipt?.blockNumber);
    print(txReceipt?.from);
    print(txReceipt?.to);
    print(txReceipt?.cumulativeGasUsed);
    print(txReceipt?.gasUsed);
    print(txReceipt?.status);
    print(DateTime.now());

    if(txReceiptStr.length<10) {
      _showDialog(context);
    } else if(txReceiptStr.length>200) {
      // Print an HTML document:
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async =>
          await Printing.convertHtml(
            format: format,
            html: '<html><body><p><h1>$txReceiptStr</h1></p></body></html>',
          ));
    }
    // To save a txReceipt to Realtime Database.
    // final _txReceipt = TransactionReceipt(jsonString["transactionHash"], jsonString["transactionIndex"], jsonString["blockHash"], jsonString["blockNumber"], jsonString["from"], jsonString["to"], jsonString["cumulativeGasUsed"], jsonString["gasUsed"], jsonString["status"], DateTime.now());
    // saveTxReceipt(_txReceipt);
    // https://www.raywenderlich.com/24346128-firebase-realtime-database-tutorial-for-flutter
    // https://medium.flutterdevs.com/explore-realtime-database-in-flutter-c5870c2b231f
    // https://stackoverflow.com/questions/55292633/how-to-convert-json-string-to-json-object-in-dart-flutter
  }

  // Write transaction info to json file
  Future<void> writeTransactionInfoJson() async {
    // Retrieve "AppData Directory" for Android and "NSApplicationSupportDirectory" for iOS
    final directory = await getApplicationDocumentsDirectory();
    // Fetch a json file
    File file = await File("${directory.path}/transactionInfoVault.json").create();
    // Get transaction block
    var transactionBlock = await web3util.getTransactionBlock(widget.passedValue3);
    // Convert json object to String data using json.encode() method
    String fileContent=json.encode({
      "blockNumber": transactionBlock,
      "transactionHash": widget.passedValue3
    });
    // Write to file using writeAsString which takes string argument
    await file.writeAsString(fileContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blockchain Transacted Data'),
          automaticallyImplyLeading: false,
        ),
        body: Column(children: <Widget>[
          Row(
            children: <Widget>[ Expanded(
              child: Text("\nNewly Stored Slot Numbers: ${widget.passedValue2}", textScaleFactor: 1.8),
            ),],
          ),
          Row(
            children: const <Widget>[ Expanded(
              child: Text(
                "Newly Stored Slot Data: ",
                textScaleFactor: 1.8,
              ),
            ),],
          ),
          Row(
            children: <Widget>[ Expanded(
                child: ListView.builder (
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: widget.passedValue1.length,
                    // A Separate Function called from itemBuilder
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Text("${index+1}: " + widget.passedValue1[index].toString(), textScaleFactor: 2.0);
                    }
                )
            ),],
          ),
          Row(
            children: <Widget>[ Expanded(
                child: RichText(
                    text: TextSpan(
                        children: [
                          const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            text: "\nTransaction Hash: ",
                          ),
                          TextSpan(
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 15),
                              text: "Click here details in Etherscan",
                              recognizer: TapGestureRecognizer()..onTap =  () async{
                                var url = "https://ropsten.etherscan.io/tx/${widget.passedValue3}";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              }
                          ),
                        ]
                    ))
            ),],
          ),
        ],),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: const Text("Receipt"),
                onPressed: () async {
                  await receiptPDF();
                  await uploadData();
                },
              ),
              ElevatedButton(
                child: const Text('Main'),
                // Within the OutputDataScreen widget
                onPressed: () async {
                  // Get transaction details
                  String txReceipt = (await web3util.getTransactionDetails(widget.passedValue3)).toString();
                  if(txReceipt.length<10) {
                    _showDialog(context);
                  } else if(txReceipt.length>200) {
                    await writeTransactionInfoJson();
                    // Navigate to the main screen using a named route.
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp(),),);
                  }
                },
              )
            ]
        )
    );
  }
}