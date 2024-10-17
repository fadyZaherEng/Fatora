import 'package:equatable/equatable.dart';

class Fatora  extends Equatable{
  final int id;
  final String paymentMethod;
  final String fatoraId;
  final String name;
  final String date;
  final String time;
  final String price;
  final String numberArrived;
  final String numberMove;
  final String status;
  final String statusSuccess;
  final String deviceNumber;
  final String traderNumber;

  const Fatora({
     this.paymentMethod="",
     this.fatoraId="",
     this.name="",
     this.date="",
     this.time="",
     this.price="",
     this.numberArrived="",
     this.numberMove="",
     this.status="",
     this.statusSuccess="",
     this.deviceNumber="",
     this.traderNumber="",
      this.id=0,
  });

  @override
  List<Object?> get props => [
    paymentMethod,
    fatoraId,
    name,
    date,
    time,
    price,
    numberArrived,
    numberMove,
    status,
    statusSuccess,
    deviceNumber,
    traderNumber,
    id
  ];

  Fatora copyWith({
    String? paymentMethod,
    String? fatoraId,
    String? name,
    String? date,
    String? time,
    String? price,
    String? numberArrived,
    String? numberMove,
    String? status,
    String? statusSuccess,
    String? deviceNumber,
    String? traderNumber,
    int? id
  }) {
    return Fatora(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fatoraId: fatoraId ?? this.fatoraId,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      numberArrived: numberArrived ?? this.numberArrived,
      numberMove: numberMove ?? this.numberMove,
      status: status ?? this.status,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      deviceNumber: deviceNumber ?? this.deviceNumber,
      traderNumber: traderNumber ?? this.traderNumber,
      id: id ?? this.id
    );
  }
  //from json
  factory Fatora.fromJson(Map<String, dynamic> json) {
    return Fatora(
      paymentMethod: json['paymentMethod'],
      fatoraId: json['fatoraId'],
      name: json['name'],
      date: json['date'],
      time: json['time'],
      price: json['price'],
      numberArrived: json['numberArrived'],
      numberMove: json['numberMove'],
      status: json['status'],
      statusSuccess: json['statusSuccess'],
      deviceNumber: json['deviceNumber'],
      traderNumber: json['traderNumber'],
      id: json['id'],
    );
  }

  //to json
  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'fatoraId': fatoraId,
      'name': name,
      'date': date,
      'time': time,
      'price': price,
      'numberArrived': numberArrived,
      'numberMove': numberMove,
      'status': status,
      'statusSuccess': statusSuccess,
      'deviceNumber': deviceNumber,
      'traderNumber': traderNumber,
      'id': id
    };
  }
}