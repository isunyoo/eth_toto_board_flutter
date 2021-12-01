import 'dart:convert';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'utilities/web3dartutil.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/profile.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/key_encryption.dart';

class ImportKey extends StatefulWidget {
  const ImportKey({Key? key}) : super(key: key);

  @override
  State<ImportKey> createState() => _ImportKeyState();
}

class _ImportKeyState extends State<ImportKey> {
  // Initialize the Web3DartHelper class from utility packages
  Web3DartHelper web3util = Web3DartHelper();

  // To create a new Firebase Remote Config instance
  late RemoteConfig _remoteConfig = RemoteConfig.instance;

  // Create a DatabaseReference which references a node called dbRef
  late final DatabaseReference _dbRef = FirebaseDatabase(
      databaseURL: jsonDecode(_remoteConfig.getValue('Connection_Config')
          .asString())['Firebase']['Firebase_Database']).reference();

  // The user's ID which is unique from the Firebase project
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Form widget variables
  bool _isProcessing = false;
  final _focusPrivateKey = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _privateKeyTextController = TextEditingController();

  // Get DataSnapshot value lists
  List<Map<dynamic, dynamic>> lists = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    // Firebase Initialize App Function
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // To fetch remote config from Firebase Remote Config
    RemoteConfigService _remoteConfigService = RemoteConfigService();
    _remoteConfig = await _remoteConfigService.setupRemoteConfig();
  }

  static String? validatePrivateKey({required String? key}) {
    // Define the valid characters on Alphanumeric
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    if (key == null) {
      return null;
    }
    if (key.isEmpty) {
      return 'PrivateKey can\'t be empty';
    } else if (key.length != 64) {
      return 'Enter a PrivateKey with 64 lengths';
    } else if (!validCharacters.hasMatch(key)) {
      return 'Special character contains in PrivateKey';
    }
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

  // Get the key and value properties data from returning DataSnapshot vaults' values
  Future<List<Map>> getVaultData() async {
    DataSnapshot snapshotResult = await _dbRef.child('vaults/$userId').once();
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

  // Function takes a txReceipt as a parameter and uses a DatabaseReference to save the MAP message to Realtime Database.
  Future<void> saveAccount(String privateKeyContext) async {
    // Encryption of PrivateKey
    encrypt.Encrypted _encryptedPrivateKey = KeyEncrypt().getEncryption(privateKeyContext);
    // encrypt.Encrypted _encryptedPrivateKey = KeyEncrypt().getEncryptionKeyRing(privateKeyContext, 'my32lengthsupers');
    // Get Account Address from inserted privateKeyContext
    String _accountAddress = await web3util.getAccountAddress(privateKeyContext);

    // Retrieve current database snapshot on vaults
    lists = await getVaultData();
    if(lists.isEmpty){
      // Map<String, String> vaultContent = <String, String>{'accountAddress': _accountAddress, 'encryptedPrivateKey': _encryptedPrivateKey.base64};
      Map<String, Encrypted> vaultContent = <String, Encrypted>{'accountAddress': _accountAddress, 'encryptedPrivateKey': _encryptedPrivateKey};
      // Save to Realtime Database(vaults)
      await _dbRef.child('vaults/$userId').push().set(vaultContent);
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Account($_accountAddress) has imported successfully.',
        ),
      );
    } else {
      for (int i = 0; i < lists.length; i++) {
        if(_accountAddress == lists[i]["accountAddress"]) {
          // print(lists[i]["accountAddress"]);
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Account($_accountAddress) has already existed in wallet.',
            ),
          );
        }
      }
    }

  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Account'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Text(
                  'Paste your private key string',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      maxLength: 64,
                      controller: _privateKeyTextController,
                      focusNode: _focusPrivateKey,
                      validator: (value) => validatePrivateKey(key: value),
                      decoration: InputDecoration(
                        hintText: "e.g. c34xff58155ad242b8e6c0e09596b202y0186763359301a2727f38r9146ff523",
                        errorBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              _focusPrivateKey.unfocus();

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isProcessing = true;
                                });


                                // To save an Account to Realtime Database(vaults).
                                await saveAccount(
                                    _privateKeyTextController.text);
                                // await getVaultData();

                                // User? user = await FireAuth.signInUsingEmailPassword(email: _emailTextController.text, password: _passwordTextController.text, context: context);

                                setState(() {
                                  _isProcessing = false;
                                });

                                // if (user != null) {
                                //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EmailVerifyPage(user: user),),);
                                // }
                              }
                            },
                            child: const Text(
                              'Import',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
          icon: Icons.menu,
          backgroundColor: Colors.blueAccent,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.account_circle_sharp),
              label: 'Profile',
              backgroundColor: Colors.blue,
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(passedValue1: myAddress)));
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.menu_rounded),
              label: 'Main',
              backgroundColor: Colors.blue,
              onTap: () {
                // Navigate to the main screen using a named route.
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BoardMain(),),);
              },
            ),
          ]
      ),
    );
  }

}

