import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eth_toto_board_flutter/output.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
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
    initialSetup();
    super.initState();
  }

  Future<void> initialSetup() async {
    // Initialize the httpClient and ethCLient in the initState() method.
    // Client class is the interface for HTTP clients that take care of maintaining persistent connections
    httpClient = Client();
    // Web3Client class used for for sending requests over an HTTP JSON-RPC API endpoint to Ethereum clients
    ethClient = Web3Client(dotenv.get('Ganache_API'), httpClient);
    await _getBalance();
    await _getBlkNum();
    await _getArrayLength();
    setState(() {
      blkNum;
      myAddress;
      balanceEther;
      arrayLength;
    });
  }

  Future<void> _getBlkNum() async {
    blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
  }

  Future<void> _getBalance() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    myAddress = await _credentials.extractAddress();
    // print('address: $_address');
    // Get native balance
    var balanceObj = await ethClient.getBalance(myAddress);
    balanceEther = balanceObj.getValueInUnit(EtherUnit.ether);
    // print('balance before transaction: ${balanceObj.getInWei} wei (${balanceObj.getValueInUnit(EtherUnit.ether)} ether)');
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
    final result = await ethClient.sendTransaction(credentials,
        Transaction.callContract(
            contract: contract,
            function: ethFunction,
            parameters: args,
            maxGas: 100000
        ), chainId: 1337
    );
    return result;
  }

  Future<String> _pushArrayData(List args) async {
    // var response = 'test';
    // print(args);
    // print(args.runtimeType);
    final List bigArgs = List

    // Transaction of array_pushData
    var response = await submit("array_pushData", [bigArgs]);
    // Hash of the transaction record return(String)
    return response;
  }

  Future<String> _addData(int num) async {
    // uint in smart contract means BigInt
    var bigNum = BigInt.from(num);
    // Transaction of array_pushData
    var response = await submit("addData", [bigNum]);
    // Hash of the transaction record return(String)
    return response;
  }

  // The query() function stores the result using the Web3Client call method, which Calls a function defined in the smart contract and returns it's result.
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<List<dynamic>> _getArrayLength() async {
    // Transaction of array_getLength
    List<dynamic> result = await query("array_getLength", []);
    // Returns list of results, in this case a list with only the array length
    arrayLength = result[0].toString();
    return result;
  }

  Future<List<dynamic>> _getArray(int index) async {
    // uint in smart contract means BigInt
    var bigIndex = BigInt.from(index);
    // Transaction of array_getArray
    List<dynamic> result = await query("array_getArray", [bigIndex]);
    // Returns list of results, in this case a list with only the array[index]
    arrayData = result[0];
    return result;
  }

  Future<List<dynamic>> _getAllArray() async {
    // Transaction of array_popAllData
    List<dynamic> result = await query("array_popAllData", []);
    // Returns list of results, in this case a list with all the arrays
    allArrayData = result[0];
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
