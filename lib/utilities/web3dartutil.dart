import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
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
    // ethClient = Web3Client(dotenv.get('Ganache_HTTP'), httpClient);
    // ethClient = Web3Client(dotenv.get('Ropsten_HTTPS'), httpClient);
    // WebSocket stream channels
    ethClient = Web3Client(dotenv.get('Ropsten_HTTPS'), Client(), socketConnector: () {
      return IOWebSocketChannel.connect(dotenv.get('Ropsten_Websockets')).cast<String>();
    });
  }

  Future<String> getBlkNum() async {
    int blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
    return blkNum.toString();
  }

  Future<String> getAddress() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    var myAddress = await _credentials.extractAddress();
    return myAddress.toString();
  }

  Future<String> getEthBalance() async {
    var _credentials = EthPrivateKey.fromHex(dotenv.get('Private_Key'));
    var myAddress = await _credentials.extractAddress();
    // print('address: $_address');
    // Get native balance
    var balanceObj = await ethClient.getBalance(myAddress);
    var balanceEther = balanceObj.getValueInUnit(EtherUnit.ether);
    // print('balance before transaction: ${balanceObj.getInWei} wei (${balanceObj.getValueInUnit(EtherUnit.ether)} ether)');
    return balanceEther.toStringAsFixed(4);
  }

  // Functions for reading the smart contract and submitting a transaction.
  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    // String contractAddress = dotenv.get('Development_Contract_Address');
    String contractAddress = dotenv.get('Ropsten_Contract_Address');
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
        ), chainId: 3 // 3:Ropsten, 1337:Development
    );
    return result;
  }

  Future<String> pushArrayData(List<dynamic> args) async {
    var response = 'test';
    print(args);
    print(args.runtimeType);
    // Transaction of array_pushData
    // var response = await submit("array_pushData", [args]);
    // print(response);
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

  // Get transaction receipt
  Future<String> getTransactionDetails(String transactedHash) async {
    var transactionInfo = await ethClient.getTransactionReceipt(transactedHash);
    return(transactionInfo.toString());
  }

  List<dynamic> generateSlots(int maxRows) {
    // Requested rows(length) x 6 columns(matrix)
    int maxColumns = 6;
    // Define min and max value inclusive
    int min = 1, max = 45;

    Random random = Random();
    var randomSlots=[];
    for(var row=0; row<maxRows; row++){
      List<int> numberList=[];
      for(var column=0; numberList.length<maxColumns; column++){
        int randomNumber = min + random.nextInt(max - min);
        if(!numberList.contains(randomNumber)) {
          numberList.add(randomNumber);
        }
        numberList.sort();
      }
      randomSlots.add(numberList);
    }
    // print(randomSlots);
    // print(randomSlots.runtimeType);
    return randomSlots;
  }

  // Function to return USD conversion values
  Future<String> getConvUSD() async {
    num balanceUSD;
    var balanceEther = await getEthBalance();
    // Make a network request
    Response response = await get(Uri.parse(dotenv.get('ETHSCAN_URL')));
    // If the server did return a 200 OK response then parse the JSON.
    if (response.statusCode == 200) {
      // print(jsonDecode(response.body));
      // print(jsonDecode(response.body)["USD"]);
      // print(jsonDecode(response.body)["USD"].runtimeType);
      // Get the current USD price of cryptocurrency conversion from API URL
      balanceUSD = double.parse(balanceEther) * jsonDecode(response.body)["USD"];
    } else {
      // If the server did not return a 200 OK response then throw an exception.
      throw Exception('Failed to load album');
    }
    // String roundedX = balanceUSD.toStringAsFixed(2);
    return balanceUSD.toStringAsFixed(2);
  }

}