class BlockNumber {
  final String blockNumber;

  BlockNumber(this.blockNumber);

  BlockNumber.fromJson(Map<String, dynamic> json)
      : blockNumber = json['blockNumber'];


  Map<String, dynamic> toJson() => {
    'blockNumber': blockNumber,
  };
}