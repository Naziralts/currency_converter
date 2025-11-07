import 'package:equatable/equatable.dart';


class HistoryPoint extends Equatable {
  final DateTime date;

  final double rate;


  const HistoryPoint({
    required this.date,
    required this.rate,
  });

  @override
  List<Object?> get props => [date, rate];
}
