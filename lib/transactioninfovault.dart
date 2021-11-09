class TransactionInfo {
  TransactionInfo({required this.blockNumber, required this.transactionHash});
  final String blockNumber;
  final String transactionHash;

  // Define a factory constructor
  factory TransactionInfo.fromJson(Map<String, dynamic> data) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final blockNumber = data['blockNumber'] as String;
    final transactionHash = data['transactionHash'] as String;
    return TransactionInfo(blockNumber: blockNumber, transactionHash: transactionHash);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'blockNumber': blockNumber,
      'transactionHash': transactionHash
    };
  }
}