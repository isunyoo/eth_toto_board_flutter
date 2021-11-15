// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class TransactionReceipt {
//
//   final String blockHash;
//   final int blockNumber;
//   final int cumulativeGasUsed;
//   final String from;
//   final bool status;
//   final String to;
//   final String transactionHash;
//   final int transactionIndex;
//   final DocumentReference reference;
//
//   TransactionReceipt(this.blockHash, this.blockNumber, this.cumulativeGasUsed, this.from, this.status, this.to, this.transactionHash, this.transactionIndex, this.reference);
//
//   TransactionReceipt.fromMap(Map<String, dynamic> Function() map, {required this.reference})
//       : assert(map()['blockHash'] != null),
//         assert(map()['blockNumber'] != null),
//         assert(map()['cumulativeGasUsed'] != null),
//         assert(map()['from'] != null),
//         assert(map()['status'] != null),
//         assert(map()['to'] != null),
//         assert(map()['transactionHash'] != null),
//         assert(map()['transactionIndex'] != null),
//         blockHash = map()['blockHash'],
//         blockNumber = map()['blockNumber'],
//         cumulativeGasUsed = map()['cumulativeGasUsed'],
//         from = map()['from'],
//         status = map()['status'],
//         to = map()['to'],
//         transactionHash = map()['transactionHash'],
//         transactionIndex = map()['transactionIndex'];
//
//   TransactionReceipt.fromSnapshot(DocumentSnapshot snapshot)
//       : this.fromMap(snapshot.data(), reference: snapshot.reference);
//
//   @override
//   String toString() => "TransactionReceipt<$blockHash:$blockNumber:$cumulativeGasUsed:$from:$status:$to:$transactionHash:$transactionIndex>";
//
// }

class TransactionReceipt {

  final String transactionHash;
  final int transactionIndex;
  final String blockHash;
  final int blockNumber;
  final String from;
  final String to;
  final int cumulativeGasUsed;
  final int gasUsed;
  final bool status;
  final DateTime date;

  TransactionReceipt(this.transactionHash, this.transactionIndex, this.blockHash, this.blockNumber, this.from, this.to, this.cumulativeGasUsed, this.gasUsed, this.status, this.date);

  TransactionReceipt.fromJson(Map<dynamic, dynamic> json)
      : transactionHash = json['transactionHash'] as String,
        transactionIndex = json['transactionIndex'] as int,
        blockHash = json['blockHash'] as String,
        blockNumber = json['blockNumber'] as int,
        from = json['from'] as String,
        to = json['to'] as String,
        cumulativeGasUsed = json['cumulativeGasUsed'] as int,
        gasUsed = json['gasUsed'] as int,
        status = json['status'] as bool,
        date = DateTime.parse(json['date'] as String);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'transactionHash': transactionHash,
    'transactionIndex': transactionIndex,
    'blockHash': blockHash,
    'blockNumber': blockNumber,
    'from': from,
    'to': to,
    'cumulativeGasUsed': cumulativeGasUsed,
    'gasUsed': gasUsed,
    'status': status,
    'date': date.toString(),
  };

}