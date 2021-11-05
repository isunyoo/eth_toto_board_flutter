import 'dart:io';
import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eth_toto_board_flutter/main.dart';
// import 'package:eth_toto_board_flutter/receipt.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    web3util.initState();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
  }

  // PDF Creation
  // https://pub.dev/packages/printing
  // https://github.com/DavBfr/dart_pdf/blob/master/printing/example/lib/main.dart
  Future<void> receiptPDF() async {
    final pdf = pw.Document();
    // final ttf = await fontFromAssetBundle('assets/fonts/open-sans.ttf');
    var txReceipt = await web3util.getTransactionDetails(widget.passedValue3);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(
              // child: pw.Text(txReceipt, style: pw.TextStyle(font: ttf, fontSize: 40)),
              child: pw.Text(txReceipt, style: const pw.TextStyle(fontSize: 30)),
            ),
      ),
    );
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    print(tempPath);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);
    // To save the pdf file using the path_provider library
    // final tempDir = await getTemporaryDirectory();
    // final file = File("${tempDir.path}/${widget.passedValue3}.pdf");
    // await file.writeAsBytes(await pdf.save());
    // PdfPreview widget to display a pdf document
    // PdfPreview(
    //   build: (format) => pdf.save(),
    // );
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
              // child: Text("\nTransacted Hash: ${widget.passedValue3}", textScaleFactor: 1.8),
                child: RichText(
                    text: TextSpan(
                        children: [
                          const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 25),
                            text: "\nTransacted Hash: ",
                          ),
                          TextSpan(
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 20),
                              text: "Click here details",
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
                  // var txReceipt = await web3util.getTransactionDetails(widget.passedValue3);
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => Receipt(passedValue1: txReceipt)));
                  await receiptPDF();
                },
              ),
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