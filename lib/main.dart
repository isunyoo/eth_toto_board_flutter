import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ether Toto',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Ether Toto'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  int myAmount = 0;
  int blkNum = 0;
  late List<dynamic> arrayLength = [];
  var myAddress;
  var balanceEther;
  List<dynamic> lst = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(dotenv.get('Ganache_API'), httpClient);
    // getBalance(dotenv.get('My_Address'));
    _getBlkNum();
  }

  void _getBlkNum() async {
    blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
  }

  void _getBalance() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    myAddress = await _credentials.extractAddress();
    // print('address: $_address');
    // get native balance
    var balanceObj = await ethClient.getBalance(myAddress);
    balanceEther = balanceObj.getValueInUnit(EtherUnit.ether);
    // print('balance before transaction: ${balanceObj.getInWei} wei (${balanceObj
    //     .getValueInUnit(EtherUnit.ether)} ether)');
  }

  // void _getBalance() async {
  //   var credentials = EthPrivateKey.fromHex(
  //       "d183f4ad08c7937fb769947be3bc85037c48e521b196e6e20b4c2b0c079a7f09");
  //   // var address = await credentials.extractAddress();
  //   lst.add(await credentials.extractAddress());
  //   print('address: $lst[0]');
  //   // get native balance
  //   // var balance = await ethClient.getBalance(address);
  //   lst.add(await ethClient.getBalance(lst[0]));
  //   print('balance before transaction: ${lst[1].getInWei} wei (${lst[1]
  //       .getValueInUnit(EtherUnit.ether)} ether)');
  // }

  // Future<List> _getBalance() async {
  //   var credentials = EthPrivateKey.fromHex(
  //       "d183f4ad08c7937fb769947be3bc85037c48e521b196e6e20b4c2b0c079a7f09");
  //   var address = await credentials.extractAddress();
  //   print('address: $address');
  //   // get native balance
  //   var balance = await ethClient.getBalance(address);
  //   print('balance before transaction: ${balance.getInWei} wei (${balance
  //       .getValueInUnit(EtherUnit.ether)} ether)');
  //
  //   return [address, balance];
  // }

  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x2208f78D1CF9DA01D4B0cFa7505eF4890Df380b0";
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "TotoSlots"), EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    var result = await ethClient.sendTransaction(credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
    );
    return result;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(contract: contract, function: ethFunction, params: args);

    return data;
  }

  Future<List<dynamic>> _getArrayLength() async {
    // array_getLength transaction
    List<dynamic> result = await query("array_getLength", []);
    // returns list of results, in this case a list with only the array length
    arrayLength = result;
    return result;
  }

  Future<List<dynamic>> _getArray(int index) async {
    var bigAmount = BigInt.from(index);
    // array_getArray transaction
    List<dynamic> result = await query("array_getArray", [bigAmount]);
    // returns list of results, in this case a list with only the array[index]
    print(result);
    return result;
  }

  Future<List<dynamic>> _getAllArray() async {
    // array_popAllData transaction
    List<dynamic> result = await query("array_popAllData", []);
    // returns list of results, in this case a list with all the arrays
    print(result);
    return result;
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
              "BlockNum: $blkNum \nAddress: $myAddress \nBalance: $balanceEther(ETH) \nArray_Length: $arrayLength",
              // "$lst[0]",
              textScaleFactor: 2,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            child: const Text("Connect Wallet"),
            onPressed: () {
              _getBalance();
              _getBlkNum();
              _getArrayLength();
              _getArray(1);
              _getAllArray();
              setState(() {
                // lst[0];
                blkNum;
                myAddress;
                balanceEther;
                arrayLength;
              });
            },
          ),
        ],
      ),
    );
  }
}
