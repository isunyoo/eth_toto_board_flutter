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

  Future<void> _showApproveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('BlockChain Transaction'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This will submit to the Ethereum BlockChain Data.'),
                Text('Would you like to approve of this transaction?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // await web3util.addData(3);
                var newSlotData = widget.passedValue1;
                var newSlotDataLength = widget.passedValue1.length;
                await web3util.pushArrayData(newSlotData);
                Navigator.push(context, MaterialPageRoute(builder: (_) => Output(passedValue1: newSlotData, passedValue2: newSlotDataLength),),);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                onPressed: () {
                  _showApproveDialog();
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