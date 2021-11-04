Reference
https://medium.com/geekculture/simple-dapp-using-flutter-and-solidity-b64f5267acf4
https://medium.com/@dev_89267/develop-blockchain-applications-with-flutter-ethereum-59e846944127
https://techblog.geekyants.com/developing-blockchain-applications-with-flutter
https://www.geeksforgeeks.org/flutter-and-blockchain-population-dapp/
https://gist.github.com/anoochit/470e0ea6555f7822a1db02974f114f78
https://github.com/simolus3/web3dart/issues/65
https://github.com/aniketambore/Flutter-Blockchain/blob/main/population/lib/contract_linking.dart


$ emulator -list-avds
$ emulator -avd Pixel_XL_API_29 -port 5557
$ adb devices
$ adb kill-server
$ adb -s emulator-5554 reverse tcp:8545 tcp:8545
$ adb reverse --list
$ adb reverse --remove tcp:8545

truffle(development)> accounts
truffle(development)> opcode TotoSlots

Obfuscating Android app
$ flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>
