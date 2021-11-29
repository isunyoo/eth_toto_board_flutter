import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/key_encryption.dart';

class Web3DartHelper {
  late Client httpClient;
  late Web3Client ethClient;
  late final String _privateKey;
  late final RemoteConfig _remoteConfig;

  Future<void> initState() async {
    // To fetch remote config from Firebase Remote Config
    RemoteConfigService _remoteConfigService = RemoteConfigService();
    _remoteConfig = await _remoteConfigService.setupRemoteConfig();
    // To fetch local config from assets
    await dotenv.load(fileName: "assets/.env");

    // Initialize the httpClient and ethCLient in the initState() method.
    // Client class is the interface for HTTP clients that take care of maintaining persistent connections
    httpClient = Client();
    // Web3Client class used for for sending requests over an HTTP JSON-RPC API endpoint to Ethereum clients
    // ethClient = Web3Client(dotenv.get('Ganache_HTTP'), httpClient);
    // ethClient = Web3Client(_remoteConfig.getString('Ropsten_HTTPS'), httpClient);
    // WebSocket stream channels
    ethClient = Web3Client(jsonDecode(_remoteConfig.getValue('Connection_Config').asString())['Ropsten']['Ropsten_HTTPS'], Client(), socketConnector: () {
      return IOWebSocketChannel.connect(jsonDecode(_remoteConfig.getValue('Connection_Config').asString())['Ropsten']['Ropsten_Websockets']).cast<String>();
    });

    print(jsonDecode(_remoteConfig.getValue('accounts_secrets').asString())['0x82d85cF1331F9410F84D0B2aaCF5e2753a5afa82']);
    _privateKey = jsonDecode(_remoteConfig.getValue('accounts_secrets').asString())['0x82d85cF1331F9410F84D0B2aaCF5e2753a5afa82']['Private_Key'];
    Encrypted _encryptedPrivateKey = KeyEncrypt().getEncryption(_privateKey, 'my32lengthsupers'); //my32lengthsupersecretnooneknows1
    print('Encrypted Key: ${_encryptedPrivateKey.base64}');
    String _decryptedPrivateKey = KeyEncrypt().getDecryption(_encryptedPrivateKey, 'my32lengthsupers');
    print('Decrypted Key:  $_decryptedPrivateKey');
  }

  Future<String> getBlkNum() async {
    int blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
    return blkNum.toString();
  }

  Future<String> getAddress() async {
    var _credentials = EthPrivateKey.fromHex(_privateKey);
    var myAddress = await _credentials.extractAddress();
    return myAddress.toString();
  }

  Future<String> getEthBalance() async {
    var _credentials = EthPrivateKey.fromHex(_privateKey);
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
    String contractAddress = _remoteConfig.getString('Ropsten_Contract_Address');
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "TotoSlots"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  // The submit() function essentially signs and sends a transaction to the blockchain network from web3dart library.
  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(_privateKey);
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credentials,
        Transaction.callContract(
            contract: contract,
            function: ethFunction,
            parameters: args,
            maxGas: 6000000
        ), chainId: 3 // 3:Ropsten, 1337:Development
    );
    await ethClient.dispose();
    return result;
  }

  Future<String> pushArrayData(List<dynamic> args) async {
    // Conversion BigInt Array
    List<dynamic> bigIntsList = [];
    for(var row=0; row<args.length; row++){
      List<BigInt> bigNumberList=[];
      for(var column=0; column<args[row].length; column++){
        // print(args[row][column]);
        bigNumberList.add(BigInt.from(args[row][column]));
      }
      bigIntsList.add(bigNumberList);
    }
    // Transaction of array_pushData
    var transactionHash = await submit("array_pushData", [bigIntsList]);
    // Hash of the transaction record return(String)
    return transactionHash;
  }

  Future<String> addData(int num) async {
    // uint in smart contract means BigInt
    var bigNum = BigInt.from(num);
    // Transaction of array_pushData
    var transactionHash = await submit("addData", [bigNum]);
    // Hash of the transaction record return(String)
    return transactionHash;
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

  // Get transaction details receipt
  // Future<String> getTransactionDetails(String transactionHash) async {
  Future<TransactionReceipt?> getTransactionDetails(String transactionHash) async {
    var transactionInfo = await ethClient.getTransactionReceipt(transactionHash);
    // return(transactionInfo.toString());
    return(transactionInfo);
  }

  // Get transaction block
  Future<String> getTransactionBlock(String transactedHash) async {
    var transactionInfo = await ethClient.getTransactionReceipt(transactedHash);
    if (transactionInfo == null) {
      return '';
    }
    return transactionInfo.blockNumber.toString();
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
    Response response = await get(Uri.parse(_remoteConfig.getString('ETH_Price_URL')));
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