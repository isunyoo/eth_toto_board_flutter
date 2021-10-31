import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/generate.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';

void main() {
  runApp(
    const MaterialApp(
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
      title: 'Flutter Ether Toto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Ether Toto'),
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
  var requestedRows=1, myAddress;
  late num blkNum=0, balanceEther=0;
  late String balanceUsd='', arrayLength='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
    blkNum = await web3util.getBlkNum();
    myAddress = await web3util.getAddress();
    balanceEther = await web3util.getEthBalance();
    balanceUsd = await web3util.getConvUSD();
    arrayLength = await web3util.getArrayLength();
    setState(() {
      blkNum;
      myAddress;
      balanceEther;
      balanceUsd;
      arrayLength;
    });
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
                  "BlockNum: $blkNum \nAddress: $myAddress \nETH Balance: $balanceEther(ETH) \nUSD Balance: $balanceUsd(USD) \nArray_Length: $arrayLength \n",
                  textScaleFactor: 1.8,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                       child: Text("How Many Slots:", textScaleFactor: 2),
                  ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50.0),
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
