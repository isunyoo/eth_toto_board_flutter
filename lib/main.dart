import 'dart:io';
import 'dart:convert';
import 'utilities/web3dartutil.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eth_toto_board_flutter/generate.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Ether Toto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Blockchain Ethereum Lotto(6/45)\n[성재의 인생역전 대박꿈]'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize the Web3DartHelper class from utility packages
  Web3DartHelper web3util = Web3DartHelper();
  var allArrayData=[], requestedRows=1;
  late String currentBlkNum='', storedBlkNum='', storedTxHash='', myAddress='', balanceEther='', balanceUsd='', arrayLength='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
    await readTransactionInfoJson();
    currentBlkNum = await web3util.getBlkNum();
    myAddress = await web3util.getAddress();
    balanceEther = await web3util.getEthBalance();
    balanceUsd = await web3util.getConvUSD();
    arrayLength = await web3util.getArrayLength();
    allArrayData = await web3util.getAllArray();
    // arrayData = await web3util.getArray(1);
    setState(() {
      currentBlkNum;
      storedBlkNum;
      storedTxHash;
      myAddress;
      balanceEther;
      balanceUsd;
      arrayLength;
      allArrayData;
    });
  }

  // Read transaction info to json file
  Future<void> readTransactionInfoJson() async {
    // Retrieve "AppData Directory" for Android and "NSApplicationSupportDirectory" for iOS
    final directory = await getApplicationDocumentsDirectory();
    // Check if a file exists synchronously
    var fileExist = File("${directory.path}/transactionInfoVault.json").existsSync();
    // Fetch a json file
    File file = await File("${directory.path}/transactionInfoVault.json").create();
    if(!fileExist) {
      String fileContent=json.encode({
        "blockNumber": "0",
        "transactionHash": "0x"
      });
      // Write to file using dummy contents
      await file.writeAsString(fileContent);
    }
    // Read the file from the json file
    final contents = await file.readAsString();
    final jsonContents = await json.decode(contents);
    // Fetch content from the json file
    storedBlkNum = jsonContents['blockNumber'];
    storedTxHash = jsonContents['transactionHash'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: <Widget>[
        Row(
          children: <Widget>[ Expanded(
            child: Text(
              "Wallet Address: $myAddress \nETH Balance: $balanceEther(ETH) \nUSD Balance: $balanceUsd(USD) \nCurrent BlockNum: $currentBlkNum \n",
              textScaleFactor: 1.6,
            ),
          ),
          ],
        ),
        Row(
          children: <Widget>[ Expanded(
              child: RichText(
                  text: TextSpan(
                      children: [
                        const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 23),
                          text: "Current Stored Slot Data \nat BlockChain ",
                        ),
                        TextSpan(
                            style: const TextStyle(color: Colors.blueAccent, fontSize: 20),
                            text: storedBlkNum,
                            recognizer: TapGestureRecognizer()..onTap =  () async{
                              var url = "https://ropsten.etherscan.io/tx/$storedTxHash";
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
        Row(
          children: <Widget>[ Expanded(
              child: ListView.builder (
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: allArrayData.length,
                // A Separate Function called from itemBuilder
                itemBuilder: (BuildContext ctxt, int index) {
                  return Text("${index+1}: " + allArrayData[index].toString(), textScaleFactor: 2.0);
                }
              )
          ),],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                     child: Text("\nHow Many New Games to play :", textScaleFactor: 1.8),
                ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 120.0),
                   child: CustomNumberPicker(
                     initialValue: 1,
                     maxValue: 10,
                     minValue: 1,
                     step: 1,
                     enable: true,
                     onValue: (value) {
                       // print(value.toString());
                       requestedRows = int.parse(value.toString());
                     },
                   ),
              ),
            ),
          ],
        ),
      ],),
      floatingActionButton: ElevatedButton(
          child: const Text("Generate"),
          onPressed: (){
            var randomSlots = web3util.generateSlots(requestedRows);
            Navigator.push(context, MaterialPageRoute(builder: (_) => GeneratedOutput(passedValue1: randomSlots),),);
          }
      ),
    );
  }
}
