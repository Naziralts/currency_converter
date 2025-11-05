import 'package:equatable/equatable.dart';
import '../../../converter/domain/entities/history_point.dart';

class ConverterState extends Equatable {

  final bool loading;

  final String base;

  final String target;

 
  final String amountText;


  final double? result;

  final List<HistoryPoint> history;


  final String? error;


  const ConverterState({
    this.loading = false,
    this.base = 'USD',
    this.target = 'EUR',
    this.amountText = '1',
    this.result,
    this.history = const [],
    this.error,
  });

  
  ConverterState copyWith({
    bool? loading,
    String? base,
    String? target,
    String? amountText,
    double? result,
    List<HistoryPoint>? history,
    String? error,
  }) {
    return ConverterState(
      loading: loading ?? this.loading,
      base: base ?? this.base,
      target: target ?? this.target,
      amountText: amountText ?? this.amountText,
      result: result,            
      history: history ?? this.history,
      error: error,                 
    );
  }

  @override
  List<Object?> get props => [loading, base, target, amountText, result, history, error];
}
