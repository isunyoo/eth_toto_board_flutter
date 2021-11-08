import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'utilities/web3dartutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eth_toto_board_flutter/main.dart';
import 'package:eth_toto_board_flutter/transactioninfovault.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    web3util.initState();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
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

  // PDF Creation
  Future<void> receiptPDF() async {
    // Get transaction details
    String txReceipt = await web3util.getTransactionDetails(widget.passedValue3);
    if(txReceipt.length<10) {
      _showDialog(context);
    } else if(txReceipt.length>200){
      // Print an HTML document:
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async =>
          await Printing.convertHtml(
            format: format,
            html: '<html><body><p><h1>$txReceipt</h1></p></body></html>',
          ));
    }
  }

  // https://stackoverflow.com/questions/51807228/writing-to-a-local-json-file-dart-flutter
  // https://gist.github.com/tomasbaran/f6726922bfa59ffcf07fa8c1663f2efc
  // Write transaction info to json file
  Future<void> writeTransactionBlockJson() async {
    // Fetch content from the json file
    String jsonString = await rootBundle.loadString('assets/transactionInfoVault.json');
    final jsonResponse = json.decode(jsonString);

    // jsonResponse['blockNumber']; // dynamic
    // jsonResponse['transactionHash']; // dynamic

    // Get transaction block
    var transactionBlock = await web3util.getTransactionBlock(widget.passedValue3);
    final jsonData = '{ "blockNumber": $transactionBlock, "transactionHash": ${widget.passedValue3} }';
    final parsedJson = jsonDecode(jsonData);
    final restaurant = TransactionInfo.fromJson(parsedJson);

    // Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
    // jsonFileContent.addAll(content);
    // jsonFile.writeAsStringSync(JSON.encode(jsonFileContent));


    // // update the list
    // _listQuestions.firstWhere((question) => question.id == questionId).bookmark = isBookmark;
    // // and write it
    // jsonFile.writeAsStringSync(json.encode(_listQuestions));
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
                },
              ),
              ElevatedButton(
                child: const Text('Main'),
                // Within the OutputDataScreen widget
                onPressed: () async {
                  // await writeTransactionBlockJson();
                  // Navigate to the main screen using a named route.
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp(),),);
                },
              )
            ]
        )
    );
  }
}