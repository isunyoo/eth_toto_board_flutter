import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utilities/web3dartutil.dart';
// import 'package:http/http.dart';
// import 'package:web3dart/web3dart.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eth_toto_board_flutter/output.dart';

Future<void> main() async {
  runApp(
    MaterialApp(
      // Start the app with the "/" named route. In this case, the app starts on the MyApp widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the MyApp widget.
        '/': (context) => const MyApp(),
        // When navigating to the "/output" route, build the Output widget.
        // '/output': (context) => const Output(),
      },
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
  late Client httpClient;
  late Web3Client ethClient;
  int myAmount=0, blkNum=0;
  var arrayLength, myAddress, balanceEther, allArrayData, arrayData;

  @override
  void initState() {
    // TODO: implement initState
    Web3DartHelper web3util = Web3DartHelper();
    web3util.initialSetup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              // "BlockNum: $blkNum \nAddress: $myAddress \nBalance: $balanceEther(ETH) \nArray_Length: $arrayLength \nAll_ArrayData: $allArrayData \nArray_Data: $arrayData",
              "BlockNum: $blkNum \nAddress: $myAddress \nBalance: $balanceEther(ETH) \nArray_Length: $arrayLength",
              textScaleFactor: 2,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
      floatingActionButton: ElevatedButton(
        child: const Text("Submit"),
        onPressed: () async {
          await _getAllArray();
          await _getArray(1);
          // await _addData(3);
          await _pushArrayData([[1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12]]);
          // setState(() {
          //   allArrayData;
          //   arrayData;
          // });
          // Navigate to the output screen using a named route.
          Navigator.push(context, MaterialPageRoute(builder: (_) => Output(passedValue1: allArrayData, passedValue2: arrayData),),);
        },
      ),
    );
  }
}
