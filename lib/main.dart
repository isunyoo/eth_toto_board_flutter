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
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  int myAmount = 0;
  int blkNum = 0;
  // late List<dynamic> arrayLength = [];
  var arrayLength;
  var myAddress;
  var balanceEther;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Client class is the interface for HTTP clients that take care of maintaining persistent connections
    httpClient = Client();
    // Web3Client class used for for sending requests over an HTTP JSON-RPC API endpoint to Ethereum clients
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

  // Functions for reading the smart contract and submitting a transaction.
  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String contractAddress = dotenv.get('Contract_Address');
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "TotoSlots"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  // The submit() function essentially signs and sends a transaction to the blockchain network from web3dart library.
  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    var result = await ethClient.sendTransaction(credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000
      ), chainId: 1337
    );
    return result;
  }

  Future<String> _pushArrayData(List<dynamic> args) async {
    var response = 'test';
    print(args);
    print(args.runtimeType);
    // array_pushData transaction
    // var response = await submit("array_pushData", [args]);
    // hash of the transaction
    print(response);
    return response;
  }

  Future<String> _addData(int num) async {
    var bigNum = BigInt.from(num);
    // array_pushData transaction
    var response = await submit("addData", [bigNum]);
    // hash of the transaction
    print(response);
    return response;
  }

  // the query() function stores the result using the Web3Client call method, which Calls a function defined in the smart contract and returns it's result.
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
    arrayLength = result[0].toString();
    return result;
  }

  Future<List<dynamic>> _getArray(int index) async {
    var bigIndex = BigInt.from(index);
    // array_getArray transaction
    List<dynamic> result = await query("array_getArray", [bigIndex]);
    // returns list of results, in this case a list with only the array[index]
    print(result[0]);
    return result;
  }

  Future<List<dynamic>> _getAllArray() async {
    // array_popAllData transaction
    List<dynamic> result = await query("array_popAllData", []);
    // returns list of results, in this case a list with all the arrays
    print(result[0]);
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
              textScaleFactor: 2,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
      floatingActionButton: ElevatedButton(
        child: const Text("Connect Wallet"),
        onPressed: () {
          _getBalance();
          _getBlkNum();
          _getArrayLength();
          _getArray(1);
          _getAllArray();
          // _pushArrayData([[1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12]]);
          _addData(1);
          setState(() {
            blkNum;
            myAddress;
            balanceEther;
            arrayLength;
          });
        },
      ),
    );
  }
}
