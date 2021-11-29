import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/profile.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eth_toto_board_flutter/utilities/remote_config.dart';

class ImportKey extends StatefulWidget {
  const ImportKey({Key? key}) : super(key: key);

  @override
  State<ImportKey> createState() => _ImportKeyState();

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

}

class _ImportKeyState extends State<ImportKey> {
  // To create a new Firebase Remote Config instance
  late RemoteConfig _remoteConfig = RemoteConfig.instance;
  // Create a DatabaseReference which references a node called txreceipts
  late final DatabaseReference _txReceiptRef = FirebaseDatabase(databaseURL:_remoteConfig.getString('Firebase_Database')).reference();
  // The user's ID which is unique from the Firebase project
  String? userId = FirebaseAuth.instance.currentUser?.uid;
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

  // Auto login(If a user has logged in to the app and then closed it, when the user comes back to the app, it should automatically sign in)
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    return firebaseApp;
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
                      const Text('Paste your private key string here:'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      Form(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Email",
                                errorBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage(),),);
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardMain(),),);
              },
            ),
          ]
      ),
    );
  }

}


