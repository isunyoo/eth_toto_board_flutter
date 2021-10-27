import 'dart:math';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Web3DartHelper {
  late Client httpClient;
  late Web3Client ethClient;

  Future<void> initState() async {
    await dotenv.load(fileName: "assets/.env");
    // Initialize the httpClient and ethCLient in the initState() method.
    // Client class is the interface for HTTP clients that take care of maintaining persistent connections
    httpClient = Client();
    // Web3Client class used for for sending requests over an HTTP JSON-RPC API endpoint to Ethereum clients
    ethClient = Web3Client(dotenv.get('Ganache_API'), httpClient);
  }

  Future<int> getBlkNum() async {
    int blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
    return blkNum;
  }

  Future<EthereumAddress> getAddress() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    var myAddress = await _credentials.extractAddress();
    return myAddress;
  }

  Future<num> getBalance() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    var myAddress = await _credentials.extractAddress();
    // print('address: $_address');
    // Get native balance
    var balanceObj = await ethClient.getBalance(myAddress);
    var balanceEther = balanceObj.getValueInUnit(EtherUnit.ether);
    // print('balance before transaction: ${balanceObj.getInWei} wei (${balanceObj.getValueInUnit(EtherUnit.ether)} ether)');
    return balanceEther;
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

  Future<String> pushArrayData(List<dynamic> args) async {
    var response = 'test';
    print(args);
    print(args.runtimeType);
    // Transaction of array_pushData
    // var response = await submit("array_pushData", [args]);
    // Hash of the transaction record return(String)
    return response;
  }

  Future<String> addData(int num) async {
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

  Future<String> getArrayLength() async {
    // Transaction of array_getLength
    List<dynamic> result = await query("array_getLength", []);
    // Returns list of results, in this case a list with only the array length
    var arrayLength = result[0].toString();
    return arrayLength;
  }

  Future<List<dynamic>> getArray(int index) async {
    // uint in smart contract means BigInt
    var bigIndex = BigInt.from(index);
    // Transaction of array_getArray
    List<dynamic> result = await query("array_getArray", [bigIndex]);
    // Returns list of results, in this case a list with only the array[index]
    var arrayData = result[0];
    return arrayData;
  }

  Future<List<dynamic>> getAllArray() async {
    // Transaction of array_popAllData
    List<dynamic> result = await query("array_popAllData", []);
    // Returns list of results, in this case a list with all the arrays
    var allArrayData = result[0];
    return allArrayData;
  }

  List<dynamic> generateSlots() {
    // Define min and max value inclusive
    int min = 1, max = 45;
    // A rows(length) x 6 columns(matrix)
    int rows = 3, columns = 6;
    Random random = Random();
    var randomSlots = List.generate(rows, (_) => List.generate(columns, (_) => min + random.nextInt(max - min)));

    // List<int> numberList=[];
    // for(var i=0; numberList.length<columns; i++){
    //   int randomNumber = min + random.nextInt(max - min);
    //   if(!numberList.contains(randomNumber)) {
    //     numberList.add(randomNumber);
    //   }
    //   numberList.sort();
    // }
    // print(numberList);

    var numberList = List.generate(rows, (_) => List.generate(columns, (_) => <int>[]));
    // List<List<num>> numberList = List.generate(columns, (i) => new List(rows));
    // var numberList = List.generate(columns, (i) => List(rows), growable: false);
    // var numberList = List.generate(rows, (i) => [0,0,0,0,0,0], growable: false);
    // var numberList = List.generate(rows, (i) => List.generate(columns, (j) => i * 4 + j));
    for(int i=0; i<numberList.length; i++) {
      for(int j=0; j<numberList[i].length; j++) {
        int randomNumber = min + random.nextInt(max - min);
        if(!numberList[i][j].contains(randomNumber)) {
          print(randomNumber);
          numberList[i][j].add(randomNumber);
          // numberList[i] = randomNumber as List<List<int>>;
        }
        // numberList[i].add(numberList[i].sort());
        numberList[i].sort();
      }
    }
    print(numberList);
    print(numberList.length);
    print(numberList[0].length);


    // https://stackoverflow.com/questions/57860596/creating-a-2d-array-in-flutter-dart

    // List<List<int>> , twoDList[0][1]
    // List<List<int>> numberList=[rows][columns] as List<List<int>>;


    // var nlist = [4,2,1,5];
    // print(nlist.sort((a, b) => a.compareTo(b)));
    // print(randomSlots.runtimeType);
    // print(randomSlots.length);
    // print(randomSlots[0]);
    // print(randomSlots[0].runtimeType);
    // print(randomSlots[0].sort((a, b) => a.compareTo(b)));
    return randomSlots;
  }
}