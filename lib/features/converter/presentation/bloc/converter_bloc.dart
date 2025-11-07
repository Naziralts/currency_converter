import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../../converter/domain/usecases/get_history.dart';
import '../../../converter/domain/usecases/get_latest_rate.dart';
import 'converter_event.dart';
import 'converter_state.dart';


class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final GetLatestRate getLatestRate;
  final GetHistory getHistory;

  ConverterBloc({
    required this.getLatestRate,
    required this.getHistory,
  }) : super(const ConverterState()) {
    on<ConverterInit>(_onInit);
    on<ConverterBaseChanged>(_onBaseChanged);
    on<ConverterTargetChanged>(_onTargetChanged);
    on<ConverterAmountChanged>(_onAmountChanged);
    on<ConverterConvertPressed>(_onConvertPressed);
  }

  Future<void> _onInit(ConverterInit event, Emitter<ConverterState> emit) async {
    add(const ConverterConvertPressed());
  }

  void _onBaseChanged(ConverterBaseChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(base: event.base));

    add(const ConverterConvertPressed());
  }

  void _onTargetChanged(ConverterTargetChanged event, Emitter<ConverterState> emit) {
    emit(state.copyWith(target: event.target));
  
    add(const ConverterConvertPressed());
  }

  void _onAmountChanged(ConverterAmountChanged event, Emitter<ConverterState> emit) {

    final validatedText = _validateAmountInput(event.amountText);
    emit(state.copyWith(amountText: validatedText));
  }

  
  String _validateAmountInput(String input) {
    if (input.isEmpty) return '';
    
    var cleaned = input.replaceAll(RegExp(r'[^\d.,]'), '');
    

    cleaned = cleaned.replaceAll(',', '.');
    
   
    final dotIndex = cleaned.indexOf('.');
    if (dotIndex != -1) {
      final beforeDot = cleaned.substring(0, dotIndex);
      final afterDot = cleaned.substring(dotIndex + 1).replaceAll('.', '');
      cleaned = '$beforeDot.$afterDot';
    }

    if (cleaned.startsWith('0') && cleaned.length > 1 && !cleaned.startsWith('0.')) {
      cleaned = cleaned.substring(1);
    }
    
    return cleaned;
  }

  Future<void> _onConvertPressed(
      ConverterConvertPressed event, Emitter<ConverterState> emit) async {
    try {
      
      if (state.amountText.isEmpty) {
        emit(state.copyWith(
          loading: false,
          error: 'Введите сумму для конвертации',
          result: null,
        ));
        return;
      }

      final amount = double.tryParse(state.amountText);
      if (amount == null || amount <= 0) {
        emit(state.copyWith(
          loading: false,
          error: 'Введите корректную сумму (только цифры)',
          result: null,
        ));
        return;
      }

   
      emit(state.copyWith(loading: true, error: null));


      final rate = await getLatestRate(
        GetLatestRateParams(base: state.base, target: state.target),
      );

      final converted = amount * rate;

  
      final history = await getHistory(
        GetHistoryParams(base: state.base, target: state.target, days: 7),
      );


      emit(state.copyWith(
        loading: false,
        result: converted,
        history: history,
      ));
    } catch (e) {

      emit(state.copyWith(
        loading: false, 
        error: 'Ошибка конвертации: $e',
        result: null,
      ));
    }
  }
}