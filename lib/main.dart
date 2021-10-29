import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/output.dart';
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
  var blkNum=0, requestedRows = 1, allArrayData=[], arrayData=[], arrayLength, myAddress, balanceEther;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
    myAddress = await web3util.getAddress();
    balanceEther = await web3util.getBalance();
    blkNum = await web3util.getBlkNum();
    arrayLength = await web3util.getArrayLength();
    setState(() {
      blkNum;
      myAddress;
      balanceEther;
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
                  "BlockNum: $blkNum \nAddress: $myAddress \nBalance: $balanceEther(ETH) \nArray_Length: $arrayLength \n",
                  textScaleFactor: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: const <Widget>[ Expanded(
              child: Text(
                "How Many Slots to generate:",
                textScaleFactor: 1.5,
              ),
            ),
            ],
          ),
          Row(
            children: <Widget>[ Expanded(
              child: Center(
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
              )
            ),],
          ),
        ],),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async {
                  allArrayData = await web3util.getAllArray();
                  arrayData = await web3util.getArray(1);
                  // await web3util.addData(3);
                  var slotData = [[1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12]];
                  await web3util.pushArrayData(slotData);
                  // Navigate to the output screen using a named route.
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Output(passedValue1: allArrayData, passedValue2: arrayData),),);
                },
              ),
              ElevatedButton(
                  child: const Text("Generate"),
                  onPressed: (){
                    var randomSlots = web3util.generateSlots(requestedRows);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => GeneratedOutput(passedValue1: randomSlots),),);
                  }
              )
            ]
        )
    );
  }
}
