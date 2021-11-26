// https://betterprogramming.pub/hide-your-passwords-e9154bbb8db4
// https://gist.github.com/Andrious/51ab198ad6128b55a70d6b1bc32f8136#file-remote_config-dart
// https://pub.dev/packages/firebase_remote_config/example
// https://tsvillain.medium.com/update-flutter-app-remotely-using-firebase-remote-config-69aadba275f7
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {

  late final RemoteConfig remoteConfig;

  // Future<void> initState() async {
  //
  // }

  Future<RemoteConfig> setupRemoteConfig() async {
    await Firebase.initializeApp();
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    // Using zero duration to force fetching from remote server.
    await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(seconds: 10), minimumFetchInterval: const Duration(hours: 1)));
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }

}