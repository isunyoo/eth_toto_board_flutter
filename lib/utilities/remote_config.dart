// https://betterprogramming.pub/hide-your-passwords-e9154bbb8db4
// https://gist.github.com/Andrious/51ab198ad6128b55a70d6b1bc32f8136#file-remote_config-dart
// https://pub.dev/packages/firebase_remote_config/example
// https://tsvillain.medium.com/update-flutter-app-remotely-using-firebase-remote-config-69aadba275f7
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {

  late final RemoteConfig _remoteConfig;

  Future<void> initState() async {
    // Using zero duration to force fetching from remote server.
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    // Fetching and activating
    await _remoteConfig.fetchAndActivate();
  }

  // https://www.google.com/search?q=flutter+firebase+remote+config+fetch%280%29&ei=otyhYfz8OfHbz7sPo5mRkAw&ved=0ahUKEwj81ZWHgbj0AhXx7XMBHaNMBMIQ4dUDCA4&uact=5&oq=flutter+firebase+remote+config+fetch%280%29&gs_lcp=Cgdnd3Mtd2l6EAM6BwgAEEcQsAM6CAgAEAgQDRAeOgUIABDNAkoECEEYAFDhEFiYUWCgUmgBcAJ4AIABNogBuAqSAQIzMZgBAKABAcgBCMABAQ&sclient=gws-wiz



  Future<RemoteConfig> setupRemoteConfig() async {
    await Firebase.initializeApp();
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    // To force fetching from remote server.
    await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(seconds: 10), minimumFetchInterval: const Duration(hours: 0)));
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }

}