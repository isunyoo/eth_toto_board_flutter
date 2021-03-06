import 'dart:math';
import 'dart:convert';
import 'dart:collection';
import 'package:http/http.dart';
import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/key_encryption.dart';

class Web3DartHelper {
  late Client httpClient;
  late Web3Client ethClient;
  late String _privateKey;
  // Get DataSnapshot value lists
  List<Map<dynamic, dynamic>> lists = [];

  // To fetch remote config from Firebase Remote Config
  late final RemoteConfig remoteConfig = RemoteConfig.instance;

  // Create a DatabaseReference which references a node called dbRef
  late final DatabaseReference dbRef = FirebaseDatabase(
      databaseURL: jsonDecode(remoteConfig.getValue('Connection_Config')
          .asString())['Firebase']['Firebase_Database']).reference();

  // The user's ID which is unique from the Firebase project
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> initState() async {
    // To fetch local config from assets
    await dotenv.load(fileName: "assets/.env");

    // Initialize the httpClient and ethCLient in the initState() method.
    // Client class is the interface for HTTP clients that take care of maintaining persistent connections
    httpClient = Client();
    // Web3Client class used for for sending requests over an HTTP JSON-RPC API endpoint to Ethereum clients
    // ethClient = Web3Client(dotenv.get('Ganache_HTTP'), httpClient);
    // ethClient = Web3Client(_remoteConfig.getString('Ropsten_HTTPS'), httpClient);
    // WebSocket stream channels
    ethClient = Web3Client(jsonDecode(remoteConfig.getValue('Connection_Config').asString())['Ropsten']['Ropsten_HTTPS'], Client(), socketConnector: () {
      return IOWebSocketChannel.connect(jsonDecode(remoteConfig.getValue('Connection_Config').asString())['Ropsten']['Ropsten_Websockets']).cast<String>();
    });

    // Retrieve current database snapshot on vaults for landing page
    lists = await getInitialVaultData();
    if(lists.isEmpty){
      // No account has imported yet in vault database
      _privateKey = '';
    } else {
      // Get PrivateKey Definition from firebaseDatabase Vaults data
      _privateKey = KeyEncrypt().getDecryption(lists[0]["encryptedPrivateKey"]);
      for (int i = 0; i < lists.length; i++) {
        print(lists[i]["encryptedPrivateKey"]);
        String _encryptedPrivateKey = lists[i]["encryptedPrivateKey"];
        print(KeyEncrypt().getDecryption(_encryptedPrivateKey));
      }
    }

    // String _encryptedPrivateKey = KeyEncrypt().getEncryptionKeyRing(_privateKey, 'my32lengthsupers');
    String _encryptedPrivateKey = KeyEncrypt().getEncryption(_privateKey);
    print('Encrypted Key: $_encryptedPrivateKey');
    // String _decryptedPrivateKey = KeyEncrypt().getDecryptionKeyRing(_encryptedPrivateKey, 'my32lengthsupers');
    String _decryptedPrivateKey = KeyEncrypt().getDecryption(_encryptedPrivateKey);
    print('Decrypted Key:  $_decryptedPrivateKey');

    // Test for Tx Input Decode
    await queryTransactedInput('0x2ac384533fcf658dc1c776245fd0ee95b09955eb6e33276837ac62996771253e');
  }

  // Get the key and value properties data from returning DataSnapshot vaults' values for landing page
  Future<List<Map>> getInitialVaultData() async {
    // Retrieve last one timestamp from vaults datasnapshot
    DataSnapshot snapshotResult = await dbRef.child('vaults/$userId').orderByChild('timestamp').limitToLast(1).once();
    if(snapshotResult.value == null ) {
      lists.clear();
      return lists;
    } else {
      final LinkedHashMap hashMapValue = snapshotResult.value;
      lists.clear();
      Map<dynamic, dynamic> mapValues = hashMapValue;
      mapValues.forEach((key, mapValues) {
        lists.add(mapValues);
      });
      return lists;
    }
  }

  Future<String> getBlkNum() async {
    int blkNum = await ethClient.getBlockNumber();
    // print('Current Block Number: $_blkNum');
    return blkNum.toString();
  }

  Future<String> getAddress() async {
    if(_privateKey == ''){
      return '';
    } else {
      var _credentials = EthPrivateKey.fromHex(_privateKey);
      var myAddress = await _credentials.extractAddress();
      return myAddress.toString();
    }
  }

  Future<String> getAccountAddress(String inputPrivateKey) async {
    try {
      var _credentials = EthPrivateKey.fromHex(inputPrivateKey);
      var myAddress = await _credentials.extractAddress();
      return myAddress.toString();
    } on FormatException {
      return '';
    }
  }

  // Function to return Ethereum values
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

  Future<String> getAccountEthBalance(String myAddress) async {
    // Get native balance
    var balanceObj = await ethClient.getBalance(EthereumAddress.fromHex(myAddress));
    var balanceEther = balanceObj.getValueInUnit(EtherUnit.ether);
    // print('balance before transaction: ${balanceObj.getInWei} wei (${balanceObj.getValueInUnit(EtherUnit.ether)} ether)');
    return balanceEther.toStringAsFixed(4);
  }

