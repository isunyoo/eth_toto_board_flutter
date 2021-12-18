import 'utilities/web3dartutil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/output.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
  late String myAddress='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    web3util.initState();
  }

  Future<void> initialSetup() async {
    await web3util.initState();
    myAddress = await web3util.getAddress();
  }

  // Display a snackbar widget
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  // An alert dialog informs the user about situations that require acknowledgement.
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
                Text('This will submit to the Ethereum BlockChain to store data.\n'),
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
                var newSlotData = widget.passedValue1;
                var newSlotDataLength = widget.passedValue1.length;
                var transactionHash = await web3util.pushArrayData(newSlotData);
                Navigator.push(context, MaterialPageRoute(builder: (_) => Output(passedValue1: newSlotData, passedValue2: newSlotDataLength, passedValue3: transactionHash),),);
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
        title: const Text('New Generated Slots'),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: <Widget>[
        Row(
          children: const <Widget>[ Expanded(
            child: Text(
              "\nNewly Generated Slots:",
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
                    return Text("${index+1}: " + widget.passedValue1[index].toString(), textScaleFactor: 2.0,);
                  }
              )
          ),],
        ),
      ],),
      floatingActionButton: SpeedDial(
          icon: Icons.menu,
          backgroundColor: Colors.blueAccent,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.party_mode_sharp),
              label: 'Submit',
              backgroundColor: Colors.blue,
              onTap: () async {
                var newSlotData = widget.passedValue1;
                String _address = await web3util.getAddress();
                String? _uid = FirebaseAuth.instance.currentUser?.uid;
                String? _email = FirebaseAuth.instance.currentUser?.email;
                String? _displayName = FirebaseAuth.instance.currentUser?.displayName;
                // var transactionHash = await web3util.pushArrayData(newSlotData);
                var transactionHash = await web3util.saveArrayData(_address, _uid!, _email!, _displayName!, newSlotData);
                // Insufficient funds for ethereum account for transaction
                if(transactionHash == ''){
                  ScaffoldMessenger.of(context).showSnackBar(
                    customSnackBar(content: 'Insufficient funds for gas * price + value.\nPlease deposit ethereum funds in account.'),
                  );
                } else {
                  // Sufficient funds for ethereum account for transaction
                  _showApproveDialog();
                }
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.menu_rounded),
              label: 'Main',
              backgroundColor: Colors.blue,
              onTap: () {
                // Navigate to the main screen using a named route.
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardMain(),),);
              },
            ),
          ]
      ),
    );
  }
}