import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:eth_toto_board_flutter/main.dart';
import 'package:eth_toto_board_flutter/output.dart';

class GeneratedOutput extends StatefulWidget {
  final List passedValue1;
  const GeneratedOutput({Key? key, required this.passedValue1}) : super(key: key);

  @override
  State<GeneratedOutput> createState() => _GeneratedOutputState();
}

class _GeneratedOutputState extends State<GeneratedOutput> {
  var allArrayData=[], arrayData=[];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Slots'),
        automaticallyImplyLeading: false,
      ),
      body: Text(
        '\nGenerated Slots: ${widget.passedValue1}',
        textAlign: TextAlign.left,
        // overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 30),
      ),
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