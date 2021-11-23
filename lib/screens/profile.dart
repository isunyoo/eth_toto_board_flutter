import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eth_toto_board_flutter/boardmain.dart';
import 'package:eth_toto_board_flutter/screens/login.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:eth_toto_board_flutter/utilities/authenticator.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
    // Request a Navigator operation if Email verified
    _launchBoardMain();
  }

  void _launchBoardMain() {
    if(_currentUser.emailVerified) {
      // The delay to route BoardMain Page
      Future.delayed(const Duration(milliseconds: 100)).then((_) {
        // Navigate to the main screen using a named route.
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardMain()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SigningOut Status Parameter
    _isSigningOut;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NAME: ${_currentUser.displayName}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 16.0),
            Text(
              'EMAIL: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 16.0),
            _currentUser.emailVerified ? Text(
              'Email verified',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.green),
            )
                : Text(
              'Email not verified',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 16.0),
            _isSendingVerification ? const CircularProgressIndicator() : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isSendingVerification = true;
                    });
                    await _currentUser.sendEmailVerification();
                    setState(() {
                      _isSendingVerification = false;
                    });
                  },
                  child: const Text('Verify Email'),
                ),
                // const SizedBox(width: 8.0),
                // IconButton(
                //   icon: const Icon(Icons.refresh),
                //   onPressed: () async {
                //     User? user = await FireAuth.refreshUser(_currentUser);
                //
                //     if (user != null) {
                //       setState(() {
                //         _currentUser = user;
                //       });
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
          icon: Icons.menu,
          backgroundColor: Colors.blueAccent,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.exit_to_app),
              label: 'Logout',
              backgroundColor: Colors.blue,
              onTap: () async {
                setState(() {
                  _isSigningOut = true;
                });
                await FirebaseAuth.instance.signOut();
                setState(() {
                  _isSigningOut = false;
                });
                // Navigate to the main screen using a named route.
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage(),),);
              },
            ),
          ]
      ),
    );
  }
}


