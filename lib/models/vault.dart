class VaultData {
  VaultData({
    required this.accountAddress,
    required this.encryptedPrivateKey
  });

  String accountAddress;
  String encryptedPrivateKey;

  Map<String, String> toMap() {
    return {
      'accountAddress': accountAddress,
      'encryptedPrivateKey': encryptedPrivateKey
    };
  }

  static VaultData fromMap(Map value) {
    return VaultData(
      accountAddress: value['accountAddress'],
      encryptedPrivateKey: value['encryptedPrivateKey']
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accountAddress': accountAddress,
    'encryptedPrivateKey': encryptedPrivateKey
  };

  @override
  String toString() {
    return ('{accountAddress: $accountAddress, encryptedPrivateKey: $encryptedPrivateKey}');
  }
}