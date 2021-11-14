import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionReceipt {
  String blockHash;
  int blockNumber;
  int cumulativeGasUsed;
  String from;
  bool status;
  String to;
  String transactionHash;
  int transactionIndex;
  final DocumentReference reference;

  TransactionReceipt({required this.blockHash, required this.blockNumber, required this.cumulativeGasUsed, required this.from, required this.status, required this.to, required this.transactionHash, required this.transactionIndex});

  factory TransactionReceipt.fromJson(Map<String, dynamic> json) => _$TransactionReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionReceiptToJson(this);
}


class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}