  // Functions for reading the smart contract and submitting a transaction.
  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/TotoSlots.json");
    // String contractAddress = dotenv.get('Development_Contract_Address');
    String contractAddress = remoteConfig.getString('Ropsten_Contract_Address');
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "TotoSlots"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  // Function to decode input data from txhash which has transacted previously
  // Future<List> queryTransactedInput(String txhash) async {
  Future<void> queryTransactedInput(String txhash) async {
    var tx = await ethClient.getTransactionByHash(txhash);
    print(tx);
    print(tx.runtimeType);
    print(tx.input);
    print(hex.encode(tx.input));
    print(tx.input.runtimeType);  // Uint8List
    var txInput = tx.input;
    DeployedContract totoContract = await loadContract();
    // List funcParams = totoContract.decode_function_input(tx["input"]); // Python Function
    // var funcParams = totoContract.event('saveTotoSlotsData').decodeResults(List<String> topics, String data);
    // print(funcParams);

    // // Extracting some functions and events that we'll need later
    // final txTotoEvent = totoContract.event('saveTotoSlotsData');
    // // Listen for the saveTotoSlotsData event when it's emitted by the contract process
    // final subscription = ethClient
    //     .events(FilterOptions.events(contract: totoContract, event: txTotoEvent))
    //     .take(1)
    //     .listen((event) {
    //       final decoded = txTotoEvent.decodeResults(event.topics!, event.data!);
    //       print(decoded);
    // final from = decoded[0] as EthereumAddress;
    // final to = decoded[1] as EthereumAddress;
    // final value = decoded[2] as BigInt;
    // final input = decoded[3] as BigInt;
    // print('$from sent $value MetaCoins to $to input $input');
    // });
    // await subscription.asFuture();
    // await subscription.cancel();
    // await ethClient.dispose();
  }
  // https://github.com/simolus3/web3dart/blob/development/example/contracts.dart
  // https://issueexplorer.com/issue/simolus3/web3dart/168
  // https://ropsten.etherscan.io/address/0x82d85cF1331F9410F84D0B2aaCF5e2753a5afa82

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
            nonce: await ethClient.getTransactionCount(await credentials.extractAddress(), atBlock: const BlockNum.pending()),
            maxGas: 6000000
        ),
        chainId: 3 // 3:Ropsten, 1337:Development
    );
    await ethClient.dispose();
    return result;
  }

  Future<String> submitTotoSlotsData(String functionName, String _issuerUID, String _issuerName, String _issuerEmail, List<dynamic> _slotsData, String _issuerTime) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(_privateKey);
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credentials,
        Transaction.callContract(
            contract: contract,
            function: ethFunction,
            parameters: [await credentials.extractAddress(), _issuerUID, _issuerName, _issuerEmail, _slotsData, _issuerTime],
            // gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 20),
            nonce: await ethClient.getTransactionCount(await credentials.extractAddress(), atBlock: const BlockNum.pending()),
            maxGas: 6000000
        ),
        chainId: 3 // 3:Ropsten, 1337:Development
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
    try {
      // Transaction of array_pushData
      var transactionHash = await submit("array_pushData", [bigIntsList]);
      // Hash of the transaction record return(String)
      return transactionHash;
    } catch(e) {
      // print(e);
      return '';
    }
  }

  Future<String> saveArrayData(String _issuerUID, String _issuerName, String _issuerEmail, List<dynamic> _slotsData, String _issuerTime) async {
    // Conversion BigInt Array
    List<dynamic> bigIntsList = [];
    for(var row=0; row<_slotsData.length; row++){
      List<BigInt> bigNumberList=[];
      for(var column=0; column<_slotsData[row].length; column++){
        // print(args[row][column]);
        bigNumberList.add(BigInt.from(_slotsData[row][column]));
      }
      bigIntsList.add(bigNumberList);
    }
    try {
      // Transaction of setTotoSlotsData
      var transactionHash = await submitTotoSlotsData("setTotoSlotsData", _issuerUID, _issuerName, _issuerEmail, bigIntsList, _issuerTime);
      // Hash of the transaction record return(String)
      return transactionHash;
    } catch(e) {
      // print(e);
      return '';
    }
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
    // print(randomSlots.runtimeType);
    return randomSlots;
  }

  // Function to return USD conversion values
  Future<String> getConvUSD() async {
    num balanceUSD;
    var balanceEther = await getEthBalance();
    // Make a network request
    Response response = (await get(Uri.parse(remoteConfig.getString('ETH_Price_URL'))));
    // If the server did return a 200 OK response then parse the JSON.
    if (response.statusCode == 200) {
      // print(jsonDecode(response.body)["USD"]);
      // Get the current USD price of cryptocurrency conversion from API URL
      balanceUSD = double.parse(balanceEther) * jsonDecode(response.body)["USD"];
    } else {
      // If the server did not return a 200 OK response then throw an exception.
      throw Exception('Failed to load API');
    }
    // String roundedX = balanceUSD.toStringAsFixed(2);
    return balanceUSD.toStringAsFixed(2);
  }

  Future<String> getConvEthUSD(String balanceEther) async {
    num balanceUSD;
    // Make a network request
    Response response = (await get(Uri.parse(remoteConfig.getString('ETH_Price_URL'))));
    // If the server did return a 200 OK response then parse the JSON.
    if (response.statusCode == 200) {
      // print(jsonDecode(response.body)["USD"]);
      // Get the current USD price of cryptocurrency conversion from API URL
      balanceUSD = double.parse(balanceEther) * jsonDecode(response.body)["USD"];
    } else {
      // If the server did not return a 200 OK response then throw an exception.
      throw Exception('Failed to load API');
    }
    // String roundedX = balanceUSD.toStringAsFixed(2);
    return balanceUSD.toStringAsFixed(2);
  }

}